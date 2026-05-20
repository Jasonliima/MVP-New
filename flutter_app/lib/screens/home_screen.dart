import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'login_screen.dart';
import '../services/session.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página Inicial',
            style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagem de quebra-cabeça colorido e acolhedor
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/puzzle.png', // Caminho onde sua imagem real vai ficar
                  height: 160,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback com ícones coloridos caso a imagem 'assets/puzzle.png' ainda não exista
                    return Container(
                      height: 160,
                      alignment: Alignment.center,
                      child: const Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 4,
                        children: [
                          Icon(Icons.extension,
                              size: 60, color: Colors.redAccent),
                          Icon(Icons.extension,
                              size: 60, color: Colors.blueAccent),
                          Icon(Icons.extension, size: 60, color: Colors.green),
                          Icon(Icons.extension,
                              size: 60, color: Colors.orangeAccent),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Olá, ${Session.userName ?? 'Usuário'}!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF102A43),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'O que você gostaria de fazer hoje?',
              style: TextStyle(fontSize: 18, color: Color(0xFF334E68)),
            ),
            const SizedBox(height: 32),

            // Cartão de ação grande e com bastante contraste para facilitar o uso
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(24),
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF102A43),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 2,
              ),
              child: const Row(
                children: [
                  Icon(Icons.auto_awesome, size: 40, color: Color(0xFF243B53)),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Falar com Assistente Gemini',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Color(0xFFD9E2EC)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
