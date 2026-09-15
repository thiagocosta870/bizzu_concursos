import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bizzu_concursos/theme/appCores.dart';
import 'package:bizzu_concursos/controllers/perfil_controller.dart';
import 'package:bizzu_concursos/views/esqueci_senha_view.dart';
import 'package:bizzu_concursos/views/bem_vindo_view.dart';

class PerfilView extends StatefulWidget {
  const PerfilView({super.key});

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  final PerfilController _controller = PerfilController();

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? corDestaque,
  }) {
    final corBase = corDestaque ?? Colors.white;
    final corIcone = corDestaque ?? AppCores.amareloBizzu;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF101820),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12, width: 0.5),
      ),
      child: ListTile(
        leading: Icon(icon, color: corIcone),
        title: Text(title, style: TextStyle(color: corBase, fontSize: 16)),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: corBase.withOpacity(0.38),
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  void _mostrarAvisoEmBreve(String funcionalidade) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Em breve: $funcionalidade!',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppCores.amareloBizzu,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _exibirDialogoEditarDados() {
    final TextEditingController nomeController = TextEditingController(
      text: _controller.nomeExibicao,
    );
    bool salvando = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: const Color(0xFF101820),
            title: const Text(
              'Editar Dados',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomeController,
                  style: const TextStyle(color: Colors.white),
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Seu Nome',
                    labelStyle: TextStyle(color: Colors.white54),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppCores.amareloBizzu),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'O e-mail não pode ser alterado por aqui por questões de segurança.',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              if (!salvando)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              salvando
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        color: AppCores.amareloBizzu,
                      ),
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppCores.amareloBizzu,
                      ),
                      onPressed: () async {
                        setStateDialog(() => salvando = true);
                        final sucesso = await _controller.atualizarNome(
                          nomeController.text,
                        );
                        if (mounted) {
                          Navigator.pop(context);
                          if (sucesso) {
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Nome atualizado!',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: AppCores.amareloBizzu,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text(
                        'Salvar',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }

  void _exibirDialogoSuporte() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF101820),
        title: const Row(
          children: [
            Icon(Icons.headset_mic, color: AppCores.amareloBizzu),
            SizedBox(width: 8),
            Text('Suporte', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Precisa de ajuda com o app ou encontrou algum problema? Entre em contato conosco através do e-mail abaixo:',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 16),
            SelectableText(
              'suporte@bizzuconcursos.com.br',
              style: TextStyle(
                color: AppCores.amareloBizzu,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _exibirDialogoTextoLongo(String titulo, String texto) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF101820),
        title: Text(titulo, style: const TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Text(
              texto,
              style: const TextStyle(color: Colors.white70, height: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Entendi',
              style: TextStyle(
                color: AppCores.amareloBizzu,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _iniciarProcessoExclusao() async {
    final confirmacao1 = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF101820),
        title: const Text(
          'Apagar Conta?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Tem certeza que deseja apagar a sua conta? Você perderá o seu acesso ao aplicativo.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Sim, quero apagar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmacao1 != true || !mounted) return;

    final confirmacao2 = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF101820),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text(
              'Aviso Final',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'Esta ação é IRREVERSÍVEL. Todo o seu histórico de estudos, concursos e dados salvos serão permanentemente apagados.\n\nDeseja confirmar a exclusão?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'EXCLUIR DEFINITIVAMENTE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmacao2 != true || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.redAccent),
      ),
    );

    final erroExclusao = await _controller.excluirConta();

    if (!mounted) return;
    Navigator.pop(context);

    if (erroExclusao == null) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const BemVindoView()),
        (route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conta excluída com sucesso.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF101820),
          title: const Text(
            'Atenção',
            style: TextStyle(color: AppCores.amareloBizzu),
          ),
          content: Text(
            erroExclusao,
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Entendi',
                style: TextStyle(color: AppCores.amareloBizzu),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: AppCores.amareloBizzu.withOpacity(0.2),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppCores.amareloBizzu,
                    child: Text(
                      _controller.inicialAvatar,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _controller.nomeExibicao,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _controller.email,
                  style: const TextStyle(color: Colors.white54, fontSize: 16),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          const Text(
            'Gerenciamento da Conta',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            icon: Icons.person_outline,
            title: 'Editar Dados',
            onTap: _exibirDialogoEditarDados,
          ),
          _buildMenuItem(
            icon: Icons.lock_outline,
            title: 'Alterar Senha',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EsqueciSenhaView(
                    tituloPersonalizado: 'Redefinir Senha',
                  ),
                ),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.notifications_none,
            title: 'Notificações',
            onTap: () => _mostrarAvisoEmBreve('Configurar notificações'),
          ),

          const SizedBox(height: 32),

          const Text(
            'Suporte e Sobre',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            icon: Icons.headset_mic_outlined,
            title: 'Falar com o Suporte',
            onTap: _exibirDialogoSuporte,
          ),
          _buildMenuItem(
            icon: Icons.description_outlined,
            title: 'Termos de Uso',
            onTap: () => _exibirDialogoTextoLongo(
              'Termos de Uso',
              'Bem-vindo ao Bizzu Concursos!\n\n'
                  '1. O Aplicativo: O Bizzu Concursos é uma ferramenta de gestão de estudos e produtividade, criada para ajudar você a cronometrar seu tempo e organizar a sua evolução nos editais.\n\n'
                  '2. Uso da Conta: Você é inteiramente responsável por manter a segurança da sua conta e senha. Não compartilhe seu acesso com terceiros.\n\n'
                  '3. Disponibilidade: O aplicativo depende de conexão com a internet para salvar e sincronizar seus dados em nuvem de forma segura. Trabalhamos constantemente para manter tudo sempre online, mas podem ocorrer instabilidades temporárias ou manutenções.\n\n'
                  '4. Encerramento: Você é livre para parar de utilizar o aplicativo a qualquer momento e pode solicitar a exclusão de todos os seus dados.',
            ),
          ),
          _buildMenuItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Política de Privacidade',
            onTap: () => _exibirDialogoTextoLongo(
              'Política de Privacidade',
              'A sua privacidade é um pilar importante para o Bizzu Concursos.\n\n'
                  '1. Dados Coletados: Coletamos apenas as informações estritamente necessárias para o funcionamento do aplicativo: seu nome, e-mail e os dados da sua rotina de estudos (concursos, matérias, assuntos concluídos e tempo cronometrado).\n\n'
                  '2. Como Usamos: Seus dados são usados exclusivamente para gerar os seus gráficos de desempenho e organizar o seu progresso pessoal. Não vendemos, alugamos ou compartilhamos suas informações com terceiros.\n\n'
                  '3. Armazenamento Seguro: Seus dados são armazenados de forma criptografada e segura utilizando os servidores em nuvem do Firebase (tecnologia do Google).\n\n'
                  '4. Seus Direitos: A qualquer momento, você possui o direito de editar as suas informações de perfil ou excluir permanentemente a sua conta.',
            ),
          ),

          const SizedBox(height: 32),
          _buildMenuItem(
            icon: Icons.delete_forever,
            title: 'Apagar Minha Conta',
            corDestaque: Colors.redAccent,
            onTap: _iniciarProcessoExclusao,
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
