import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geoponto/config/api_config.dart';
import 'package:geoponto/screens/employer/dashboard_screen.dart';
import 'package:geoponto/screens/employer/employer_registration_screen.dart';
import 'package:geoponto/screens/employee/home_screen.dart';
import 'package:geoponto/screens/biometric_auth_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:geoponto/components/analytics_button.dart';
import 'package:geoponto/mixins/render_time_mixin.dart';

enum LoginType { collaborator, employer }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with RenderTimeMixin<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  LoginType _loginType = LoginType.collaborator;
  bool _rememberMe = false;
  bool _isLoading = false;

  final _userController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_userController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    if (_loginType == LoginType.collaborator) {
      try {
        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/login/funcionario'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'email': _userController.text,
            'senha': _passwordController.text,
          }),
        );

        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          final int idFuncionario = responseBody['id_funcionario'];
          final int idEmpresa = responseBody['id_empresa'];
          
          // Verifica se já existe biometria cadastrada para este funcionário no dispositivo
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('id_funcionario', idFuncionario);
          await prefs.setInt('id_empresa', idEmpresa);
          final String biometryKey = 'biometry_template_$idFuncionario';
          final bool hasBiometry = prefs.containsKey(biometryKey);


          if (mounted) {
            if (ApiConfig.bypassBiometry) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => EmployeeHomeScreen(idFuncionario: idFuncionario, idEmpresa: idEmpresa),
                  settings: const RouteSettings(name: '/employee/home'),
                ),
              );
              return;
            }
            
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => BiometricAuthScreen(
                  idFuncionario: idFuncionario, // Passa o ID para salvar/validar corretamente
                  isRegistration: !hasBiometry, // Se não tem, vai para cadastro
                  onAuthenticated: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => EmployeeHomeScreen(idFuncionario: idFuncionario, idEmpresa: idEmpresa),
                        settings: const RouteSettings(name: '/employee/home'),
                      ),
                    );
                  },
                ),
                settings: const RouteSettings(name: '/biometric_auth'),
              ),
            );
          }
        } else {
          final responseBody = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseBody['message'] ?? 'Erro desconhecido ao tentar fazer login.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro de conexão: $e')),
        );
      }
    } else {
      // Employer Login Logic
      try {
        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/login/empresa'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'username': _userController.text,
            'senha': _passwordController.text,
          }),
        );

        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          final int idEmpresa = responseBody['id_empresa'];
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => EmployerDashboardScreen(idEmpresa: idEmpresa),
              settings: const RouteSettings(name: '/employer/dashboard'),
            ),
          );
        } else {
          final responseBody = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseBody['message'] ?? 'Erro desconhecido ao tentar fazer login.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro de conexão: $e')),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 40),
                SvgPicture.asset(
                  'assets/images/logo.svg',
                  height: 100,
                ),
                const SizedBox(height: 16),
                Text(
                  'GeoPonto',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 40),
                _buildLoginTypeSelector(),
                const SizedBox(height: 24),
                _buildLoginForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _loginType = LoginType.collaborator),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _loginType == LoginType.collaborator
                      ? const Color(0xFFBDBDBD)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: const Text(
                  'Colaborador',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _loginType = LoginType.employer),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _loginType == LoginType.employer
                      ? const Color(0xFFBDBDBD)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: const Text(
                  'Empregador',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _userController,
              decoration: InputDecoration(
                hintText: _loginType == LoginType.employer ? 'Usuário' : 'E-mail ou CPF',
              ),
              keyboardType: _loginType == LoginType.employer
                  ? TextInputType.text
                  : TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Senha',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                      activeColor: Theme.of(context).primaryColor,
                    ),
                    const Text('Manter logado'),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Esqueci a senha',
                    style: TextStyle(color: Colors.black54, decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AnalyticsButton(
              buttonId: 'login_button',
              onPressed: _isLoading ? () {} : _handleLogin,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    )
                  : const Text('Entrar'),
            ),
            if (_loginType == LoginType.employer)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: AnalyticsButton(
                  buttonId: 'employer_registration_button',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const EmployerRegistrationScreen(),
                        settings: const RouteSettings(name: '/employer/registration'),
                      ),
                    );
                  },
                  child: const Text('Cadastrar'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
