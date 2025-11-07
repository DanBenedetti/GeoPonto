# Backend - GeoPonto API

Este diretório contém o código-fonte da API do sistema GeoPonto, desenvolvida em Python com o framework Flask.

## 🚀 Tecnologias Principais

*   **Linguagem:** Python 3
*   **Framework:** Flask
*   **Banco de Dados:** PostgreSQL
*   **Driver de Conexão:** `psycopg2-binary`
*   **Gerenciamento de Ambiente:** `python-dotenv`
*   **CORS:** `Flask-Cors`
*   **Servidor WSGI:** `gunicorn`

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

### Desenvolvimento
Para rodar a aplicação em modo de desenvolvimento, com hot-reload:
```bash
flask run
```
A API estará disponível em **`http://localhost:5000`**.

### Produção
Para rodar a aplicação em modo de produção, utilize o `gunicorn`:
```bash
gunicorn --bind 0.0.0.0:5000 main:app
```
A API estará disponível em **`http://localhost:5000`**.

**Nota:** A porta `5001` está configurada no arquivo `docker-compose.yml`. Se você rodar o `main.py` manualmente (`python main.py`), a API estará na porta `5000`.

---

## 📋 Endpoints da API (Consulta Rápida)

Aqui está a lista de todos os endpoints disponíveis na API.

### Autenticação

*   `POST /login/empresa`
    *   **Função:** Autentica um empregador.
    *   **Corpo (Body):** `{ "username": "...", "senha": "..." }`
    *   **Resposta (Sucesso):** `{ "token": "seu_token_jwt", "id_empresa": "..." }`
*   `POST /login/funcionario`
    *   **Função:** Autentica um funcionário.
    *   **Corpo (Body):** `{ "email": "...", "senha": "..." }`
    *   **Resposta (Sucesso):** `{ "token": "seu_token_jwt", "id_funcionario": "...", "id_empresa": "..." }`

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
*   `GET /funcionarios?id_empresa=<id_empresa>`
    *   **Função:** Lista todos os funcionários de uma empresa.
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
    *   **Corpo (Body):** `{ "latitude": ..., "longitude": ... }`
*   `GET /ponto/funcionario/<id_funcionario>?month=<mes>&year=<ano>`
    *   **Função:** Lista todos os registros de ponto de um funcionário em um determinado mês e ano.
*   `DELETE /ponto/funcionario/<id_ponto>`
    *   **Função:** Deleta um registro de ponto específico.

### Jornadas

*   `POST /jornadas`
    *   **Função:** Cria ou atualiza a jornada de um funcionário.
    *   **Corpo (Body):** Dados da jornada em JSON.
*   `GET /jornadas/funcionario/<id_funcionario>?day_of_week=<dia_da_semana>`
    *   **Função:** Retorna a jornada de um funcionário para um dia específico da semana.
*   `PUT /jornadas/<id_jornada>`
    *   **Função:** Atualiza uma jornada específica.
*   `DELETE /jornadas/<id_jornada>`
    *   **Função:** Deleta uma jornada específica.

### Localizações

*   `POST /localizacoes`
    *   **Função:** Cria uma nova localização para um funcionário.
    *   **Corpo (Body):** `{ "id_funcionario": ..., "latitude": ..., "longitude": ..., "raio_permitido": ... }`
*   `GET /localizacoes/funcionario/<id_funcionario>`
    *   **Função:** Retorna a localização de um funcionário.
*   `PUT /localizacoes/<id_localizacao>`
    *   **Função:** Atualiza uma localização.
*   `DELETE /localizacoes/<id_localizacao>`
    *   **Função:** Deleta uma localização.

### Faltas

*   `GET /funcionarios/<id_funcionario>/faltas`
    *   **Função:** Retorna a lista de faltas de um funcionário nos últimos 40 dias.

### Analytics

*   `POST /analytics/page-view`
    *   **Função:** Registra a visualização de uma página.
    *   **Corpo (Body):** `{ "page_name": "...", "render_time_ms": ... }`
*   `POST /analytics/button-click`
    *   **Função:** Registra o clique em um botão.
    *   **Corpo (Body):** `{ "button_id": "...", "page_name": "..." }`
*   `GET /analytics/metrics`
    *   **Função:** Retorna as métricas de analytics.

### Status do Banco de Dados

*   `GET /db-status`
    *   **Função:** Retorna o status do banco de dados.

---

## Exemplos de JSON

### `POST /empresas`
```json
{
    "nome_fantasia": "Tech Solutions",
    "razao_social": "Tech Solutions Ltda.",
    "cnpj": "12.345.678/0001-99",
    "senha": "senha_segura",
    "cep": "12345-678",
    "logradouro": "Rua dos Desenvolvedores",
    "numero": "123",
    "bairro": "Centro",
    "cidade": "São Paulo",
    "estado": "SP",
    "pais": "Brasil",
    "username": "techsolutions"
}
```

### `POST /funcionarios`
```json
{
    "id_empresa": 1,
    "nome": "João",
    "sobrenome": "Silva",
    "cpf": "123.456.789-00",
    "rua": "Rua do Comércio",
    "numero": "456",
    "bairro": "Centro",
    "cidade": "São Paulo",
    "cep": "12345-678",
    "email": "joao.silva@example.com",
    "telefone": "11987654321",
    "cargo": "Desenvolvedor",
    "senha": "outra_senha_segura",
    "data_admissao": "2023-01-15"
}
```

### `POST /ponto/<id_funcionario>`
```json
{
    "latitude": -23.550520,
    "longitude": -46.633308
}
```

### `POST /jornadas` (Jornada Padrão)
```json
{
    "id_funcionario": 1,
    "jornada_diferenciada": false,
    "dias_semana": [1, 2, 3, 4, 5],
    "horario_entrada": "09:00",
    "horario_saida_intervalo": "12:00",
    "horario_retorno_intervalo": "13:00",
    "horario_saida": "18:00"
}
```

### `POST /jornadas` (Jornada Diferenciada)
```json
{
    "id_funcionario": 1,
    "jornada_diferenciada": true,
    "dias": [
        {
            "dia_semana": 1,
            "horario_entrada": "09:00",
            "horario_saida": "17:00"
        },
        {
            "dia_semana": 2,
            "horario_entrada": "08:00",
            "horario_saida_intervalo": "12:00",
            "horario_retorno_intervalo": "13:00",
            "horario_saida": "17:00"
        }
    ]
}
```

### `POST /localizacoes`
```json
{
    "id_funcionario": 1,
    "latitude": -23.550520,
    "longitude": -46.633308,
    "raio_permitido": 100
}
```
