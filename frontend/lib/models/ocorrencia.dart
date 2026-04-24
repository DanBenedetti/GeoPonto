class Ocorrencia {
  final int? id_ocorrencia;
  final int id_funcionario;
  final String data_ocorrencia;
  final String tipo;
  final String? descricao;
  final String? anexo_url;
  final String status;
  final String? nome_funcionario;
  final String? sobrenome_funcionario;

  Ocorrencia({
    this.id_ocorrencia,
    required this.id_funcionario,
    required this.data_ocorrencia,
    required this.tipo,
    this.descricao,
    this.anexo_url,
    this.status = 'Pendente',
    this.nome_funcionario,
    this.sobrenome_funcionario,
  });

  factory Ocorrencia.fromJson(Map<String, dynamic> json) {
    return Ocorrencia(
      id_ocorrencia: json['id_ocorrencia'],
      id_funcionario: json['id_funcionario'],
      data_ocorrencia: json['data_ocorrencia'],
      tipo: json['tipo'],
      descricao: json['descricao'],
      anexo_url: json['anexo_url'],
      status: json['status'] ?? 'Pendente',
      nome_funcionario: json['nome'],
      sobrenome_funcionario: json['sobrenome'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_funcionario': id_funcionario,
      'data_ocorrencia': data_ocorrencia,
      'tipo': tipo,
      'descricao': descricao,
      'anexo_url': anexo_url,
      'status': status,
    };
  }
}
