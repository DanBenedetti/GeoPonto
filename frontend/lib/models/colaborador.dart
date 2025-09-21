class Colaborador {
  final String nome;
  final String cpf;
  final String rua;
  final String numero;
  final String bairro;
  final String cidade;
  final String cep;
  final String email;
  final String telefone;
  final String cargo;
  final String horarioEntrada;
  final String horarioSaidaIntervalo;
  final String horarioRetornoIntervalo;
  final String horarioSaida;

  Colaborador({
    required this.nome,
    required this.cpf,
    required this.rua,
    required this.numero,
    required this.bairro,
    required this.cidade,
    required this.cep,
    required this.email,
    required this.telefone,
    required this.cargo,
    required this.horarioEntrada,
    required this.horarioSaidaIntervalo,
    required this.horarioRetornoIntervalo,
    required this.horarioSaida,
  });

  Map<String, dynamic> toJson() => {
        'nome': nome,
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
      };
}
