import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geoponto/config/api_config.dart';
import 'package:geoponto/screens/employee/point_details_screen.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:geoponto/services/analytics_service.dart';

class AbsencesScreen extends StatefulWidget {
  final int idFuncionario;
  const AbsencesScreen({super.key, required this.idFuncionario});

  @override
  State<AbsencesScreen> createState() => _AbsencesScreenState();
}

class _AbsencesScreenState extends State<AbsencesScreen> {
  List<String> _absences = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAbsences();
  }

  Future<void> _fetchAbsences() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/funcionarios/${widget.idFuncionario}/pendencias'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _absences = data
              .where((p) => p['tipo'] == 'Falta')
              .map((p) => p['data'] as String)
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faltas'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _absences.isEmpty
              ? const Center(child: Text('Nenhuma falta encontrada.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _absences.length,
                  itemBuilder: (context, index) {
                    final absenceDate = DateTime.parse(_absences[index]);
                    final formattedDate = DateFormat('dd/MM/yyyy').format(absenceDate);
                    final dayOfWeek = DateFormat('EEEE', 'pt_BR').format(absenceDate);
                    return _buildAbsenceItem(
                      context,
                      date: '$formattedDate | $dayOfWeek',
                      reason: 'Nenhum registro',
                      absenceDate: absenceDate,
                    );
                  },
                ),
    );
  }

  Widget _buildAbsenceItem(BuildContext context, {required String date, required String reason, required DateTime absenceDate}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 32),
        title: Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(reason),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          AnalyticsService.recordButtonClick('view_absence_details', pageName: '/employee/absences');
          Navigator.push(context, MaterialPageRoute(builder: (context) => PointDetailsScreen(idFuncionario: widget.idFuncionario, absenceDate: absenceDate), settings: const RouteSettings(name: '/employee/point-details')));
        },
        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      ),
    );
  }
}