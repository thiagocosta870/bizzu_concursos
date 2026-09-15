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
        const promessasNotificacoes = [];

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
                const mensagem = {
                    token: fcmToken,
                    notification: {
                        title: "📚 Hora da Revisão!",
                        body: `Você tem ${quantidade} assunto(s) aguardando revisão hoje. Bora gabaritar?`,
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

               promessasNotificacoes.push(admin.messaging().send(mensagem));
            }
        }

        await Promise.all(promessasNotificacoes);
        console.log(`✅ Sucesso! Notificações enviadas para ${promessasNotificacoes.length} usuários.`);

    } catch (erro) {
        console.error("🔴 Erro ao enviar notificações diárias:", erro);
    }
});