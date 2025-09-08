import 'package:flutter/material.dart';
import 'package:geoponto/screens/employee/adjustment_screen.dart';
import 'package:geoponto/screens/employee/adjustment_screen.dart';

class PointDetailsScreen extends StatelessWidget {
  // In a real app, you'd pass the specific date or record ID
  const PointDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Example data based on the image
    const String date = '20/08/2025 | quarta-feira';
    const String shift = '08:00 às 12:00 | 13:00 às 17:30';
    const bool hasRecords = false; // Toggle this to see different states

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da jornada'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfo('Data:', date),
            const SizedBox(height: 8),
            _buildInfo('Turno:', shift),
            const SizedBox(height: 24),
            if (!hasRecords)
              _buildNoRecordsWarning(),
            const SizedBox(height: 24),
            const Text('Registros do dia', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            hasRecords ? _buildRecordsList() : const Text('Nenhum registro'),
            const SizedBox(height: 32),
            _buildHoursSummary(),
            const SizedBox(height: 32),
            _buildAdjustmentSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(String label, String value) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(width: 8),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildNoRecordsWarning() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'Você estava ausente nesse dia? Nenhum registro de ponto foi identificado. Caso não se trate de falta, solicite um ajuste no seu ponto.',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsList() {
    // This would be built from a list of records in a real app
    return const Column(
      children: [
        Text('Aqui iriam os registros de ponto do dia'),
        // Example: ListTile(leading: Icon(Icons.timer), title: Text('08:00'), subtitle: Text('Entrada'))
      ],
    );
  }

  Widget _buildHoursSummary() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildHoursInfo('H.T.:', '08:30'),
          _buildHoursInfo('H.F.:', '00:00'),
          _buildHoursInfo('H.E.:', '00:00'),
        ],
      ),
    );
  }

  Widget _buildHoursInfo(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildAdjustmentSection(BuildContext context) {
    return Column(
      children: [
        const Text('Solicitação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        const Text('Deseja realizar alguma solicitação de ajuste ao seu gestor?', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AdjustmentScreen()));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
            foregroundColor: Colors.black,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            minimumSize: const Size(150, 50),
          ),
          child: const Text('Ajuste'),
        ),
      ],
    );
  }
}
