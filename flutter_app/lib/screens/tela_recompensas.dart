import 'package:flutter/material.dart';

class TarefaRecompensa {
  final String emoji;
  final String texto;

  const TarefaRecompensa({required this.emoji, required this.texto});
}

class RecompensaScreen extends StatefulWidget {
  final TarefaRecompensa tarefaAtual;
  final List<TarefaRecompensa> historico;
  final bool rotinaConcluida;
  final VoidCallback onContinuar;
  final String mensagemPersonalizada;

  const RecompensaScreen({
    super.key,
    required this.tarefaAtual,
    required this.historico,
    required this.rotinaConcluida,
    required this.onContinuar,
    this.mensagemPersonalizada = 'Você conseguiu! 🎉',
  });

  @override
  State<RecompensaScreen> createState() => _RecompensaScreenState();
}

class _RecompensaScreenState extends State<RecompensaScreen>
    with SingleTickerProviderStateMixin {

  // =========================================================
  // CORES
  // =========================================================

  static const Color _verde800 = Color(0xFF085041);
  static const Color _verde600 = Color(0xFF0F6E56);
  static const Color _verde400 = Color(0xFF1D9E75);
  static const Color _verde200 = Color(0xFF9FE1CB);
  static const Color _verde100 = Color(0xFFD6EEE5);
  static const Color _verde50  = Color(0xFFE1F5EE);
  static const Color _fundo    = Color(0xFFF0F7F4);
  static const Color _branco   = Color(0xFFFFFFFF);

  // =========================================================
  // ANIMAÇÕES
  // =========================================================

  late AnimationController _controller;
  late Animation<double> _fadeCheck;
  late Animation<double> _scaleCheck;
  late Animation<double> _fadeFrase;
  late Animation<double> _fadeHistorico;
  late Animation<double> _fadeBotao;

  late List<TarefaRecompensa> _listaCompleta;

  // =========================================================
  // CICLO DE VIDA
  // =========================================================

  @override
  void initState() {
    super.initState();

    _listaCompleta = [...widget.historico, widget.tarefaAtual];

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeCheck = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );

    _scaleCheck = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );

    _fadeFrase = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
    );

    _fadeHistorico = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
    );

    _fadeBotao = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fundo,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: widget.rotinaConcluida
                    ? _buildRotinaConcluida()
                    : _buildTarefaConcluida(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // WIDGETS AUXILIARES
  // =========================================================

  Widget _buildHeader() {
    return Container(
      color: _verde100,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Color(0xFFA8D8C5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star_outline, color: _verde600, size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            widget.rotinaConcluida ? 'Rotina completa!' : 'Recompensa',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _verde600,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: widget.onContinuar,
            icon: const Icon(Icons.close, color: _verde600),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildTarefaConcluida() {
    return Column(
      children: [
        const SizedBox(height: 32),
        FadeTransition(
          opacity: _fadeCheck,
          child: ScaleTransition(
            scale: _scaleCheck,
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: _verde400,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: _branco, size: 36),
            ),
          ),
        ),
        const SizedBox(height: 8),
        FadeTransition(
          opacity: _fadeCheck,
          child: const Text('⭐', style: TextStyle(fontSize: 28)),
        ),
        const SizedBox(height: 20),
        FadeTransition(
          opacity: _fadeFrase,
          child: Column(
            children: [
              // Mensagem personalizada do pai
              Text(
                widget.mensagemPersonalizada,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: _verde800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tarefa concluída com sucesso.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: _verde600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        FadeTransition(
          opacity: _fadeHistorico,
          child: _buildCardHistorico(
            titulo: 'Tarefas concluídas hoje',
            lista: _listaCompleta,
          ),
        ),
        const SizedBox(height: 24),
        FadeTransition(
          opacity: _fadeBotao,
          child: _buildBotaoContinuar(label: 'Continuar rotina'),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildRotinaConcluida() {
    return Column(
      children: [
        const SizedBox(height: 32),
        FadeTransition(
          opacity: _fadeCheck,
          child: ScaleTransition(
            scale: _scaleCheck,
            child: const Text('🏆', style: TextStyle(fontSize: 56)),
          ),
        ),
        const SizedBox(height: 16),
        FadeTransition(
          opacity: _fadeFrase,
          child: Column(
            children: [
              // Mensagem personalizada do pai na rotina completa
              Text(
                widget.mensagemPersonalizada,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: _verde800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Todas as tarefas foram concluídas.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: _verde600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        FadeTransition(
          opacity: _fadeHistorico,
          child: _buildCardHistorico(
            titulo: 'Resumo da rotina',
            lista: _listaCompleta,
          ),
        ),
        const SizedBox(height: 12),
        FadeTransition(
          opacity: _fadeHistorico,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: _verde50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total de tarefas',
                  style: TextStyle(fontSize: 13, color: _verde600),
                ),
                Text(
                  '${_listaCompleta.length}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: _verde800,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        FadeTransition(
          opacity: _fadeBotao,
          child: _buildBotaoContinuar(label: 'Encerrar rotina'),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildCardHistorico({
    required String titulo,
    required List<TarefaRecompensa> lista,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _branco,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _verde200, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _verde600,
            ),
          ),
          const SizedBox(height: 12),
          ...lista.map((t) => _buildItemHistorico(t)),
        ],
      ),
    );
  }

  Widget _buildItemHistorico(TarefaRecompensa tarefa) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _fundo,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(tarefa.emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tarefa.texto,
              style: const TextStyle(fontSize: 13, color: _verde800),
            ),
          ),
          const Icon(Icons.check_circle, color: _verde400, size: 18),
        ],
      ),
    );
  }

  Widget _buildBotaoContinuar({required String label}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.onContinuar,
        style: ElevatedButton.styleFrom(
          backgroundColor: _verde400,
          foregroundColor: _branco,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}