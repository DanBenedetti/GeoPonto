import 'package:flutter/material.dart';
import 'package:geoponto/screens/employee/point_details_screen.dart';

class MyPointScreen extends StatelessWidget {
  const MyPointScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu ponto'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filter functionality
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildPointRecordItem(
            context,
            date: '19/08/2025 | terça-feira',
            extraHours: '00:00',
            missingHours: '00:00',
          ),
          _buildPointRecordItem(
            context,
            date: '18/08/2025 | segunda-feira',
            extraHours: '00:00',
            missingHours: '00:00',
          ),
          _buildPointRecordItem(
            context,
            date: '15/08/2025 | sexta-feira',
            extraHours: '00:00',
            missingHours: '00:00',
            isPending: true,
          ),
           _buildPointRecordItem(
            context,
            date: '14/08/2025 | quinta-feira',
            extraHours: '00:00',
            missingHours: '00:00',
          ),
           _buildPointRecordItem(
            context,
            date: '13/08/2025 | quarta-feira',
            extraHours: '00:00',
            missingHours: '00:00',
          ),
        ],
      ),
    );
  }

  Widget _buildPointRecordItem(
    BuildContext context, {
    required String date,
    required String extraHours,
    required String missingHours,
    bool isPending = false,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        title: Text(date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: isPending
            ? const Text('Solicitação pendente', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12))
            : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const PointDetailsScreen()));
        },
        shape: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
    );
  }
}