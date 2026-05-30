from flask import Flask, jsonify, request
from flask_cors import CORS
import psycopg2
import os
from dotenv import load_dotenv
import datetime
from decimal import Decimal
import numpy as np
import tensorflow as tf
from PIL import Image
import io
import pika
import json

load_dotenv()

app = Flask(__name__)
CORS(app)

# Carregamento do Modelo de Biometria (Singleton)
MODEL_PATH = os.path.join(os.path.dirname(__file__), '..', 'Biometria', 'modelo_final_homologado.keras')
biometry_extractor = None

def get_biometry_model():
    global biometry_extractor
    if biometry_extractor is None:
        if os.path.exists(MODEL_PATH):
            try:
                print(f"Carregando modelo de biometria de: {MODEL_PATH}")
                full_model = tf.keras.models.load_model(MODEL_PATH)
                # Criamos um novo modelo que vai até a camada de 'embedding' (128 unidades)
                # Isso garante que o servidor retorne exatamente o que o mobile espera.
                biometry_extractor = tf.keras.Model(
                    inputs=full_model.input,
                    outputs=full_model.get_layer('embedding').output if 'embedding' in [l.name for l in full_model.layers] else full_model.layers[-2].output
                )
                print("Extrator de biometria configurado com sucesso!")
            except Exception as e:
                print(f"Erro ao configurar extrator: {e}")
        else:
            print(f"AVISO: Modelo não encontrado em {MODEL_PATH}")
    return biometry_extractor

def get_db_connection():
    conn = psycopg2.connect(
        host=os.environ.get("POSTGRES_HOST", "localhost"),
        database=os.environ.get("POSTGRES_DB"),
        user=os.environ.get("POSTGRES_USER"),
        password=os.environ.get("POSTGRES_PASSWORD"),
        port=int(os.environ.get("POSTGRES_PORT", 5432))
    )
    return conn

@app.route('/biometry/extract', methods=['POST'])
def extract_biometry():
    if 'image' not in request.files:
        return jsonify({'message': 'Nenhuma imagem enviada'}), 400
    
    file = request.files['image']
    model = get_biometry_model()
    
    if model is None:
        return jsonify({'message': 'Modelo de biometria não disponível no servidor'}), 503

    try:
        # Processamento da imagem (Exatamente como no Mobile)
        img = Image.open(file.stream).convert('RGB')
        img = img.resize((224, 224))
        img_array = np.array(img).astype(np.float32)
        
        # Removida a normalização /255 pois o modelo v8.3.1 usa 0-255
        img_array = np.expand_dims(img_array, axis=0) 

        # Extração do embedding
        embedding = model.predict(img_array)
        embedding_list = embedding[0].tolist()

        return jsonify({'embedding': embedding_list})
    except Exception as e:
        print(f"Erro no processamento de biometria: {e}")
        return jsonify({'message': f'Erro ao processar imagem: {str(e)}'}), 500

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
    cur.execute('SELECT id_empresa FROM empresas WHERE username = %s AND senha = %s', (data['username'], data['senha']))
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
    cur.execute('SELECT id_funcionario, id_empresa FROM funcionarios WHERE email = %s AND senha = %s AND status = TRUE', (data['email'], data['senha']))
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
        'INSERT INTO empresas (nome_fantasia, razao_social, cnpj, senha, cep, logradouro, numero, bairro, cidade, estado, pais, username) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)',
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
    cur.execute('SELECT * FROM empresas')
    empresas = cur.fetchall()
    cur.close()
    conn.close()
    return jsonify({'empresas': empresas})

@app.route('/empresas/<int:id>', methods=['GET'])
def get_empresa(id):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM empresas WHERE id_empresa = %s', (id,))
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



@app.route('/analytics/page-view', methods=['POST'])
def record_page_view():
    data = request.get_json()
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(
        'INSERT INTO page_views (page_name, render_time_ms) VALUES (%s, %s)',
        (data['page_name'], data['render_time_ms'])
    )
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({'status': 'success'}), 201

@app.route('/analytics/button-click', methods=['POST'])
def record_button_click():
    data = request.get_json()
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(
        'INSERT INTO button_clicks (button_id, page_name) VALUES (%s, %s)',
        (data['button_id'], data.get('page_name'))
    )
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({'status': 'success'}), 201

@app.route('/analytics/metrics', methods=['GET'])
def get_analytics_metrics():
    conn = get_db_connection()
    cur = conn.cursor()

    # Páginas mais acessadas
    cur.execute("""
        SELECT page_name, COUNT(*) as view_count
        FROM page_views
        GROUP BY page_name
        ORDER BY view_count DESC
        LIMIT 5;
    """)
    most_accessed_pages = [{'page_name': row[0], 'view_count': row[1]} for row in cur.fetchall()]

    # Botões mais clicados
    cur.execute("""
        SELECT button_id, COUNT(*) as click_count
        FROM button_clicks
        GROUP BY button_id
        ORDER BY click_count DESC
        LIMIT 5;
    """)
    most_clicked_buttons = [{'button_id': row[0], 'click_count': row[1]} for row in cur.fetchall()]

    # Páginas mais pesadas (maior tempo médio de renderização)
    cur.execute("""
        SELECT page_name, AVG(render_time_ms) as avg_render_time
        FROM page_views
        GROUP BY page_name
        ORDER BY avg_render_time DESC
        LIMIT 5;
    """)
    slowest_pages = [{'page_name': row[0], 'avg_render_time': float(row[1])} for row in cur.fetchall()]

    cur.close()
    conn.close()

    return jsonify({
        'most_accessed_pages': most_accessed_pages,
        'most_clicked_buttons': most_clicked_buttons,
        'slowest_pages': slowest_pages
    })

def send_to_queue(message):
    try:
        url = os.environ.get('CLOUDAMQP_URL', 'amqp://guest:guest@localhost/%2f')
        params = pika.URLParameters(url)
        connection = pika.BlockingConnection(params)
        channel = connection.channel()
        channel.queue_declare(queue='ocorrencias_fila', durable=True)
        channel.basic_publish(
            exchange='',
            routing_key='ocorrencias_fila',
            body=json.dumps(message),
            properties=pika.BasicProperties(
                delivery_mode=2,  # make message persistent
            ))
        connection.close()
    except Exception as e:
        print(f"Erro ao enviar para a fila: {e}")

@app.route('/ocorrencias', methods=['POST'])
def create_ocorrencia():
    data = request.get_json()
    conn = get_db_connection()
    cur = conn.cursor()
    
    # Precisamos do id_empresa do funcionário
    cur.execute('SELECT id_empresa FROM funcionarios WHERE id_funcionario = %s', (data['id_funcionario'],))
    empresa_data = cur.fetchone()
    if not empresa_data:
        cur.close()
        conn.close()
        return jsonify({'message': 'Funcionário não encontrado'}), 404
    
    id_empresa = empresa_data[0]

    cur.execute(
        'INSERT INTO ocorrencias (id_funcionario, id_empresa, data_ocorrencia, tipo, descricao, anexo_url) VALUES (%s, %s, %s, %s, %s, %s) RETURNING id_ocorrencia',
        (data['id_funcionario'], id_empresa, data['data_ocorrencia'], data['tipo'], data.get('descricao'), data.get('anexo_url'))
    )
    id_ocorrencia = cur.fetchone()[0]
    conn.commit()
    
    # Enviar mensagem para a fila
    message = {
        'action': 'NEW_OCCURRENCE',
        'id_ocorrencia': id_ocorrencia,
        'id_funcionario': data['id_funcionario'],
        'id_empresa': id_empresa,
        'tipo': data['tipo'],
        'data': data['data_ocorrencia']
    }
    send_to_queue(message)

    cur.close()
    conn.close()
    return jsonify({'message': 'Ocorrência criada com sucesso', 'id_ocorrencia': id_ocorrencia}), 201

@app.route('/ocorrencias/empresa/<int:id_empresa>', methods=['GET'])
def get_ocorrencias_empresa(id_empresa):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("""
        SELECT o.*, f.nome, f.sobrenome 
        FROM ocorrencias o
        JOIN funcionarios f ON o.id_funcionario = f.id_funcionario
        WHERE o.id_empresa = %s
        ORDER BY o.criado_em DESC
    """, (id_empresa,))
    
    columns = [desc[0] for desc in cur.description]
    rows = cur.fetchall()
    ocorrencias = [dict(zip(columns, row)) for row in rows]
    
    for o in ocorrencias:
        for key, value in o.items():
            if isinstance(value, (datetime.datetime, datetime.date)):
                o[key] = value.isoformat()
    
    cur.close()
    conn.close()
    return jsonify(ocorrencias)

@app.route('/ocorrencias/funcionario/<int:id_funcionario>', methods=['GET'])
def get_ocorrencias_funcionario(id_funcionario):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("""
        SELECT * 
        FROM ocorrencias
        WHERE id_funcionario = %s
        ORDER BY data_ocorrencia DESC
    """, (id_funcionario,))
    
    columns = [desc[0] for desc in cur.description]
    rows = cur.fetchall()
    ocorrencias = [dict(zip(columns, row)) for row in rows]
    
    for o in ocorrencias:
        for key, value in o.items():
            if isinstance(value, (datetime.datetime, datetime.date)):
                o[key] = value.isoformat()
                
    cur.close()
    conn.close()
    return jsonify(ocorrencias)

@app.route('/ocorrencias/<int:id_ocorrencia>/status', methods=['PUT'])

def update_ocorrencia_status(id_ocorrencia):
    data = request.get_json()
    status = data.get('status')
    if not status:
        return jsonify({'message': 'Status é obrigatório'}), 400

    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(
        'UPDATE ocorrencias SET status = %s, atualizado_em = CURRENT_TIMESTAMP WHERE id_ocorrencia = %s',
        (status, id_ocorrencia)
    )
    conn.commit()
    
    # Enviar mensagem para a fila sobre a atualização
    message = {
        'action': 'STATUS_UPDATED',
        'id_ocorrencia': id_ocorrencia,
        'status': status
    }
    send_to_queue(message)

    cur.close()
    conn.close()
    return jsonify({'message': f'Ocorrência {status} com sucesso'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
