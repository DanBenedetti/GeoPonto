import pika
import os
import json
import sys
from dotenv import load_dotenv

load_dotenv()

def test_connection():
    try:
        url = os.environ.get('CLOUDAMQP_URL', 'amqp://guest:guest@localhost/%2f')
        print(f"[*] Tentando conectar a: {url.split('@')[-1]}") # Esconde credenciais
        params = pika.URLParameters(url)
        params.connection_attempts = 3
        params.retry_delay = 2
        
        connection = pika.BlockingConnection(params)
        channel = connection.channel()
        channel.queue_declare(queue='ocorrencias_fila', durable=True)
        
        test_msg = {'action': 'TEST_CONNECTION', 'timestamp': 'now'}
        channel.basic_publish(
            exchange='',
            routing_key='ocorrencias_fila',
            body=json.dumps(test_msg)
        )
        print("[v] Conexão e Publicação: OK")
        
        connection.close()
        return True
    except Exception as e:
        print(f"[!] Erro no teste de mensageria: {e}")
        return False

if __name__ == "__main__":
    if not test_connection():
        sys.exit(1)
