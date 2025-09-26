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
      ),
      home: const ABTestDecider(),
    );
  }
}

// Tela inicial com botão para iniciar teste A/B
class ABTestDecider extends StatefulWidget {
  const ABTestDecider({super.key});

  @override
  State<ABTestDecider> createState() => _ABTestDeciderState();
}

class _ABTestDeciderState extends State<ABTestDecider> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teste A/B - GeoPonto')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final start = DateTime.now();
            final prefs = await SharedPreferences.getInstance();
            String? variant = prefs.getString('ab_variant');

            // Sorteia variante se não existir
            if (variant == null) {
              variant = Random().nextBool() ? 'A' : 'B';
              await prefs.setString('ab_variant', variant);
            }

            // Atualiza métrica de exibição
            String metricKey = 'ab_metric_$variant';
            int count = prefs.getInt(metricKey) ?? 0;
            await prefs.setInt(metricKey, count + 1);

            // Mede tempo de carregamento simulando delay (remova se não quiser delay)
            await Future.delayed(const Duration(milliseconds: 500));
            final end = DateTime.now();
            final loadTime = end.difference(start).inMilliseconds;

            // Salva tempo de carregamento
            String timeKey = 'ab_time_${variant}_ms';
            int totalTime = prefs.getInt(timeKey) ?? 0;
            int totalLoads = prefs.getInt('ab_loads_$variant') ?? 0;
            await prefs.setInt(timeKey, totalTime + loadTime);
            await prefs.setInt('ab_loads_$variant', totalLoads + 1);

            // Navega para variante e passa tempo de carregamento
            if (variant == 'A') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VariantAScreen(loadTime: loadTime),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VariantBScreen(loadTime: loadTime),
                ),
              );
            }
          },
          child: const Text('Iniciar Teste A/B'),
        ),
      ),
    );
  }
}

// Variante A
class VariantAScreen extends StatelessWidget {
  final int loadTime;
  const VariantAScreen({super.key, required this.loadTime});

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
            const SizedBox(height: 16),
            Text('Tempo de carregamento: ${loadTime} ms'),
            const SizedBox(height: 32),
            const MetricsWidget(variant: 'A'),
          ],
        ),
      ),
    );
  }
}

// Variante B
class VariantBScreen extends StatelessWidget {
  final int loadTime;
  const VariantBScreen({super.key, required this.loadTime});

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
            const SizedBox(height: 16),
            Text('Tempo de carregamento: ${loadTime} ms'),
            const SizedBox(height: 32),
            const MetricsWidget(variant: 'B'),
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
  double? avgTimeA;
  double? avgTimeB;

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

      int totalTimeA = prefs.getInt('ab_time_A_ms') ?? 0;
      int loadsA = prefs.getInt('ab_loads_A') ?? 0;
      avgTimeA = loadsA > 0 ? totalTimeA / loadsA : null;

      int totalTimeB = prefs.getInt('ab_time_B_ms') ?? 0;
      int loadsB = prefs.getInt('ab_loads_B') ?? 0;
      avgTimeB = loadsB > 0 ? totalTimeB / loadsB : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Exibições Variante A: ${countA ?? "..."}'),
        Text('Exibições Variante B: ${countB ?? "..."}'),
        const SizedBox(height: 16),
        Text('Tempo médio Variante A: ${avgTimeA?.toStringAsFixed(2) ?? "..."} ms'),
        Text('Tempo médio Variante B: ${avgTimeB?.toStringAsFixed(2) ?? "..."} ms'),
      ],
    );
  }
}