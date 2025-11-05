import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateEditor extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isRequired;

  const DateEditor({
    super.key,
    required this.controller,
    required this.hintText,
    this.isRequired = true,
  });

  @override
  State<DateEditor> createState() => _DateEditorState();
}

class _DateEditorState extends State<DateEditor> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: widget.controller,
        decoration: InputDecoration(
          labelText: widget.hintText,
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        readOnly: true,
        onTap: () => _selectDate(context),
        validator: (value) {
          if (widget.isRequired && (value == null || value.isEmpty)) {
            return 'Campo obrigatório';
          }
          return null;
        },
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        widget.controller.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }
}
