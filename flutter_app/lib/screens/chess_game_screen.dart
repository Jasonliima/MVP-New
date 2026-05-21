import 'package:flutter/material.dart';

class ChessGameScreen extends StatefulWidget {
  const ChessGameScreen({super.key});

  @override
  State<ChessGameScreen> createState() => _ChessGameScreenState();
}

class _ChessGameScreenState extends State<ChessGameScreen> {
  // Tabuleiro 8x8. Maiúsculas = Brancas, Minúsculas = Pretas
  List<List<String>> board = [
    ['r', 'n', 'b', 'q', 'k', 'b', 'n', 'r'],
    ['p', 'p', 'p', 'p', 'p', 'p', 'p', 'p'],
    ['', '', '', '', '', '', '', ''],
    ['', '', '', '', '', '', '', ''],
    ['', '', '', '', '', '', '', ''],
    ['', '', '', '', '', '', '', ''],
    ['P', 'P', 'P', 'P', 'P', 'P', 'P', 'P'],
    ['R', 'N', 'B', 'Q', 'K', 'B', 'N', 'R'],
  ];

  int? selectedRow;
  int? selectedCol;
  bool whiteTurn = true;

  // Usamos os ícones preenchidos e controlamos a cor dinamicamente para melhor visibilidade
  final Map<String, String> pieceSymbols = {
    'r': '♜',
    'n': '♞',
    'b': '♝',
    'q': '♛',
    'k': '♚',
    'p': '♟',
    'R': '♜',
    'N': '♞',
    'B': '♝',
    'Q': '♛',
    'K': '♚',
    'P': '♟',
  };

  void _onSquareTapped(int row, int col) {
    setState(() {
      if (selectedRow == null && selectedCol == null) {
        // Selecionar uma peça
        if (board[row][col].isNotEmpty) {
          selectedRow = row;
          selectedCol = col;
        }
      } else {
        // Mover ou Deselecionar
        if (selectedRow == row && selectedCol == col) {
          selectedRow = null;
          selectedCol = null;
        } else {
          // Move a peça para o novo local (Sandbox: Sem validação de regras automáticas)
          board[row][col] = board[selectedRow!][selectedCol!];
          board[selectedRow!][selectedCol!] = '';
          selectedRow = null;
          selectedCol = null;
          whiteTurn = !whiteTurn; // Troca o turno
        }
      }
    });
  }

  void _resetBoard() {
    setState(() {
      board = [
        ['r', 'n', 'b', 'q', 'k', 'b', 'n', 'r'],
        ['p', 'p', 'p', 'p', 'p', 'p', 'p', 'p'],
        ['', '', '', '', '', '', '', ''],
        ['', '', '', '', '', '', '', ''],
        ['', '', '', '', '', '', '', ''],
        ['', '', '', '', '', '', '', ''],
        ['P', 'P', 'P', 'P', 'P', 'P', 'P', 'P'],
        ['R', 'N', 'B', 'Q', 'K', 'B', 'N', 'R'],
      ];
      selectedRow = null;
      selectedCol = null;
      whiteTurn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8DDCB), // Fundo bege elegante
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A3424), // Marrom escuro da madeira
        foregroundColor: Colors.white,
        title: const Text('Xadrez Livre'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetBoard,
            tooltip: 'Reiniciar Partida',
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              whiteTurn ? 'Vez das Brancas' : 'Vez das Pretas',
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A3424)),
            ),
          ),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFF4A3424),
                        width: 6), // Borda do tabuleiro de madeira
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 8))
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                        10), // Arredonda o Grid interno para não vazar pela borda
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 8),
                      itemCount: 64,
                      itemBuilder: (context, index) {
                        int row = index ~/ 8;
                        int col = index % 8;
                        bool isLightSquare = (row + col) % 2 == 0;
                        bool isSelected =
                            row == selectedRow && col == selectedCol;
                        String piece = board[row][col];
                        bool isWhitePiece =
                            piece == piece.toUpperCase() && piece.isNotEmpty;

                        return GestureDetector(
                          onTap: () => _onSquareTapped(row, col),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            color: isSelected
                                ? const Color(0xFFF6EB71)
                                    .withOpacity(0.8) // Amarelo de seleção
                                : isLightSquare
                                    ? const Color(0xFFF0D9B5) // Madeira clara
                                    : const Color(0xFFB58863), // Madeira escura
                            child: Center(
                              child: piece.isNotEmpty
                                  ? LayoutBuilder(
                                      builder: (context, constraints) => Text(
                                        pieceSymbols[piece]!,
                                        style: TextStyle(
                                          fontSize: constraints.maxWidth * 0.70,
                                          color: isWhitePiece
                                              ? Colors.white
                                              : Colors.black87,
                                          shadows: [
                                            Shadow(
                                                color: isWhitePiece
                                                    ? Colors.black54
                                                    : Colors.white54,
                                                blurRadius: 3)
                                          ],
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Modo Sandbox: Movimente as peças livremente.\nRegras e capturas ficam por conta dos jogadores!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          )
        ],
      ),
    );
  }
}
