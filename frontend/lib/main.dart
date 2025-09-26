import 'package:flutter/material.dart';
import 'package:geoponto/screens/loading_screen.dart';
import 'package:geoponto/ab_test_service.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeoPonto',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF0F0F0),
        primaryColor: const Color(0xFF16D04D),
        fontFamily: 'sans-serif',
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF16D04D),
          secondary: Color(0xFF16D04D),
          background: Color(0xFFF0F0F0),
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onBackground: Colors.black,
          onSurface: Colors.black,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF16D04D),
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF16D04D),
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black54),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: Colors.grey),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE0E0E0),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            )
          ),
        ),
      ),
      home: const ABTestScreen(),
    );
  }
}

// Tela de Teste A/B
class ABTestScreen extends StatefulWidget {
  const ABTestScreen({super.key});

  @override
  State<ABTestScreen> createState() => _ABTestScreenState();
}

class _ABTestScreenState extends State<ABTestScreen> {
  String? variant;
  int? loadTimeMs;
  bool loading = false;

  Future<void> runABTest() async {
    setState(() {
      loading = true;
    });

    final start = DateTime.now();
    variant ??= Random().nextBool() ? 'A' : 'B';

    // Simula carregamento
    await Future.delayed(const Duration(milliseconds: 500));
    final end = DateTime.now();
    loadTimeMs = end.difference(start).inMilliseconds;

    // Envia métrica para backend
    await ABTestService.sendMetric(
      variant: variant!,
      loadTimeMs: loadTimeMs!,
      action: 'page_load',
    );

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teste A/B - GeoPonto')),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: runABTest,
                    child: const Text('Executar Teste A/B'),
                  ),
                  if (variant != null && loadTimeMs != null) ...[
                    const SizedBox(height: 24),
                    Text('Variante: $variant'),
                    Text('Tempo de carregamento: ${loadTimeMs} ms'),
                    const SizedBox(height: 24),
                    const Text('Métrica enviada ao backend!'),
                  ],
                ],
              ),
      ),
    );
  }
}