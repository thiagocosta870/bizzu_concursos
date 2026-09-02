import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bizzu_concursos/controllers/cadastro_concurso_controller.dart';
import 'package:bizzu_concursos/models/concurso_model.dart';
import 'package:bizzu_concursos/views/widgets/campo_texto_customizado.dart';
import 'package:bizzu_concursos/views/widgets/botao_customizado.dart';
import 'package:bizzu_concursos/theme/appCores.dart';

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

  final List<String> _todasAsMaterias = [
    'Língua Portuguesa',
    'Matemática',
    'Raciocínio Lógico',
    'Informática',
    'Direito Administrativo',
    'Direito Constitucional',
    'Direito Penal',
    'Direitos Humanos',
    'Atualidades',
    'Redação',
  ];
  List<String> _materiasSelecionadas = [];

  final _controller = CadastroConcursoController();
  bool _estaCarregando = false;

  @override
  void initState() {
    super.initState();
    if (widget.concursoParaEditar != null) {
      _nomeController.text = widget.concursoParaEditar!.nome;
      _dataController.text = widget.concursoParaEditar!.dataProva;
      _cargoController.text = widget.concursoParaEditar!.cargo;

      if (widget.concursoParaEditar!.materias.isNotEmpty) {
        _materiasSelecionadas = widget.concursoParaEditar!.materias
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _dataController.dispose();
    _cargoController.dispose();
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
              primary: AppCores.amareloBizzu,
              onPrimary: Colors.black,
              surface: Color(0xFF101820),
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF02080C),
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

  void _abrirSelecaoDeMaterias() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF101820),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Selecione as Matérias',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _todasAsMaterias.length,
                      itemBuilder: (context, index) {
                        final materia = _todasAsMaterias[index];
                        final isSelected = _materiasSelecionadas.contains(
                          materia,
                        );

                        return CheckboxListTile(
                          title: Text(
                            materia,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          value: isSelected,
                          activeColor: AppCores.amareloBizzu,
                          checkColor: Colors.black,
                          side: const BorderSide(color: Colors.grey),
                          onChanged: (bool? value) {
                            setModalState(() {
                              if (value == true) {
                                _materiasSelecionadas.add(materia);
                              } else {
                                _materiasSelecionadas.remove(materia);
                              }
                            });
                            setState(() {});
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppCores.amareloBizzu,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Confirmar',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _salvarDados() async {
    if (_materiasSelecionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione pelo menos uma matéria.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _estaCarregando = true);
      final usuarioId = FirebaseAuth.instance.currentUser?.uid;

      if (usuarioId != null) {
        bool sucesso;

        String materiasFormatadas = _materiasSelecionadas.join(', ');

        if (widget.concursoParaEditar == null) {
          sucesso = await _controller.salvarNovoConcurso(
            nome: _nomeController.text.trim(),
            cargo: _cargoController.text.trim(),
            dataProva: _dataController.text.trim(),
            materias: materiasFormatadas,
            usuarioId: usuarioId,
          );
        } else {
          sucesso = await _controller.atualizarConcurso(
            id: widget.concursoParaEditar!.id!,
            nome: _nomeController.text.trim(),
            cargo: _cargoController.text.trim(),
            dataProva: _dataController.text.trim(),
            materias: materiasFormatadas,
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
        iconTheme: const IconThemeData(color: AppCores.amareloBizzu),
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

              GestureDetector(
                onTap: _abrirSelecaoDeMaterias,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  margin: const EdgeInsets.only(bottom: 24.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101820),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _materiasSelecionadas.isNotEmpty
                          ? AppCores.amareloBizzu
                          : Colors.white12,
                      width: _materiasSelecionadas.isNotEmpty ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.menu_book, color: Color(0xFF415A77)),
                          const SizedBox(width: 12),
                          Text(
                            _materiasSelecionadas.isEmpty
                                ? 'Selecione as matérias'
                                : 'Matérias do concurso',
                            style: TextStyle(
                              color: _materiasSelecionadas.isEmpty
                                  ? Colors.grey
                                  : AppCores.amareloBizzu,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      if (_materiasSelecionadas.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _materiasSelecionadas.map((materia) {
                            return Chip(
                              label: Text(
                                materia,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              backgroundColor: AppCores.amareloBizzu,
                              deleteIconColor: Colors.black,
                              onDeleted: () {
                                setState(() {
                                  _materiasSelecionadas.remove(materia);
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
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
                  color: AppCores.amareloBizzu,
                ),
                label: const Text(
                  'Importar Edital',
                  style: TextStyle(
                    color: AppCores.amareloBizzu,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(
                    color: AppCores.amareloBizzu,
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
                      child: CircularProgressIndicator.adaptive(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppCores.amareloBizzu,
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
