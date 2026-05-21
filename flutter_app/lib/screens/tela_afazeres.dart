import 'package:flutter/material.dart';
import 'tela_recompensas.dart';
import '../services/afazeres_service.dart';
import '../services/session.dart';

class TelaAfazeres extends StatefulWidget {
  final String tipoUsuario;

  const TelaAfazeres({super.key, required this.tipoUsuario});

  @override
  State<TelaAfazeres> createState() => _TelaAfazeresState();
}

class _TelaAfazeresState extends State<TelaAfazeres> {
  // =========================================================
  // VARIÁVEIS
  // =========================================================

  final AfazeresService _afazeresService = AfazeresService();
  List<Map<String, dynamic>> tarefas = [];
  bool carregando = true;
  int? indexExpandido;

  final TextEditingController _controladorTarefa = TextEditingController();
  final TextEditingController _controladorPasso = TextEditingController();
  final TextEditingController _controladorMensagem = TextEditingController();
  final TextEditingController _controladorTempo = TextEditingController();

  final List<Color> _coresArcoIris = const [
    Color(0xFFFF6B8A), // rosa vibrante
    Color(0xFFFF9F45), // laranja vibrante
    Color(0xFFFFD700), // amarelo vibrante
    Color(0xFF4CD964), // verde vibrante
    Color(0xFF40B0FF), // azul vibrante
    Color(0xFFAA66FF), // lilás vibrante
    Color(0xFFFF66E0), // roxo vibrante
  ];

  // =========================================================
  // CICLO DE VIDA
  // =========================================================

  @override
  void initState() {
    super.initState();
    _carregarTarefas();
  }

  @override
  void dispose() {
    _controladorTarefa.dispose();
    _controladorPasso.dispose();
    _controladorMensagem.dispose();
    _controladorTempo.dispose();
    super.dispose();
  }

  // =========================================================
  // FUNÇÕES DE TAREFA
  // =========================================================

  Future<void> _carregarTarefas() async {
    setState(() => carregando = true);
    try {
      final dados = await _afazeresService.getAfazeres();
      if (mounted) {
        setState(() {
          tarefas = List<Map<String, dynamic>>.from(dados);
          carregando = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => carregando = false);
      debugPrint('Erro ao carregar afazeres: $e');
    }
  }

  void _toggleTarefa(int index) {
    setState(() {
      indexExpandido = indexExpandido == index ? null : index;
    });
  }

  Color _corDaTarefa(int index, bool concluida) {
    if (concluida) return const Color(0xFF4CD964);
    return _coresArcoIris[index % _coresArcoIris.length];
  }

  // Abre a tela de recompensa passando a mensagem personalizada
  void _abrirRecompensa(int indexTarefa) {
    final tarefa = tarefas[indexTarefa];

    final bool rotinaConcluida =
        tarefas.isNotEmpty && tarefas.every((t) => t['concluida'] == true);

    final List<TarefaRecompensa> historico = tarefas
        .where((t) => t['concluida'] == true && t['id'] != tarefa['id'])
        .map((t) => TarefaRecompensa(
              emoji: '⭐',
              texto: t['titulo'],
            ))
        .toList();

    final String mensagem = tarefa['mensagem'] ?? 'Você conseguiu! 🎉';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecompensaScreen(
          tarefaAtual: TarefaRecompensa(
            emoji: '✅',
            texto: tarefa['titulo'],
          ),
          historico: historico,
          rotinaConcluida: rotinaConcluida,
          mensagemPersonalizada: mensagem,
          onContinuar: () => Navigator.pop(context),
        ),
      ),
    );
  }

  // Futuro: DELETE /tarefas/:id
  void _excluirTarefa(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Excluir tarefa'),
        content: Text(
          'Deseja excluir "${tarefas[index]['titulo']}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              try {
                final id = tarefas[index]['id'];
                await _afazeresService.deleteAfazer(id);
                setState(() {
                  // Fecha o painel se a tarefa excluída estava expandida
                  if (indexExpandido == index) {
                    indexExpandido = null;
                  } else if (indexExpandido != null &&
                      indexExpandido! > index) {
                    indexExpandido = indexExpandido! - 1;
                  }
                  tarefas.removeAt(index);
                });
                if (mounted) Navigator.pop(context);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        'Erro: ${e.toString().replaceAll("Exception: ", "")}'),
                    backgroundColor: Colors.red,
                  ));
                }
              }
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  // Futuro: POST /tarefas
  void _adicionarTarefa() {
    showDialog(
      context: context,
      builder: (context) {
        bool salvando = false;
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(
              'Nova Tarefa',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _controladorTarefa,
                    decoration: InputDecoration(
                      hintText: 'Digite o nome da tarefa...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFFF0080),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _controladorMensagem,
                    decoration: InputDecoration(
                      hintText: 'Mensagem de recompensa... (opcional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFFF0080),
                          width: 2,
                        ),
                      ),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _controladorTempo,
                    decoration: InputDecoration(
                      hintText: 'Tempo estipulado (ex: 30 min)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFFF0080),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: salvando
                    ? null
                    : () {
                        _controladorTarefa.clear();
                        _controladorMensagem.clear();
                        _controladorTempo.clear();
                        Navigator.pop(context);
                      },
                child: const Text('Cancelar',
                    style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF2222),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: salvando
                    ? null
                    : () async {
                        if (_controladorTarefa.text.trim().isEmpty) return;

                        setStateDialog(() => salvando = true);
                        try {
                          final novaTarefa =
                              await _afazeresService.createAfazer(
                            _controladorTarefa.text.trim(),
                            _controladorMensagem.text.trim(),
                            widget.tipoUsuario == 'pai'
                                ? 'geral'
                                : (Session.userId ?? ''),
                            _controladorTempo.text.trim(),
                          );

                          setState(() {
                            tarefas.add(novaTarefa);
                          });

                          _controladorTarefa.clear();
                          _controladorMensagem.clear();
                          _controladorTempo.clear();
                          if (mounted) Navigator.pop(context);
                        } catch (e) {
                          setStateDialog(() => salvando = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Erro: ${e.toString().replaceAll("Exception: ", "")}'),
                              backgroundColor: Colors.red,
                            ));
                          }
                        }
                      },
                child: salvando
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Salvar'),
              ),
            ],
          );
        });
      },
    );
  }

  // =========================================================
  // FUNÇÕES DE PASSO
  // =========================================================

  // Futuro: POST /passos
  void _adicionarPasso(int indexTarefa) {
    showDialog(
      context: context,
      builder: (context) {
        bool salvando = false;
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(
              'Novo Passo',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: TextField(
              controller: _controladorPasso,
              decoration: InputDecoration(
                hintText: 'Descreva o passo...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFFF0080),
                    width: 2,
                  ),
                ),
              ),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: salvando
                    ? null
                    : () {
                        _controladorPasso.clear();
                        Navigator.pop(context);
                      },
                child: const Text('Cancelar',
                    style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF2222),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: salvando
                    ? null
                    : () async {
                        if (_controladorPasso.text.trim().isEmpty) return;

                        setStateDialog(() => salvando = true);
                        try {
                          final afazerId = tarefas[indexTarefa]['id'];
                          final novoPasso = await _afazeresService.createPasso(
                            afazerId,
                            _controladorPasso.text.trim(),
                          );

                          setState(() {
                            tarefas[indexTarefa]['passos'].add(novoPasso);
                          });

                          _controladorPasso.clear();
                          if (mounted) Navigator.pop(context);
                        } catch (e) {
                          setStateDialog(() => salvando = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Erro: ${e.toString().replaceAll("Exception: ", "")}'),
                              backgroundColor: Colors.red,
                            ));
                          }
                        }
                      },
                child: salvando
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Salvar'),
              ),
            ],
          );
        });
      },
    );
  }

  // Futuro: DELETE /passos/:id
  void _excluirPasso(int indexTarefa, int indexPasso) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Excluir passo'),
        content: Text(
          'Deseja excluir "${tarefas[indexTarefa]['passos'][indexPasso]['descricao']}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              try {
                final afazerId = tarefas[indexTarefa]['id'];
                final passoId =
                    tarefas[indexTarefa]['passos'][indexPasso]['id'];

                await _afazeresService.deletePasso(afazerId, passoId);

                setState(() {
                  tarefas[indexTarefa]['passos'].removeAt(indexPasso);
                });
                if (mounted) Navigator.pop(context);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        'Erro: ${e.toString().replaceAll("Exception: ", "")}'),
                    backgroundColor: Colors.red,
                  ));
                }
              }
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // WIDGETS AUXILIARES
  // =========================================================

  Widget _numeroPasso(int index, bool concluido) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: concluido ? const Color(0xFF4CD964) : const Color(0xFFAA66FF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                (concluido ? const Color(0xFF4CD964) : const Color(0xFFAA66FF))
                    .withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _painelPassos(int indexTarefa) {
    final bool ehPai = widget.tipoUsuario == 'pai';
    final List passos = tarefas[indexTarefa]['passos'];
    final Color corBase = _corDaTarefa(indexTarefa, false);

    return AnimatedSize(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      child: Container(
        decoration: BoxDecoration(
          color: corBase.withOpacity(0.25),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.list_alt_rounded,
                          size: 20, color: Color(0xFF8800FF)),
                      SizedBox(width: 6),
                      Text(
                        'Passo a passo',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8800FF),
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                  if (ehPai)
                    TextButton.icon(
                      onPressed: () => _adicionarPasso(indexTarefa),
                      icon: const Icon(
                        Icons.add_circle,
                        size: 20,
                        color: Color(0xFFFF0080),
                      ),
                      label: const Text(
                        'Adicionar passo',
                        style: TextStyle(
                          color: Color(0xFFFF0080),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            passos.isEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    child: Text(
                      ehPai
                          ? '✨ Nenhum passo ainda. Clique em adicionar!'
                          : '✨ Nenhum passo cadastrado ainda.',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    itemCount: passos.length,
                    itemBuilder: (context, indexPasso) {
                      final passo = passos[indexPasso];
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: passo['concluido']
                              ? const Color(0xFFDFF5E0)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              _numeroPasso(indexPasso, passo['concluido']),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  passo['descricao'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    decoration: passo['concluido']
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    color: passo['concluido']
                                        ? Colors.grey
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                              if (!ehPai)
                                Checkbox(
                                  value: passo['concluido'],
                                  activeColor: const Color(0xFF4CD964),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  onChanged: (bool? valor) async {
                                    try {
                                      final afazerId =
                                          tarefas[indexTarefa]['id'];
                                      final passoId = passo['id'];
                                      await _afazeresService.togglePasso(
                                          afazerId, passoId, valor!);

                                      setState(() {
                                        tarefas[indexTarefa]['passos']
                                            [indexPasso]['concluido'] = valor!;
                                      });
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(
                                              'Erro: ${e.toString().replaceAll("Exception: ", "")}'),
                                          backgroundColor: Colors.red,
                                        ));
                                      }
                                    }
                                  },
                                ),
                              if (ehPai)
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      _excluirPasso(indexTarefa, indexPasso),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _cardTarefa(int index, bool ehDesktop, bool ehTablet) {
    final tarefa = tarefas[index];
    final bool ehPai = widget.tipoUsuario == 'pai';
    final bool expandido = indexExpandido == index;
    final Color cor = _corDaTarefa(index, tarefa['concluida']);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cor.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _toggleTarefa(index),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ehDesktop ? 20 : 16,
                vertical: ehDesktop ? 18 : 14,
              ),
              child: Row(
                children: [
                  if (!ehPai)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Checkbox(
                        value: tarefa['concluida'],
                        activeColor: const Color(0xFF4CD964),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        onChanged: (bool? valor) async {
                          try {
                            final id = tarefas[index]['id'];
                            await _afazeresService.toggleAfazer(id, valor!);

                            setState(() {
                              tarefas[index]['concluida'] = valor!;
                            });
                            if (valor == true) {
                              _abrirRecompensa(index);
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                    'Erro: ${e.toString().replaceAll("Exception: ", "")}'),
                                backgroundColor: Colors.red,
                              ));
                            }
                          }
                        },
                      ),
                    ),
                  if (tarefa['concluida'])
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.star_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tarefa['titulo'],
                          style: TextStyle(
                            fontSize: ehDesktop
                                ? 17
                                : ehTablet
                                    ? 16
                                    : 15,
                            fontWeight: FontWeight.w600,
                            decoration: tarefa['concluida']
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: tarefa['concluida']
                                ? Colors.white70
                                : Colors.white,
                          ),
                        ),
                        // Mostrando o Tempo abaixo do título caso tenha sido estipulado pelo pai
                        if (tarefa['tempo'] != null &&
                            tarefa['tempo'].toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              children: [
                                const Icon(Icons.timer_outlined,
                                    size: 14, color: Colors.white70),
                                const SizedBox(width: 4),
                                Text(
                                  'Tempo: ${tarefa['tempo']}',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Botão excluir tarefa apenas para o pai
                  if (ehPai)
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: () => _excluirTarefa(index),
                    ),
                  AnimatedRotation(
                    turns: expandido ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (expandido) _painelPassos(index),
        ],
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final bool ehPai = widget.tipoUsuario == 'pai';
    final double largura = MediaQuery.of(context).size.width;
    final bool ehTablet = largura >= 600 && largura < 900;
    final bool ehDesktop = largura >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8FF),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFF0080),
                Color(0xFFFF6600),
                Color(0xFFFFCC00),
                Color(0xFF00CC44),
                Color(0xFF0088FF),
                Color(0xFF8800FF),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Meus Afazeres 🌈',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 26,
            letterSpacing: 1.5,
            shadows: [
              Shadow(
                color: Colors.black38,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: ehPai
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFFFF2222),
              onPressed: _adicionarTarefa,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text(
                'Nova Tarefa',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            )
          : null,
      body: carregando
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF0080)),
            )
          : Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: ehDesktop
                      ? 1000
                      : ehTablet
                          ? 720
                          : double.infinity,
                ),
                child: SizedBox.expand(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.all(
                            ehDesktop
                                ? 28
                                : ehTablet
                                    ? 20
                                    : 14,
                          ),
                          itemCount: tarefas.length,
                          itemBuilder: (context, index) =>
                              _cardTarefa(index, ehDesktop, ehTablet),
                        ),
                      ),
                      if ((ehDesktop || ehTablet) && indexExpandido != null)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              0,
                              ehDesktop ? 28 : 20,
                              ehDesktop ? 28 : 20,
                              ehDesktop ? 28 : 20,
                            ),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: _painelPassos(indexExpandido!),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
