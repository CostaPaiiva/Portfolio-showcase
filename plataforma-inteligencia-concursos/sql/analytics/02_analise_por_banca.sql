-- ============================================================
-- 02_analise_por_banca.sql
-- Objetivo: Analisar concursos por banca organizadora.
-- ============================================================

-- Seleciona o nome da banca e calcula métricas como total de concursos, vagas e salários.
SELECT
    b.nome_banca,
    COUNT(*) AS total_concursos,
    SUM(f.vagas) AS total_vagas,
    ROUND(AVG(f.salario), 2) AS salario_medio,
    MIN(f.salario) AS menor_salario,
    MAX(f.salario) AS maior_salario
-- Junta a tabela de fatos de concurso com a dimensão de bancas.
FROM fato_concurso f
JOIN dim_banca b 
    ON f.id_banca = b.id_banca
-- Agrupa os resultados pelo nome da banca para calcular as métricas por cada uma.
GROUP BY
    b.nome_banca
-- Ordena os resultados para mostrar as bancas com mais concursos e maiores salários médios primeiro.
ORDER BY
    total_concursos DESC,
    salario_medio DESC;
