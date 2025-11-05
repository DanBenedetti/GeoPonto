from flask import Flask, jsonify, request
import psycopg2
import os
from dotenv import load_dotenv
import datetime
from decimal import Decimal

load_dotenv()

app = Flask(__name__)

def get_db_connection():
    conn = psycopg2.connect(
        host="localhost",
        database=os.environ.get("POSTGRES_DB"),
        user=os.environ.get("POSTGRES_USER"),
        password=os.environ.get("POSTGRES_PASSWORD"),
        port=5432
    )
    return conn

@app.route('/')
def index():
    return "olá, mundo"

@app.route('/db_test')
def db_test():
    try:
        conn = get_db_connection()
        conn.close()
        return jsonify({"status": "success", "message": "Database connection successful!"})
    except Exception as e:
        return jsonify({'status': "error", "message": str(e)})

@app.route('/login/empresa', methods=['POST'])
def login_empresa():
    data = request.get_json()
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT id_empresa FROM Empresas WHERE username = %s AND senha = %s', (data['username'], data['senha']))
    empresa = cur.fetchone()
    cur.close()
    conn.close()
    if empresa:
        return jsonify({'token': 'dummy-token', 'id_empresa': empresa[0]})
    else:
        return jsonify({'message': 'Usuário ou senha inválidos'}), 401

@app.route('/login/funcionario', methods=['POST'])
def login_funcionario():
    data = request.get_json()
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT id_funcionario, id_empresa FROM Funcionarios WHERE email = %s AND senha = %s AND status = TRUE', (data['email'], data['senha']))
    funcionario = cur.fetchone()
    cur.close()
    conn.close()
    if funcionario:
        return jsonify({
            'token': 'dummy-token-funcionario',
            'id_funcionario': funcionario[0],
            'id_empresa': funcionario[1]
        })
    else:
        return jsonify({'message': 'E-mail ou senha inválidos'}), 401

@app.route('/empresas', methods=['POST'])
def create_empresa():
    data = request.get_json()
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(
        'INSERT INTO Empresas (nome_fantasia, razao_social, cnpj, senha, cep, logradouro, numero, bairro, cidade, estado, pais, username) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)',
        (data['nome_fantasia'], data['razao_social'], data['cnpj'], data['senha'], data['cep'], data['logradouro'], data['numero'], data['bairro'], data['cidade'], data['estado'], data['pais'], data['username'])
    )
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({'message': 'Empresa created successfully'}), 201

@app.route('/empresas', methods=['GET'])
def get_empresas():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM Empresas')
    empresas = cur.fetchall()
    cur.close()
    conn.close()
    return jsonify({'empresas': empresas})

@app.route('/empresas/<int:id>', methods=['GET'])
def get_empresa(id):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM Empresas WHERE id_empresa = %s', (id,))
    empresa = cur.fetchone()
    cur.close()
    conn.close()
    return jsonify({'empresa': empresa})

@app.route('/empresas/<int:id>', methods=['PUT'])
def update_empresa(id):
    data = request.get_json()
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(
        'UPDATE Empresas SET nome_fantasia = %s, razao_social = %s, cnpj = %s, cep = %s, logradouro = %s, numero = %s, bairro = %s, cidade = %s, estado = %s, pais = %s WHERE id_empresa = %s',
        (data['nome_fantasia'], data['razao_social'], data['cnpj'], data['cep'], data['logradouro'], data['numero'], data['bairro'], data['cidade'], data['estado'], data['pais'], id)
    )
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({'message': 'Empresa updated successfully'})

@app.route('/empresas/<int:id>', methods=['DELETE'])
def delete_empresa(id):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('UPDATE Empresas SET status = FALSE WHERE id_empresa = %s', (id,))
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({'message': 'Empresa deleted successfully'})

@app.route('/funcionarios', methods=['POST'])
def create_funcionario():
    data = request.get_json()
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(
            'INSERT INTO Funcionarios (id_empresa, nome, sobrenome, cpf, rua, numero, bairro, cidade, cep, email, telefone, cargo, senha, data_admissao) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)',
            (data['id_empresa'], data['nome'], data['sobrenome'], data['cpf'], data['rua'], data['numero'], data['bairro'], data['cidade'], data['cep'], data['email'], data['telefone'], data['cargo'], data['senha'], data.get('data_admissao'))
        )
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({'message': 'Funcionario created successfully'}), 201
    except Exception as e:
        if conn:
            conn.rollback()
        if conn:
            cur.close()
            conn.close()
        return jsonify({'status': 'error', 'message': str(e)}), 500

@app.route('/funcionarios', methods=['GET'])
def get_funcionarios():
    id_empresa = request.args.get('id_empresa', type=int)
    if not id_empresa:
        return jsonify({'message': 'O id_empresa é obrigatório'}), 400

    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM Funcionarios WHERE id_empresa = %s', (id_empresa,))
    
    # Get column names from the cursor description
    columns = [desc[0] for desc in cur.description]
    
    # Fetch all rows and create a list of dictionaries
    funcionarios_data = cur.fetchall()
    funcionarios = []
    for row in funcionarios_data:
        funcionarios.append(dict(zip(columns, row)))

    cur.close()
    conn.close()
    
    # Convert date/time objects to strings
    for f in funcionarios:
        for key, value in f.items():
            if isinstance(value, (datetime.datetime, datetime.date)):
                f[key] = value.isoformat()

    return jsonify({'funcionarios': funcionarios})

@app.route('/funcionarios/<int:id>', methods=['GET'])
def get_funcionario(id):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM Funcionarios WHERE id_funcionario = %s', (id,))
    
    # Get column names from the cursor description
    columns = [desc[0] for desc in cur.description]
    
    # Fetch one row and create a dictionary
    funcionario_data = cur.fetchone()
    cur.close()
    conn.close()

    if funcionario_data:
        funcionario = dict(zip(columns, funcionario_data))
        # Convert date/time objects to strings
        for key, value in funcionario.items():
            if isinstance(value, (datetime.datetime, datetime.date)):
                funcionario[key] = value.isoformat()
        return jsonify(funcionario)
    else:
        return jsonify({'message': 'Funcionário não encontrado'}), 404

@app.route('/funcionarios/<int:id>', methods=['PUT'])
def update_funcionario(id):
    data = request.get_json()
    conn = get_db_connection()
    cur = conn.cursor()

    # Base query and values
    query_parts = []
    values = []

    fields = [
        'nome', 'sobrenome', 'cpf', 'rua', 'numero', 'bairro', 'cidade', 
        'cep', 'email', 'telefone', 'cargo', 'data_admissao'
    ]

    for field in fields:
        if field in data:
            query_parts.append(f"{field} = %s")
            values.append(data[field])

    # Conditionally add password to the update query
    if 'senha' in data and data['senha']:
        query_parts.append("senha = %s")
        values.append(data['senha'])

    if not query_parts:
        return jsonify({'message': 'Nenhum dado para atualizar'}), 400

    values.append(id)
    
    query = f"UPDATE Funcionarios SET { ', '.join(query_parts) } WHERE id_funcionario = %s"

    cur.execute(query, tuple(values))
    
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({'message': 'Funcionário atualizado com sucesso'})

@app.route('/funcionarios/<int:id>', methods=['DELETE'])
def delete_funcionario(id):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('UPDATE Funcionarios SET status = FALSE WHERE id_funcionario = %s', (id,))
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({'message': 'Funcionario deleted successfully'})

@app.route('/ponto/<int:id>', methods=['POST'])
def create_ponto(id):
    data = request.get_json()
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(
        'INSERT INTO Pontos (id_funcionario, latitude, longitude) VALUES (%s, %s, %s)',
        (id, data['latitude'], data['longitude'])
    )
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({'message': 'Ponto created successfully'}), 201

@app.route('/ponto/funcionario/<int:id>', methods=['GET'])
def get_pontos_funcionario(id):
    month = request.args.get('month', type=int)
    year = request.args.get('year', type=int)

    now = datetime.datetime.now()
    if not month:
        month = now.month
    if not year:
        year = now.year

    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(
        'SELECT * FROM Pontos WHERE id_funcionario = %s AND EXTRACT(MONTH FROM criado_em) = %s AND EXTRACT(YEAR FROM criado_em) = %s ORDER BY criado_em DESC',
        (id, month, year)
    )
    
    columns = [desc[0] for desc in cur.description]
    pontos_data = cur.fetchall()
    
    pontos = []
    for row in pontos_data:
        pontos.append(dict(zip(columns, row)))

    # Convert datetime and Decimal objects to string/float
    for p in pontos:
        for key, value in p.items():
            if isinstance(value, datetime.datetime):
                p[key] = value.isoformat()
            elif isinstance(value, Decimal):
                p[key] = float(value)

    cur.close()
    conn.close()
    
    # Now, group by date
    pontos_by_date = {}
    for ponto in pontos:
        date_str = datetime.datetime.fromisoformat(ponto['criado_em']).strftime('%Y-%m-%d')
        if date_str not in pontos_by_date:
            pontos_by_date[date_str] = {
                'data': date_str,
                'registros': []
            }
        # just the time part of the timestamp
        time_str = datetime.datetime.fromisoformat(ponto['criado_em']).strftime('%H:%M:%S')
        pontos_by_date[date_str]['registros'].append({
            'time': time_str,
            'latitude': ponto['latitude'],
            'longitude': ponto['longitude']
        })
        
    return jsonify(list(pontos_by_date.values()))



@app.route('/ponto/funcionario/<int:id>', methods=['DELETE'])
def delete_ponto(id):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('DELETE FROM Pontos WHERE id_ponto = %s', (id,))
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({'message': 'Ponto deleted successfully'})

@app.route('/relatorios/horas-trabalhadas/funcionario/<int:id>', methods=['GET'])
def get_relatorio_horas_trabalhadas(id):
    # TODO: Implementar a lógica para calcular as horas trabalhadas
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM Pontos WHERE id_funcionario = %s', (id,))
    pontos = cur.fetchall()
    cur.close()
    conn.close()
    return jsonify({'pontos': pontos})

@app.route('/relatorios/faltas/funcionario/<int:id>', methods=['GET'])
def get_relatorio_faltas(id):
    # TODO: Implementar a lógica para gerar o relatório de faltas
    return jsonify({'message': 'Relatório de faltas a ser implementado'})

@app.route('/jornadas', methods=['POST'])
def create_jornada():
    data = request.get_json()
    conn = get_db_connection()
    cur = conn.cursor()

    id_funcionario = data['id_funcionario']
    
    # Delete existing jornadas for the funcionario to avoid duplicates
    cur.execute('DELETE FROM Jornadas WHERE id_funcionario = %s', (id_funcionario,))

    if data.get('jornada_diferenciada'):
        dias = data['dias']
        for dia_info in dias:
            cur.execute(
                'INSERT INTO Jornadas (id_funcionario, dia_semana, horario_entrada, horario_saida_intervalo, horario_retorno_intervalo, horario_saida) VALUES (%s, %s, %s, %s, %s, %s)',
                (id_funcionario, dia_info['dia_semana'], dia_info.get('horario_entrada'), dia_info.get('horario_saida_intervalo'), dia_info.get('horario_retorno_intervalo'), dia_info.get('horario_saida'))
            )
    else:
        dias_semana = data['dias_semana']
        horario_entrada = data.get('horario_entrada')
        horario_saida_intervalo = data.get('horario_saida_intervalo')
        horario_retorno_intervalo = data.get('horario_retorno_intervalo')
        horario_saida = data.get('horario_saida')
        for dia in dias_semana:
            cur.execute(
                'INSERT INTO Jornadas (id_funcionario, dia_semana, horario_entrada, horario_saida_intervalo, horario_retorno_intervalo, horario_saida) VALUES (%s, %s, %s, %s, %s, %s)',
                (id_funcionario, dia, horario_entrada, horario_saida_intervalo, horario_retorno_intervalo, horario_saida)
            )
    
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({'message': 'Jornadas created successfully'}), 201

@app.route('/jornadas/funcionario/<int:id_funcionario>', methods=['GET'])
def get_jornadas_funcionario(id_funcionario):
    day_of_week = request.args.get('day_of_week', type=int)

    conn = get_db_connection()
    cur = conn.cursor()
    if day_of_week is not None:
        cur.execute('SELECT * FROM Jornadas WHERE id_funcionario = %s AND dia_semana = %s', (id_funcionario, day_of_week))
    else:
        cur.execute('SELECT * FROM Jornadas WHERE id_funcionario = %s', (id_funcionario,))
    
    columns = [desc[0] for desc in cur.description]
    jornadas_data = cur.fetchall()
    jornadas = []
    for row in jornadas_data:
        jornadas.append(dict(zip(columns, row)))

    cur.close()
    conn.close()

    for j in jornadas:
        for key, value in j.items():
            if isinstance(value, datetime.time):
                j[key] = value.strftime('%H:%M:%S')

    return jsonify({'jornadas': jornadas})

@app.route('/jornadas/<int:id_jornada>', methods=['PUT'])
def update_jornada(id_jornada):
    data = request.get_json()
    conn = get_db_connection()
    cur = conn.cursor()

    query_parts = []
    values = []

    fields = [
        'dia_semana', 'horario_entrada', 'horario_saida_intervalo', 
        'horario_retorno_intervalo', 'horario_saida', 'ocorrencia', 'falta'
    ]

    for field in fields:
        if field in data:
            query_parts.append(f"{field} = %s")
            values.append(data[field])

    if not query_parts:
        return jsonify({'message': 'Nenhum dado para atualizar'}), 400

    values.append(id_jornada)
    
    query = f"UPDATE Jornadas SET { ', '.join(query_parts) } WHERE id_jornada = %s"

    cur.execute(query, tuple(values))
    
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({'message': 'Jornada atualizada com sucesso'})

@app.route('/jornadas/<int:id_jornada>', methods=['DELETE'])
def delete_jornada(id_jornada):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('DELETE FROM Jornadas WHERE id_jornada = %s', (id_jornada,))
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({'message': 'Jornada deleted successfully'})

@app.route('/localizacoes', methods=['POST'])
def create_localizacao():
    data = request.get_json()
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(
        'INSERT INTO Localizacoes (id_funcionario, latitude, longitude, raio_permitido) VALUES (%s, %s, %s, %s)',
        (data['id_funcionario'], data['latitude'], data['longitude'], data['raio_permitido'])
    )
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({'message': 'Localizacao created successfully'}), 201

@app.route('/localizacoes/funcionario/<int:id_funcionario>', methods=['GET'])
def get_localizacao_funcionario(id_funcionario):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM Localizacoes WHERE id_funcionario = %s', (id_funcionario,))
    
    columns = [desc[0] for desc in cur.description]
    localizacao_data = cur.fetchone()
    
    if localizacao_data:
        localizacao = dict(zip(columns, localizacao_data))
        for key, value in localizacao.items():
            if isinstance(value, Decimal):
                localizacao[key] = float(value)
        return jsonify({'localizacao': localizacao})
    else:
        return jsonify({'localizacao': None})

@app.route('/localizacoes/<int:id_localizacao>', methods=['PUT'])
def update_localizacao(id_localizacao):
    data = request.get_json()
    conn = get_db_connection()
    cur = conn.cursor()

    query_parts = []
    values = []

    fields = ['latitude', 'longitude', 'raio_permitido']

    for field in fields:
        if field in data:
            query_parts.append(f"{field} = %s")
            values.append(data[field])

    if not query_parts:
        return jsonify({'message': 'Nenhum dado para atualizar'}), 400

    values.append(id_localizacao)
    
    query = f"UPDATE Localizacoes SET { ', '.join(query_parts) } WHERE id_localizacao = %s"

    cur.execute(query, tuple(values))
    
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({'message': 'Localizacao updated successfully'})

@app.route('/localizacoes/<int:id_localizacao>', methods=['DELETE'])
def delete_localizacao(id_localizacao):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('DELETE FROM Localizacoes WHERE id_localizacao = %s', (id_localizacao,))
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({'message': 'Localizacao deleted successfully'})

@app.route('/funcionarios/<int:id_funcionario>/faltas', methods=['GET'])
def get_faltas_funcionario(id_funcionario):
    conn = get_db_connection()
    cur = conn.cursor()

    # 1. Get employee's admission date
    cur.execute('SELECT data_admissao FROM Funcionarios WHERE id_funcionario = %s', (id_funcionario,))
    data_admissao = cur.fetchone()[0]

    # 2. Get employee's work schedule
    cur.execute('SELECT dia_semana FROM Jornadas WHERE id_funcionario = %s', (id_funcionario,))
    dias_de_trabalho = {row[0] for row in cur.fetchall()}

    # 3. Get all time punches for the last 40 days
    end_date = datetime.date.today()
    start_date = end_date - datetime.timedelta(days=40)

    cur.execute(
        'SELECT DISTINCT CAST(criado_em AS DATE) FROM Pontos WHERE id_funcionario = %s AND criado_em >= %s',
        (id_funcionario, start_date)
    )
    dias_com_ponto = {row[0] for row in cur.fetchall()}

    cur.close()
    conn.close()

    # 4. Determine absences
    faltas = []
    # If data_admissao is more recent than start_date, begin from data_admissao
    current_date = max(start_date, data_admissao)

    while current_date <= end_date:
        # weekday() -> Monday is 0 and Sunday is 6
        # dia_semana in Jornadas -> 0: Domingo, 1: Segunda, ..., 6: Sábado
        # We need to map Python's weekday to the database's dia_semana
        dia_semana_db = (current_date.weekday() + 1) % 7 

        if dia_semana_db in dias_de_trabalho and current_date not in dias_com_ponto:
            faltas.append(current_date.isoformat())
        
        current_date += datetime.timedelta(days=1)

    return jsonify({'faltas': faltas})


@app.route('/db-status')
def db_status():
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()

        # Get list of tables
        cur.execute("""
            SELECT tablename
            FROM pg_catalog.pg_tables
            WHERE schemaname != 'pg_catalog' AND schemaname != 'information_schema';
        """)
        tables = [row[0] for row in cur.fetchall()]

        table_counts = []
        for table in tables:
            cur.execute(f'SELECT COUNT(*) FROM {table}')
            count = cur.fetchone()[0]
            table_counts.append({'table_name': table, 'record_count': count})

        # Example DDL and DML from your project
        ddl_example = """
-- Tabela de Funcionários
CREATE TABLE Funcionarios (
    id_funcionario SERIAL PRIMARY KEY,
    id_empresa INT,
    nome VARCHAR(255) NOT NULL,
    sobrenome VARCHAR(255) NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    status BOOLEAN DEFAULT TRUE,
    ...
);
        """.strip()

        dml_example = """
-- Inserir um novo funcionário
INSERT INTO Funcionarios (id_empresa, nome, sobrenome, cpf, email, senha) 
VALUES (1, 'João', 'Silva', '123.456.789-00', 'joao.silva@example.com', 'senha123');
        """.strip()

        db_info = {
            'database_name': os.environ.get("POSTGRES_DB"),
            'status': 'connected',
            'tables': table_counts,
            'ddl_example': ddl_example,
            'dml_example': dml_example
        }

        cur.close()
        return jsonify(db_info)

    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500
    finally:
        if conn:
            conn.close()


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)