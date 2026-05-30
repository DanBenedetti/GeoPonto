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
  List<Map<String, dynamic>> _registrosDoDia = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchJornadaAndPontos();
  }

  Future<void> _fetchJornadaAndPontos() async {
    final dayOfWeek = (widget.absenceDate.weekday + 1) % 7;
    final dateStr = DateFormat('yyyy-MM-dd').format(widget.absenceDate);

    try {
      // 1. Buscar a Jornada esperada
      final jornadaResponse = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/jornadas/funcionario/${widget.idFuncionario}?day_of_week=$dayOfWeek'),
      );

      // 2. Buscar todos os pontos do mês
      final pontosResponse = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/ponto/funcionario/${widget.idFuncionario}?month=${widget.absenceDate.month}&year=${widget.absenceDate.year}'),
      );

      Jornada? tempJornada;
      List<Map<String, dynamic>> tempRegistros = [];

      if (jornadaResponse.statusCode == 200) {
        final data = jsonDecode(jornadaResponse.body);
        if (data['jornadas'] != null && data['jornadas'].isNotEmpty) {
          tempJornada = Jornada.fromJson(data['jornadas'][0]);
        }
      }

      if (pontosResponse.statusCode == 200) {
        final data = jsonDecode(pontosResponse.body) as List;
        final targetDayData = data.firstWhere(
          (element) => element['data'] == dateStr,
          orElse: () => null,
        );
        if (targetDayData != null) {
          tempRegistros = List<Map<String, dynamic>>.from(targetDayData['registros']);
          // Ordena os registros do dia de forma crescente por horário
          tempRegistros.sort((a, b) => (a['time'] as String).compareTo(b['time'] as String));
        }
      }

      setState(() {
        _jornada = tempJornada;
        _registrosDoDia = tempRegistros;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Duration _parseTimeToDuration(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) {
      return Duration.zero;
    }
    try {
      final parts = timeStr.split(':');
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);
      return Duration(hours: hours, minutes: minutes);
    } catch (_) {
      return Duration.zero;
    }
  }


  Map<String, String> _calculateDailyHours() {
    Duration worked = Duration.zero;
    
    // Calcula o tempo trabalhado em intervalos (par de entrada/saída)
    for (int i = 0; i < _registrosDoDia.length; i += 2) {
      if (i + 1 < _registrosDoDia.length) {
        final start = _parseTimeToDuration(_registrosDoDia[i]['time']);
        final end = _parseTimeToDuration(_registrosDoDia[i + 1]['time']);
        worked += (end - start);
      }
    }

    // Calcula a jornada esperada (padrão 8 horas se não cadastrado)
    Duration standard = const Duration(hours: 8);
    if (_jornada != null) {
      try {
        final ent = _parseTimeToDuration(_jornada!.horario_entrada);
        final saInterval = _parseTimeToDuration(_jornada!.horario_saida_intervalo);
        final reInterval = _parseTimeToDuration(_jornada!.horario_retorno_intervalo);
        final sai = _parseTimeToDuration(_jornada!.horario_saida);
        standard = (saInterval - ent) + (sai - reInterval);
      } catch (_) {}
    }

    Duration missing = Duration.zero;
    Duration extra = Duration.zero;

    if (worked > standard) {
      extra = worked - standard;
    } else if (worked < standard) {
      missing = standard - worked;
    }

    String format(Duration d) {
      String twoDigits(int n) => n.toString().padLeft(2, "0");
      return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}";
    }

    return {
      'worked': format(worked),
      'missing': format(missing),
      'extra': format(extra),
    };
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd/MM/yyyy | EEEE', 'pt_BR').format(widget.absenceDate);
    final shift = _jornada != null 
        ? '${_jornada!.horario_entrada} às ${_jornada!.horario_saida_intervalo} | ${_jornada!.horario_retorno_intervalo} às ${_jornada!.horario_saida}'
        : 'Nenhuma jornada cadastrada para este dia';
    
    final bool hasRecords = _registrosDoDia.isNotEmpty; 
    final dailyHours = _calculateDailyHours();

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
                  _buildHoursSummary(dailyHours),
                  const SizedBox(height: 32),
                  _buildAdjustmentSection(context, shift),
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
    return Column(
      children: _registrosDoDia.map((reg) {
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: ListTile(
            leading: const Icon(Icons.access_time, color: Colors.blue),
            title: Text(
              'Marcação de Ponto: ${reg['time']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Coordenadas: ${reg['latitude']}, ${reg['longitude']}'),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHoursSummary(Map<String, String> hours) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildHoursInfo('H.T.:', hours['worked']!),
          _buildHoursInfo('H.F.:', hours['missing']!),
          _buildHoursInfo('H.E.:', hours['extra']!),
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

  Widget _buildAdjustmentSection(BuildContext context, String shift) {
    return Column(
      children: [
        const Text('Solicitação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        const Text('Deseja realizar alguma solicitação de ajuste ao seu gestor?', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            AnalyticsService.recordButtonClick('adjustment_button', pageName: '/employee/point-details');
            
            // Converte os horários existentes em objetos TimeOfDay para o ajuste
            List<TimeOfDay> initialTimes = _registrosDoDia.map((reg) {
              final parts = (reg['time'] as String).split(':');
              return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
            }).toList();

            Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (context) => AdjustmentScreen(
                  idFuncionario: widget.idFuncionario,
                  dataOcorrencia: widget.absenceDate,
                  initialRecords: initialTimes,
                  shiftInfo: shift,
                ), 
                settings: const RouteSettings(name: '/employee/adjustment')
              )
            );
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
