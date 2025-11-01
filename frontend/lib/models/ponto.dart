class Ponto {
  final String data;
  final List<Map<String, dynamic>> registros;

  Ponto({
    required this.data,
    required this.registros,
  });

  factory Ponto.fromJson(Map<String, dynamic> json) {
    return Ponto(
      data: json['data'],
      registros: List<Map<String, dynamic>>.from(json['registros']),
    );
  }
}
