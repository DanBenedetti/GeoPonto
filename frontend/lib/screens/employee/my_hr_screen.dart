import 'package:flutter/material.dart';
import 'package:geoponto/mixins/search_mixin.dart';
import 'package:geoponto/screens/employee/absences_screen.dart';
import 'package:geoponto/screens/employee/my_point_screen.dart';
import 'package:geoponto/screens/employee/occurrences_screen.dart';
import 'package:geoponto/screens/employee/point_mirror_screen.dart';
import 'package:geoponto/screens/employee/requests_screen.dart';
import 'package:geoponto/widgets/app_bottom_nav_bar.dart';
import 'package:geoponto/widgets/shortcuts_widget.dart';

class MyHrScreen extends StatefulWidget {
  const MyHrScreen({super.key});

  @override
  State<MyHrScreen> createState() => _MyHrScreenState();
}

class _MyHrScreenState extends State<MyHrScreen> with SearchMixin<MyHrScreen> {
  int _selectedIndex = 1; // 0: Menu, 1: Início, 2: Ajustes
  int _selectedShortcutIndex = 1; // 0: Bater Ponto, 1: Meu RH, 2: Holerite

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildSearchAppBar(context, automaticallyImplyLeading: false),
      body: buildSearchableBody(
        context,
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShortcuts(),
                const SizedBox(height: 32),
                _buildPendenciasSection(),
                const SizedBox(height: 32),
                _buildControlePontoSection(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          if (index == 1 && _selectedIndex != 1) {
            Navigator.pop(context);
          } else {
            setState(() => _selectedIndex = index);
          }
        },
      ),
    );
  }

  Widget _buildShortcuts() {
    return ShortcutsWidget(
      selectedIndex: _selectedShortcutIndex,
      onIndexChanged: (index) {
        if (index == 0) { // Tapped "Bater ponto"
          Navigator.pop(context);
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

  Widget _buildPendenciasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Pendências', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Últimos 30 dias', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 16),
        _buildPendenciaItem(
          title: 'Faltas', 
          count: '01',
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AbsencesScreen()));
          }
        ),
        const SizedBox(height: 12),
        _buildPendenciaItem(
          title: 'Ocorrências', 
          count: '02',
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const OccurrencesScreen()));
          }
        ),
      ],
    );
  }

  Widget _buildPendenciaItem({required String title, required String count, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.yellow[700],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(count, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlePontoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Controle de ponto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildControlePontoItem(
              icon: Icons.timer_outlined, 
              label: 'Meu ponto',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MyPointScreen()));
              }
            ),
            _buildControlePontoItem(
              icon: Icons.chat_bubble_outline, 
              label: 'Solicitações',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const RequestsScreen()));
              }
            ),
            _buildControlePontoItem(
              icon: Icons.file_copy_outlined, 
              label: 'Espelho ponto',
              onTap: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context) => const PointMirrorScreen()));
              }
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControlePontoItem({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15.0),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}