import 'package:flutter/material.dart';
import 'package:geoponto/models/colaborador.dart';

class EmployeeListScreen extends StatefulWidget {
  final List<Colaborador> employees;

  const EmployeeListScreen({super.key, required this.employees});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  late List<Colaborador> _employees;

  @override
  void initState() {
    super.initState();
    _employees = List.from(widget.employees); 
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
                child: Text(employee.nome[0]),
              ),
              title: Text(employee.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(employee.cargo),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
                    onPressed: () {
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () {
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
