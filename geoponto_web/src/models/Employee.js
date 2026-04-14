export class Employee {
  constructor(data = {}) {
    this.id_funcionario = data.id_funcionario || null;
    this.id_empresa = data.id_empresa || null;
    this.nome = data.nome || '';
    this.sobrenome = data.sobrenome || '';
    this.cpf = data.cpf || '';
    this.rua = data.rua || '';
    this.numero = data.numero || '';
    this.bairro = data.bairro || '';
    this.cidade = data.cidade || '';
    this.cep = data.cep || '';
    this.email = data.email || '';
    this.telefone = data.telefone || '';
    this.cargo = data.cargo || '';
    this.senha = data.senha || '';
    this.data_admissao = data.data_admissao || null;
    this.status = data.status ?? true;
    this.criado_em = data.criado_em || null;
  }

  toJSON() {
    return {
      id_empresa: this.id_empresa,
      nome: this.nome,
      sobrenome: this.sobrenome,
      cpf: this.cpf,
      rua: this.rua,
      numero: this.numero,
      bairro: this.bairro,
      cidade: this.cidade,
      cep: this.cep,
      email: this.email,
      telefone: this.telefone,
      cargo: this.cargo,
      senha: this.senha,
      data_admissao: this.data_admissao
    };
  }
}
