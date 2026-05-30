class AnalyticsService {
  // Serviço silenciado para limpeza do projeto.
  // Não realiza mais chamadas de rede para analytics.

  static Future<void> recordPageView(String pageName, int renderTimeMs) async {
    // Silenciado
  }

  static Future<void> recordButtonClick(String buttonId, {String? pageName}) async {
    // Silenciado
  }

  static Future<Map<String, dynamic>> getAnalyticsMetrics() async {
    return {};
  }
}
