import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geoponto/config/api_config.dart';
import 'package:geoponto/models/ocorrencia.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class OccurrencesScreen extends StatefulWidget {
  final int idFuncionario;

  const OccurrencesScreen({super.key, required this.idFuncionario});

  @override
  State<OccurrencesScreen> createState() => _OccurrencesScreenState();
}

class _OccurrencesScreenState extends State<OccurrencesScreen> {
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
        Uri.parse('${ApiConfig.baseUrl}/ocorrencias/funcionario/${widget.idFuncionario}'),
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
      // Erro silencioso ou SnackBar
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ocorrências'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _ocorrencias.isEmpty
              ? const Center(child: Text('Nenhuma ocorrência registrada.'))
              : RefreshIndicator(
                  onRefresh: _fetchOcorrencias,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _ocorrencias.length,
                    itemBuilder: (context, index) {
                      final oc = _ocorrencias[index];
                      return _buildOccurrenceItem(context, oc);
                    },
                  ),
                ),
    );
  }

  Widget _buildOccurrenceItem(BuildContext context, Ocorrencia oc) {
    final date = DateTime.parse(oc.data_ocorrencia);
    final formattedDate = DateFormat('dd/MM/yyyy | EEEE', 'pt_BR').format(date);
    
    Color statusColor = Colors.orange;
    if (oc.status == 'Aprovado') statusColor = Colors.green;
    if (oc.status == 'Reprovado') statusColor = Colors.red;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        leading: Icon(
          oc.status == 'Aprovado' ? Icons.check_circle_outline : Icons.warning_amber_rounded, 
          color: statusColor, 
          size: 32
        ),
        title: Text(formattedDate, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(oc.tipo),
            Text(
              oc.status,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Detalhes se necessário
        },
        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      ),
    );
  }
}
