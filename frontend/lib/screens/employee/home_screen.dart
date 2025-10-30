import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geoponto/config/api_config.dart';
import 'package:geoponto/mixins/search_mixin.dart';
import 'package:geoponto/models/colaborador.dart';
import 'package:geoponto/screens/employee/my_hr_screen.dart';
import 'package:geoponto/widgets/app_bottom_nav_bar.dart';
import 'package:geoponto/widgets/shortcuts_widget.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildSearchAppBar(context),
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
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the 
      // App to enable the location services.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Serviço de localização desabilitado.')));
      }
      print("Serviço de localização desabilitado.");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      print("Permissão de localização negada, solicitando...");
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permissão de localização negada.')),
          );
        }
        print("Permissão de localização negada pelo usuário.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissão negada permanentemente. Habilite nas configurações.')),
        );
      }
      print("Permissão de localização negada permanentemente.");
      return;
    }

    print("Permissão concedida. Obtendo localização...");
    try {
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print("Localização obtida: Lat: ${position.latitude}, Lon: ${position.longitude}");

      if (!mounted) return;

      print("Enviando para o backend...");
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/ponto/${widget.idFuncionario}'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(<String, dynamic>{
          'latitude': position.latitude,
          'longitude': position.longitude,
        }),
      );

      print("Resposta do backend: ${response.statusCode}");

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
      print("Erro durante o processo de bater ponto: $e");
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao obter localização: $e')),
        );
      }
    }
  }


}
