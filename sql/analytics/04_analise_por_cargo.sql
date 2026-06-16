 ============================================================
-- 04_analise_por_cargo.sql
-- Objetivo: Analisar concursos por cargo, área e nível.
-- ============================================================

SELECT
    c.nome_cargo,
    c.area,
    c.nivel,
    COUNT(*) AS total_concursos,
    SUM(f.vagas) AS total_vagas,
    ROUND(AVG(f.salario), 2) AS salario_medio,
    MIN(f.salario) AS menor_salario,
    MAX(f.salario) AS maior_salario
FROM fato_concurso f
JOIN dim_cargo c 
    ON f.id_cargo = c.id_cargo
GROUP BY
    c.nome_cargo,
    c.area,
    c.nivel
ORDER BY
    salario_medio DESC,
    total_vagas DESC;