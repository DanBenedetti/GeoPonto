import 'package:flutter/material.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  // Mock data - in a real app, this would come from an API
  final List<Map<String, String>> employees = [
    {'name': 'Fabiana Oliveira', 'position': 'Desenvolvedora Frontend'},
    {'name': 'Carlos Souza', 'position': 'Designer UX/UI'},
    {'name': 'Beatriz Lima', 'position': 'Gerente de Projetos'},
    {'name': 'Ricardo Alves', 'position': 'Desenvolvedor Backend'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Funcionários Cadastrados'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: employees.length,
        itemBuilder: (context, index) {
          final employee = employees[index];
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
              trailing: IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  // Logic to edit employee data would go here
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
