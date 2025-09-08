import 'package:flutter/material.dart';
import 'package:geoponto/screens/employee/home_screen.dart';
import 'package:geoponto/screens/employee/my_hr_screen.dart';
import 'package:geoponto/screens/employee/absences_screen.dart';
import 'package:geoponto/screens/employee/occurrences_screen.dart';
import 'package:geoponto/screens/employee/my_point_screen.dart';
import 'package:geoponto/screens/employee/requests_screen.dart';
import 'package:geoponto/screens/employee/point_mirror_screen.dart';
import 'package:geoponto/screens/employee/point_details_screen.dart';
import 'package:geoponto/screens/employee/adjustment_screen.dart';

class AppScreen {
  final String name;
  final Widget Function() screenBuilder;

  const AppScreen({required this.name, required this.screenBuilder});
}

class AppRoutes {
  static final List<AppScreen> all = [
    const AppScreen(name: 'Bater Ponto', screenBuilder: EmployeeHomeScreen.new),
    const AppScreen(name: 'Meu RH', screenBuilder: MyHrScreen.new),
    const AppScreen(name: 'Minhas Faltas', screenBuilder: AbsencesScreen.new),
    const AppScreen(name: 'Ocorrências de Ponto', screenBuilder: OccurrencesScreen.new),
    const AppScreen(name: 'Meu Ponto', screenBuilder: MyPointScreen.new),
    const AppScreen(name: 'Solicitações', screenBuilder: RequestsScreen.new),
    const AppScreen(name: 'Espelho de Ponto', screenBuilder: PointMirrorScreen.new),
    const AppScreen(name: 'Detalhes do Ponto', screenBuilder: PointDetailsScreen.new),
    const AppScreen(name: 'Ajuste de Ponto', screenBuilder: AdjustmentScreen.new),
  ];

  static final List<AppScreen> suggestions = [
    all.firstWhere((s) => s.name == 'Meu Ponto'),
    all.firstWhere((s) => s.name == 'Meu RH'),
    all.firstWhere((s) => s.name == 'Ocorrências de Ponto'),
    all.firstWhere((s) => s.name == 'Minhas Faltas'),
    all.firstWhere((s) => s.name == 'Solicitações'),
    all.firstWhere((s) => s.name == 'Espelho de Ponto'),
  ];
}
