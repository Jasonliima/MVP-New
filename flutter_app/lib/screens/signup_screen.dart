import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authService = AuthService();
  bool _isLoading = false;
  String _selectedRole = 'admin'; // Admin/Pai como padrão inicial

  Future<void> _register() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos')),
      );
      return;
    }

    final email = _emailController.text.trim();
    final regexEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!regexEmail.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Por favor, insira um e-mail válido completo (ex: seu.nome@gmail.com).'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Bloqueia se o formato de e-mail estiver errado
    }

    final senha = _passwordController.text.trim();
    final regexValidacao = RegExp(r'^(?=.*[A-Z])(?=.*\d).{6,}$');

    if (!regexValidacao.hasMatch(senha)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'A senha deve ter no mínimo 6 caracteres, 1 letra maiúscula e 1 número.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Bloqueia a continuação e não envia para a API
    }

    setState(() => _isLoading = true);

    try {
      await _authService.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _selectedRole,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Conta criada com sucesso!'),
              backgroundColor: Colors.green),
        );
        // Volta para a tela de Login
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Erro: ${e.toString().replaceAll("Exception: ", "")}'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFFFF8FF), // Fundo limpo e consistente com o app
      appBar: AppBar(
        title: const Text('Criar Nova Conta',
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF8800FF), // Roxo vibrante para combinar
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Informações do usuário',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8800FF)),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                labelText: 'Nome Completo',
                filled: true,
                fillColor: Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                final text = textEditingValue.text.toLowerCase();
                if (text.isEmpty) return const Iterable<String>.empty();

                // Sugere o provedor se o usuário digitar o '@'
                if (text.contains('@')) {
                  final parts = text.split('@');
                  final name = parts[0];
                  final domain = parts.length > 1 ? parts[1] : '';
                  const domains = [
                    'gmail.com',
                    'hotmail.com',
                    'outlook.com',
                    'yahoo.com'
                  ];
                  return domains
                      .where((d) => d.startsWith(domain))
                      .map((d) => '$name@$d');
                }

                // Sugestões enquanto ele digita apenas o nome de usuário
                return [
                  '$text@gmail.com',
                  '$text@hotmail.com',
                ];
              },
              onSelected: (String selection) =>
                  _emailController.text = selection,
              fieldViewBuilder:
                  (context, controller, focusNode, onEditingComplete) {
                controller
                    .addListener(() => _emailController.text = controller.text);
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    labelText: 'E-mail (com sugestões)',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                labelText: 'Senha',
                filled: true,
                fillColor: Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Tipo de conta:',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF8800FF))),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Admin (Pai)',
                        style: TextStyle(fontSize: 16)),
                    value: 'admin',
                    groupValue: _selectedRole,
                    onChanged: (value) =>
                        setState(() => _selectedRole = value!),
                    activeColor: const Color(0xFFFF0080),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Usuário (Filho)',
                        style: TextStyle(fontSize: 16)),
                    value: 'user',
                    groupValue: _selectedRole,
                    onChanged: (value) =>
                        setState(() => _selectedRole = value!),
                    activeColor: const Color(0xFFFF0080),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _register,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor:
                    const Color(0xFFFF0080), // Rosa vibrante principal
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('CRIAR CONTA',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
