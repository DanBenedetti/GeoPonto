import psycopg2
import os
from dotenv import load_dotenv

load_dotenv()

def create_table():
    conn = psycopg2.connect(
        host=os.environ.get("POSTGRES_HOST", "localhost"),
        database=os.environ.get("POSTGRES_DB"),
        user=os.environ.get("POSTGRES_USER"),
        password=os.environ.get("POSTGRES_PASSWORD"),
        port=int(os.environ.get("POSTGRES_PORT", 5432))
    )
    cur = conn.cursor()
    cur.execute("""
    CREATE TABLE IF NOT EXISTS ocorrencias (
        id_ocorrencia SERIAL PRIMARY KEY,
        id_funcionario INT NOT NULL,
        id_empresa INT NOT NULL,
        data_ocorrencia DATE NOT NULL,
        tipo VARCHAR(100) NOT NULL,
        descricao TEXT,
        anexo_url TEXT,
        status VARCHAR(50) DEFAULT 'Pendente',
        criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (id_funcionario) REFERENCES funcionarios(id_funcionario),
        FOREIGN KEY (id_empresa) REFERENCES empresas(id_empresa)
    );
    """)
    conn.commit()
    cur.close()
    conn.close()
    print("Tabela ocorrencias criada com sucesso!")

if __name__ == "__main__":
    create_table()
