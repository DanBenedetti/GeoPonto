import 'package:flutter/material.dart';
import 'package:geoponto/mixins/search_mixin.dart';
import 'package:geoponto/screens/employee/my_hr_screen.dart';
import 'package:geoponto/widgets/app_bottom_nav_bar.dart';
import 'package:geoponto/widgets/shortcuts_widget.dart';

class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> with SearchMixin<EmployeeHomeScreen> {
  int _selectedIndex = 1; // Home is selected by default
  int _selectedShortcutIndex = 0; // 0: Bater Ponto, 1: Meu RH, 2: Holerite

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildSearchAppBar(context),
      body: buildSearchableBody(
        context,
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShortcuts(),
                const SizedBox(height: 24),
                _buildWelcomeCard(),
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
            // TODO: Navigate to Holerite screen
        } else {
          setState(() {
            _selectedShortcutIndex = index;
          });
        }
      },
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: const Center(
        child: Text(
          'Olá, Fabiana. \nVocê possui pendências de ponto.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
          const Text('12:01 | 25 agosto, 2025', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
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
}