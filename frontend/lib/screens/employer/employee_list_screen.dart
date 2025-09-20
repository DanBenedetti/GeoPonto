import 'package:flutter/material.dart';
import 'package:geoponto/screens/employer/employee_registration_screen.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  // Mock data moved to a state variable to allow modification
  final List<Map<String, String>> _employees = [
    {'name': 'Fabiana Oliveira', 'position': 'Desenvolvedora Frontend'},
    {'name': 'Carlos Souza', 'position': 'Designer UX/UI'},
    {'name': 'Beatriz Lima', 'position': 'Gerente de Projetos'},
    {'name': 'Ricardo Alves', 'position': 'Desenvolvedor Backend'},
  ];

  void _navigateAndRefresh() async {
    // Navigate to the registration screen and wait for it to pop
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EmployeeRegistrationScreen()),
    );

    // When the registration screen pops, we simulate a refresh
    // by adding a new employee to the list and rebuilding the widget.
    // In a real app, you would refetch the list from the API.
    if (result != null || true) { // Assuming a successful registration, refresh
      setState(() {
        // Add a new mock employee to demonstrate the refresh
        _employees.add({'name': 'Novo Colaborador', 'position': 'Cargo Definido'});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Funcionários Cadastrados'),
      ),
      body: ListView.builder(
        itemCount: _employees.length,
        itemBuilder: (context, index) {
          final employee = _employees[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(employee['name']![0]), // First letter of the name
              ),
              title: Text(employee['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(employee['position']!),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
                    onPressed: () {
                      // Logic to edit employee data would go here
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () {
                      // Logic to delete employee would go here
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateAndRefresh,
        child: const Icon(Icons.add),
      ),
    );
  }
}
