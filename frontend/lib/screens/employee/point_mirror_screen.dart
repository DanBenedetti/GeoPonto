import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geoponto/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PointMirrorScreen extends StatefulWidget {
  const PointMirrorScreen({super.key});

  @override
  State<PointMirrorScreen> createState() => _PointMirrorScreenState();
}

class _PointMirrorScreenState extends State<PointMirrorScreen> {
  Map<String, dynamic>? _selectedMonthStats;
  bool _isLoadingStats = false;
  int? _idFuncionario;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    _idFuncionario = prefs.getInt('id_funcionario');
    if (_idFuncionario != null) {
      _fetchMonthStats(_selectedDate.year, _selectedDate.month);
    }
  }

  Future<void> _fetchMonthStats(int year, int month) async {
    setState(() => _isLoadingStats = true);
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/funcionarios/$_idFuncionario/espelho/$year/$month'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _selectedMonthStats = jsonDecode(response.body);
          _isLoadingStats = false;
        });
      } else {
        setState(() => _isLoadingStats = false);
      }
    } catch (e) {
      setState(() => _isLoadingStats = false);
    }
  }

  void _changeDate(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
    _fetchMonthStats(newDate.year, newDate.month);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Espelho ponto'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          _buildMonthSelector(context),
          Expanded(
            child: _isLoadingStats
                ? const Center(child: CircularProgressIndicator())
                : _selectedMonthStats == null
                    ? const Center(child: Text('Nenhum dado encontrado.'))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildMonthSummaryItem(
                          month: DateFormat.yMMMM('pt_BR').format(_selectedDate),
                          period: _selectedMonthStats!['periodo'],
                          normalHours: _selectedMonthStats!['horas_normais'],
                          absences: _selectedMonthStats!['horas_faltas'],
                          extraHours: _selectedMonthStats!['horas_extras'],
                        ),
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

  Widget _buildMonthSummaryItem({
    required String month,
    required String period,
    required String normalHours,
    required String absences,
    required String extraHours,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(month.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 4),
            Text(period, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const Divider(height: 40),
            _buildHoursRow('Horas Trabalhadas', normalHours, Icons.work_outline, Colors.blue),
            const SizedBox(height: 20),
            _buildHoursRow('Faltas / Débitos', absences, Icons.warning_amber_rounded, Colors.red),
            const SizedBox(height: 20),
            _buildHoursRow('Horas Extras', extraHours, Icons.add_circle_outline, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildHoursRow(String label, String hours, IconData icon, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 16, color: Colors.black87)),
          ],
        ),
        Text(hours, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }
}
