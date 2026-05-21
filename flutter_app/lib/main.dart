import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MVP App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor:
            const Color(0xFFFFF8FF), // Fundo claro da Tela de Afazeres
        appBarTheme: const AppBarTheme(
          backgroundColor:
              Color(0xFF8800FF), // Roxo vibrante da Tela de Afazeres
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        primaryColor: const Color(0xFFFF0080), // Rosa vibrante principal
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFF0080),
          foregroundColor: Colors.white,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
