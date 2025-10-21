#!/bin/bash

# Para o script se qualquer comando falhar
set -e

# Detecta o endereço IP do host (testado em Linux)
# Este comando extrai o primeiro endereço IPv4 que não seja o localhost.
HOST_IP=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -n 1)

# Verifica se o IP foi encontrado
if [ -z "$HOST_IP" ]; then
    echo "ERRO: Não foi possível determinar o endereço IP do host."
    exit 1
fi

echo "=================================================="
echo "Endereço IP do Host detectado: $HOST_IP"
echo "=================================================="

echo ""
echo "-> Iniciando contêineres do backend com Docker Compose..."
# Sobe os contêineres em modo detached (background) e força o rebuild se necessário
docker-compose up -d --build

echo "-> Backend iniciado com sucesso."
echo ""
echo "-> Iniciando aplicativo Flutter (aguarde, isso pode levar um momento)..."

# Define a URL da API para o Flutter
API_URL="http://$HOST_IP:5001"

# Navega para o diretório do frontend e executa o app
# passando a URL da API como uma variável de ambiente para o Dart.
cd frontend
flutter run --dart-define="API_BASE_URL=$API_URL"

echo ""
echo "=================================================="
echo "Para parar os serviços do backend, execute:"
echo "docker-compose down"
echo "=================================================="
