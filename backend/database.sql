-- Tabela de Empresas
CREATE TABLE Empresas (
    id_empresa SERIAL PRIMARY KEY,
    nome_fantasia VARCHAR(255) NOT NULL,
    razao_social VARCHAR(255) NOT NULL,
    cnpj VARCHAR(18) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    cep VARCHAR(10),
    logradouro VARCHAR(255),
    numero VARCHAR(20),
    bairro VARCHAR(100),
    cidade VARCHAR(100),
    estado VARCHAR(2),
    pais VARCHAR(50),
    status BOOLEAN DEFAULT TRUE,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Funcionários
CREATE TABLE Funcionarios (
    id_funcionario SERIAL PRIMARY KEY,
    id_empresa INT,
    nome VARCHAR(255) NOT NULL,
    sobrenome VARCHAR(255) NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    rua VARCHAR(255),
    numero VARCHAR(20),
    bairro VARCHAR(100),
    cidade VARCHAR(100),
    cep VARCHAR(10),
    email VARCHAR(255) NOT NULL UNIQUE,
    telefone VARCHAR(20),
    cargo VARCHAR(100),
    senha VARCHAR(255) NOT NULL,
    status BOOLEAN DEFAULT TRUE,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Pontos
CREATE TABLE Pontos (
    id_ponto SERIAL PRIMARY KEY,
    id_funcionario INT NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_funcionario) REFERENCES Funcionarios(id_funcionario)
);

-- Tabela de Jornadas
CREATE TABLE Jornadas (
    id_jornada SERIAL PRIMARY KEY,
    id_funcionario INT NOT NULL,
    dia_semana INT NOT NULL, -- (0: Domingo, 1: Segunda, ..., 6: Sábado)
    horario_entrada TIME,
    horario_saida_intervalo TIME,
    horario_retorno_intervalo TIME,
    horario_saida TIME,
    ocorrencia TEXT,
    falta BOOLEAN,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_funcionario) REFERENCES Funcionarios(id_funcionario)
);

-- Tabela de Localizações
CREATE TABLE Localizacoes (
    id_localizacao SERIAL PRIMARY KEY,
    id_funcionario INT NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    raio_permitido INT NOT NULL, -- em metros
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_funcionario) REFERENCES Funcionarios(id_funcionario)
);
