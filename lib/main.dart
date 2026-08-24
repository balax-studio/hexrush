import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/screens/game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: HexIdleApp(),
    ),
  );
}

class HexIdleApp extends StatelessWidget {
  const HexIdleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hex Idle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primaryColor: const Color(0xFFFFD54F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFD54F),
          secondary: Color(0xFF00E5FF),
          surface: Color(0xFF1E293B),
        ),
        fontFamily: 'Segoe UI',
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}
