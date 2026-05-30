import pika
import os
import json
import time
from dotenv import load_dotenv

load_dotenv()

def callback(ch, method, properties, body):
    message = json.loads(body)
    print(f" [x] Mensagem recebida: {message}")
    
    action = message.get('action')
    
    if action == 'NEW_OCCURRENCE':
        print(f" [!] Nova ocorrência registrada!")
        print(f"     ID: {message.get('id_ocorrencia')}")
        print(f"     Funcionário ID: {message.get('id_funcionario')}")
        print(f"     Tipo: {message.get('tipo')}")
        print(f"     Data: {message.get('data')}")
        print(f"     -> Notificando empregador da empresa {message.get('id_empresa')}...")
        
    elif action == 'STATUS_UPDATED':
        status = message.get('status')
        id_occ = message.get('id_ocorrencia')
        print(f" [√] AÇÃO DO EMPREGADOR: Ocorrência ID {id_occ} foi {status.upper()}.")
        print(f" [x] Mensagem removida da fila de pendências. Notificando funcionário...")

    print(" [x] Processamento concluído.\n")
    ch.basic_ack(delivery_tag=method.delivery_tag)

def start_worker():
    url = os.environ.get('CLOUDAMQP_URL', 'amqp://guest:guest@localhost/%2f')
    params = pika.URLParameters(url)
    
    while True:
        try:
            print(" [*] Conectando ao CloudAMQP...")
            connection = pika.BlockingConnection(params)
            channel = connection.channel()
            
            channel.queue_declare(queue='ocorrencias_fila', durable=True)
            print(' [*] Aguardando mensagens. Para sair pressione CTRL+C')

            channel.basic_qos(prefetch_count=1)
            channel.basic_consume(queue='ocorrencias_fila', on_message_callback=callback)

            channel.start_consuming()
        except pika.exceptions.AMQPConnectionError:
            print(" [!] Erro de conexão. Tentando novamente em 5 segundos...")
            time.sleep(5)
        except Exception as e:
            print(f" [!] Erro inesperado: {e}")
            time.sleep(5)

if __name__ == "__main__":
    start_worker()
