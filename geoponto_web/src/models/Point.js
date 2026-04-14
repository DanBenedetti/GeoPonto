export class Point {
  constructor(data = {}) {
    this.id_ponto = data.id_ponto || null;
    this.id_funcionario = data.id_funcionario || null;
    this.latitude = data.latitude || 0;
    this.longitude = data.longitude || 0;
    this.criado_em = data.criado_em || null;
    this.time = data.time || null;
  }

  toJSON() {
    return {
      latitude: this.latitude,
      longitude: this.longitude
    };
  }
}
