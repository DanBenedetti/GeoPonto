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
import 'package:geoponto/screens/loading_screen.dart';
import 'package:geoponto/screens/login_screen.dart';
import 'package:geoponto/screens/employer/dashboard_screen.dart';
import 'package:geoponto/screens/employer/employer_registration_screen.dart';

// Data class for searchable screens
class SearchableScreen {
  final String displayName;
  final String routeName;
  final bool isMainScreen;

  const SearchableScreen({
    required this.displayName,
    required this.routeName,
    this.isMainScreen = false,
  });
}

class AppRouteNames {
  static const String loading = '/';
  static const String login = '/login';
  static const String employeeHome = '/employee/home';
  static const String employerDashboard = '/employer/dashboard';
  static const String employerRegistration = '/employer/registration';
  static const String myHr = '/employee/my_hr';
  static const String absences = '/employee/absences';
  static const String occurrences = '/employee/occurrences';
  static const String myPoint = '/employee/my_point';
  static const String requests = '/employee/requests';
  static const String pointMirror = '/employee/point_mirror';
  static const String pointDetails = '/employee/point_details';
  static const String adjustment = '/employee/adjustment';
}

class AppRoutes {
  static Map<String, WidgetBuilder> generateRoutes() {
    return {
      AppRouteNames.loading: (context) => const LoadingScreen(),
      AppRouteNames.login: (context) => const LoginScreen(),
      AppRouteNames.employeeHome: (context) => const EmployeeHomeScreen(),
      AppRouteNames.employerDashboard: (context) => const EmployerDashboardScreen(),
      AppRouteNames.employerRegistration: (context) => const EmployerRegistrationScreen(),
      AppRouteNames.myHr: (context) => const MyHrScreen(),
      AppRouteNames.absences: (context) => const AbsencesScreen(),
      AppRouteNames.occurrences: (context) => const OccurrencesScreen(),
      AppRouteNames.myPoint: (context) => const MyPointScreen(),
      AppRouteNames.requests: (context) => const RequestsScreen(),
      AppRouteNames.pointMirror: (context) => const PointMirrorScreen(),
      AppRouteNames.pointDetails: (context) => const PointDetailsScreen(),
      AppRouteNames.adjustment: (context) => const AdjustmentScreen(),
    };
  }

  static final List<SearchableScreen> allScreens = [
    const SearchableScreen(displayName: 'Bater Ponto', routeName: AppRouteNames.employeeHome, isMainScreen: true),
    const SearchableScreen(displayName: 'Meu RH', routeName: AppRouteNames.myHr, isMainScreen: true),
    const SearchableScreen(displayName: 'Minhas Faltas', routeName: AppRouteNames.absences),
    const SearchableScreen(displayName: 'Ocorrências de Ponto', routeName: AppRouteNames.occurrences),
    const SearchableScreen(displayName: 'Meu Ponto', routeName: AppRouteNames.myPoint),
    const SearchableScreen(displayName: 'Solicitações', routeName: AppRouteNames.requests),
    const SearchableScreen(displayName: 'Espelho de Ponto', routeName: AppRouteNames.pointMirror),
    const SearchableScreen(displayName: 'Detalhes do Ponto', routeName: AppRouteNames.pointDetails),
    const SearchableScreen(displayName: 'Ajuste de Ponto', routeName: AppRouteNames.adjustment),
  ];

  static final List<SearchableScreen> suggestions = [
    allScreens.firstWhere((s) => s.displayName == 'Meu Ponto'),
    allScreens.firstWhere((s) => s.displayName == 'Meu RH'),
    allScreens.firstWhere((s) => s.displayName == 'Ocorrências de Ponto'),
    allScreens.firstWhere((s) => s.displayName == 'Minhas Faltas'),
    allScreens.firstWhere((s) => s.displayName == 'Solicitações'),
    allScreens.firstWhere((s) => s.displayName == 'Espelho de Ponto'),
  ];
}
