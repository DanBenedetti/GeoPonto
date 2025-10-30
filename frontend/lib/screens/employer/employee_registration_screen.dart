import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geoponto/components/editor.dart';
import 'package:geoponto/components/time_editor.dart';
import 'package:geoponto/config/api_config.dart';
import 'package:geoponto/models/colaborador.dart';
import 'package:http/http.dart' as http;

class EmployeeRegistrationScreen extends StatefulWidget {
  final int idEmpresa;
  final Colaborador? colaborador;

  const EmployeeRegistrationScreen({
    super.key,
    required this.idEmpresa,
    this.colaborador,
  });

  @override
  State<EmployeeRegistrationScreen> createState() =>
      _EmployeeRegistrationScreenState();
}

class _EmployeeRegistrationScreenState extends State<EmployeeRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool get _isEditMode => widget.colaborador != null;
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _sobrenomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _cepController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _positionController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _populateFields();
    }
  }

  void _populateFields() {
    final c = widget.colaborador!;
    _nameController.text = c.nome;
    _sobrenomeController.text = c.sobrenome ?? '';
    _cpfController.text = c.cpf;
    _streetController.text = c.rua ?? '';
    _numberController.text = c.numero ?? '';
    _neighborhoodController.text = c.bairro ?? '';
    _cityController.text = c.cidade ?? '';
    _cepController.text = c.cep ?? '';
    _emailController.text = c.email;
    _phoneController.text = c.telefone ?? '';
    _positionController.text = c.cargo ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sobrenomeController.dispose();
    _cpfController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _cepController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      if (_isEditMode) {
        await _updateEmployee();
      } else {
        await _createEmployee();
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _buildJsonPayload() {
    final payload = {
      'id_empresa': widget.idEmpresa,
      'nome': _nameController.text,
      'sobrenome': _sobrenomeController.text,
      'cpf': _cpfController.text,
      'rua': _streetController.text,
      'numero': _numberController.text,
      'bairro': _neighborhoodController.text,
      'cidade': _cityController.text,
      'cep': _cepController.text,
      'email': _emailController.text,
      'telefone': _phoneController.text,
      'cargo': _positionController.text,
    };

    // Only include password if it's not empty
    if (_senhaController.text.isNotEmpty) {
      payload['senha'] = _senhaController.text;
    }

    return payload;
  }

  Future<void> _createEmployee() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/funcionarios'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(_buildJsonPayload()),
      );
      _handleResponse(response, isCreating: true);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> _updateEmployee() async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/funcionarios/${widget.colaborador!.id_funcionario}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(_buildJsonPayload()),
      );
      _handleResponse(response, isCreating: false);
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleResponse(http.Response response, {required bool isCreating}) {
    final successMessage = isCreating 
        ? 'Funcionário cadastrado com sucesso!' 
        : 'Funcionário atualizado com sucesso!';
    final failureMessage = isCreating 
        ? 'Falha ao cadastrar funcionário' 
        : 'Falha ao atualizar funcionário';

    if (response.statusCode == 201 || response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage)),
      );
      Navigator.of(context).pop();
    } else {
      try {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$failureMessage: ${errorData['message']}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$failureMessage: ${response.body}')),
        );
      }
    }
  }

  void _handleError(Object e) {
     ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão: $e')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Editar Funcionário' : 'Cadastrar Funcionário'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Editor(controller: _nameController, hintText: 'Nome'),
                Editor(controller: _sobrenomeController, hintText: 'Sobrenome'),
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
                Editor(
                  controller: _senhaController,
                  hintText: _isEditMode ? 'Nova Senha (deixe em branco para não alterar)' : 'Senha',
                  obscureText: true,
                  validator: (value) {
                    if (!_isEditMode && (value == null || value.isEmpty)) {
                      return 'O campo Senha é obrigatório';
                    }
                    return null;
                  },
                ),
                Editor(
                  controller: _confirmarSenhaController,
                  hintText: 'Confirmar Senha',
                  obscureText: true,
                  validator: (value) {
                    if (_senhaController.text.isNotEmpty && value != _senhaController.text) {
                      return 'As senhas não coincidem';
                    }
                    // Only required in create mode
                    if (!_isEditMode && (value == null || value.isEmpty)) {
                      return 'O campo Confirmar Senha é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : Text(_isEditMode ? 'Salvar Alterações' : 'Cadastrar Funcionário'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}