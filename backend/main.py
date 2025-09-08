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
        return jsonify({"status": "error", "message": str(e)})

@app.route('/empresas', methods=['POST'])
def create_empresa():
    # Logic to create a new company
    return jsonify({'message': 'Empresa created successfully'}), 201

@app.route('/empresas', methods=['GET'])
def get_empresas():
    # Logic to get all companies
    return jsonify({'empresas': []})

@app.route('/empresas/<int:id>', methods=['GET'])
def get_empresa(id):
    # Logic to get a specific company
    return jsonify({'empresa': {}})

@app.route('/empresas/<int:id>', methods=['PUT'])
def update_empresa(id):
    # Logic to update a company
    return jsonify({'message': 'Empresa updated successfully'})

@app.route('/empresas/<int:id>', methods=['DELETE'])
def delete_empresa(id):
    # Logic to delete a company
    return jsonify({'message': 'Empresa deleted successfully'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)