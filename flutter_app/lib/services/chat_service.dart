import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'session.dart';

class ChatService {
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

  Future<String> sendMessageToGemini(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Session.token ?? ""}'
        },
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply'];
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Falha na resposta do servidor');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> updateLimit(int newLimit) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat/admin/settings'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Session.token ?? ""}'
      },
      body: jsonEncode({
        'newLimit': newLimit,
      }),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Falha ao atualizar o limite');
    }
  }
}
