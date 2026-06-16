-- ============================================================
-- 03_analise_por_estado.sql
-- Objetivo: Analisar concursos por estado e região.
-- ============================================================

SELECT
    e.sigla_estado,
    e.nome_estado,
    e.regiao,
    COUNT(*) AS total_concursos,
    SUM(f.vagas) AS total_vagas,
    ROUND(AVG(f.salario), 2) AS salario_medio,
    MAX(f.salario) AS maior_salario
FROM fato_concurso f
JOIN dim_estado e 
    ON f.id_estado = e.id_estado
GROUP BY
    e.sigla_estado,
    e.nome_estado,
    e.regiao
ORDER BY
    salario_medio DESC,
    total_vagas DESC;