import 'package:flutter/material.dart';
import 'package:geoponto/screens/employee/adjustment_screen.dart';

enum RequestStatus { pending, approved, rejected }

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for demonstration
    final List<Map<String, dynamic>> requests = [
      {'date': '22/08/2025 | sexta-feira', 'status': RequestStatus.pending},
      {'date': '19/08/2025 | terça-feira', 'status': RequestStatus.approved},
      {'date': '15/08/2025 | sexta-feira', 'status': RequestStatus.rejected},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Solicitações'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return _buildRequestItem(
            context,
            date: request['date'],
            status: request['status'],
          );
        },
      ),
    );
  }

  Widget _buildRequestItem(BuildContext context, {required String date, required RequestStatus status}) {
    String statusText;
    Color statusColor;

    switch (status) {
      case RequestStatus.pending:
        statusText = 'Pendente';
        statusColor = Colors.orange;
        break;
      case RequestStatus.approved:
        statusText = 'Aprovada';
        statusColor = Colors.green;
        break;
      case RequestStatus.rejected:
        statusText = 'Indeferida';
        statusColor = Colors.red;
        break;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        title: Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              statusText,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
        onTap: () {
          if (status == RequestStatus.rejected) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AdjustmentScreen()));
          }
          // TODO: Navigate to a read-only detail screen for other statuses if needed
        },
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      ),
    );
  }
}
