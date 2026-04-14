import API_BASE_URL from './apiConfig';

export const employeeService = {
  async getAllByCompany(companyId) {
    const response = await fetch(`${API_BASE_URL}/funcionarios?id_empresa=${companyId}`);
    if (!response.ok) throw new Error('Erro ao buscar funcionários');
    return await response.json();
  },

  async getById(id) {
    const response = await fetch(`${API_BASE_URL}/funcionarios/${id}`);
    if (!response.ok) throw new Error('Erro ao buscar funcionário');
    return await response.json();
  },

  async register(employeeData) {
    const response = await fetch(`${API_BASE_URL}/funcionarios`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(employeeData),
    });

    if (!response.ok) throw new Error('Erro ao cadastrar funcionário');
    return await response.json();
  },

  async update(id, employeeData) {
    const response = await fetch(`${API_BASE_URL}/funcionarios/${id}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(employeeData),
    });

    if (!response.ok) throw new Error('Erro ao atualizar funcionário');
    return await response.json();
  },

  async delete(id) {
    const response = await fetch(`${API_BASE_URL}/funcionarios/${id}`, {
      method: 'DELETE',
    });
    if (!response.ok) throw new Error('Erro ao excluir funcionário');
    return await response.json();
  }
};
