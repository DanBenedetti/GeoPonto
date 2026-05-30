import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geoponto/config/api_config.dart';
import 'package:geoponto/screens/employee/adjustment_screen.dart';
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
  List<dynamic> _requests = [];
  bool _isLoading = true;
  int? _resolvedIdFuncionario;

  @override
  void initState() {
    super.initState();
    _resolvedIdFuncionario = widget.idFuncionario;
    _loadAndFetchRequests();
  }

  Future<void> _loadAndFetchRequests() async {
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

    await _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    try {
      // Diferente de OccurrencesScreen, aqui queremos ver TODAS as solicitações feitas, 
      // inclusive as já aprovadas, para servir de histórico.
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/ocorrencias/funcionario/$_resolvedIdFuncionario/historico'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _requests = data;
          _isLoading = false;
        });
      } else {
        // Fallback para o endpoint padrão caso o /historico não exista ou falhe
        final fallbackResponse = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/ocorrencias/funcionario/$_resolvedIdFuncionario'),
        );
        if (fallbackResponse.statusCode == 200) {
           final data = jsonDecode(fallbackResponse.body);
           setState(() {
            _requests = data;
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      }
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
              : _requests.isEmpty
                  ? const Center(child: Text('Nenhuma solicitação encontrada.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _requests.length,
                      itemBuilder: (context, index) {
                        final request = _requests[index];
                        final date = DateTime.parse(request['data_ocorrencia']);
                        final formattedDate = DateFormat('dd/MM/yyyy | EEEE', 'pt_BR').format(date);
                        
                        return _buildRequestItem(
                          context,
                          date: formattedDate,
                          status: request['status'],
                          description: request['tipo'],
                          occurrenceDate: date,
                        );
                      },
                    ),
    );
  }

  Widget _buildRequestItem(
    BuildContext context, {
    required String date,
    required String status,
    required String description,
    required DateTime occurrenceDate,
  }) {
    String statusText = status;
    Color statusColor = Colors.orange;

    if (status == 'Aprovado') {
      statusText = 'Aprovada';
      statusColor = Colors.green;
    } else if (status == 'Rejeitado') {
      statusText = 'Indeferida';
      statusColor = Colors.red;
    } else {
      statusText = 'Pendente';
      statusColor = Colors.orange;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        title: Text(date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(description, style: const TextStyle(fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                statusText,
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
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
            );
          }
        },
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      ),
    );
  }
}
