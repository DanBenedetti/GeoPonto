import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
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
      home: const ABTestDecider(),
    );
  }
}

// Tela que decide e registra a variante
class ABTestDecider extends StatefulWidget {
  const ABTestDecider({super.key});

  @override
  State<ABTestDecider> createState() => _ABTestDeciderState();
}

class _ABTestDeciderState extends State<ABTestDecider> {
  Future<Widget> _decideVariant() async {
    final prefs = await SharedPreferences.getInstance();
    String? variant = prefs.getString('ab_variant');

    // Se não houver variante salva, sorteia e salva
    if (variant == null) {
      variant = Random().nextBool() ? 'A' : 'B';
      await prefs.setString('ab_variant', variant);
    }

    // Atualiza métrica local
    String metricKey = 'ab_metric_$variant';
    int count = prefs.getInt(metricKey) ?? 0;
    await prefs.setInt(metricKey, count + 1);

    // Retorna a tela correspondente
    if (variant == 'A') {
      return const VariantAScreen();
    } else {
      return const VariantBScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _decideVariant(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          return snapshot.data!;
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

// Variante A
class VariantAScreen extends StatelessWidget {
  const VariantAScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Variante A')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bem-vindo à Variante A!',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 32),
            MetricsWidget(variant: 'A'),
          ],
        ),
      ),
    );
  }
}

// Variante B
class VariantBScreen extends StatelessWidget {
  const VariantBScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Variante B')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bem-vindo à Variante B!',
              style: TextStyle(fontSize: 24, color: Colors.blue),
            ),
            const SizedBox(height: 32),
            MetricsWidget(variant: 'B'),
          ],
        ),
      ),
    );
  }
}

// Widget para mostrar métricas locais
class MetricsWidget extends StatefulWidget {
  final String variant;
  const MetricsWidget({super.key, required this.variant});

  @override
  State<MetricsWidget> createState() => _MetricsWidgetState();
}

class _MetricsWidgetState extends State<MetricsWidget> {
  int? countA;
  int? countB;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      countA = prefs.getInt('ab_metric_A') ?? 0;
      countB = prefs.getInt('ab_metric_B') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Exibições Variante A: ${countA ?? "..."}'),
        Text('Exibições Variante B: ${countB ?? "..."}'),
      ],
    );
  }
}