import os
import sys
from datetime import datetime, timedelta, time
from dotenv import load_dotenv

# Carrega as variáveis do arquivo .env
load_dotenv()

try:
    from main import get_db_connection
except ImportError:
    # Caso execute fora da pasta ou com algum problema de importação do main.py
    import psycopg2
    def get_db_connection():
        return psycopg2.connect(
            host=os.environ.get("POSTGRES_HOST", "localhost"),
            database=os.environ.get("POSTGRES_DB"),
            user=os.environ.get("POSTGRES_USER"),
            password=os.environ.get("POSTGRES_PASSWORD"),
            port=int(os.environ.get("POSTGRES_PORT", 5432))
        )

def main():
    print("==================================================")
    print("   GeoPonto - Gerador de Ocorrências para Testes   ")
    print("==================================================")
    
    conn = None
    cur = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
    except Exception as e:
        print(f"Erro ao conectar ao banco de dados: {e}")
        sys.exit(1)
        
    try:
        # 1. Solicitar ID da Empresa
        id_empresa_input = input("Digite o ID da empresa: ").strip()
        if not id_empresa_input.isdigit():
            print("Erro: O ID da empresa deve ser um número inteiro.")
            return
        id_empresa = int(id_empresa_input)
        
        # Verificar se a empresa existe
        cur.execute("SELECT nome_fantasia FROM empresas WHERE id_empresa = %s", (id_empresa,))
        empresa = cur.fetchone()
        if not empresa:
            print(f"Erro: Empresa com ID {id_empresa} não encontrada.")
            return
        print(f"Empresa encontrada: {empresa[0]}")
        
        # 2. Solicitar ID do Funcionário
        id_funcionario_input = input("Digite o ID do funcionário: ").strip()
        if not id_funcionario_input.isdigit():
            print("Erro: O ID do funcionário deve ser um número inteiro.")
            return
        id_funcionario = int(id_funcionario_input)
        
        # Verificar se o funcionário existe e pertence à empresa
        cur.execute(
            "SELECT nome, sobrenome, id_empresa FROM funcionarios WHERE id_funcionario = %s",
            (id_funcionario,)
        )
        funcionario = cur.fetchone()
        if not funcionario:
            print(f"Erro: Funcionário com ID {id_funcionario} não encontrado.")
            return
        
        nome_func, sobrenome_func, id_emp_func = funcionario
        if id_emp_func != id_empresa:
            print(f"Erro: O funcionário {nome_func} {sobrenome_func} pertence à empresa com ID {id_emp_func}, não à empresa {id_empresa}.")
            return
        print(f"Funcionário selecionado: {nome_func} {sobrenome_func}")
        
        # 3. Calcular datas das últimas 4 semanas (segunda-feira de cada semana)
        hoje = datetime.now().date()
        # Segunda-feira da semana atual
        segunda_atual = hoje - timedelta(days=hoje.weekday())
        
        datas_semanas = [
            segunda_atual - timedelta(weeks=4), # Semana 1 (4 semanas atrás)
            segunda_atual - timedelta(weeks=3), # Semana 2 (3 semanas atrás)
            segunda_atual - timedelta(weeks=2), # Semana 3 (2 semanas atrás)
            segunda_atual - timedelta(weeks=1)  # Semana 4 (1 semana atrás)
        ]
        
        print("\nDatas selecionadas para gerar as ocorrências:")
        for idx, dt in enumerate(datas_semanas, 1):
            print(f"  Semana {idx}: {dt.strftime('%d/%m/%Y')} (Segunda-feira)")
        
        confirmacao = input("\nConfirma a reescrita das jornadas nessas datas para gerar as ocorrências? (s/n): ").strip().lower()
        if confirmacao != 's':
            print("Operação cancelada.")
            return

        # 4. Processar cada semana
        
        # --- SEMANA 1: Falta (sem marcação de ponto) ---
        dt_s1 = datas_semanas[0]
        # Limpar pontos e ocorrências da data
        cur.execute("DELETE FROM pontos WHERE id_funcionario = %s AND CAST(criado_em AS DATE) = %s", (id_funcionario, dt_s1))
        cur.execute("DELETE FROM ocorrencias WHERE id_funcionario = %s AND data_ocorrencia = %s", (id_funcionario, dt_s1))
        
        # Inserir ocorrência de Falta
        cur.execute("""
            INSERT INTO ocorrencias (id_funcionario, id_empresa, data_ocorrencia, tipo, descricao, status)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (
            id_funcionario,
            id_empresa,
            dt_s1,
            'Falta',
            'Ausência injustificada - Nenhum registro de ponto encontrado para este dia de trabalho.',
            'Pendente'
        ))
        print(f"✅ Semana 1 ({dt_s1}): Falta gerada (0 marcações e registro de ocorrência inserido).")

        # --- SEMANA 2: Jornada com 2 horas a menos (4 marcações) ---
        dt_s2 = datas_semanas[1]
        cur.execute("DELETE FROM pontos WHERE id_funcionario = %s AND CAST(criado_em AS DATE) = %s", (id_funcionario, dt_s2))
        cur.execute("DELETE FROM ocorrencias WHERE id_funcionario = %s AND data_ocorrencia = %s", (id_funcionario, dt_s2))
        
        # Inserir 4 marcações (jornada reduzida: 8h às 12h [4h] e 13h às 15h [2h] = 6h no total, 2h a menos)
        horarios_s2 = [
            datetime.combine(dt_s2, time(8, 0)),
            datetime.combine(dt_s2, time(12, 0)),
            datetime.combine(dt_s2, time(13, 0)),
            datetime.combine(dt_s2, time(15, 0))
        ]
        for hr in horarios_s2:
            cur.execute("""
                INSERT INTO pontos (id_funcionario, latitude, longitude, criado_em)
                VALUES (%s, -20.5, -47.3, %s)
            """, (id_funcionario, hr))
            
        # Inserir ocorrência correspondente
        cur.execute("""
            INSERT INTO ocorrencias (id_funcionario, id_empresa, data_ocorrencia, tipo, descricao, status)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (
            id_funcionario,
            id_empresa,
            dt_s2,
            'Jornada Incompleta',
            'Jornada diária com 2 horas a menos do que o esperado (total trabalhado: 6 horas).',
            'Pendente'
        ))
        print(f"✅ Semana 2 ({dt_s2}): Jornada de 6h gerada (4 marcações e ocorrência de jornada incompleta inserida).")

        # --- SEMANA 3: Sem registro de saída (apenas 3 marcações) ---
        dt_s3 = datas_semanas[2]
        cur.execute("DELETE FROM pontos WHERE id_funcionario = %s AND CAST(criado_em AS DATE) = %s", (id_funcionario, dt_s3))
        cur.execute("DELETE FROM ocorrencias WHERE id_funcionario = %s AND data_ocorrencia = %s", (id_funcionario, dt_s3))
        
        # Inserir 3 marcações (Entrada, Saída Almoço, Retorno Almoço - Sem Saída Final)
        horarios_s3 = [
            datetime.combine(dt_s3, time(8, 0)),
            datetime.combine(dt_s3, time(12, 0)),
            datetime.combine(dt_s3, time(13, 0))
        ]
        for hr in horarios_s3:
            cur.execute("""
                INSERT INTO pontos (id_funcionario, latitude, longitude, criado_em)
                VALUES (%s, -20.5, -47.3, %s)
            """, (id_funcionario, hr))
            
        # Inserir ocorrência correspondente
        cur.execute("""
            INSERT INTO ocorrencias (id_funcionario, id_empresa, data_ocorrencia, tipo, descricao, status)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (
            id_funcionario,
            id_empresa,
            dt_s3,
            'Ponto Incompleto',
            'Jornada sem registro de saída (apenas 3 marcações realizadas).',
            'Pendente'
        ))
        print(f"✅ Semana 3 ({dt_s3}): Ponto incompleto gerado (3 marcações e ocorrência inserida).")

        # --- SEMANA 4: Mais de 6 marcações (7 marcações no total) ---
        dt_s4 = datas_semanas[3]
        cur.execute("DELETE FROM pontos WHERE id_funcionario = %s AND CAST(criado_em AS DATE) = %s", (id_funcionario, dt_s4))
        cur.execute("DELETE FROM ocorrencias WHERE id_funcionario = %s AND data_ocorrencia = %s", (id_funcionario, dt_s4))
        
        # Inserir 7 marcações
        horarios_s4 = [
            datetime.combine(dt_s4, time(8, 0)),   # Entrada
            datetime.combine(dt_s4, time(12, 0)),  # Saída almoço
            datetime.combine(dt_s4, time(13, 0)),  # Retorno almoço
            datetime.combine(dt_s4, time(15, 0)),  # Saída acidental
            datetime.combine(dt_s4, time(15, 15)), # Retorno acidental
            datetime.combine(dt_s4, time(17, 0)),  # Saída oficial
            datetime.combine(dt_s4, time(17, 5))   # Marcação extra duplicada
        ]
        for hr in horarios_s4:
            cur.execute("""
                INSERT INTO pontos (id_funcionario, latitude, longitude, criado_em)
                VALUES (%s, -20.5, -47.3, %s)
            """, (id_funcionario, hr))
            
        # Inserir ocorrência correspondente
        cur.execute("""
            INSERT INTO ocorrencias (id_funcionario, id_empresa, data_ocorrencia, tipo, descricao, status)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (
            id_funcionario,
            id_empresa,
            dt_s4,
            'Excesso de Marcações',
            'Registro de ponto inconsistente com mais de 6 marcações (total de 7 marcações).',
            'Pendente'
        ))
        print(f"✅ Semana 4 ({dt_s4}): Excesso de marcações gerado (7 marcações e ocorrência inserida).")
        
        conn.commit()
        print("\n🎉 Todas as ocorrências de teste foram geradas e salvas com sucesso!")
        
    except Exception as e:
        print(f"\n❌ Erro durante a geração das ocorrências: {e}")
        if conn:
            conn.rollback()
    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()

if __name__ == '__main__':
    main()
