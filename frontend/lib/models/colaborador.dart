class Colaborador {
  final int? id_funcionario;
  final int? id_empresa;
  final String nome_completo;
  final String cpf;
  final String rua;
  final String numero;
  final String bairro;
  final String cidade;
  final String cep;
  final String email;
  final String telefone;
  final String cargo;
  final String? horarioEntrada;
  final String? horarioSaidaIntervalo;
  final String? horarioRetornoIntervalo;
  final String? horarioSaida;
  final String? senha;
  final bool? status;

  Colaborador({
    this.id_funcionario,
    this.id_empresa,
    required this.nome_completo,
    required this.cpf,
    required this.rua,
    required this.numero,
    required this.bairro,
    required this.cidade,
    required this.cep,
    required this.email,
    required this.telefone,
    required this.cargo,
    this.horarioEntrada,
    this.horarioSaidaIntervalo,
    this.horarioRetornoIntervalo,
    this.horarioSaida,
    this.senha,
    this.status,
  });

  factory Colaborador.fromJson(Map<String, dynamic> json) {
    return Colaborador(
      id_funcionario: json['id_funcionario'],
      id_empresa: json['id_empresa'],
      nome_completo: json['nome_completo'],
      cpf: json['cpf'],
      rua: json['rua'],
      numero: json['numero'],
      bairro: json['bairro'],
      cidade: json['cidade'],
      cep: json['cep'],
      email: json['email'],
      telefone: json['telefone'],
      cargo: json['cargo'],
      horarioEntrada: json['horario_entrada'],
      horarioSaidaIntervalo: json['horario_saida_intervalo'],
      horarioRetornoIntervalo: json['horario_retorno_intervalo'],
      horarioSaida: json['horario_saida'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id_empresa': id_empresa,
        'nome_completo': nome_completo,
        'cpf': cpf,
        'rua': rua,
        'numero': numero,
        'bairro': bairro,
        'cidade': cidade,
        'cep': cep,
        'email': email,
        'telefone': telefone,
        'cargo': cargo,
        'horario_entrada': horarioEntrada,
        'horario_saida_intervalo': horarioSaidaIntervalo,
        'horario_retorno_intervalo': horarioRetornoIntervalo,
        'horario_saida': horarioSaida,
        'senha': senha,
      };
}