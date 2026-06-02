import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geoponto/config/api_config.dart';
import 'package:geoponto/screens/employee/point_details_screen.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OccurrencesScreen extends StatefulWidget {
  final int? idFuncionario;
  const OccurrencesScreen({super.key, this.idFuncionario});

  @override
  State<OccurrencesScreen> createState() => _OccurrencesScreenState();
}

class _OccurrencesScreenState extends State<OccurrencesScreen> {
  List<dynamic> _occurrences = [];
  bool _isLoading = true;
  int? _resolvedIdFuncionario;

  @override
  void initState() {
    super.initState();
    _resolvedIdFuncionario = widget.idFuncionario;
    _loadAndFetchOccurrences();
  }

  Future<void> _loadAndFetchOccurrences() async {
    if (_resolvedIdFuncionario == null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final storedId = prefs.getInt('id_funcionario');
        if (storedId != null) {
          setState(() {
            _resolvedIdFuncionario = storedId;
          });
        }
      } catch (_) {}
    }

    if (_resolvedIdFuncionario == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    await _fetchOccurrences();
  }

  Future<void> _fetchOccurrences() async {
    try {
      // 1. Fetch dynamic pendencies (excluding absences)
      final pendenciasResponse = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/funcionarios/$_resolvedIdFuncionario/pendencias'),
      );

      // 2. Fetch already registered occurrences in DB
      final dbOccurrencesResponse = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/ocorrencias/funcionario/$_resolvedIdFuncionario'),
      );

      List<dynamic> combined = [];

      if (pendenciasResponse.statusCode == 200) {
        final List<dynamic> pendencias = jsonDecode(pendenciasResponse.body);
        // Map pendencies to match occurrence format for display
        combined.addAll(pendencias.where((p) => p['tipo'] != 'Falta').map((p) => {
          'data_ocorrencia': p['data'],
          'tipo': p['tipo'],
          'descricao': p['descricao'],
          'status': 'Pendente (Ação Requerida)',
        }));
      }

      if (dbOccurrencesResponse.statusCode == 200) {
        final List<dynamic> dbOccs = jsonDecode(dbOccurrencesResponse.body);
        combined.addAll(dbOccs);
      }

      // Sort by date descending
      combined.sort((a, b) => b['data_ocorrencia'].compareTo(a['data_ocorrencia']));

      setState(() {
        _occurrences = combined;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ocorrências'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _resolvedIdFuncionario == null
              ? const Center(child: Text('Erro: ID do funcionário não localizado.'))
              : _occurrences.isEmpty
                  ? const Center(child: Text('Nenhuma ocorrência encontrada.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _occurrences.length,
                      itemBuilder: (context, index) {
                        final occurrence = _occurrences[index];
                        final occurrenceDate = DateTime.parse(occurrence['data_ocorrencia']);
                        final formattedDate = DateFormat('dd/MM/yyyy').format(occurrenceDate);
                        final dayOfWeek = DateFormat('EEEE', 'pt_BR').format(occurrenceDate);
                        final status = occurrence['status'] ?? 'Pendente';
                        
                        return _buildOccurrenceItem(
                          context,
                          date: '$formattedDate | $dayOfWeek',
                          description: '${occurrence['tipo']}: ${occurrence['descricao'] ?? ''}',
                          occurrenceDate: occurrenceDate,
                          status: status,
                        );
                      },
                    ),
    );
  }

  Widget _buildOccurrenceItem(
    BuildContext context, {
    required String date,
    required String description,
    required DateTime occurrenceDate,
    required String status,
  }) {
    Color statusColor = Colors.orange;
    IconData statusIcon = Icons.warning_amber_rounded;

    if (status == 'Rejeitado' || status == 'Reprovado' || status == 'Indeferida') {
      statusColor = Colors.red;
      statusIcon = Icons.error_outline;
    } else if (status.contains('Ação Requerida')) {
      statusColor = Colors.blue;
      statusIcon = Icons.info_outline;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: (status == 'Rejeitado' || status == 'Reprovado' || status == 'Indeferida') ? const BorderSide(color: Colors.red, width: 0.5) : BorderSide.none,
      ),
      child: ListTile(
        leading: Icon(statusIcon, color: statusColor, size: 32),
        title: Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          if (_resolvedIdFuncionario != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PointDetailsScreen(
                  idFuncionario: _resolvedIdFuncionario!,
                  absenceDate: occurrenceDate,
                ),
                settings: const RouteSettings(name: '/employee/point-details'),
              ),
            );
          }
        },
        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      ),
    );
  }
}