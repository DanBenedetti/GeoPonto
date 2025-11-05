
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';

class DatabaseStatusScreen extends StatefulWidget {
  const DatabaseStatusScreen({super.key});

  @override
  State<DatabaseStatusScreen> createState() => _DatabaseStatusScreenState();
}

class _DatabaseStatusScreenState extends State<DatabaseStatusScreen> {
  late Future<Map<String, dynamic>> _dbStatusFuture;

  @override
  void initState() {
    super.initState();
    _dbStatusFuture = _fetchDbStatus();
  }

  Future<Map<String, dynamic>> _fetchDbStatus() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/db-status'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao carregar o status do banco de dados.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status do Banco de Dados'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>> (
        future: _dbStatusFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Nenhum dado encontrado.'));
          }

          final dbInfo = snapshot.data!;
          final List<dynamic> tables = dbInfo['tables'] ?? [];

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildInfoCard(
                title: 'Informações Gerais',
                children: [
                  ListTile(
                    title: const Text('Nome do Banco'),
                    subtitle: Text(dbInfo['database_name'] ?? 'N/A'),
                  ),
                  ListTile(
                    title: const Text('Status'),
                    subtitle: Text(
                      dbInfo['status'] ?? 'N/A',
                      style: TextStyle(
                        color: dbInfo['status'] == 'connected' ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                title: 'Tabelas e Registros',
                children: tables.map((table) {
                  return ListTile(
                    title: Text(table['table_name'] ?? 'N/A'),
                    trailing: Text('${table['record_count']} registros', style: const TextStyle(fontWeight: FontWeight.bold)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              _buildCodeCard(
                title: 'Exemplo DDL (CREATE TABLE)',
                code: dbInfo['ddl_example'] ?? 'N/A',
              ),
              const SizedBox(height: 16),
              _buildCodeCard(
                title: 'Exemplo DML (INSERT)',
                code: dbInfo['dml_example'] ?? 'N/A',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildCodeCard({required String title, required String code}) {
    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20, thickness: 1),
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey[200],
              width: double.infinity,
              child: Text(
                code,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
