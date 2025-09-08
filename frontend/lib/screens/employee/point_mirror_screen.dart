import 'package:flutter/material.dart';

class PointMirrorScreen extends StatelessWidget {
  const PointMirrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Espelho ponto'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildMonthSummaryItem(
            month: 'Junho',
            period: '01 jun 2025 - 31 jun 2025',
            normalHours: '170:05',
            absences: '08:25',
            extraHours: '00:00',
          ),
          // Adicione mais resumos mensais aqui
        ],
      ),
    );
  }

  Widget _buildMonthSummaryItem({
    required String month,
    required String period,
    required String normalHours,
    required String absences,
    required String extraHours,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to month details
        },
        borderRadius: BorderRadius.circular(10.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(month, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 4),
                      Text(period, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildHoursInfo('H. Normais', normalHours),
                  _buildHoursInfo('Faltas', absences),
                  _buildHoursInfo('H. Extras', extraHours),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHoursInfo(String label, String hours) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(hours, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}
