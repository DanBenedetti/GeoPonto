# Backend - GeoPonto API

Este diretório contém o código-fonte da API do sistema GeoPonto, desenvolvida em Python com o framework Flask.

## 🚀 Tecnologias Principais

*   **Linguagem:** Python 3
*   **Framework:** Flask
*   **Banco de Dados:** PostgreSQL
*   **Driver de Conexão:** `psycopg2-binary`
*   **Gerenciamento de Ambiente:** `python-dotenv`

## 🛠️ Configuração do Ambiente de Desenvolvimento

1.  **Crie um Ambiente Virtual:**
    É uma boa prática isolar as dependências do projeto.
    ```bash
    python -m venv venv
    ```

2.  **Ative o Ambiente Virtual:**
    *   No Linux/macOS:
        ```bash
        source venv/bin/activate
        ```
    *   No Windows:
        ```bash
        .\venv\Scripts\activate
        ```

3.  **Instale as Dependências:**
    Todas as dependências necessárias estão listadas no arquivo `requirements.txt`.
    ```bash
    pip install -r requirements.txt
    ```

## 🐘 Banco de Dados (PostgreSQL)

O banco de dados é gerenciado via Docker Compose para facilitar a configuração e execução.

1.  **Arquivo de Configuração:**
    As credenciais do banco de dados (usuário, senha, nome do banco) são definidas em um arquivo `.env` dentro deste diretório (`/backend`). Crie este arquivo se ele não existir, com base no exemplo:
    ```env
    POSTGRES_USER=seu_usuario
    POSTGRES_PASSWORD=sua_senha
    POSTGRES_DB=geoponto_db
    ```

2.  **Inicialização:**
    Para subir o contêiner do banco de dados, utilize o Docker Compose a partir da raiz do projeto (`GeoPonto/`):
    ```bash
    docker-compose up -d postgres
    ```
    O script `database.sql` será executado automaticamente na primeira vez que o contêiner for criado, montando toda a estrutura de tabelas.

## ▶️ Como Rodar a Aplicação

A forma recomendada de rodar todo o ambiente (backend + banco de dados) é com Docker Compose, a partir da raiz do projeto:
```bash
docker-compose up --build -d
```
A API estará disponível em **`http://localhost:5001`**.

**Nota:** A porta `5001` está configurada no arquivo `docker-compose.yml`. Se você rodar o `main.py` manualmente (`python main.py`), a API estará na porta `5000`.

---

## 📋 Endpoints da API (Consulta Rápida)

Aqui está a lista de todos os endpoints disponíveis na API.

### Autenticação

*   `POST /login`
    *   **Função:** Autentica um usuário (funcionário ou empregador).
    *   **Corpo (Body):** `{ "email": "...", "senha": "..." }`
    *   **Resposta (Sucesso):** `{ "token": "seu_token_jwt" }`

### Empresas

*   `POST /empresas`
    *   **Função:** Cria uma nova empresa.
    *   **Corpo (Body):** Dados da empresa em JSON.
*   `GET /empresas`
    *   **Função:** Lista todas as empresas cadastradas.
*   `GET /empresas/<id>`
    *   **Função:** Retorna os detalhes de uma empresa específica.
*   `PUT /empresas/<id>`
    *   **Função:** Atualiza os dados de uma empresa.
    *   **Corpo (Body):** Dados da empresa em JSON.
*   `DELETE /empresas/<id>`
    *   **Função:** Desativa uma empresa (altera o status para `FALSE`).

### Funcionários

*   `POST /funcionarios`
    *   **Função:** Cadastra um novo funcionário.
    *   **Corpo (Body):** Dados do funcionário em JSON.
*   `GET /funcionarios`
    *   **Função:** Lista todos os funcionários.
*   `GET /funcionarios/<id>`
    *   **Função:** Retorna os detalhes de um funcionário específico.
*   `PUT /funcionarios/<id>`
    *   **Função:** Atualiza os dados de um funcionário.
    *   **Corpo (Body):** Dados do funcionário em JSON.
*   `DELETE /funcionarios/<id>`
    *   **Função:** Desativa um funcionário (altera o status para `FALSE`).

### Pontos (Registros)

*   `POST /ponto/<id_funcionario>`
    *   **Função:** Cria um novo registro de ponto para um funcionário.
    *   **Corpo (Body):** `{ "latitude": ..., "longitude": ..., "tipo_ponto": "..." }`
*   `GET /ponto/funcionario/<id_funcionario>`
    *   **Função:** Lista todos os registros de ponto de um funcionário.
*   `PUT /ponto/funcionario/<id_ponto>`
    *   **Função:** Atualiza um registro de ponto específico.
*   `DELETE /ponto/funcionario/<id_ponto>`
    *   **Função:** Deleta um registro de ponto específico.

### Relatórios

*   `GET /relatorios/horas-trabalhadas/funcionario/<id_funcionario>`
    *   **Função:** Retorna os dados para o relatório de horas trabalhadas (lógica a ser implementada).
*   `GET /relatorios/faltas/funcionario/<id_funcionario>`
    *   **Função:** Retorna os dados para o relatório de faltas (lógica a ser implementada).