import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geoponto/config/api_config.dart';
import 'package:geoponto/models/jornada.dart';
import 'package:geoponto/screens/employee/adjustment_screen.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:geoponto/services/analytics_service.dart';

class PointDetailsScreen extends StatefulWidget {
  final int idFuncionario;
  final DateTime absenceDate;

  const PointDetailsScreen({
    super.key,
    required this.idFuncionario,
    required this.absenceDate,
  });

  @override
  State<PointDetailsScreen> createState() => _PointDetailsScreenState();
}

class _PointDetailsScreenState extends State<PointDetailsScreen> {
  Jornada? _jornada;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchJornada();
  }

  Future<void> _fetchJornada() async {
    // dia_semana in Jornadas -> 0: Domingo, 1: Segunda, ..., 6: Sábado
    // Python's weekday() -> Monday is 0 and Sunday is 6
    final dayOfWeek = (widget.absenceDate.weekday + 1) % 7;

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/jornadas/funcionario/${widget.idFuncionario}?day_of_week=$dayOfWeek'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['jornadas'].isNotEmpty) {
          setState(() {
            _jornada = Jornada.fromJson(data['jornadas'][0]);
            _isLoading = false;
          });
        }
      } else {
        // Handle error
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle error
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd/MM/yyyy | EEEE', 'pt_BR').format(widget.absenceDate);
    final shift = _jornada != null 
        ? '${_jornada!.horario_entrada} às ${_jornada!.horario_saida_intervalo} | ${_jornada!.horario_retorno_intervalo} às ${_jornada!.horario_saida}'
        : 'Nenhuma jornada cadastrada para este dia';
    const bool hasRecords = false; 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da jornada'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfo('Data:', formattedDate),
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
    return const Column(
      children: [
        Text('Aqui iriam os registros de ponto do dia'),
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
            AnalyticsService.recordButtonClick('adjustment_button', pageName: '/employee/point-details');
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AdjustmentScreen(), settings: const RouteSettings(name: '/employee/adjustment')));
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
