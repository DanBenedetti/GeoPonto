import 'package:flutter/material.dart';
import 'package:geoponto/screens/employer/employee_list_screen.dart';
import 'package:geoponto/screens/employer/employee_registration_screen.dart';

import 'package:geoponto/screens/login_screen.dart';
import 'package:geoponto/services/analytics_service.dart';
import 'package:geoponto/mixins/render_time_mixin.dart';

class EmployerDashboardScreen extends StatefulWidget {
  final int idEmpresa;

  const EmployerDashboardScreen({super.key, required this.idEmpresa});

  @override
  State<EmployerDashboardScreen> createState() => _EmployerDashboardScreenState();
}

class _EmployerDashboardScreenState extends State<EmployerDashboardScreen> with RenderTimeMixin<EmployerDashboardScreen> {
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
                AnalyticsService.recordButtonClick('logout_cancel_button', pageName: '/employer/dashboard');
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sair', style: TextStyle(color: Colors.red)),
              onPressed: () {
                AnalyticsService.recordButtonClick('logout_confirm_button', pageName: '/employer/dashboard');
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
      appBar: AppBar(
        title: const Text('Painel do Empregador'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AnalyticsService.recordButtonClick('logout_icon_button', pageName: '/employer/dashboard');
              _showLogoutConfirmationDialog();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDashboardCard(
              context,
              icon: Icons.person_add_alt_1_outlined,
              title: 'Cadastrar Novo Funcionário',
              onTap: () {
                AnalyticsService.recordButtonClick('register_employee_card', pageName: '/employer/dashboard');
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => EmployeeRegistrationScreen(idEmpresa: widget.idEmpresa), settings: const RouteSettings(name: '/employer/registration')),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildDashboardCard(
              context,
              icon: Icons.people_outline,
              title: 'Gerir Funcionários',
              onTap: () {
                 AnalyticsService.recordButtonClick('manage_employees_card', pageName: '/employer/dashboard');
                 Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => EmployeeListScreen(idEmpresa: widget.idEmpresa), settings: const RouteSettings(name: '/employer/employee-list')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(icon, size: 60, color: Theme.of(context).primaryColor),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
