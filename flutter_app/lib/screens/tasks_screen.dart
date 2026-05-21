import 'package:flutter/material.dart';
import '../services/task_service.dart';
import '../services/session.dart';
import 'snake_game_screen.dart';
import 'chess_game_screen.dart';
import 'puzzle_game_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TaskService _taskService = TaskService();
  List<dynamic> _tasks = [];
  bool _isLoading = true;
  final String _role = Session.userRole ?? 'user';

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    setState(() => _isLoading = true);
    try {
      final tasks = await _taskService.getTasks();
      setState(() => _tasks = tasks);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('Erro: ${e.toString().replaceAll("Exception: ", "")}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _completeTask(int id) async {
    try {
      await _taskService.completeTask(id);
      _fetchTasks(); // Recarrega a lista
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('Erro: ${e.toString().replaceAll("Exception: ", "")}')));
      }
    }
  }

  Future<void> _deleteTask(int id) async {
    try {
      await _taskService.deleteTask(id);
      _fetchTasks(); // Recarrega a lista
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('Erro: ${e.toString().replaceAll("Exception: ", "")}')));
      }
    }
  }

  Future<void> _showCreateTaskDialog() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final userController = TextEditingController(); // ID do usuário alvo

    await showDialog(
      context: context,
      builder: (context) {
        bool isSaving = false;
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Nova Recompensa'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration:
                        const InputDecoration(labelText: 'Nome da Recompensa'),
                  ),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                        labelText: 'Custo / Condição (opcional)'),
                  ),
                  TextField(
                    controller: userController,
                    decoration: const InputDecoration(
                        labelText: 'Para quem? (ID ou vazio = todos)'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        if (titleController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('O nome da recompensa é obrigatório!'),
                                backgroundColor: Colors.red),
                          );
                          return;
                        }

                        setStateDialog(() => isSaving = true);
                        try {
                          await _taskService.createTask(
                            titleController.text,
                            descController.text,
                            userController.text.trim().isEmpty
                                ? 'geral'
                                : userController.text.trim(),
                          );
                          if (mounted) {
                            Navigator.pop(context);
                            _fetchTasks();
                          }
                        } catch (e) {
                          setStateDialog(() => isSaving = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                    'Erro: ${e.toString().replaceAll("Exception: ", "")}')));
                          }
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Criar'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F4), // Fundo da tela de Recompensas
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF0F6E56), // Verde forte da tela Recompensas
        foregroundColor: Colors.white,
        title: const Text('Meus Jogos'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchTasks),
        ],
      ),
      body: Column(
        children: [
          // Banners dos Jogos Disponíveis
          SizedBox(
            height: 140, // Altura reservada para o carrossel horizontal
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16),
              children: [
                _buildGameBanner(
                  title: 'Jogo da Minhoca',
                  subtitle: 'Toque para jogar!',
                  icon: Icons.videogame_asset,
                  color: const Color(0xFF1D9E75),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SnakeGameScreen())),
                ),
                const SizedBox(width: 16),
                _buildGameBanner(
                  title: 'Xadrez Livre',
                  subtitle: 'Modo 2 Jogadores',
                  icon: Icons.grid_on_rounded, // Ícone atualizado
                  color: const Color(0xFF4A3424), // Cor de madeira
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ChessGameScreen())),
                ),
                const SizedBox(width: 16),
                _buildGameBanner(
                  title: 'Quebra-Cabeça',
                  subtitle: 'Para os pequenos',
                  icon: Icons.extension_rounded,
                  color: const Color(0xFFFF0080), // Rosa vibrante
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PuzzleGameScreen())),
                ),
              ],
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Jogos Resgatáveis / Salvos',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF0F6E56)),
              ),
            ),
          ),
          // Lista antiga que busca na API
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _tasks.isEmpty
                    ? const Center(child: Text('Nenhum jogo cadastrado.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _tasks.length,
                        itemBuilder: (context, index) {
                          final task = _tasks[index];
                          final isCompleted = task['status'] == 'completed';

                          return Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(
                                  color: Color(0xFF9FE1CB), width: 1),
                            ),
                            elevation: 2,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              title: Text(task['title'],
                                  style: TextStyle(
                                      decoration: isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                  '${task['description'] ?? ''}\nPara: ID ${task['assignedTo'] ?? "Geral"}'),
                              isThreeLine: true,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isCompleted)
                                    const Icon(Icons.check_circle,
                                        color: Color(0xFF1D9E75), size: 32)
                                  else
                                    IconButton(
                                      icon: const Icon(Icons.redeem_rounded,
                                          color: Color(0xFF1D9E75), size: 32),
                                      onPressed: () =>
                                          _completeTask(task['id']),
                                    ),
                                  if (_role == 'admin')
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Color(0xFFFF2222), size: 28),
                                      onPressed: () => _deleteTask(task['id']),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // Função construtora para reaproveitamento e facilidade para criar novos jogos
  Widget _buildGameBanner({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 280, // Largura fixa para manter o scroll horizontal consistente
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 48),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
          ],
        ),
      ),
    );
  }
}
