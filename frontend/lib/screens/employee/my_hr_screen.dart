import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geoponto/mixins/search_mixin.dart';
import 'package:geoponto/models/colaborador.dart';
import 'package:geoponto/screens/employee/absences_screen.dart';
import 'package:geoponto/screens/employer/employee_point_screen.dart';
import 'package:geoponto/screens/employee/occurrences_screen.dart';
import 'package:geoponto/components/app_bottom_nav_bar.dart';
import 'package:geoponto/components/shortcuts_widget.dart';
import 'package:geoponto/screens/employee/requests_screen.dart';
import 'package:geoponto/screens/employee/point_mirror_screen.dart';
import 'package:geoponto/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:geoponto/services/analytics_service.dart';
import 'package:geoponto/mixins/render_time_mixin.dart';

import 'package:geoponto/screens/employer/employee_registration_screen.dart';
import 'package:geoponto/screens/login_screen.dart';
import 'package:geoponto/screens/status_database/status.dart';

class MyHrScreen extends StatefulWidget {
  final Colaborador colaborador;

  const MyHrScreen({super.key, required this.colaborador});

  @override
  State<MyHrScreen> createState() => _MyHrScreenState();
}

class _MyHrScreenState extends State<MyHrScreen> with SearchMixin<MyHrScreen>, RenderTimeMixin<MyHrScreen> {
  int _selectedIndex = 1; // 0: Menu, 1: Início, 2: Ajustes
  int _selectedShortcutIndex = 1; // 0: Bater Ponto, 1: Meu RH, 2: Holerite
  int _absenceCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchAbsenceCount();
  }

  Future<void> _fetchAbsenceCount() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/funcionarios/${widget.colaborador.id_funcionario}/faltas'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _absenceCount = List<String>.from(data['faltas']).length;
        });
      } else {
        // Handle error, maybe show a toast or a default value
      }
    } catch (e) {
      // Handle error
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
                AnalyticsService.recordButtonClick('logout_cancel_button', pageName: '/employee/my-hr');
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sair', style: TextStyle(color: Colors.red)),
              onPressed: () {
                AnalyticsService.recordButtonClick('logout_confirm_button', pageName: '/employee/my-hr');
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
        automaticallyImplyLeading: false,
        onMeuCadastro: () {
          AnalyticsService.recordButtonClick('edit_employee_from_my_hr_button', pageName: '/employee/my-hr');
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EmployeeRegistrationScreen(
                idEmpresa: widget.colaborador.id_empresa!,
                colaborador: widget.colaborador,
              ),
              settings: const RouteSettings(name: '/employee/registration'),
            ),
          );
        },
        onSair: _showLogoutConfirmationDialog,
        onDbStatus: () {
          AnalyticsService.recordButtonClick('db_status_from_my_hr_button', pageName: '/employee/my-hr');
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const DatabaseStatusScreen(), settings: const RouteSettings(name: '/db-status')),
          );
        },
      ),
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
            AnalyticsService.recordButtonClick('bottom_nav_home', pageName: '/employee/my-hr');
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
        if (index == 0) { // selecionado "Bater ponto"
          AnalyticsService.recordButtonClick('clock_in_shortcut_from_my_hr', pageName: '/employee/my-hr');
          Navigator.pop(context);
        } else if (index == 2) { // selecionado "Holerite"
            AnalyticsService.recordButtonClick('payslip_shortcut_from_my_hr', pageName: '/employee/my-hr');
            setState(() {
              _selectedShortcutIndex = 2;
            });
            // TODO: Tela e lógica do botão Holerite, no momento não serão implementadas
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
          count: _absenceCount.toString().padLeft(2, '0'),
          onTap: () {
            AnalyticsService.recordButtonClick('absences_button', pageName: '/employee/my-hr');
            Navigator.push(context, MaterialPageRoute(builder: (context) => AbsencesScreen(idFuncionario: widget.colaborador.id_funcionario!), settings: const RouteSettings(name: '/employee/absences')));
          }
        ),
        const SizedBox(height: 12),
        _buildPendenciaItem(
          title: 'Ocorrências', 
          count: '02',
          onTap: () {
            AnalyticsService.recordButtonClick('occurrences_button', pageName: '/employee/my-hr');
            Navigator.push(context, MaterialPageRoute(builder: (context) => const OccurrencesScreen(), settings: const RouteSettings(name: '/employee/occurrences')));
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
                AnalyticsService.recordButtonClick('my_point_button', pageName: '/employee/my-hr');
                Navigator.push(context, MaterialPageRoute(builder: (context) => EmployeePointScreen(colaborador: widget.colaborador), settings: const RouteSettings(name: '/employee/point')));
              }
            ),
            _buildControlePontoItem(
              icon: Icons.chat_bubble_outline, 
              label: 'Solicitações',
              onTap: () {
                AnalyticsService.recordButtonClick('requests_button', pageName: '/employee/my-hr');
                Navigator.push(context, MaterialPageRoute(builder: (context) => RequestsScreen(), settings: const RouteSettings(name: '/employee/requests')));
              }
            ),
            _buildControlePontoItem(
              icon: Icons.file_copy_outlined, 
              label: 'Espelho ponto',
              onTap: () {
                 AnalyticsService.recordButtonClick('point_mirror_button', pageName: '/employee/my-hr');
                 Navigator.push(context, MaterialPageRoute(builder: (context) => PointMirrorScreen(), settings: const RouteSettings(name: '/employee/point-mirror')));
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