#!/bin/bash

# Script para Parar o Backend GeoPonto
# -----------------------------------

if [ -f backend.pid ]; then
    PID=$(cat backend.pid)
    echo "🛑 Parando servidor (PID: $PID)..."
    kill $PID
    rm backend.pid
    echo "✅ Servidor parado!"
else
    echo "⚠️ O servidor não está rodando (arquivo backend.pid não encontrado)."
fi
