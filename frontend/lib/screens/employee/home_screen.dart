import 'dart:async';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geoponto/config/api_config.dart';
import 'package:geoponto/mixins/search_mixin.dart';
import 'package:geoponto/models/colaborador.dart';
import 'package:geoponto/models/localizacao.dart';
import 'package:geoponto/screens/employee/my_hr_screen.dart';
import 'package:geoponto/widgets/app_bottom_nav_bar.dart';
import 'package:geoponto/widgets/shortcuts_widget.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

import 'package:geoponto/screens/employer/employee_registration_screen.dart';
import 'package:geoponto/screens/login_screen.dart';

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

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> with SearchMixin<EmployeeHomeScreen> {
  late Future<Colaborador> _funcionarioFuture;
  late String _currentTime;
  late Timer _timer;
  int _selectedIndex = 1; // Home is selected by default
  int _selectedShortcutIndex = 0; // 0: Bater Ponto, 1: Meu RH, 2: Holerite

  @override
  void initState() {
    super.initState();
    _funcionarioFuture = _fetchFuncionario();
    _updateTime(); // Set initial time
    _timer = Timer.periodic(const Duration(minutes: 1), (Timer t) => _updateTime());
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer to prevent memory leaks
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
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sair', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
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
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EmployeeRegistrationScreen(
                  idEmpresa: widget.idEmpresa,
                  colaborador: funcionario,
                ),
              ),
            );
          });
        },
        onSair: _showLogoutConfirmationDialog,
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
                      _buildShortcuts(),
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

  Widget _buildShortcuts() {
    return ShortcutsWidget(
      selectedIndex: _selectedShortcutIndex,
      onIndexChanged: (index) async {
        if (index == 1) { // Tapped "Meu RH"
          setState(() {
            _selectedShortcutIndex = 1;
          });
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyHrScreen()),
          );
          // When we come back, reset the index
          setState(() {
            _selectedShortcutIndex = 0;
          });
        } else if (index == 2) { // Tapped "Holerite"
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildRecordCard(time: '07:59', type: 'Entrada', day: 'Hoje'),
        _buildRecordCard(time: '17:20', type: 'Saída', day: 'Ontem'),
        _buildRecordCard(time: '12:30', type: 'Entrada', day: 'Ontem'),
        _buildRecordCard(time: '12:00', type: 'Saída', day: 'Ontem'),
      ],
    );
  }

  Widget _buildRecordCard({required String time, required String type, required String day}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text(type),
          const SizedBox(height: 4),
          Text(day, style: const TextStyle(color: Colors.grey)),
        ],
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
          ElevatedButton(
            onPressed: _handleClockIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Bater ponto'),
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Contador de Jornada'),
              Text('03:58h', style: TextStyle(fontWeight: FontWeight.bold)),
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
