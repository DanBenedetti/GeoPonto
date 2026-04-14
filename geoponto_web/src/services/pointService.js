import API_BASE_URL from './apiConfig';

export const pointService = {
  async getByEmployee(employeeId, month, year) {
    const response = await fetch(`${API_BASE_URL}/ponto/funcionario/${employeeId}?month=${month}&year=${year}`);
    if (!response.ok) throw new Error('Erro ao buscar registros de ponto');
    return await response.json();
  },

  async delete(pointId) {
    const response = await fetch(`${API_BASE_URL}/ponto/funcionario/${pointId}`, {
      method: 'DELETE',
    });
    if (!response.ok) throw new Error('Erro ao excluir registro de ponto');
    return await response.json();
  }
};
