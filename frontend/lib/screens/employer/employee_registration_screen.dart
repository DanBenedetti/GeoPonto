import 'package:geoponto/components/editor.dart';
import 'package:geoponto/components/time_editor.dart';
import 'package:geoponto/models/colaborador.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geoponto/config/api_config.dart';
import 'package:http/http.dart' as http;

class EmployeeRegistrationScreen extends StatefulWidget {
  const EmployeeRegistrationScreen({super.key});

  @override
  State<EmployeeRegistrationScreen> createState() =>
      _EmployeeRegistrationScreenState();
}

class _EmployeeRegistrationScreenState extends State<EmployeeRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers for each text field
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _cepController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _positionController = TextEditingController();
  final _entryTimeController = TextEditingController();
  final _startIntervalController = TextEditingController();
  final _endIntervalController = TextEditingController();
  final _exitTimeController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _nameController.dispose();
    _cpfController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _cepController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _entryTimeController.dispose();
    _startIntervalController.dispose();
    _endIntervalController.dispose();
    _exitTimeController.dispose();
    super.dispose();
  }

  Future<void> _registerEmployee() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final colaborador = Colaborador(
      nome: _nameController.text,
      cpf: _cpfController.text,
      rua: _streetController.text,
      numero: _numberController.text,
      bairro: _neighborhoodController.text,
      cidade: _cityController.text,
      cep: _cepController.text,
      email: _emailController.text,
      telefone: _phoneController.text,
      cargo: _positionController.text,
      horarioEntrada: _entryTimeController.text,
      horarioSaidaIntervalo: _startIntervalController.text,
      horarioRetornoIntervalo: _endIntervalController.text,
      horarioSaida: _exitTimeController.text,
      empresaId: 1, // Assuming the API requires empresa_id. Adjust as needed.
    );

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/funcionarios'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(colaborador.toJson()),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Funcionário cadastrado com sucesso!')),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar funcionário: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Funcionário'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Editor(controller: _nameController, hintText: 'Nome Completo'),
                Editor(controller: _cpfController, hintText: 'CPF'),
                Editor(controller: _streetController, hintText: 'Rua'),
                Editor(controller: _numberController, hintText: 'Número'),
                Editor(controller: _neighborhoodController, hintText: 'Bairro'),
                Editor(controller: _cityController, hintText: 'Cidade'),
                Editor(controller: _cepController, hintText: 'CEP'),
                Editor(
                  controller: _emailController,
                  hintText: 'E-mail (para o login)',
                  keyboardType: TextInputType.emailAddress,
                ),
                Editor(
                  controller: _phoneController,
                  hintText: 'Telefone',
                  keyboardType: TextInputType.phone,
                ),
                Editor(controller: _positionController, hintText: 'Cargo'),
                TimeEditor(controller: _entryTimeController, hintText: 'Entrada (HH:MM)'),
                TimeEditor(controller: _startIntervalController, hintText: 'Saída para o Intervalo (HH:MM)'),
                TimeEditor(controller: _endIntervalController, hintText: 'Retorno do Intervalo (HH:MM)'),
                TimeEditor(controller: _exitTimeController, hintText: 'Saída (HH:MM)'),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: _isLoading ? null : _registerEmployee,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Cadastrar Funcionário'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


}