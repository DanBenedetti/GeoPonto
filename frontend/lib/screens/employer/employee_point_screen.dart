import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geoponto/config/api_config.dart';
import 'package:geoponto/models/colaborador.dart';
import 'package:geoponto/models/ponto.dart';
import 'package:geoponto/screens/employer/employer_point_details_screen.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:geoponto/services/analytics_service.dart';

class EmployeePointScreen extends StatefulWidget {
  final Colaborador colaborador;
  const EmployeePointScreen({super.key, required this.colaborador});

  @override
  State<EmployeePointScreen> createState() => _EmployeePointScreenState();
}

class _EmployeePointScreenState extends State<EmployeePointScreen> {
  late Future<List<Ponto>> _pontosFuture;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _pontosFuture = _fetchPontos(_selectedDate.year, _selectedDate.month);
  }

  Future<List<Ponto>> _fetchPontos(int year, int month) async {
    final response = await http.get(Uri.parse(
        '${ApiConfig.baseUrl}/ponto/funcionario/${widget.colaborador.id_funcionario}?year=$year&month=$month'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> pontoList = data;
      return pontoList.map((json) => Ponto.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load pontos');
    }
  }

  void _changeDate(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
      _pontosFuture = _fetchPontos(_selectedDate.year, _selectedDate.month);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ponto de ${widget.colaborador.nome}'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          _buildMonthSelector(context),
          Expanded(
            child: FutureBuilder<List<Ponto>>(
              future: _pontosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nenhum registro de ponto encontrado.'));
                } else {
                  final pontos = snapshot.data!;
                  return ListView.builder(
                    itemCount: pontos.length,
                    padding: const EdgeInsets.all(16.0),
                    itemBuilder: (context, index) {
                      final ponto = pontos[index];
                      return _buildPointRecordItem(
                        context,
                        ponto: ponto,
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => _changeDate(DateTime(_selectedDate.year, _selectedDate.month - 1)),
          ),
          TextButton(
            onPressed: () {
              showMonthPicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              ).then((date) {
                if (date != null) {
                  _changeDate(date);
                }
              });
            },
            child: Text(
              DateFormat.yMMMM('pt_BR').format(_selectedDate),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: () => _changeDate(DateTime(_selectedDate.year, _selectedDate.month + 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildPointRecordItem(
    BuildContext context, {
    required Ponto ponto,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        title: Text(DateFormat.yMd('pt_BR').format(DateTime.parse(ponto.data)),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          AnalyticsService.recordButtonClick('view_point_details', pageName: '/employer/employee-point');
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EmployerPointDetailsScreen(ponto: ponto, idFuncionario: widget.colaborador.id_funcionario!,), settings: const RouteSettings(name: '/employer/employee-point-details')));
        },
        shape: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
    );
  }
}
