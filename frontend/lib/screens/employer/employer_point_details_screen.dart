import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geoponto/config/api_config.dart';
import 'package:geoponto/models/jornada.dart';
import 'package:geoponto/models/ponto.dart';
import 'package:geoponto/screens/employer/map_view_screen.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class EmployerPointDetailsScreen extends StatefulWidget {
  final Ponto ponto;
  final int idFuncionario;

  const EmployerPointDetailsScreen(
      {super.key, required this.ponto, required this.idFuncionario});

  @override
  State<EmployerPointDetailsScreen> createState() =>
      _EmployerPointDetailsScreenState();
}

class _EmployerPointDetailsScreenState
    extends State<EmployerPointDetailsScreen> {
  late Future<Jornada?> _jornadaFuture;

  @override
  void initState() {
    super.initState();
    _jornadaFuture = _fetchJornada();
  }

  Future<Jornada?> _fetchJornada() async {
    final dayOfWeek =
        DateFormat('yyyy-MM-dd').parse(widget.ponto.data).weekday % 7;
    final response = await http.get(Uri.parse(
        '${ApiConfig.baseUrl}/jornadas/funcionario/${widget.idFuncionario}?day_of_week=$dayOfWeek'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<Jornada> jornadas =
          (data['jornadas'] as List).map((j) => Jornada.fromJson(j)).toList();
      return jornadas.isNotEmpty ? jornadas.first : null;
    }
    return null;
  }

  Duration _calcularTempoTrabalhado(Ponto ponto) {
    Duration tempoTrabalhado = Duration.zero;
    DateTime? ultimaEntrada;
    // The records from the backend are already sorted chronologically descending.
    // To calculate worked time, we need to process them chronologically ascending.
    final registros = ponto.registros.reversed.toList();

    for (int i = 0; i < registros.length; i++) {
      final registro = registros[i];
      final parsedTime = DateFormat('HH:mm:ss').parse(registro['time']);
      // We use a fixed date (like today) just to perform date operations,
      // the date itself doesn't matter, only the time difference.
      final now = DateTime.now();
      final dateTimeRegistro = DateTime(now.year, now.month, now.day,
          parsedTime.hour, parsedTime.minute, parsedTime.second);

      if (i % 2 == 0) {
        // Even index (0, 2, ...) is 'Entrada'
        ultimaEntrada = dateTimeRegistro;
      } else {
        // Odd index (1, 3, ...) is 'Saída'
        if (ultimaEntrada != null) {
          tempoTrabalhado += dateTimeRegistro.difference(ultimaEntrada);
          ultimaEntrada = null;
        }
      }
    }
    return tempoTrabalhado;
  }

  Duration _calcularTotalJornada(Jornada jornada) {
    Duration total = Duration.zero;
    if (jornada.horario_entrada != null && jornada.horario_saida != null) {
      final entrada = DateFormat('HH:mm:ss').parse(jornada.horario_entrada!);
      final saida = DateFormat('HH:mm:ss').parse(jornada.horario_saida!);
      total += saida.difference(entrada);
    }
    if (jornada.horario_saida_intervalo != null &&
        jornada.horario_retorno_intervalo != null) {
      final saidaIntervalo =
          DateFormat('HH:mm:ss').parse(jornada.horario_saida_intervalo!);
      final retornoIntervalo =
          DateFormat('HH:mm:ss').parse(jornada.horario_retorno_intervalo!);
      total -= retornoIntervalo.difference(saidaIntervalo);
    }
    return total;
  }

  String _formatarDuracao(Duration duration) {
    if (duration.isNegative) {
      duration = duration.abs();
    }
    String doisDigitos(int n) => n.toString().padLeft(2, '0');
    String doisDigitosHoras = doisDigitos(duration.inHours);
    String doisDigitosMinutos = doisDigitos(duration.inMinutes.remainder(60));
    return "$doisDigitosHoras:$doisDigitosMinutos";
  }

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('yyyy-MM-dd').parse(widget.ponto.data);
    final formattedDate = DateFormat('dd/MM/yyyy | EEEE', 'pt_BR').format(date);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da jornada'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<Jornada?>(
        future: _jornadaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final jornada = snapshot.data;
          final shift = jornada != null
              ? '${jornada.horario_entrada?.substring(0, 5) ?? '--:--'} às ${jornada.horario_saida_intervalo?.substring(0, 5) ?? '--:--'} | ${jornada.horario_retorno_intervalo?.substring(0, 5) ?? '--:--'} às ${jornada.horario_saida?.substring(0, 5) ?? '--:--'}'
              : 'Sem jornada definida para este dia';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfo('Data:', formattedDate),
                const SizedBox(height: 8),
                _buildInfo('Turno:', shift),
                const SizedBox(height: 24),
                if (widget.ponto.registros.isEmpty) _buildNoRecordsWarning(),
                const SizedBox(height: 24),
                const Text('Registros do dia',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),
                widget.ponto.registros.isNotEmpty
                    ? _buildRecordsList(context)
                    : const Text('Nenhum registro'),
                const SizedBox(height: 32),
                if (jornada != null)
                  _buildHoursSummary(widget.ponto, jornada),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfo(String label, String value) {
    return Row(
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
      children: widget.ponto.registros.map((registro) {
        final time = DateFormat('HH:mm:ss').parse(registro['time']);
        final formattedTime = DateFormat('HH:mm').format(time);
        return ListTile(
          title: Text(formattedTime),
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

  Widget _buildHoursSummary(Ponto ponto, Jornada jornada) {
    final tempoTrabalhado = _calcularTempoTrabalhado(ponto);
    final totalJornada = _calcularTotalJornada(jornada);
    final diferenca = tempoTrabalhado - totalJornada;

    final horasFaltantes = diferenca.isNegative ? diferenca.abs() : Duration.zero;
    final horasExtras = !diferenca.isNegative ? diferenca : Duration.zero;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildHoursInfo('H.T.:', _formatarDuracao(tempoTrabalhado)),
          _buildHoursInfo('H.F.:', _formatarDuracao(horasFaltantes)),
          _buildHoursInfo('H.E.:', _formatarDuracao(horasExtras)),
        ],
      ),
    );
  }

  Widget _buildHoursInfo(String label, String value) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
