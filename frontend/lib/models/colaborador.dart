class Colaborador {
  final int? id_funcionario;
  final int? id_empresa;
  final String nome;
  final String? sobrenome;
  final String cpf;
  final String? rua;
  final String? numero;
  final String? bairro;
  final String? cidade;
  final String? cep;
  final String email;
  final String? telefone;
  final String? cargo;
  final String? senha;
  final bool? status;
  final String? data_admissao;

  Colaborador({
    this.id_funcionario,
    this.id_empresa,
    required this.nome,
    this.sobrenome,
    required this.cpf,
    this.rua,
    this.numero,
    this.bairro,
    this.cidade,
    this.cep,
    required this.email,
    this.telefone,
    this.cargo,
    this.senha,
    this.status,
    this.data_admissao,
  });

  factory Colaborador.fromJson(Map<String, dynamic> json) {
    return Colaborador(
      id_funcionario: json['id_funcionario'],
      id_empresa: json['id_empresa'],
      nome: json['nome'],
      sobrenome: json['sobrenome'],
      cpf: json['cpf'],
      rua: json['rua'],
      numero: json['numero'],
      bairro: json['bairro'],
      cidade: json['cidade'],
      cep: json['cep'],
      email: json['email'],
      telefone: json['telefone'],
      cargo: json['cargo'],
      status: json['status'],
      data_admissao: json['data_admissao'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id_empresa': id_empresa,
        'nome': nome,
        'sobrenome': sobrenome,
        'cpf': cpf,
        'rua': rua,
        'numero': numero,
        'bairro': bairro,
        'cidade': cidade,
        'cep': cep,
        'email': email,
        'telefone': telefone,
        'cargo': cargo,
        'senha': senha,
        'data_admissao': data_admissao,
      };
}