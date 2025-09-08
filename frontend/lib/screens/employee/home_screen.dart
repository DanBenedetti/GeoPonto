import 'package:flutter/material.dart';
import 'package:geoponto/screens/employee/my_hr_screen.dart';

class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  int _selectedIndex = 1; // Home is selected by default
  int _selectedShortcutIndex = 0; // 0: Bater Ponto, 1: Meu RH, 2: Holerite

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
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
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      title: TextField(
        decoration: InputDecoration(
          hintText: 'Pesquisar...', 
          hintStyle: TextStyle(color: Colors.white70),
          prefixIcon: Icon(Icons.search, color: Colors.white),
          border: InputBorder.none,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.person_outline, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildShortcuts() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildShortcutItem(
          icon: Icons.touch_app_outlined,
          label: 'Bater ponto',
          isSelected: _selectedShortcutIndex == 0,
          onTap: () async {
            setState(() {
              _selectedShortcutIndex = 0;
            });
            // TODO: Navegar para a tela de Bater Ponto (se for uma tela separada)
            // await Navigator.push(context, MaterialPageRoute(builder: (context) => const BaterPontoScreen()));
            // setState(() { _selectedShortcutIndex = 0; }); // Reset if needed
          },
        ),
        _buildShortcutItem(
          icon: Icons.work_outline,
          label: 'Meu RH',
          isSelected: _selectedShortcutIndex == 1,
          onTap: () async {
            setState(() {
              _selectedShortcutIndex = 1;
            });
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyHrScreen()),
            );
            setState(() {
              _selectedShortcutIndex = 0; // Reset to 'Bater Ponto' when returning
            });
          },
        ),
        _buildShortcutItem(
          icon: Icons.receipt_long_outlined,
          label: 'Holerite',
          isSelected: _selectedShortcutIndex == 2,
          onTap: () async {
            setState(() {
              _selectedShortcutIndex = 2;
            });
            // TODO: Navegar para a tela de Holerite
            // await Navigator.push(context, MaterialPageRoute(builder: (context) => const HoleriteScreen()));
            // setState(() { _selectedShortcutIndex = 0; }); // Reset if needed
          },
        ),
      ],
    );
  }

  Widget _buildShortcutItem({required IconData icon, required String label, required VoidCallback onTap, required bool isSelected}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: isSelected ? Theme.of(context).primaryColor.withOpacity(0.7) : const Color(0xFFE0E0E0),
            child: Icon(icon, size: 30, color: isSelected ? Colors.white : Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
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

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.menu),
          label: 'Menu',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Início',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          label: 'Ajustes',
        ),
      ],
    );
  }
}
