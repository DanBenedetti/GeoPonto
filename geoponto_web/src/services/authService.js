import API_BASE_URL from './apiConfig';

export const authService = {
  async loginEmpresa(username, senha) {
    const response = await fetch(`${API_BASE_URL}/login/empresa`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ username, senha }),
    });

    if (!response.ok) {
      const errorData = await response.json();
      throw new Error(errorData.message || 'Erro ao realizar login');
    }

    return await response.json();
  },

  logout() {
    localStorage.removeItem('token');
    localStorage.removeItem('id_empresa');
    localStorage.removeItem('isLoggedIn');
    localStorage.removeItem('userName');
    localStorage.removeItem('userType');
  }
};
