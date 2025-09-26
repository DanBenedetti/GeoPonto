import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geoponto/screens/employer/dashboard_screen.dart';
import 'package:geoponto/screens/employer/employer_registration_screen.dart';
import 'package:geoponto/screens/employee/home_screen.dart';
import 'package:geoponto/services/metrics_service.dart';
import 'package:geoponto/navigation/app_routes.dart';

enum LoginType { collaborator, employer }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginType _loginType = LoginType.collaborator;
  bool _rememberMe = false;

  void _handleLogin() {
    if (_loginType == LoginType.collaborator) {
      Navigator.of(context).pushReplacementNamed(AppRouteNames.employeeHome);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRouteNames.employerDashboard);
    }
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
              onTap: () {
                MetricsService().trackButtonClick('collaborator_login_type_selected');
                setState(() => _loginType = LoginType.collaborator);
              },
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
              onTap: () {
                MetricsService().trackButtonClick('employer_login_type_selected');
                setState(() => _loginType = LoginType.employer);
              },
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TextField(
            decoration: InputDecoration(
              hintText: 'E-mail ou CPF',
            ),
          ),
          const SizedBox(height: 16),
          const TextField(
            obscureText: true,
            decoration: InputDecoration(
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
                onPressed: () {
                  MetricsService().trackButtonClick('forgot_password_click');
                },
                child: const Text(
                  'Esqueci a senha',
                  style: TextStyle(color: Colors.black54, decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              MetricsService().trackButtonClick('login_button_click');
              _handleLogin();
            },
            child: const Text('Entrar'),
          ),
          if (_loginType == LoginType.employer)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  MetricsService().trackButtonClick('register_button_click');
                  Navigator.of(context).pushNamed(AppRouteNames.employerRegistration);
                },
                child: const Text('Cadastrar'),
              ),
            ),
        ],
      ),
    );
  }
}
