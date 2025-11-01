import 'package:flutter/material.dart';
import 'package:geoponto/models/ponto.dart';
import 'package:geoponto/screens/employer/map_view_screen.dart';
import 'package:latlong2/latlong.dart';

class EmployerPointDetailsScreen extends StatelessWidget {
  final Ponto ponto;

  const EmployerPointDetailsScreen({super.key, required this.ponto});

  @override
  Widget build(BuildContext context) {
    const String shift = '08:00 às 12:00 | 13:00 às 17:30'; // Placeholder

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
            _buildInfo('Data:', ponto.data),
            const SizedBox(height: 8),
            _buildInfo('Turno:', shift),
            const SizedBox(height: 24),
            if (ponto.registros.isEmpty) _buildNoRecordsWarning(),
            const SizedBox(height: 24),
            const Text('Registros do dia', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            ponto.registros.isNotEmpty ? _buildRecordsList(context) : const Text('Nenhum registro'),
            const SizedBox(height: 32),
            _buildHoursSummary(),
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
              'Nenhum registro de ponto foi identificado para este dia.',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsList(BuildContext context) {
    return Column(
      children: ponto.registros.map((registro) {
        return ListTile(
          title: Text(registro['time']),
          trailing: IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              final latitude = registro['latitude'];
              final longitude = registro['longitude'];
              if (latitude != null && longitude != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MapViewScreen(
                      location: LatLng(latitude, longitude),
                    ),
                  ),
                );
              }
            },
          ),
        );
      }).toList(),
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
          _buildHoursInfo('H.T.:', '00:00'), // Placeholder
          _buildHoursInfo('H.F.:', '00:00'), // Placeholder
          _buildHoursInfo('H.E.:', '00:00'), // Placeholder
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
}
