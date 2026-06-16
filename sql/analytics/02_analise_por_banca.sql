-- ============================================================
-- 02_analise_por_banca.sql
-- Objetivo: Analisar concursos por banca organizadora.
-- ============================================================

SELECT
    b.nome_banca,
    COUNT(*) AS total_concursos,
    SUM(f.vagas) AS total_vagas,
    ROUND(AVG(f.salario), 2) AS salario_medio,
    MIN(f.salario) AS menor_salario,
    MAX(f.salario) AS maior_salario
FROM fato_concurso f
JOIN dim_banca b 
    ON f.id_banca = b.id_banca
GROUP BY
    b.nome_banca
ORDER BY
    total_concursos DESC,
    salario_medio DESC;