import 'package:flutter/material.dart';
import 'package:geoponto/services/analytics_service.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  static const String routeName = '/analytics-dashboard';

  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  late Future<Map<String, dynamic>> _metricsFuture;

  @override
  void initState() {
    super.initState();
    _metricsFuture = AnalyticsService.getAnalyticsMetrics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de Análise'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _metricsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum dado de análise disponível.'));
          } else {
            final metrics = snapshot.data!;
            final List<dynamic> mostAccessedPages = metrics['most_accessed_pages'] ?? [];
            final List<dynamic> mostClickedButtons = metrics['most_clicked_buttons'] ?? [];
            final List<dynamic> slowestPages = metrics['slowest_pages'] ?? [];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Páginas Mais Acessadas'),
                  _buildMetricList(mostAccessedPages, (item) => '${item['page_name']} (${item['view_count']} visualizações)'),
                  const SizedBox(height: 20),

                  _buildSectionTitle('Botões Mais Clicados'),
                  _buildMetricList(mostClickedButtons, (item) => '${item['button_id']} (${item['click_count']} cliques)'),
                  const SizedBox(height: 20),

                  _buildSectionTitle('Páginas Mais Lentas (Tempo Médio)'),
                  _buildMetricList(slowestPages, (item) => '${item['page_name']} (${item['avg_render_time']} ms)'),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }

  Widget _buildMetricList(List<dynamic> items, String Function(dynamic) itemBuilder) {
    if (items.isEmpty) {
      return const Text('N/D');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Text(itemBuilder(item)),
      )).toList(),
    );
  }
}
