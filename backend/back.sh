#!/bin/bash

# Script para Iniciar o Backend GeoPonto em Segundo Plano
# -----------------------------------------------------

# 1. Verificar/Criar o Ambiente Virtual
if [ ! -d "venv" ]; then
    echo "⚠️ Ambiente virtual não encontrado. Criando..."
    python3 -m venv venv
    source venv/bin/activate
    echo "📦 Instalando dependências (isso pode demorar na primeira vez)..."
    pip install --upgrade pip
    pip install -r requirements.txt
else
    source venv/bin/activate
fi

# 2. Iniciar Gunicorn em Segundo Plano (nohup)
echo "🚀 Iniciando Backend GeoPonto na porta 5000..."
# Usamos o caminho completo do gunicorn do venv para garantir
./venv/bin/gunicorn --bind 0.0.0.0:5000 main:app > backend.log 2>&1 &

# 3. Salvar o PID do processo para facilitar o desligamento posterior
echo $! > backend.pid

echo "✅ Backend iniciado em segundo plano (logs em backend.log)!"
echo "Para parar o servidor, execute: ./stop.sh"
