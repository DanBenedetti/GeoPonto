class Localizacao {
  final int? id_localizacao;
  final int id_funcionario;
  final double latitude;
  final double longitude;
  final int raio_permitido;

  Localizacao({
    this.id_localizacao,
    required this.id_funcionario,
    required this.latitude,
    required this.longitude,
    required this.raio_permitido,
  });

  factory Localizacao.fromJson(Map<String, dynamic> json) {
    return Localizacao(
      id_localizacao: json['id_localizacao'],
      id_funcionario: json['id_funcionario'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      raio_permitido: json['raio_permitido'],
    );
  }
}
