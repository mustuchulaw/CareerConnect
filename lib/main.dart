import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_screen.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const CareerConnectApp());
}

class CareerConnectApp extends StatelessWidget {
  const CareerConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CareerConnect',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF06B6D4),
          secondary: Color(0xFF3B82F6),
          surface: Colors.transparent,
        ),
        fontFamily: 'Roboto',
      ),
      home: const AuthScreen(),
    );
  }
}