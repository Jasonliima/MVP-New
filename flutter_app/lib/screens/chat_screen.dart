import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../services/session.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _chatService = ChatService();
  final List<Map<String, String>> _messages = [];
  String _currentUserRole = Session.userRole ?? 'user';
  final String _currentUserId = Session.userId ?? 'usuario_anonimo';
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    final text = _messageController.text;
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _isLoading = true;
    });
    _messageController.clear();

    try {
      final reply = await _chatService.sendMessageToGemini(text);
      setState(() {
        _messages.add({'sender': 'gemini', 'text': reply});
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
        setState(() => _messages
            .removeLast()); // Remove a mensagem do usuário caso tenha dado erro de limite
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _changeLimitDialog() async {
    final limitController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configurações de Admin'),
        content: TextField(
          controller: limitController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
              labelText: 'Novo limite de mensagens para usuários'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final int? newLimit = int.tryParse(limitController.text);
              if (newLimit != null) {
                try {
                  await _chatService.updateLimit(newLimit);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Limite atualizado!'),
                        backgroundColor: Colors.green));
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('$e')));
                  }
                }
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F5F7), // Fundo suave para reduzir a fadiga visual
      appBar: AppBar(
        title: const Text('Assistente Gemini',
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFD9E2EC),
        foregroundColor: const Color(0xFF102A43),
        elevation: 0,
        actions: [
          // Removido o menu suspenso de testes: Agora validamos pela role verdadeira da conta conectada.
          if (_currentUserRole == 'admin')
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _changeLimitDialog,
            )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['sender'] == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width *
                          0.85, // Impede que o balão fique muito largo e force os olhos
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFFE2EEDA)
                          : Colors.white, // Contrastes amenizados
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD9E2EC)),
                    ),
                    child: Text(
                      message['text'] ?? '',
                      style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF102A43),
                          height:
                              1.4), // Altura de linha ajuda em casos de dislexia
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator()),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFD9E2EC))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Digite sua mensagem...',
                      filled: true,
                      fillColor: const Color(0xFFF4F5F7),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor:
                      const Color(0xFF243B53), // Dá destque na ação
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _isLoading ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
