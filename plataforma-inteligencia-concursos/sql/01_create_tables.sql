-- =================================================================================
-- Script de Criação do Data Warehouse (Modelo Estrela / Star Schema)
-- O modelo é composto por tabelas Dimensão (dim_*) que guardam o contexto
-- e uma tabela Fato (fato_concurso) que guarda os eventos e métricas.
-- =================================================================================

-- ---------------------------------------------------------------------------------
-- 1. Tabela Dimensão: Bancas Organizadoras (Ex: Cebraspe, FCC, FGV)
-- ---------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS dim_banca (
    id_banca SERIAL PRIMARY KEY,              -- Chave primária autoincremental
    nome_banca VARCHAR(100) NOT NULL UNIQUE   -- Nome da banca organizadora (único e obrigatório)
);

-- ---------------------------------------------------------------------------------
-- 2. Tabela Dimensão: Estados/Localização das Vagas
-- ---------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS dim_estado (
    id_estado SERIAL PRIMARY KEY,             -- Chave primária autoincremental
    sigla_estado CHAR(2) NOT NULL UNIQUE,     -- Sigla do estado (Ex: SP, RJ). Fixa em 2 caracteres
    nome_estado VARCHAR(100),                 -- Nome por extenso do estado
    regiao VARCHAR(50)                        -- Região do estado (Ex: Sudeste, Nordeste)
);

-- ---------------------------------------------------------------------------------
-- 3. Tabela Dimensão: Cargos Oferecidos (Ex: Analista, Técnico, Auditor)
-- ---------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS dim_cargo (
    id_cargo SERIAL PRIMARY KEY,              -- Chave primária autoincremental
    nome_cargo VARCHAR(150) NOT NULL,         -- Nome completo do cargo oferecido
    area VARCHAR(100),                        -- Área de atuação (Ex: Fiscal, TI, Administrativa)
    nivel VARCHAR(50)                         -- Nível de escolaridade exigido (Ex: Médio, Superior)
);

-- ---------------------------------------------------------------------------------
-- 4. Tabela Dimensão: Órgãos Públicos (Ex: Receita Federal, INSS, Tribunais)
-- ---------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS dim_orgao (
    id_orgao SERIAL PRIMARY KEY,              -- Chave primária autoincremental
    nome_orgao VARCHAR(150) NOT NULL UNIQUE,  -- Nome do órgão público contratante
    esfera VARCHAR(50)                        -- Esfera do governo (Ex: Federal, Estadual, Municipal)
);

-- ---------------------------------------------------------------------------------
-- 5. Tabela Fato: Concursos (Agrupa as chaves das dimensões e as métricas/valores)
-- ---------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS fato_concurso (
    id_concurso SERIAL PRIMARY KEY,           -- Chave primária autoincremental do concurso (identificador do edital/vaga)

    -- Chaves Estrangeiras (Foreign Keys) ligando o fato às dimensões
    id_banca INT REFERENCES dim_banca(id_banca),   -- Referência à banca organizadora
    id_estado INT REFERENCES dim_estado(id_estado),-- Referência ao estado
    id_cargo INT REFERENCES dim_cargo(id_cargo),   -- Referência ao cargo
    id_orgao INT REFERENCES dim_orgao(id_orgao),   -- Referência ao órgão

    -- Métricas e Dados específicos do concurso (Fatos)
    ano INT,                                  -- Ano de realização do concurso
    vagas INT,                                -- Quantidade de vagas oferecidas
    salario NUMERIC(12,2),                    -- Salário oferecido (Até 12 dígitos, com 2 casas decimais)
    inscricao_inicio DATE,                    -- Data de início do período de inscrições
    inscricao_fim DATE,                       -- Data de término do período de inscrições
    data_prova DATE,                          -- Data agendada para aplicação da prova

    -- Metadados / Informações complementares
    url_edital TEXT,                          -- Link de acesso para o documento do edital original
    data_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Data e hora exata em que o dado foi inserido no Data Warehouse (Auditoria)
);
