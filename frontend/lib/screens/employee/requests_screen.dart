import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geoponto/config/api_config.dart';
import 'package:geoponto/screens/employee/point_details_screen.dart';
import 'package:geoponto/services/analytics_service.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RequestsScreen extends StatefulWidget {
  final int? idFuncionario;
  const RequestsScreen({super.key, this.idFuncionario});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  List<dynamic> _combinedRequests = [];
  bool _isLoading = true;
  int? _resolvedIdFuncionario;

  @override
  void initState() {
    super.initState();
    _resolvedIdFuncionario = widget.idFuncionario;
    _loadAndFetchAll();
  }

  Future<void> _loadAndFetchAll() async {
    if (_resolvedIdFuncionario == null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final storedId = prefs.getInt('id_funcionario');
        if (storedId != null) {
          setState(() {
            _resolvedIdFuncionario = storedId;
          });
        }
      } catch (_) {}
    }

    if (_resolvedIdFuncionario == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    await _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Buscar pendências dinâmicas (incluindo Faltas)
      final pendenciasResponse = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/funcionarios/$_resolvedIdFuncionario/pendencias'),
      );

      // 2. Buscar histórico de solicitações gravadas no banco
      final historyResponse = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/ocorrencias/funcionario/$_resolvedIdFuncionario/historico'),
      );

      List<dynamic> combined = [];

      // Processar Pendências (Ação Requerida)
      if (pendenciasResponse.statusCode == 200) {
        final List<dynamic> pendencias = jsonDecode(pendenciasResponse.body);
        combined.addAll(pendencias.map((p) => {
          'data_ocorrencia': p['data'],
          'tipo': p['tipo'],
          'descricao': p['descricao'],
          'status': 'Ação Requerida', // Status especial para pendências
          'is_dynamic': true,
        }));
      }

      // Processar Histórico (Registros do Banco)
      if (historyResponse.statusCode == 200) {
        final List<dynamic> history = jsonDecode(historyResponse.body);
        combined.addAll(history.map((h) => {
          ...h,
          'is_dynamic': false,
        }));
      }

      // Ordenar por data decrescente
      combined.sort((a, b) => b['data_ocorrencia'].compareTo(a['data_ocorrencia']));

      setState(() {
        _combinedRequests = combined;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Solicitações'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _resolvedIdFuncionario == null
              ? const Center(child: Text('Erro: ID do funcionário não localizado.'))
              : _combinedRequests.isEmpty
                  ? const Center(child: Text('Nenhuma solicitação ou pendência encontrada.'))
                  : RefreshIndicator(
                      onRefresh: _fetchAllData,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _combinedRequests.length,
                        itemBuilder: (context, index) {
                          final item = _combinedRequests[index];
                          final date = DateTime.parse(item['data_ocorrencia']);
                          final formattedDate = DateFormat('dd/MM/yyyy | EEEE', 'pt_BR').format(date);
                          
                          return _buildRequestItem(
                            context,
                            date: formattedDate,
                            status: item['status'],
                            type: item['tipo'],
                            description: item['descricao'] ?? '',
                            occurrenceDate: date,
                            isDynamic: item['is_dynamic'] ?? false,
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _buildRequestItem(
    BuildContext context, {
    required String date,
    required String status,
    required String type,
    required String description,
    required DateTime occurrenceDate,
    required bool isDynamic,
  }) {
    String statusText = status;
    Color statusColor = Colors.orange;
    IconData icon = Icons.info_outline;

    if (isDynamic) {
      statusText = 'Ação Requerida';
      statusColor = Colors.blue;
      icon = Icons.warning_amber_rounded;
    } else if (status == 'Aprovado') {
      statusText = 'Aprovada';
      statusColor = Colors.green;
      icon = Icons.check_circle_outline;
    } else if (status == 'Rejeitado' || status == 'Reprovado' || status == 'Indeferida') {
      statusText = 'Indeferida';
      statusColor = Colors.red;
      icon = Icons.error_outline;
    } else {
      statusText = 'Pendente';
      statusColor = Colors.orange;
      icon = Icons.access_time;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: isDynamic ? BorderSide(color: statusColor.withOpacity(0.5), width: 1) : BorderSide.none,
      ),
      child: ListTile(
        leading: Icon(icon, color: statusColor, size: 28),
        title: Text(date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$type: $description', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                statusText.toUpperCase(),
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: () {
          AnalyticsService.recordButtonClick('view_request_details', pageName: '/employee/requests');
          if (_resolvedIdFuncionario != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PointDetailsScreen(
                  idFuncionario: _resolvedIdFuncionario!,
                  absenceDate: occurrenceDate,
                ),
                settings: const RouteSettings(name: '/employee/point-details'),
              ),
            ).then((_) => _fetchAllData()); // Recarregar ao voltar
          }
        },
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      ),
    );
  }
}
