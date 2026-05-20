import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'session.dart';

class AuthService {
  // Configuração inteligente que foge do Firewall do Windows!
  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api'; // Chrome/Web passa direto pelo firewall
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:3000/api'; // Emulador passa direto pelo firewall
      }
    } catch (_) {}
    return 'http://localhost:3000/api'; // Padrão
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password, String role) async {
    try {
      print('🔄 [AuthService] Tentando registrar em: $baseUrl/auth/register');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Falha ao criar conta');
      }
    } catch (e) {
      throw Exception('Erro de conexão com o servidor: $e');
    }
  }

  Future<void> login(String email, String password) async {
    try {
      print('🔄 [AuthService] Tentando fazer login em: $baseUrl/auth/login');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Salva o token e dados do usuário globalmente
        Session.token = data['token'];
        Session.userId = data['user']['id'];
        Session.userName = data['user']['name'];
        Session.userRole = data['user']['role'];
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Falha ao realizar login');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}
