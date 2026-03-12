#!/bin/bash

# Script de configuração automática para VM Azure (Ubuntu/Debian)
# GeoPonto Backend - Instalação sem Docker

echo "🚀 Iniciando configuração do ambiente GeoPonto..."

# 1. Atualizar pacotes
echo "📦 Atualizando pacotes do sistema..."
sudo apt update && sudo apt upgrade -y

# 2. Instalar PostgreSQL
echo "🐘 Instalando PostgreSQL..."
sudo apt install -y postgresql postgresql-contrib

# 3. Instalar Python e Venv
echo "🐍 Instalando Python e ferramentas de ambiente virtual..."
sudo apt install -y python3-venv python3-pip libpq-dev

# 4. Criar ambiente virtual
echo "🛠️ Criando ambiente virtual Python..."
python3 -m venv venv
source venv/bin/activate

# 5. Instalar dependências do projeto
echo "📚 Instalando dependências do backend..."
pip install --upgrade pip
pip install -r requirements.txt

# 6. Preparar arquivo de ambiente
if [ ! -f .env ]; then
    echo "📝 Criando arquivo .env a partir do exemplo..."
    cp .env.example .env
    echo "⚠️  ATENÇÃO: Lembre-se de editar o arquivo .env com suas credenciais!"
fi

echo "✅ Configuração básica concluída!"
echo ""
echo "PRÓXIMOS PASSOS:"
echo "1. Configure o banco de dados conforme o README.md."
echo "2. Ative o ambiente virtual: source venv/bin/activate"
echo "3. Execute o servidor: gunicorn --bind 0.0.0.0:5000 main:app"
