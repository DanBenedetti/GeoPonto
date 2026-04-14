export class Company {
  constructor(data = {}) {
    this.id_empresa = data.id_empresa || null;
    this.nome_fantasia = data.nome_fantasia || '';
    this.razao_social = data.razao_social || '';
    this.cnpj = data.cnpj || '';
    this.username = data.username || '';
    this.senha = data.senha || '';
    this.cep = data.cep || '';
    this.logradouro = data.logradouro || '';
    this.numero = data.numero || '';
    this.bairro = data.bairro || '';
    this.cidade = data.cidade || '';
    this.estado = data.estado || '';
    this.pais = data.pais || 'Brasil';
    this.status = data.status ?? true;
    this.criado_em = data.criado_em || null;
  }

  toJSON() {
    return {
      nome_fantasia: this.nome_fantasia,
      razao_social: this.razao_social,
      cnpj: this.cnpj,
      senha: this.senha,
      cep: this.cep,
      logradouro: this.logradouro,
      numero: this.numero,
      bairro: this.bairro,
      cidade: this.cidade,
      estado: this.estado,
      pais: this.pais,
      username: this.username
    };
  }
}
