import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'session.dart';

class AfazeresService {
  final String baseUrl = AuthService().baseUrl;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Session.token}',
      };

  // Buscar afazeres (rotinas)
  Future<List<dynamic>> getAfazeres() async {
    final response =
        await http.get(Uri.parse('$baseUrl/afazeres'), headers: _headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Falha ao carregar afazeres');
  }

  // Criar rotina
  Future<Map<String, dynamic>> createAfazer(
      String titulo, String mensagem, String assignedTo, String tempo) async {
    final response = await http.post(
      Uri.parse('$baseUrl/afazeres'),
      headers: _headers,
      body: jsonEncode({
        'titulo': titulo,
        'mensagem': mensagem,
        'assignedTo': assignedTo,
        'tempo': tempo,
      }),
    );
    if (response.statusCode == 201) return jsonDecode(response.body);

    try {
      final erroBody = jsonDecode(response.body);
      throw Exception(erroBody['error'] ?? 'Falha ao criar afazer');
    } catch (_) {
      throw Exception('Falha ao criar afazer (HTTP ${response.statusCode})');
    }
  }

  // Excluir rotina
  Future<void> deleteAfazer(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/afazeres/$id'),
        headers: _headers);
    if (response.statusCode != 200) throw Exception('Falha ao deletar afazer');
  }

  // Concluir rotina
  Future<void> toggleAfazer(int id, bool concluida) async {
    final response = await http.put(
      Uri.parse('$baseUrl/afazeres/$id/concluir'),
      headers: _headers,
      body: jsonEncode({'concluida': concluida}),
    );
    if (response.statusCode != 200)
      throw Exception('Falha ao atualizar afazer');
  }

  // Criar passo
  Future<Map<String, dynamic>> createPasso(
      int afazerId, String descricao) async {
    final response = await http.post(
      Uri.parse('$baseUrl/afazeres/$afazerId/passos'),
      headers: _headers,
      body: jsonEncode({'descricao': descricao}),
    );
    if (response.statusCode == 201) return jsonDecode(response.body);
    throw Exception('Falha ao criar passo');
  }

  // Concluir passo
  Future<void> togglePasso(int afazerId, int passoId, bool concluido) async {
    final response = await http.put(
      Uri.parse('$baseUrl/afazeres/$afazerId/passos/$passoId/concluir'),
      headers: _headers,
      body: jsonEncode({'concluido': concluido}),
    );
    if (response.statusCode != 200) throw Exception('Falha ao atualizar passo');
  }

  // Excluir passo
  Future<void> deletePasso(int afazerId, int passoId) async {
    final response = await http.delete(
        Uri.parse('$baseUrl/afazeres/$afazerId/passos/$passoId'),
        headers: _headers);
    if (response.statusCode != 200) throw Exception('Falha ao deletar passo');
  }
}
