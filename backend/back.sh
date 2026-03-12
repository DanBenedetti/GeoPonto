#!/bin/bash

# Script para Iniciar o Backend GeoPonto em Segundo Plano
# -----------------------------------------------------

# 1. Ativar o Ambiente Virtual
source venv/bin/activate

# 2. Iniciar Gunicorn em Segundo Plano (nohup)
echo "🚀 Iniciando Backend GeoPonto na porta 5000..."
nohup gunicorn --bind 0.0.0.0:5000 main:app > backend.log 2>&1 &

# 3. Salvar o PID do processo para facilitar o desligamento posterior
echo $! > backend.pid

echo "✅ Backend iniciado em segundo plano (logs em backend.log)!"
echo "Para parar o servidor, execute: ./stop.sh"
