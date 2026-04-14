import API_BASE_URL from './apiConfig';

export const companyService = {
  async register(companyData) {
    const response = await fetch(`${API_BASE_URL}/empresas`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(companyData),
    });

    if (!response.ok) {
      const errorData = await response.json();
      throw new Error(errorData.message || 'Erro ao cadastrar empresa');
    }

    return await response.json();
  },

  async getById(id) {
    const response = await fetch(`${API_BASE_URL}/empresas/${id}`);
    if (!response.ok) throw new Error('Erro ao buscar dados da empresa');
    return await response.json();
  },

  async update(id, companyData) {
    const response = await fetch(`${API_BASE_URL}/empresas/${id}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(companyData),
    });

    if (!response.ok) throw new Error('Erro ao atualizar empresa');
    return await response.json();
  }
};
