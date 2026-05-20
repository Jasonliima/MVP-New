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
        scaffoldBackgroundColor: const Color(0xFFF4F5F7), // Fundo suave global
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFD9E2EC),
          foregroundColor: Color.fromARGB(255, 3, 189, 142),
          elevation: 0,
        ),
        primaryColor: const Color.fromARGB(255, 2, 151, 177),
      ),
      home: const LoginScreen(),
    );
  }
}
