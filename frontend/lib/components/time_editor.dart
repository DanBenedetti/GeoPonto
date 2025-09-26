import 'package:flutter/material.dart';

class TimeEditor extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const TimeEditor({
    super.key,
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: hintText,
          suffixIcon: const Icon(Icons.access_time),
        ),
        keyboardType: TextInputType.datetime,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Campo obrigatório';
          }
          // Basic time format validation (HH:MM)
          if (!RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value)) {
            return 'Formato inválido. Use HH:MM';
          }
          return null;
        },
      ),
    );
  }
}
