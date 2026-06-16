============================================================
-- 05_top_salarios.sql
-- Objetivo: Listar os concursos com maiores salários.
-- ============================================================

SELECT
    o.nome_orgao,
    c.nome_cargo,
    c.area,
    c.nivel,
    b.nome_banca,
    e.sigla_estado,
    e.regiao,
    f.ano,
    f.vagas,
    f.salario,
    f.data_prova,
    f.url_edital
FROM fato_concurso f
JOIN dim_orgao o 
    ON f.id_orgao = o.id_orgao
JOIN dim_cargo c 
    ON f.id_cargo = c.id_cargo
JOIN dim_banca b 
    ON f.id_banca = b.id_banca
JOIN dim_estado e 
    ON f.id_estado = e.id_estado
ORDER BY
    f.salario DESC,
    f.vagas DESC
LIMIT 10;