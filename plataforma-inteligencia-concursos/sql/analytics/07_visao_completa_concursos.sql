-- ============================================================
-- 07_visao_completa_concursos.sql
-- Objetivo: Criar uma visão analítica completa dos concursos.
-- ============================================================

-- Seleciona todos os campos relevantes para uma visão completa de cada concurso.
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
    ON f.id_estado = e.id_estado
-- Ordena os resultados para mostrar os concursos mais recentes e com maiores salários primeiro.
ORDER BY
    f.ano DESC,
    f.salario DESC;
