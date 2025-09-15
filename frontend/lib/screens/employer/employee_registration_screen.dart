import 'package:flutter/material.dart';

class EmployeeRegistrationScreen extends StatefulWidget {
  const EmployeeRegistrationScreen({super.key});

  @override
  State<EmployeeRegistrationScreen> createState() =>
      _EmployeeRegistrationScreenState();
}

class _EmployeeRegistrationScreenState extends State<EmployeeRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Funcionário'),
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
                _buildTextField(hintText: 'Nome Completo'),
                _buildTextField(hintText: 'CPF'),
                _buildTextField(hintText: 'Rua'),
                _buildTextField(hintText: 'Número'),
                _buildTextField(hintText: 'Bairro'),
                _buildTextField(hintText: 'Cidade'),
                _buildTextField(hintText: 'CEP'),
                _buildTextField(
                  hintText: 'E-mail (para o login)',
                  keyboardType: TextInputType.emailAddress,
                ),
                _buildTextField(
                  hintText: 'Telefone',
                  keyboardType: TextInputType.phone,
                ),
                _buildTextField(hintText: 'Cargo'),
                _buildTimeField(hintText: 'Entrada'),
                _buildTimeField(hintText: 'Saída para o Intervalo'),
                _buildTimeField(hintText: 'Retorno do Intervalo'),
                _buildTimeField(hintText: 'Saída'),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Lógica de cadastro de funcionário
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Cadastrar Funcionário'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required String hintText, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Campo obrigatório';
          }
          return null;
        },
      ),
    );
  }
}

  Widget _buildTimeField({required String hintText}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: hintText,
          suffixIcon: const Icon(Icons.access_time),
        ),
        keyboardType: TextInputType.datetime,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Campo obrigatório';
          }
          return null;
        },
      ),
    );
  }
