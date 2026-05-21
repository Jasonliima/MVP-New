import 'dart:math';
import 'package:flutter/material.dart';

class PuzzleGameScreen extends StatefulWidget {
  const PuzzleGameScreen({super.key});

  @override
  State<PuzzleGameScreen> createState() => _PuzzleGameScreenState();
}

class _PuzzleGameScreenState extends State<PuzzleGameScreen> {
  // O tabuleiro tem 9 posições. A posição '8' representa o espaço vazio.
  List<int> board = List.generate(9, (index) => index);

  // Emojis de animais divertidos para as crianças
  final List<String> emojis = [
    '🐶',
    '🐱',
    '🐭',
    '🐹',
    '🐰',
    '🦊',
    '🐻',
    '🐼',
    ''
  ];

  final List<Color> tileColors = [
    const Color(0xFFFF6B8A),
    const Color(0xFFFF9F45),
    const Color(0xFFFFD700),
    const Color(0xFF4CD964),
    const Color(0xFF40B0FF),
    const Color(0xFFAA66FF),
    const Color(0xFFFF66E0),
    const Color(0xFF00CC44),
    Colors.transparent
  ];

  @override
  void initState() {
    super.initState();
    _shuffleBoard();
  }

  // Embaralha o tabuleiro fazendo movimentos reais válidos para garantir que tem solução
  void _shuffleBoard() {
    final random = Random();
    int emptyIndex = 8;
    for (int i = 0; i < 100; i++) {
      List<int> validMoves = _getValidMoves(emptyIndex);
      int move = validMoves[random.nextInt(validMoves.length)];
      board[emptyIndex] = board[move];
      board[move] = 8;
      emptyIndex = move;
    }
    setState(() {});
  }

  List<int> _getValidMoves(int emptyIndex) {
    List<int> moves = [];
    int row = emptyIndex ~/ 3;
    int col = emptyIndex % 3;
    if (row > 0) moves.add(emptyIndex - 3); // Cima
    if (row < 2) moves.add(emptyIndex + 3); // Baixo
    if (col > 0) moves.add(emptyIndex - 1); // Esquerda
    if (col < 2) moves.add(emptyIndex + 1); // Direita
    return moves;
  }

  void _onTileTapped(int index) {
    int emptyIndex = board.indexOf(8);
    if (_getValidMoves(emptyIndex).contains(index)) {
      setState(() {
        board[emptyIndex] = board[index];
        board[index] = 8;
      });
      _checkWin();
    }
  }

  void _checkWin() {
    bool isWin = true;
    for (int i = 0; i < 8; i++) {
      if (board[i] != i) {
        isWin = false;
        break;
      }
    }
    if (isWin) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Parabéns! 🎉',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(0xFFFF0080),
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          content: const Text('Você montou o quebra-cabeça dos bichinhos!',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CD964),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(context);
                _shuffleBoard();
              },
              child: const Text('Jogar Novamente',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF0080), // Rosa vibrante
        foregroundColor: Colors.white,
        title: const Text('Quebra-Cabeça'),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _shuffleBoard,
              tooltip: 'Embaralhar'),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.pink.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10)),
                ],
              ),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  int tileValue = board[index];
                  if (tileValue == 8)
                    return const SizedBox.shrink(); // Espaço vazio

                  return GestureDetector(
                    onTap: () => _onTileTapped(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: tileColors[tileValue],
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: tileColors[tileValue].withOpacity(0.5),
                              blurRadius: 6,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: Center(
                          child: Text(emojis[tileValue],
                              style: const TextStyle(fontSize: 48))),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
