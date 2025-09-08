import 'package:flutter/material.dart';

class MyHrScreen extends StatelessWidget {
  const MyHrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu RH'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          _buildHrOption(
            context,
            icon: Icons.person_outline,
            title: 'Meus Dados',
            subtitle: 'Visualize e edite suas informações pessoais',
            onTap: () {
              // TODO: Navegar para a tela de Meus Dados
            },
          ),
          _buildHrOption(
            context,
            icon: Icons.receipt_long_outlined,
            title: 'Holerites',
            subtitle: 'Acesse seus recibos de pagamento',
            onTap: () {
              // TODO: Navegar para a tela de Holerites
            },
          ),
          _buildHrOption(
            context,
            icon: Icons.beach_access_outlined,
            title: 'Férias',
            subtitle: 'Consulte seu saldo e histórico de férias',
            onTap: () {
              // TODO: Navegar para a tela de Férias
            },
          ),
          _buildHrOption(
            context,
            icon: Icons.warning_amber_outlined,
            title: 'Ocorrências de Ponto',
            subtitle: 'Visualize e justifique suas ocorrências',
            onTap: () {
              // TODO: Navegar para a tela de Ocorrências
            },
          ),
           _buildHrOption(
            context,
            icon: Icons.document_scanner_outlined,
            title: 'Documentos',
            subtitle: 'Acesse documentos importantes',
            onTap: () {
              // TODO: Navegar para a tela de Documentos
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHrOption(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, size: 40, color: Theme.of(context).primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
    );
  }
}