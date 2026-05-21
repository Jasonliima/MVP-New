import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'session.dart';

class TaskService {
  // Reutiliza a URL base do AuthService para manter consistência e passar no Firewall
  final String baseUrl = AuthService().baseUrl;

  Future<List<dynamic>> getTasks() async {
    final response = await http.get(
      Uri.parse('$baseUrl/tasks'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Session.token ?? ""}'
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao carregar tarefas');
    }
  }

  Future<void> createTask(
      String title, String description, String assignedTo) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Session.token ?? ""}'
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'assignedTo': assignedTo,
      }),
    );

    if (response.statusCode != 201) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Falha ao criar tarefa');
    }
  }

  Future<void> completeTask(int id) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tasks/$id/complete'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Session.token ?? ""}'
      },
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Falha ao concluir tarefa');
    }
  }

  Future<void> deleteTask(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/tasks/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Session.token ?? ""}'
      },
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Falha ao excluir tarefa');
    }
  }
}
