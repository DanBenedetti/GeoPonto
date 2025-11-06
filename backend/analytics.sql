-- Tabela para registrar visualizações de página e tempo de renderização
CREATE TABLE page_views (
    id SERIAL PRIMARY KEY,
    page_name VARCHAR(255) NOT NULL,
    render_time_ms INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela para registrar cliques em botões
CREATE TABLE button_clicks (
    id SERIAL PRIMARY KEY,
    button_id VARCHAR(255) NOT NULL,
    page_name VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
