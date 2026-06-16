============================================================
-- 06_evolucao_por_ano.sql
-- Objetivo: Analisar evolução de concursos, vagas e salários por ano.
-- ============================================================

-- Seleciona o ano e calcula a evolução de concursos, vagas e salários.
-- Inclui total de concursos, vagas, salário médio, menor e maior salário para cada ano.
SELECT
    f.ano,
    COUNT(*) AS total_concursos,
    SUM(f.vagas) AS total_vagas,
    ROUND(AVG(f.salario), 2) AS salario_medio,
    MIN(f.salario) AS menor_salario,
    MAX(f.salario) AS maior_salario
FROM fato_concurso f
-- Agrupa os resultados por ano para analisar a evolução anual.
GROUP BY
    f.ano
-- Ordena os resultados por ano para uma visualização cronológica.
ORDER BY
    f.ano;
