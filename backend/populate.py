import os
import random
from datetime import datetime, timedelta
from dotenv import load_dotenv

# Carrega as variáveis do arquivo .env
load_dotenv()

from main import get_db_connection

def populate_data():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        # 1. Encontrar a empresa 'admin@empresa.com' (vamos pegar a primeira se não existir)
        cur.execute("SELECT id_empresa FROM empresas LIMIT 1")
        res = cur.fetchone()
        if not res:
            print("Criando empresa padrão...")
            cur.execute("""
                INSERT INTO empresas (nome_fantasia, razao_social, cnpj, senha, username)
                VALUES ('Empresa Teste', 'Empresa Teste LTDA', '00.000.000/0001-00', '123456', 'admin@empresa.com')
                RETURNING id_empresa
            """)
            id_empresa = cur.fetchone()[0]
        else:
            id_empresa = res[0]
        
        # 2. Obter TODOS os funcionários
        cur.execute("SELECT id_funcionario FROM funcionarios")
        rows = cur.fetchall()
        ids_funcionarios = [row[0] for row in rows]
        
        # 3. Gerar pontos simulados
        # Limpar pontos antigos desses funcionarios
        for id_func in ids_funcionarios:
            cur.execute("DELETE FROM pontos WHERE id_funcionario = %s", (id_func,))
            
        dias_para_simular = 30
        hoje = datetime.now()
        
        for id_func in ids_funcionarios:
            for i in range(dias_para_simular):
                dia = hoje - timedelta(days=i)
                # Pula finais de semana na maioria das vezes
                if dia.weekday() >= 5:
                    continue
                    
                # Adiciona alguma aleatoriedade (faltas ou pontos normais)
                if random.random() < 0.1:
                    # 10% de chance de falta (sem pontos)
                    continue
                    
                # Horários base: 08:00, 12:00, 13:00, 17:00
                # Adiciona minutos aleatorios
                def t(h, m):
                    return dia.replace(hour=h, minute=m, second=0, microsecond=0) + timedelta(minutes=random.randint(-15, 30))
                    
                pontos_dia = [
                    t(8, 0),
                    t(12, 0),
                    t(13, 0),
                    t(17, 0)
                ]
                
                # Se for o Carlos (ou um ID par), às vezes faz hora extra
                if id_func % 2 == 0 and random.random() < 0.3:
                    pontos_dia[3] = t(19, 0) # Sai as 19:00
                    
                # Se for outro, às vezes se atrasa
                if id_func % 2 != 0 and random.random() < 0.2:
                    pontos_dia[0] = t(8, 45) # Chega as 08:45
                    
                for pt in pontos_dia:
                    cur.execute("""
                        INSERT INTO pontos (id_funcionario, latitude, longitude, criado_em)
                        VALUES (%s, -20.5, -47.3, %s)
                    """, (id_func, pt))
                    
        conn.commit()
        cur.close()
        conn.close()
        print("Pontos simulados inseridos com sucesso!")
    except Exception as e:
        print(f"Erro: {e}")

if __name__ == '__main__':
    populate_data()
