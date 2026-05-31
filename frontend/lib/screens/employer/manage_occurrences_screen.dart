import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geoponto/config/api_config.dart';
import 'package:geoponto/models/ocorrencia.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ManageOccurrencesScreen extends StatefulWidget {
  final int idEmpresa;

  const ManageOccurrencesScreen({super.key, required this.idEmpresa});

  @override
  State<ManageOccurrencesScreen> createState() => _ManageOccurrencesScreenState();
}

class _ManageOccurrencesScreenState extends State<ManageOccurrencesScreen> {
  List<Ocorrencia> _ocorrencias = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOcorrencias();
  }

  Future<void> _fetchOcorrencias() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/ocorrencias/empresa/${widget.idEmpresa}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _ocorrencias = data.map((json) => Ocorrencia.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar ocorrências: $e')),
      );
    }
  }

  Future<void> _updateStatus(int idOcorrencia, String status) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/ocorrencias/$idOcorrencia/status'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ocorrência $status com sucesso!')),
        );
        _fetchOcorrencias();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Ocorrências'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _ocorrencias.isEmpty
              ? const Center(child: Text('Nenhuma ocorrência encontrada.'))
              : RefreshIndicator(
                  onRefresh: _fetchOcorrencias,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _ocorrencias.length,
                    itemBuilder: (context, index) {
                      final oc = _ocorrencias[index];
                      return _buildOccurrenceCard(oc);
                    },
                  ),
                ),
    );
  }

  Widget _buildOccurrenceCard(Ocorrencia oc) {
    final date = DateTime.parse(oc.data_ocorrencia);
    final formattedDate = DateFormat('dd/MM/yyyy').format(date);
    
    Color statusColor = Colors.orange;
    if (oc.status == 'Aprovado') statusColor = Colors.green;
    if (oc.status == 'Rejeitado') statusColor = Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${oc.nome_funcionario} ${oc.sobrenome_funcionario}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    oc.status,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const Divider(),
            _buildDetailRow('Data:', formattedDate),
            _buildDetailRow('Tipo:', oc.tipo),
            _buildDetailRow('Descrição:', oc.descricao ?? 'Sem descrição'),
            const SizedBox(height: 16),
            if (oc.status == 'Pendente')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _updateStatus(oc.id_ocorrencia!, 'Rejeitado'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Reprovar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _updateStatus(oc.id_ocorrencia!, 'Aprovado'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    child: const Text('Aprovar'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
