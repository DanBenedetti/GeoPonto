import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geoponto/config/api_config.dart';
import 'package:geoponto/models/colaborador.dart';
import 'package:geoponto/screens/employer/employee_point_screen.dart';
import 'package:geoponto/screens/employer/employee_registration_screen.dart';
import 'package:geoponto/screens/employer/jornada_screen.dart';
import 'package:http/http.dart' as http;
import 'package:geoponto/services/analytics_service.dart';

class EmployeeListScreen extends StatefulWidget {
  final int idEmpresa;
  const EmployeeListScreen({super.key, required this.idEmpresa});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  late Future<List<Colaborador>> _employeesFuture;

  @override
  void initState() {
    super.initState();
    _employeesFuture = _fetchEmployees();
  }

  Future<List<Colaborador>> _fetchEmployees() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/funcionarios?id_empresa=${widget.idEmpresa}'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> employeeList = data['funcionarios'];
      // Filter out employees with status = false
      return employeeList
          .map((json) => Colaborador.fromJson(json))
          .where((c) => c.status ?? true)
          .toList();
    } else {
      throw Exception('Failed to load employees');
    }
  }

  Future<void> _deleteEmployee(int employeeId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/funcionarios/$employeeId'),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Funcionário excluído com sucesso!')),
        );
        // Refresh the list
        setState(() {
          _employeesFuture = _fetchEmployees();
        });
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao excluir funcionário: ${errorData['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão: $e')),
      );
    }
  }

  void _showDeleteConfirmationDialog(Colaborador employee) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Você tem certeza que deseja excluir o funcionário ${employee.nome} ${employee.sobrenome ?? ''}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                AnalyticsService.recordButtonClick('delete_employee_cancel', pageName: '/employer/employee-list');
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
              onPressed: () {
                AnalyticsService.recordButtonClick('delete_employee_confirm', pageName: '/employer/employee-list');
                Navigator.of(context).pop();
                _deleteEmployee(employee.id_funcionario!);
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
        title: const Text('Funcionários Cadastrados'),
      ),
      body: FutureBuilder<List<Colaborador>>(
        future: _employeesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum funcionário cadastrado.'));
          } else {
            final employees = snapshot.data!;
            return ListView.builder(
              itemCount: employees.length,
              itemBuilder: (context, index) {
                final employee = employees[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(employee.nome.isNotEmpty ? employee.nome[0] : ' '),
                    ),
                    title: Text('${employee.nome} ${employee.sobrenome ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(employee.cargo ?? ''),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'jornada') {
                          AnalyticsService.recordButtonClick('view_journey_button', pageName: '/employer/employee-list');
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => JornadaScreen(
                                colaborador: employee,
                              ),
                              settings: const RouteSettings(name: '/employer/journey'),
                            ),
                          );
                        } else if (value == 'editar') {
                          AnalyticsService.recordButtonClick('edit_employee_button', pageName: '/employer/employee-list');
                          Navigator.of(context)
                              .push(
                            MaterialPageRoute(
                              builder: (context) => EmployeeRegistrationScreen(
                                idEmpresa: widget.idEmpresa,
                                colaborador: employee,
                              ),
                              settings: const RouteSettings(name: '/employer/registration'),
                            ),
                          )
                              .then((_) {
                            setState(() {
                              _employeesFuture = _fetchEmployees();
                            });
                          });
                        } else if (value == 'excluir') {
                          AnalyticsService.recordButtonClick('delete_employee_button', pageName: '/employer/employee-list');
                          _showDeleteConfirmationDialog(employee);
                        } else if (value == 'ver_ponto') {
                          AnalyticsService.recordButtonClick('view_point_button', pageName: '/employer/employee-list');
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EmployeePointScreen(
                                colaborador: employee,
                              ),
                              settings: const RouteSettings(name: '/employer/employee-point'),
                            ),
                          );
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'jornada',
                          child: Text('Jornada'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'editar',
                          child: Text('Alterar Dados'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'ver_ponto',
                          child: Text('Ver Ponto'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'excluir',
                          child: Text('Excluir'),
                        ),
                      ],
                      icon: const Icon(Icons.menu),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}