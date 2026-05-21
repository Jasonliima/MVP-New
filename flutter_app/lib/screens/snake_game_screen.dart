import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SnakeGameScreen extends StatefulWidget {
  const SnakeGameScreen({super.key});

  @override
  State<SnakeGameScreen> createState() => _SnakeGameScreenState();
}

class _SnakeGameScreenState extends State<SnakeGameScreen> {
  // Grade 30x30 (blocos menores e mais espaço para jogar)
  final int squaresPerRow = 30;
  final int numberOfSquares = 900;

  List<int> snakePosition = [45, 75, 105];
  int fruitPosition = 150;
  String direction = 'down';
  int score = 0;
  bool gameHasStarted = false;
  Timer? timer;
  Color fruitColor = Colors.redAccent;

  final Random _random = Random();

  // Paleta de cores para a minhoca (Arco-íris)
  final List<Color> snakeColors = const [
    Color(0xFF00FF87),
    Color(0xFF60EFFF),
    Color(0xFFFF0080),
    Color(0xFFFF8C00),
    Color(0xFFFFD700),
    Color(0xFF8A2BE2),
  ];

  // Paleta de cores para as frutas
  final List<Color> fruitColors = const [
    Colors.redAccent,
    Colors.pinkAccent,
    Colors.orangeAccent,
    Colors.greenAccent,
    Colors.cyanAccent,
    Colors.yellowAccent
  ];

  void startGame() {
    gameHasStarted = true;
    snakePosition = [45, 75, 105];
    direction = 'down';
    score = 0;
    generateNewFruit();

    timer?.cancel();
    // Atualiza a posição a cada 100 milissegundos (muito mais rápido e fluido)
    timer = Timer.periodic(const Duration(milliseconds: 100), (Timer t) {
      updateSnake();
      if (gameOver()) {
        t.cancel();
        _showGameOverDialog();
      }
    });
  }

  void generateNewFruit() {
    fruitPosition = _random.nextInt(numberOfSquares);
    while (snakePosition.contains(fruitPosition)) {
      fruitPosition = _random.nextInt(numberOfSquares);
    }
    // Sorteia uma nova cor para a fruta
    fruitColor = fruitColors[_random.nextInt(fruitColors.length)];
  }

  void updateSnake() {
    setState(() {
      switch (direction) {
        case 'down':
          if (snakePosition.last + squaresPerRow >= numberOfSquares) {
            snakePosition
                .add(snakePosition.last + squaresPerRow - numberOfSquares);
          } else {
            snakePosition.add(snakePosition.last + squaresPerRow);
          }
          break;
        case 'up':
          if (snakePosition.last < squaresPerRow) {
            snakePosition
                .add(snakePosition.last - squaresPerRow + numberOfSquares);
          } else {
            snakePosition.add(snakePosition.last - squaresPerRow);
          }
          break;
        case 'left':
          if (snakePosition.last % squaresPerRow == 0) {
            snakePosition.add(snakePosition.last - 1 + squaresPerRow);
          } else {
            snakePosition.add(snakePosition.last - 1);
          }
          break;
        case 'right':
          if ((snakePosition.last + 1) % squaresPerRow == 0) {
            snakePosition.add(snakePosition.last + 1 - squaresPerRow);
          } else {
            snakePosition.add(snakePosition.last + 1);
          }
          break;
      }

      // Se a minhoca pegou a fruta
      if (snakePosition.last == fruitPosition) {
        score++;
        generateNewFruit();
      } else {
        // Se não pegou, remove o rabo para dar ilusão de movimento
        snakePosition.removeAt(0);
      }
    });
  }

  bool gameOver() {
    // Checa se a cabeça (último item) bateu no próprio corpo
    for (int i = 0; i < snakePosition.length - 1; i++) {
      if (snakePosition.last == snakePosition[i]) {
        return true;
      }
    }
    return false;
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Fim de Jogo! 🐍'),
          content: Text('Você conseguiu comer $score frutas!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  gameHasStarted = false;
                });
              },
              child: const Text('Jogar Novamente',
                  style: TextStyle(color: Color(0xFF1D9E75))),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D9E75),
        foregroundColor: Colors.white,
        title: Text('🍎 Pontos: $score'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              // Controles por gesto na tela
              onVerticalDragUpdate: (details) {
                if (direction != 'up' && details.delta.dy > 0)
                  direction = 'down';
                else if (direction != 'down' && details.delta.dy < 0)
                  direction = 'up';
              },
              onHorizontalDragUpdate: (details) {
                if (direction != 'left' && details.delta.dx > 0)
                  direction = 'right';
                else if (direction != 'right' && details.delta.dx < 0)
                  direction = 'left';
              },
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: numberOfSquares,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: squaresPerRow,
                ),
                itemBuilder: (BuildContext context, int index) {
                  if (snakePosition.contains(index)) {
                    // Corpo da minhoca
                    bool isHead = index == snakePosition.last;
                    int colorIndex = snakePosition.indexOf(index);

                    return Container(
                      margin: const EdgeInsets.all(0.5),
                      decoration: BoxDecoration(
                        color: isHead
                            ? Colors.white // Cabeça branca brilhante
                            : snakeColors[colorIndex %
                                snakeColors.length], // Corpo colorido
                        borderRadius: BorderRadius.circular(isHead ? 4 : 2),
                      ),
                    );
                  }
                  if (index == fruitPosition) {
                    // Fruta
                    return Container(
                      margin: const EdgeInsets.all(1.5),
                      decoration: BoxDecoration(
                        color: fruitColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: fruitColor.withOpacity(0.6),
                              blurRadius: 4,
                              spreadRadius: 1),
                        ],
                      ),
                    );
                  }
                  // Fundo vazio
                  return Container(
                    margin: const EdgeInsets.all(0.5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: gameHasStarted
                ? const SizedBox(
                    height: 50) // Mantém o espaço para a tela não pular
                : ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D9E75),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: startGame,
                    icon: const Icon(Icons.play_arrow_rounded, size: 28),
                    label: const Text(
                      'INICIAR JOGO',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
          )
        ],
      ),
    );
  }
}
