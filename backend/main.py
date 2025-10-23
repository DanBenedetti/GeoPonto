from flask import Flask, jsonify, request
import psycopg2
import os
from dotenv import load_dotenv
import datetime

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
            'INSERT INTO Funcionarios (id_empresa, nome_completo, cpf, rua, numero, bairro, cidade, cep, email, telefone, cargo, senha, horario_entrada, horario_saida_intervalo, horario_retorno_intervalo, horario_saida) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)',
            (data['id_empresa'], data['nome_completo'], data['cpf'], data['rua'], data['numero'], data['bairro'], data['cidade'], data['cep'], data['email'], data['telefone'], data['cargo'], data['senha'], data['horario_entrada'], data['horario_saida_intervalo'], data['horario_retorno_intervalo'], data['horario_saida'])
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
    
    # Convert TIME objects to strings
    for f in funcionarios:
        for key, value in f.items():
            if isinstance(value, datetime.time):
                f[key] = value.strftime('%H:%M:%S')

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
        # Convert TIME objects to strings
        for key, value in funcionario.items():
            if isinstance(value, datetime.time):
                funcionario[key] = value.strftime('%H:%M:%S')
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
        'nome_completo', 'cpf', 'rua', 'numero', 'bairro', 'cidade', 
        'cep', 'email', 'telefone', 'cargo', 'horario_entrada', 
        'horario_saida_intervalo', 'horario_retorno_intervalo', 'horario_saida'
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
        'INSERT INTO Pontos (id_funcionario, latitude, longitude, tipo_ponto) VALUES (%s, %s, %s, %s)',
        (id, data['latitude'], data['longitude'], data['tipo_ponto'])
    )
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({'message': 'Ponto created successfully'}), 201

@app.route('/ponto/funcionario/<int:id>', methods=['GET'])
def get_pontos_funcionario(id):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM Pontos WHERE id_funcionario = %s', (id,))
    pontos = cur.fetchall()
    cur.close()
    conn.close()
    return jsonify({'pontos': pontos})

@app.route('/ponto/funcionario/<int:id>', methods=['PUT'])
def update_ponto(id):
    data = request.get_json()
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(
        'UPDATE Pontos SET tipo_ponto = %s, latitude = %s, longitude = %s WHERE id_ponto = %s',
        (data['tipo_ponto'], data['latitude'], data['longitude'], id)
    )
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({'message': 'Ponto updated successfully'})

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

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)