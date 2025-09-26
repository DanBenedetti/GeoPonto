import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geoponto/config/api_config.dart';
import 'package:http/http.dart' as http;

class EmployerRegistrationScreen extends StatefulWidget {
  const EmployerRegistrationScreen({super.key});

  @override
  State<EmployerRegistrationScreen> createState() =>
      _EmployerRegistrationScreenState();
}

class _EmployerRegistrationScreenState extends State<EmployerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  final _razaoSocialController = TextEditingController();
  final _nomeFantasiaController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _numeroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _municipioController = TextEditingController();
  final _ufController = TextEditingController();
  final _cepController = TextEditingController();
  final _paisController = TextEditingController();
  final _usernameController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  @override
  void dispose() {
    _razaoSocialController.dispose();
    _nomeFantasiaController.dispose();
    _cnpjController.dispose();
    _logradouroController.dispose();
    _numeroController.dispose();
    _bairroController.dispose();
    _municipioController.dispose();
    _ufController.dispose();
    _cepController.dispose();
    _paisController.dispose();
    _usernameController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _registerEmployer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/empresas'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'razao_social': _razaoSocialController.text,
          'nome_fantasia': _nomeFantasiaController.text,
          'cnpj': _cnpjController.text,
          'username': _usernameController.text,
          'password': _senhaController.text,
          'logradouro': _logradouroController.text,
          'numero': _numeroController.text,
          'bairro': _bairroController.text,
          'cidade': _municipioController.text,
          'estado': _ufController.text,
          'cep': _cepController.text,
          'pais': _paisController.text,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Empresa cadastrada com sucesso!')),
        );
        // Navigate to login or dashboard after successful registration
        Navigator.of(context).pop(); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar empresa: ${response.body}')),
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
        title: const Text('Cadastro de Empregador'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildTextField(controller: _razaoSocialController, hintText: 'Razão Social'),
                _buildTextField(controller: _nomeFantasiaController, hintText: 'Nome Fantasia'),
                _buildTextField(controller: _cnpjController, hintText: 'CNPJ'),
                _buildTextField(controller: _logradouroController, hintText: 'Logradouro'),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(controller: _numeroController, hintText: 'Número'),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(controller: _bairroController, hintText: 'Bairro'),
                    ),
                  ],
                ),
                _buildTextField(controller: _municipioController, hintText: 'Município'),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(controller: _ufController, hintText: 'UF'),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(controller: _cepController, hintText: 'CEP'),
                    ),
                  ],
                ),
                _buildTextField(controller: _paisController, hintText: 'País'),
                const SizedBox(height: 16),
                _buildTextField(controller: _usernameController, hintText: 'Nome de Usuário'),
                _buildTextField(
                  controller: _senhaController,
                  hintText: 'Senha',
                  obscureText: true,
                ),
                _buildTextField(
                  controller: _confirmarSenhaController,
                  hintText: 'Confirmar Senha',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    if (value != _senhaController.text) {
                      return 'As senhas não coincidem';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: _isLoading ? null : _registerEmployer,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Cadastrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: validator ?? (value) {
          if (value == null || value.isEmpty) {
            return 'Campo obrigatório';
          }
          return null;
        },
      ),
    );
  }
}