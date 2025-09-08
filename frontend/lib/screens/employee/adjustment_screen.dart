import 'package:flutter/material.dart';
import 'dart:async';

class AdjustmentScreen extends StatefulWidget {
  const AdjustmentScreen({super.key});

  @override
  State<AdjustmentScreen> createState() => _AdjustmentScreenState();
}

class _AdjustmentScreenState extends State<AdjustmentScreen> {
  final _justificationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  List<TimeOfDay> _records = [
    const TimeOfDay(hour: 8, minute: 1),
    const TimeOfDay(hour: 12, minute: 5),
    const TimeOfDay(hour: 13, minute: 3),
    const TimeOfDay(hour: 17, minute: 30),
  ];

  Duration _workedHours = Duration.zero;
  Duration _missingHours = Duration.zero;
  Duration _extraHours = Duration.zero;
  final Duration _standardWorkday = const Duration(hours: 8, minutes: 30);

  @override
  void initState() {
    super.initState();
    _calculateHours();
  }

  @override
  void dispose() {
    _justificationController.dispose();
    super.dispose();
  }

  void _calculateHours() {
    Duration totalDuration = Duration.zero;
    List<TimeOfDay> sortedRecords = List.from(_records);
    sortedRecords.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));

    for (int i = 0; i < sortedRecords.length; i += 2) {
      if (i + 1 < sortedRecords.length) {
        final start = sortedRecords[i];
        final end = sortedRecords[i + 1];
        final startTime = start.hour * 60 + start.minute;
        final endTime = end.hour * 60 + end.minute;
        totalDuration += Duration(minutes: endTime - startTime);
      }
    }

    setState(() {
      _workedHours = totalDuration;
      if (totalDuration > _standardWorkday) {
        _extraHours = totalDuration - _standardWorkday;
        _missingHours = Duration.zero;
      } else {
        _missingHours = _standardWorkday - totalDuration;
        _extraHours = Duration.zero;
      }
    });
  }

  void _addRecord(int index) {
    setState(() {
      _records.insert(index, TimeOfDay.now());
    });
    _calculateHours();
  }

  void _removeRecord(int index) {
    setState(() {
      _records.removeAt(index);
    });
    _calculateHours();
  }

  Future<void> _selectTime(BuildContext context, int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _records[index],
    );
    if (picked != null && picked != _records[index]) {
      setState(() {
        _records[index] = picked;
      });
      _calculateHours();
    }
  }
  
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitação de ajuste'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfo('Data:', '20/08/2025 | quarta-feira'),
              const SizedBox(height: 8),
              _buildInfo('Turno:', '08:00 às 12:00 | 13:00 às 17:30'),
              const SizedBox(height: 16),
              
              TextButton.icon(
                icon: const Icon(Icons.add, color: Colors.green),
                label: const Text('Adicionar ponto antes', style: TextStyle(color: Colors.green)),
                onPressed: () => _addRecord(0),
              ),
              
              ..._buildRecordList(),

              TextButton.icon(
                icon: const Icon(Icons.add, color: Colors.green),
                label: const Text('Adicionar ponto depois', style: TextStyle(color: Colors.green)),
                onPressed: () => _addRecord(_records.length),
              ),

              const SizedBox(height: 24),
              _buildHoursSummary(),
              const SizedBox(height: 24),

              const Text('Qual o motivo da solicitação?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _justificationController,
                decoration: const InputDecoration(
                  hintText: 'Digite aqui...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'A justificativa é obrigatória.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              const Text('Gostaria de anexar algum arquivo?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildAttachmentButton(icon: Icons.photo_camera, label: 'Foto')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildAttachmentButton(icon: Icons.attach_file, label: 'Arquivo')),
                ],
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // TODO: lógica do Submit  do botão
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Enviar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRecordList() {
    return List.generate(_records.length, (index) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectTime(context, index),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _records[index].format(context),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => _removeRecord(index),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.green),
              onPressed: () => _addRecord(index + 1),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildInfo(String label, String value) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Text(value),
      ],
    );
  }

  Widget _buildHoursSummary() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildHoursInfo('H.T.:', _formatDuration(_workedHours)),
          _buildHoursInfo('H.F.:', _formatDuration(_missingHours)),
          _buildHoursInfo('H.E.:', _formatDuration(_extraHours)),
        ],
      ),
    );
  }

  Widget _buildHoursInfo(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildAttachmentButton({required IconData icon, required String label}) {
    return OutlinedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: () {
        // TODO: implementar funcionalidade de anexar arquivo ou foto
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: Colors.grey[400]!),
      ),
    );
  }
}
