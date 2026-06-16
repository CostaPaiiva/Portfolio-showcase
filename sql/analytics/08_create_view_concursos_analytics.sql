-- ============================================================
-- 08_create_view_concursos_analytics.sql
-- Objetivo: Criar uma view analítica consolidada para dashboards.
-- ============================================================

-- Cria ou substitui uma view chamada `vw_concursos_analytics`.
-- Esta view consolida dados de concursos para uso em análises e dashboards.
CREATE OR REPLACE VIEW vw_concursos_analytics AS
-- Seleciona todos os campos relevantes para a visão analítica de concursos.
-- Inclui informações detalhadas do fato (id, ano, vagas, salário, datas, edital, carga) e das dimensões relacionadas.
SELECT
    f.id_concurso,
    o.nome_orgao,
    o.esfera,
    c.nome_cargo,
    c.area,
    c.nivel,
    b.nome_banca,
    e.sigla_estado,
    e.nome_estado,
    e.regiao,
    f.ano,
    f.vagas,
    f.salario,
    f.inscricao_inicio,
    f.inscricao_fim,
    f.data_prova,
    f.url_edital,
    f.data_carga
-- Realiza junções (JOINs) com as tabelas de dimensão (órgão, cargo, banca, estado) para enriquecer os dados dos concursos.
FROM fato_concurso f
JOIN dim_orgao o
    ON f.id_orgao = o.id_orgao
JOIN dim_cargo c
    ON f.id_cargo = c.id_cargo
JOIN dim_banca b
    ON f.id_banca = b.id_banca
JOIN dim_estado e
    ON f.id_estado = e.id_estado;
