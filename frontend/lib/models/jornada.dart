class Jornada {
  final int? id_jornada;
  final int id_funcionario;
  final int dia_semana;
  final String? horario_entrada;
  final String? horario_saida_intervalo;
  final String? horario_retorno_intervalo;
  final String? horario_saida;

  Jornada({
    this.id_jornada,
    required this.id_funcionario,
    required this.dia_semana,
    this.horario_entrada,
    this.horario_saida_intervalo,
    this.horario_retorno_intervalo,
    this.horario_saida,
  });

  factory Jornada.fromJson(Map<String, dynamic> json) {
    return Jornada(
      id_jornada: json['id_jornada'],
      id_funcionario: json['id_funcionario'],
      dia_semana: json['dia_semana'],
      horario_entrada: json['horario_entrada'],
      horario_saida_intervalo: json['horario_saida_intervalo'],
      horario_retorno_intervalo: json['horario_retorno_intervalo'],
      horario_saida: json['horario_saida'],
    );
  }
}
