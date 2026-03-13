#!/bin/bash

# Configuração Automática do Backend GeoPonto na Azure
# ---------------------------------------------------

# 1. Parâmetros do Banco de Dados
DB_NAME="geoponto"
DB_USER="geoponto_user"
DB_PASS="geoponto_pass" # Recomendo mudar após a primeira execução

echo "🚀 Iniciando configuração completa do ambiente..."

# 2. Atualizar e Instalar dependências
echo "📦 Instalando pacotes do sistema (PostgreSQL, Python, etc)..."
sudo apt update
sudo apt install -y postgresql postgresql-contrib python3-venv python3-pip libpq-dev

# 3. Configurar PostgreSQL (Garantir Reset e Criação)
echo "🐘 Resetando e configurando banco de dados PostgreSQL..."
# Remover banco e usuário se existirem para evitar erros de duplicidade
sudo -u postgres psql -c "DROP DATABASE IF EXISTS $DB_NAME;"
sudo -u postgres psql -c "DROP USER IF EXISTS $DB_USER;"

# Criar do zero
sudo -u postgres psql -c "CREATE DATABASE $DB_NAME;"
sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"
sudo -u postgres psql -d $DB_NAME -c "GRANT ALL ON SCHEMA public TO $DB_USER;"

# 4. Importar Tabelas
echo "📊 Importando estruturas das tabelas (database.sql e analytics.sql)..."
export PGPASSWORD=$DB_PASS
psql -h localhost -U $DB_USER -d $DB_NAME -f database.sql
psql -h localhost -U $DB_USER -d $DB_NAME -f analytics.sql

# 5. Configurar Python Venv e Dependências
echo "🐍 Configurando ambiente virtual e dependências Python..."
if [ -d "venv" ]; then
    rm -rf venv
fi
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# 6. Criar o arquivo .env final
echo "📝 Gerando arquivo .env com as credenciais configuradas..."
cat <<EOF > .env
POSTGRES_DB=$DB_NAME
POSTGRES_USER=$DB_USER
POSTGRES_PASSWORD=$DB_PASS
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
EOF

echo "✅ Configuração concluída com sucesso!"
echo "Para iniciar: ./back.sh"
