import 'package:flutter/material.dart';

class EmployerRegistrationScreen extends StatefulWidget {
  const EmployerRegistrationScreen({super.key});

  @override
  State<EmployerRegistrationScreen> createState() =>
      _EmployerRegistrationScreenState();
}

class _EmployerRegistrationScreenState extends State<EmployerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

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
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Text(
                    'É novo por aqui? Cadastre-se abaixo:',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24.0),
                  _buildTextField(hintText: 'Razão Social'),
                  _buildTextField(hintText: 'Nome Fantasia'),
                  _buildTextField(hintText: 'CNPJ'),
                  _buildTextField(hintText: 'Logradouro'),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(hintText: 'Número'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(hintText: 'Complemento'),
                      ),
                    ],
                  ),
                  _buildTextField(hintText: 'Bairro'),
                  _buildTextField(hintText: 'Município'),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(hintText: 'UF'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(hintText: 'CEP'),
                      ),
                    ],
                  ),
                  _buildTextField(hintText: 'Telefone'),
                  _buildTextField(
                    hintText: 'E-mail',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _buildTextField(hintText: 'Nome do proprietário ou contato do representante do RH'),
                   const SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Lógica de cadastro
                      }
                    },
                    child: const Text('Cadastrar'),
                  ),
                ],
              ),
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
          hintText: hintText,
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