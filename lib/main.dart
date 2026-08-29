import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/graphics/hex_shader_service.dart';
import 'presentation/screens/game_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HexShaderService.initialize();
  runApp(
    const ProviderScope(
      child: HexRushApp(),
    ),
  );
}

class HexRushApp extends StatelessWidget {
  const HexRushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HexRush',
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
