class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://20.168.121.103:5000',
  );

  static const bool bypassBiometry = false; // Altere para false para reativar a biometria
}
