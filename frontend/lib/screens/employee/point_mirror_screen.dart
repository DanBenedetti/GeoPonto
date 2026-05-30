import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geoponto/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PointMirrorScreen extends StatefulWidget {
  const PointMirrorScreen({super.key});

  @override
  State<PointMirrorScreen> createState() => _PointMirrorScreenState();
}

class _PointMirrorScreenState extends State<PointMirrorScreen> {
  List<dynamic> _availableMonths = [];
  Map<String, dynamic>? _selectedMonthStats;
  bool _isLoadingMonths = true;
  bool _isLoadingStats = false;
  int? _idFuncionario;
  Map<String, int>? _currentSelected;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    _idFuncionario = prefs.getInt('id_funcionario');
    if (_idFuncionario != null) {
      await _fetchAvailableMonths();
      if (_availableMonths.isNotEmpty) {
        final firstMonth = _availableMonths.first;
        _fetchMonthStats(firstMonth['year'], firstMonth['month']);
        _currentSelected = {'year': firstMonth['year'], 'month': firstMonth['month']};
      }
    } else {
      setState(() => _isLoadingMonths = false);
    }
  }

  Future<void> _fetchAvailableMonths() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/funcionarios/$_idFuncionario/meses-disponiveis'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _availableMonths = jsonDecode(response.body);
          _isLoadingMonths = false;
        });
      }
    } catch (e) {
      setState(() => _isLoadingMonths = false);
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
          _currentSelected = {'year': year, 'month': month};
        });
      }
    } catch (e) {
      setState(() => _isLoadingStats = false);
    }
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
      body: _isLoadingMonths
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildMonthSelector(),
                Expanded(
                  child: _isLoadingStats
                      ? const Center(child: CircularProgressIndicator())
                      : _selectedMonthStats == null
                          ? const Center(child: Text('Selecione um mês para visualizar.'))
                          : SingleChildScrollView(
                              padding: const EdgeInsets.all(16.0),
                              child: _buildMonthSummaryItem(
                                month: _getLabelForCurrent(),
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

  String _getLabelForCurrent() {
    if (_currentSelected == null) return '';
    final monthData = _availableMonths.firstWhere(
      (m) => m['year'] == _currentSelected!['year'] && m['month'] == _currentSelected!['month'],
      orElse: () => {'label': ''},
    );
    return monthData['label'];
  }

  Widget _buildMonthSelector() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _availableMonths.length,
        itemBuilder: (context, index) {
          final m = _availableMonths[index];
          final isSelected = _currentSelected != null &&
              _currentSelected!['year'] == m['year'] &&
              _currentSelected!['month'] == m['month'];

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(m['label']),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  _fetchMonthStats(m['year'], m['month']);
                }
              },
              selectedColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
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
            Text(month, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
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
