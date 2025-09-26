from flask import Flask, jsonify, request
import psycopg2
import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)

def get_db_connection():
    conn = psycopg2.connect(
        host="postgres",
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

@app.route('/login', methods=['POST'])
def login():
    # TODO: Implementar a lógica de autenticação
    return jsonify({'token': 'dummy-token'})

@app.route('/empresas', methods=['POST'])
def create_empresa():
    data = request.get_json()
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(
        'INSERT INTO Empresas (nome_fantasia, razao_social, cnpj, cep, logradouro, numero, bairro, cidade, estado, pais) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)',
        (data['nome_fantasia'], data['razao_social'], data['cnpj'], data['cep'], data['logradouro'], data['numero'], data['bairro'], data['cidade'], data['estado'], data['pais'])
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
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(
        'INSERT INTO Funcionarios (id_empresa, nome, sobrenome, cpf, email, senha, cargo, departamento, carga_horaria_semanal) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)',
        (data['id_empresa'], data['nome'], data['sobrenome'], data['cpf'], data['email'], data['senha'], data['cargo'], data['departamento'], data['carga_horaria_semanal'])
    )
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({'message': 'Funcionario created successfully'}), 201

@app.route('/funcionarios', methods=['GET'])
def get_funcionarios():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM Funcionarios')
    funcionarios = cur.fetchall()
    cur.close()
    conn.close()
    return jsonify({'funcionarios': funcionarios})

@app.route('/funcionarios/<int:id>', methods=['GET'])
def get_funcionario(id):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM Funcionarios WHERE id_funcionario = %s', (id,))
    funcionario = cur.fetchone()
    cur.close()
    conn.close()
    return jsonify({'funcionario': funcionario})

@app.route('/funcionarios/<int:id>', methods=['PUT'])
def update_funcionario(id):
    data = request.get_json()
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(
        'UPDATE Funcionarios SET id_empresa = %s, nome = %s, sobrenome = %s, cpf = %s, email = %s, senha = %s, cargo = %s, departamento = %s, carga_horaria_semanal = %s WHERE id_funcionario = %s',
        (data['id_empresa'], data['nome'], data['sobrenome'], data['cpf'], data['email'], data['senha'], data['cargo'], data['departamento'], data['carga_horaria_semanal'], id)
    )
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({'message': 'Funcionario updated successfully'})

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

# --- Endpoints de Métricas A/B ---
@app.route('/ab-metric', methods=['POST'])
def ab_metric():
    data = request.get_json()
    variant = data.get('variant')
    load_time_ms = data.get('load_time_ms')
    action = data.get('action')

    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(
        'INSERT INTO ab_metrics (variant, load_time_ms, action) VALUES (%s, %s, %s)',
        (variant, load_time_ms, action)
    )
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({'message': 'Metric received'}), 201

@app.route('/ab-metric', methods=['GET'])
def get_ab_metrics():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT variant, AVG(load_time_ms), COUNT(*) FROM ab_metrics GROUP BY variant')
    results = cur.fetchall()
    cur.close()
    conn.close()
    metrics = [
        {'variant': r[0], 'avg_load_time_ms': float(r[1]), 'count': r[2]}
        for r in results
    ]
    return jsonify({'metrics': metrics})

@app.route('/ab-dashboard')
def ab_dashboard():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT variant, AVG(load_time_ms), COUNT(*) FROM ab_metrics GROUP BY variant')
    results = cur.fetchall()
    cur.close()
    conn.close()
    html = "<h1>Dashboard A/B</h1><table border='1'><tr><th>Variante</th><th>Média Tempo (ms)</th><th>Exibições</th></tr>"
    for r in results:
        html += f"<tr><td>{r[0]}</td><td>{r[1]:.2f}</td><td>{r[2]}</td></tr>"
    html += "</table>"
    return html

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)