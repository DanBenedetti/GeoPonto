import 'package:flutter/material.dart';
import 'package:geoponto/models/colaborador.dart';
import 'package:geoponto/screens/employer/employee_list_screen.dart';
import 'package:geoponto/screens/employer/employee_registration_screen.dart';

import 'package:geoponto/screens/login_screen.dart';

class EmployerDashboardScreen extends StatefulWidget {
  final int idEmpresa;

  const EmployerDashboardScreen({super.key, required this.idEmpresa});

  @override
  State<EmployerDashboardScreen> createState() => _EmployerDashboardScreenState();
}

class _EmployerDashboardScreenState extends State<EmployerDashboardScreen> {
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
      appBar: AppBar(
        title: const Text('Painel do Empregador'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutConfirmationDialog,
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
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => EmployeeRegistrationScreen(idEmpresa: widget.idEmpresa)),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildDashboardCard(
              context,
              icon: Icons.people_outline,
              title: 'Visualizar / Editar Funcionários',
              onTap: () {
                 Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => EmployeeListScreen(idEmpresa: widget.idEmpresa)),
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
