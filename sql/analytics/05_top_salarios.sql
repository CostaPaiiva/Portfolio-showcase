============================================================
-- 05_top_salarios.sql
-- Objetivo: Listar os concursos com maiores salários.
-- ============================================================

-- Seleciona detalhes completos dos concursos, incluindo órgão, cargo, banca, estado, ano, vagas, salário, data da prova e URL do edital.
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
-- Realiza junções (JOINs) com as tabelas de dimensão para obter informações detalhadas de cada concurso.
FROM fato_concurso f
JOIN dim_orgao o 
    ON f.id_orgao = o.id_orgao
JOIN dim_cargo c 
    ON f.id_cargo = c.id_cargo
JOIN dim_banca b 
    ON f.id_banca = b.id_banca
JOIN dim_estado e 
    ON f.id_estado = e.id_estado
-- Ordena os resultados para mostrar os concursos com maiores salários e mais vagas primeiro.
ORDER BY
    f.salario DESC,
    f.vagas DESC
-- Limita o resultado aos 10 primeiros registros, que correspondem aos top salários.
LIMIT 10;
