const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

exports.notificarRevisoesDiarias = onSchedule({
    schedule: "0 5 * * *",
    timeZone: "America/Sao_Paulo"
}, async (event) => {
    try {
        console.log("Iniciando a varredura diária de revisões...");

        const usuariosSnapshot = await db.collection("usuarios").get();
        
        const promessasGlobais = []; 

        const hoje = new Date();
        const fimDoDia = new Date(hoje.getFullYear(), hoje.getMonth(), hoje.getDate(), 23, 59, 59).getTime();

        for (const usuarioDoc of usuariosSnapshot.docs) {
            const usuarioDados = usuarioDoc.data();
            const fcmToken = usuarioDados.fcmToken;

            if (!fcmToken) continue;

            const revisoesSnapshot = await db.collection("usuarios")
                .doc(usuarioDoc.id)
                .collection("revisoes")
                .where("concluido", "==", false)
                .where("dataAgendada", "<=", fimDoDia)
                .get();

            const quantidade = revisoesSnapshot.size;

            if (quantidade > 0) {
                const tituloAviso = "📚 Hora da Revisão!";
                const corpoAviso = `Você tem ${quantidade} assunto(s) aguardando revisão hoje. Bora gabaritar?`;

                const mensagem = {
                    token: fcmToken,
                    notification: {
                        title: tituloAviso,
                        body: corpoAviso,
                    },
                    android: {
                        priority: "high",
                        notification: {
                            sound: "default",
                            channelId: "high_importance_channel",
                            icon: "ic_notification"
                        }
                    }
                };

                promessasGlobais.push(admin.messaging().send(mensagem));


                const salvarNoBanco = db.collection("usuarios")
                    .doc(usuarioDoc.id)
                    .collection("notificacoes")
                    .add({
                        titulo: tituloAviso,
                        mensagem: corpoAviso,
                        lida: false,
                        timestamp: admin.firestore.FieldValue.serverTimestamp()
                    });

                promessasGlobais.push(salvarNoBanco);
            }
        }

        await Promise.all(promessasGlobais);
        console.log(`✅ Sucesso! Varredura concluída. ${promessasGlobais.length / 2} usuários notificados.`);

    } catch (erro) {
        console.error("🔴 Erro ao enviar notificações diárias:", erro);
    }
});