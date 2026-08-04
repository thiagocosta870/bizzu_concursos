import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bizzu_concursos/controllers/cadastro_concurso_controller.dart';
import 'package:bizzu_concursos/models/concurso_model.dart';
import 'package:bizzu_concursos/views/widgets/campo_texto_customizado.dart';
import 'package:bizzu_concursos/views/widgets/botao_customizado.dart';

class CadastrarConcursoView extends StatefulWidget {
  final ConcursoModel? concursoParaEditar;

  const CadastrarConcursoView({super.key, this.concursoParaEditar});

  @override
  State<CadastrarConcursoView> createState() => _CadastrarConcursoViewState();
}

class _CadastrarConcursoViewState extends State<CadastrarConcursoView> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _dataController = TextEditingController();
  final _cargoController = TextEditingController();
  final _materiasController = TextEditingController();

  final _controller = CadastroConcursoController();
  bool _estaCarregando = false;

  @override
  void initState() {
    super.initState();
    if (widget.concursoParaEditar != null) {
      _nomeController.text = widget.concursoParaEditar!.nome;
      _dataController.text = widget.concursoParaEditar!.dataProva;
      _cargoController.text = widget.concursoParaEditar!.cargo;
      _materiasController.text = widget.concursoParaEditar!.materias;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _dataController.dispose();
    _cargoController.dispose();
    _materiasController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData(BuildContext context) async {
    final dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color.fromARGB(255, 251, 239, 12),
              onPrimary: Colors.black,
              surface: Color(0xFF101820),
              onSurface: Colors.white,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: const Color(0xFF02080C),
            ),
          ),
          child: child!,
        );
      },
    );

    if (dataSelecionada != null) {
      setState(() {
        String dia = dataSelecionada.day.toString().padLeft(2, '0');
        String mes = dataSelecionada.month.toString().padLeft(2, '0');
        String ano = dataSelecionada.year.toString();
        _dataController.text = "$dia/$mes/$ano";
      });
    }
  }

  Future<void> _salvarDados() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _estaCarregando = true);
      final usuarioId = FirebaseAuth.instance.currentUser?.uid;

      if (usuarioId != null) {
        bool sucesso;

        if (widget.concursoParaEditar == null) {
          sucesso = await _controller.salvarNovoConcurso(
            nome: _nomeController.text.trim(),
            cargo: _cargoController.text.trim(),
            dataProva: _dataController.text.trim(),
            materias: _materiasController.text.trim(),
            usuarioId: usuarioId,
          );
        } else {
          sucesso = await _controller.atualizarConcurso(
            id: widget.concursoParaEditar!.id!,
            nome: _nomeController.text.trim(),
            cargo: _cargoController.text.trim(),
            dataProva: _dataController.text.trim(),
            materias: _materiasController.text.trim(),
            usuarioId: usuarioId,
          );
        }

        if (sucesso && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.concursoParaEditar == null
                    ? 'Concurso cadastrado com sucesso!'
                    : 'Concurso atualizado com sucesso!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao salvar. Tente novamente.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      setState(() => _estaCarregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditando = widget.concursoParaEditar != null;

    return Scaffold(
      backgroundColor: const Color(0xFF02080C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 90,
        centerTitle: true,
        title: Image.asset(
          'assets/images/logo_horizontal.png',
          height: 120,
          width: 160,
          fit: BoxFit.contain,
        ),
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 251, 239, 12),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditando ? 'Editar concurso' : 'Novo concurso',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              CampoTextoCustomizado(
                controller: _nomeController,
                hintText: 'Nome do concurso',
                icone: Icons.account_balance,
                textCapitalization: TextCapitalization.words,
                paddingBottom: 16.0,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Campo obrigatório'
                    : null,
              ),

              CampoTextoCustomizado(
                controller: _dataController,
                hintText: 'Data da prova',
                icone: Icons.calendar_month,
                readOnly: true,
                onTap: () => _selecionarData(context),
                paddingBottom: 16.0,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),

              CampoTextoCustomizado(
                controller: _cargoController,
                hintText: 'Cargo do concurso',
                icone: Icons.work_outline,
                textCapitalization: TextCapitalization.sentences,
                paddingBottom: 16.0,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Campo obrigatório'
                    : null,
              ),

              CampoTextoCustomizado(
                controller: _materiasController,
                hintText: 'Matérias do concurso',
                icone: Icons.menu_book,
                textCapitalization: TextCapitalization.sentences,
                paddingBottom: 24.0,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Campo obrigatório'
                    : null,
              ),

              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Funcionalidade de importação de edital em breve!',
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.file_upload_outlined,
                  color: Color.fromARGB(255, 251, 239, 12),
                ),
                label: const Text(
                  'Importar Edital',
                  style: TextStyle(
                    color: Color.fromARGB(255, 251, 239, 12),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(
                    color: Color.fromARGB(255, 251, 239, 12),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              _estaCarregando
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color.fromARGB(255, 251, 239, 12),
                        ),
                      ),
                    )
                  : BotaoCustomizado(
                      texto: isEditando ? 'Salvar Alterações' : 'Cadastrar',
                      onPressed: _salvarDados,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
