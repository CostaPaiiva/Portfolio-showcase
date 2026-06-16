-- ============================================================
-- 03_analise_por_estado.sql
-- Objetivo: Analisar concursos por estado e região.
-- ============================================================

-- Seleciona informações do estado (sigla, nome, região) e calcula métricas dos concursos.
-- Inclui total de concursos, vagas, salário médio e maior salário para cada estado.
SELECT
    e.sigla_estado,
    e.nome_estado,
    e.regiao,
    COUNT(*) AS total_concursos,
    SUM(f.vagas) AS total_vagas,
    ROUND(AVG(f.salario), 2) AS salario_medio,
    MAX(f.salario) AS maior_salario
-- Junta a tabela de fatos de concurso com a dimensão de estado.
FROM fato_concurso f
JOIN dim_estado e 
    ON f.id_estado = e.id_estado
-- Agrupa os resultados por sigla, nome e região do estado para obter métricas estaduais.
GROUP BY
    e.sigla_estado,
    e.nome_estado,
    e.regiao
-- Ordena os resultados para mostrar os estados com maiores salários médios e mais vagas primeiro.
ORDER BY
    salario_medio DESC,
    total_vagas DESC;
