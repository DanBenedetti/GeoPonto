import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geoponto/config/api_config.dart';
import 'package:geoponto/mixins/search_mixin.dart';
import 'package:geoponto/models/colaborador.dart';
import 'package:geoponto/models/jornada.dart';
import 'package:geoponto/models/localizacao.dart';
import 'package:geoponto/models/ponto.dart';
import 'package:geoponto/screens/employee/my_hr_screen.dart';
import 'package:geoponto/components/app_bottom_nav_bar.dart';
import 'package:geoponto/components/shortcuts_widget.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

import 'package:geoponto/screens/employer/employee_registration_screen.dart';
import 'package:geoponto/screens/login_screen.dart';
import 'package:geoponto/screens/status_database/status.dart';
import 'package:geoponto/services/analytics_service.dart';
import 'package:geoponto/components/analytics_button.dart';
import 'package:geoponto/mixins/render_time_mixin.dart';

class EmployeeHomeScreen extends StatefulWidget {
  final int idFuncionario;
  final int idEmpresa;

  const EmployeeHomeScreen({
    super.key,
    required this.idFuncionario,
    required this.idEmpresa,
  });

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> with SearchMixin<EmployeeHomeScreen>, RenderTimeMixin<EmployeeHomeScreen> {
  late Future<Colaborador> _funcionarioFuture;
  late Future<Jornada?> _jornadaFuture;
  late Future<List<Ponto>> _pontosFuture;
  late String _currentTime;
  late Timer _clockTimer;
  Timer? _countdownTimer;
  Duration _tempoRestante = Duration.zero;
  bool _trabalhando = false;

  int _selectedIndex = 1; // Home is selected by default
  int _selectedShortcutIndex = 0; // 0: Bater Ponto, 1: Meu RH, 2: Holerite

  @override
  void initState() {
    super.initState();
    _funcionarioFuture = _fetchFuncionario();
    _jornadaFuture = _fetchJornada();
    _pontosFuture = _fetchLastPontos();
    _updateTime(); // Set initial time
    _clockTimer = Timer.periodic(const Duration(minutes: 1), (Timer t) => _updateTime());

    Future.wait([_jornadaFuture, _pontosFuture]).then((_) {
      _calcularTempoRestante();
      _iniciarContador();
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = DateFormat('HH:mm | dd \'de\' MMMM \'de\' yyyy', 'pt_BR').format(now);
    });
  }

  Future<Colaborador> _fetchFuncionario() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/funcionarios/${widget.idFuncionario}'));

    if (response.statusCode == 200) {
      return Colaborador.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Falha ao carregar os dados do funcionário.');
    }
  }

  Future<Jornada?> _fetchJornada() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/jornadas/funcionario/${widget.idFuncionario}'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<Jornada> jornadas = (data['jornadas'] as List).map((j) => Jornada.fromJson(j)).toList();
      final today = DateTime.now().weekday % 7; // Convert to backend format (Sun=0, Mon=1, ...)
      
      Jornada? foundJornada;
      for (var j in jornadas) {
        if (j.dia_semana == today) {
          foundJornada = j;
          break;
        }
      }
      return foundJornada;
    }
    return null;
  }

  Future<List<Ponto>> _fetchLastPontos() async {
    List<Ponto> allPontos = [];
    DateTime now = DateTime.now();
    int month = now.month;
    int year = now.year;
    int recordsFound = 0;

    // Go back a maximum of 3 months to find records
    for (int i = 0; i < 3; i++) {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/ponto/funcionario/${widget.idFuncionario}?year=$year&month=$month'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<Ponto> monthPontos = (data as List).map((p) => Ponto.fromJson(p)).toList();
        allPontos.addAll(monthPontos);

        // Count total records fetched
        recordsFound = 0;
        for (var p in allPontos) {
          recordsFound += p.registros.length;
        }

        // If we have at least 4 records, we can stop.
        if (recordsFound >= 4) {
          break;
        }
      }

      // Prepare to fetch for the previous month
      if (month == 1) {
        month = 12;
        year -= 1;
      } else {
        month -= 1;
      }
    }
    // The backend already sorts by date descending, but since we are fetching month by month, we need to re-sort the Ponto objects.
    allPontos.sort((a, b) => b.data.compareTo(a.data));
    return allPontos;
  }

  void _calcularTempoRestante() async {
    final jornada = await _jornadaFuture;
    final pontosDoMes = await _pontosFuture;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final pontos = pontosDoMes.where((p) => p.data == today).toList();

    if (jornada == null) {
      setState(() {
        _tempoRestante = Duration.zero;
      });
      return;
    }

    Duration totalJornada = _calcularTotalJornada(jornada);
    Duration tempoTrabalhado = Duration.zero;
    DateTime? ultimaEntrada;

    if (pontos.isNotEmpty) {
      // Backend sends descending, reverse to process chronologically.
      final registros = pontos.first.registros.reversed.toList();
      for (int i = 0; i < registros.length; i++) {
        final registro = registros[i];
        final parsedTime = DateFormat('HH:mm:ss').parse(registro['time']);
        final now = DateTime.now();
        final dateTimeRegistro = DateTime(now.year, now.month, now.day, parsedTime.hour, parsedTime.minute, parsedTime.second);

        if (i % 2 == 0) { // Entrada
          ultimaEntrada = dateTimeRegistro;
        } else { // Saida
          if (ultimaEntrada != null) {
            tempoTrabalhado += dateTimeRegistro.difference(ultimaEntrada);
            ultimaEntrada = null;
          }
        }
      }
    }

    Duration restante = totalJornada - tempoTrabalhado;

    if (ultimaEntrada != null) {
      _trabalhando = true;
      // Subtract time already passed in the current work session
      restante -= DateTime.now().difference(ultimaEntrada);
    } else {
      _trabalhando = false;
    }

    setState(() {
      _tempoRestante = restante.isNegative ? Duration.zero : restante;
    });
  }

  Duration _calcularTotalJornada(Jornada jornada) {
    Duration total = Duration.zero;
    if (jornada.horario_entrada != null && jornada.horario_saida != null) {
      final entrada = TimeOfDay.fromDateTime(DateFormat('HH:mm:ss').parse(jornada.horario_entrada!));
      final saida = TimeOfDay.fromDateTime(DateFormat('HH:mm:ss').parse(jornada.horario_saida!));
      final now = DateTime.now();
      final entradaDT = DateTime(now.year, now.month, now.day, entrada.hour, entrada.minute);
      final saidaDT = DateTime(now.year, now.month, now.day, saida.hour, saida.minute);
      total += saidaDT.difference(entradaDT);
    }
    if (jornada.horario_saida_intervalo != null && jornada.horario_retorno_intervalo != null) {
      final saidaIntervalo = TimeOfDay.fromDateTime(DateFormat('HH:mm:ss').parse(jornada.horario_saida_intervalo!));
      final retornoIntervalo = TimeOfDay.fromDateTime(DateFormat('HH:mm:ss').parse(jornada.horario_retorno_intervalo!));
      final now = DateTime.now();
      final saidaIntervaloDT = DateTime(now.year, now.month, now.day, saidaIntervalo.hour, saidaIntervalo.minute);
      final retornoIntervaloDT = DateTime(now.year, now.month, now.day, retornoIntervalo.hour, retornoIntervalo.minute);
      total -= retornoIntervaloDT.difference(saidaIntervaloDT);
    }
    return total;
  }

  void _iniciarContador() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_trabalhando && _tempoRestante > Duration.zero) {
        setState(() {
          _tempoRestante -= const Duration(seconds: 1);
        });
      } else if (_tempoRestante <= Duration.zero) {
        timer.cancel();
      }
    });
  }

  String _formatarDuracao(Duration duration) {
    String doisDigitos(int n) => n.toString().padLeft(2, '0');
    String doisDigitosHoras = doisDigitos(duration.inHours);
    String doisDigitosMinutos = doisDigitos(duration.inMinutes.remainder(60));
    String doisDigitosSegundos = doisDigitos(duration.inSeconds.remainder(60));
    return "$doisDigitosHoras:$doisDigitosMinutos:$doisDigitosSegundos";
  }


  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Saída'),
          content: const Text('Você tem certeza que deseja sair?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                AnalyticsService.recordButtonClick('logout_cancel_button', pageName: '/employee/home');
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sair', style: TextStyle(color: Colors.red)),
              onPressed: () {
                AnalyticsService.recordButtonClick('logout_confirm_button', pageName: '/employee/home');
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen(), settings: const RouteSettings(name: '/login')),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildSearchAppBar(
        context,
        onMeuCadastro: () {
          _funcionarioFuture.then((funcionario) {
            AnalyticsService.recordButtonClick('edit_employee_from_home_button', pageName: '/employee/home');
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EmployeeRegistrationScreen(
                  idEmpresa: widget.idEmpresa,
                  colaborador: funcionario,
                ),
                settings: const RouteSettings(name: '/employee/registration'),
              ),
            );
          });
        },
        onSair: _showLogoutConfirmationDialog,
        onDbStatus: () {
          AnalyticsService.recordButtonClick('db_status_from_home_button', pageName: '/employee/home');
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const DatabaseStatusScreen(), settings: const RouteSettings(name: '/db-status')),
          );
        },
      ),
      body: FutureBuilder<Colaborador>(
        future: _funcionarioFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          } else if (snapshot.hasData) {
            final funcionario = snapshot.data!;
            return buildSearchableBody(
              context,
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShortcuts(funcionario),
                      const SizedBox(height: 24),
                      _buildWelcomeCard(funcionario),
                      const SizedBox(height: 24),
                      const Text('Últimos registros', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 16),
                      _buildRecentRecords(),
                      const SizedBox(height: 24),
                      _buildClockInCard(),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const Center(child: Text('Nenhum dado encontrado.'));
          }
        },
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }

  Widget _buildShortcuts(Colaborador funcionario) {
    return ShortcutsWidget(
      selectedIndex: _selectedShortcutIndex,
      onIndexChanged: (index) async {
        if (index == 1) { // Tapped "Meu RH"
          AnalyticsService.recordButtonClick('my_hr_shortcut', pageName: '/employee/home');
          setState(() {
            _selectedShortcutIndex = 1;
          });
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyHrScreen(colaborador: funcionario), settings: const RouteSettings(name: '/employee/my-hr')),
          );
          // When we come back, reset the index
          setState(() {
            _selectedShortcutIndex = 0;
          });
        } else if (index == 2) { // Tapped "Holerite"
            AnalyticsService.recordButtonClick('payslip_shortcut', pageName: '/employee/home');
            setState(() {
              _selectedShortcutIndex = 2;
            });
            // TODO: tela Holerite
        } else {
          setState(() {
            _selectedShortcutIndex = index;
          });
        }
      },
    );
  }

  Widget _buildWelcomeCard(Colaborador funcionario) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Center(
        child: Text(
          'Olá, ${funcionario.nome}.\nVocê possui pendências de ponto.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildRecentRecords() {
    return FutureBuilder<List<Ponto>>(
      future: _pontosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar registros.'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nenhum registro encontrado.'));
        }

        final ultimosRegistros = _getUltimosRegistrosFormatados(snapshot.data!);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ultimosRegistros.map((registro) {
            return _buildRecordCard(
              time: registro['time']!,
              type: registro['type']!,
              day: registro['day']!,
            );
          }).toList(),
        );
      },
    );
  }

  List<Map<String, String>> _getUltimosRegistrosFormatados(List<Ponto> pontos) {
    final List<Map<String, String>> formatados = [];

    for (var ponto in pontos) { // Iterates from most recent day
      final totalRegistrosNoDia = ponto.registros.length;

      for (int i = 0; i < totalRegistrosNoDia; i++) { // Iterates from most recent record of the day
        if (formatados.length >= 4) {
          return formatados; // Stop when we have 4 records
        }

        final registro = ponto.registros[i];
        final String dataStr = ponto.data;
        final DateTime dataRegistro = DateFormat('yyyy-MM-dd').parse(dataStr);
        final DateTime now = DateTime.now();
        final DateTime today = DateTime(now.year, now.month, now.day);
        final DateTime yesterday = today.subtract(const Duration(days: 1));

        String diaFormatado;
        if (dataRegistro.isAtSameMomentAs(today)) {
          diaFormatado = 'Hoje';
        } else if (dataRegistro.isAtSameMomentAs(yesterday)) {
          diaFormatado = 'Ontem';
        } else {
          diaFormatado = DateFormat('dd/MM').format(dataRegistro);
        }

        // The type is based on chronological order (1st, 2nd, 3rd...)
        // Since records are sorted descending, index `i` corresponds to the (total - i)-th record.
        final ordemCronologica = totalRegistrosNoDia - i;
        final tipo = ordemCronologica % 2 != 0 ? 'Entrada' : 'Saída';

        formatados.add({
          'time': DateFormat('HH:mm').format(DateFormat('HH:mm:ss').parse(registro['time'])),
          'type': tipo,
          'day': diaFormatado,
        });
      }
    }

    return formatados;
  }

  Widget _buildRecordCard({required String time, required String type, required String day}) {
    return Card(
      elevation: 2.0, // Add some elevation for the card effect
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)), // Match the border radius
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          // Remove color and borderRadius from Container as Card will handle it
          // color: Colors.white,
          // borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          children: [
            Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(type),
            const SizedBox(height: 4),
            Text(day, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildClockInCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        children: [
          Text(_currentTime, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          AnalyticsButton(
            buttonId: 'clock_in_button',
            onPressed: _handleClockIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Bater ponto'),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Contador de Jornada'),
              Text(_formatarDuracao(_tempoRestante), style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Future<void> _handleClockIn() async {
    print("Iniciando processo de bater ponto...");

    try {
      // Fetch allowed location
      final localizacaoResponse = await http.get(Uri.parse('${ApiConfig.baseUrl}/localizacoes/funcionario/${widget.idFuncionario}'));

      Localizacao? localizacao;
      if (localizacaoResponse.statusCode == 200) {
        final data = jsonDecode(localizacaoResponse.body);
        if (data['localizacao'] != null) {
          localizacao = Localizacao.fromJson(data['localizacao']);
        }
      }

      final Position position = await _determinePosition();

      print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');

      // Check distance if location is restricted
      if (localizacao != null) {
        final double distance = Geolocator.distanceBetween(
          localizacao.latitude,
          localizacao.longitude,
          position.latitude,
          position.longitude,
        );

        if (distance > localizacao.raio_permitido) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Local de registro diverge do local esperado. Entre em contato com o seu empregador.')),
            );
          }
          return;
        }
      }

      // Proceed with clock-in
      if (!mounted) return;

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/ponto/${widget.idFuncionario}'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(<String, dynamic>{
          'latitude': position.latitude,
          'longitude': position.longitude,
        }),
      );

      if (mounted) {
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ponto registrado com sucesso!')),
          );
          // Refresh data
          setState(() {
            _pontosFuture = _fetchLastPontos();
          });
          await _pontosFuture;
          _calcularTempoRestante();
          _iniciarContador();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Falha ao registrar o ponto: ${response.body}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao registrar o ponto: $e')),
        );
      }
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Serviço de localização desabilitado.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de localização negada.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permissão negada permanentemente. Habilite nas configurações.');
    }

    final completer = Completer<Position>();
    StreamSubscription<Position>? positionStream;

    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    ).listen((Position newPosition) {
      if (!completer.isCompleted) {
        completer.complete(newPosition);
        positionStream?.cancel();
      }
    });

    // Timeout to avoid waiting forever
    Future.delayed(const Duration(seconds: 10), () {
      if (!completer.isCompleted) {
        completer.completeError('Timeout para obter a localização.');
        positionStream?.cancel();
      }
    });

    return completer.future;
  }
}
