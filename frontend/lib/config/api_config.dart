class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://20.220.34.118:5000',
  );

  static const bool bypassBiometry = false; // Altere para false para reativar a biometria
}
