 ============================================================
-- 04_analise_por_cargo.sql
-- Objetivo: Analisar concursos por cargo, área e nível.
-- ============================================================

-- Seleciona informações do cargo (nome, área, nível) e calcula métricas dos concursos.
-- Inclui total de concursos, vagas, salário médio, menor e maior salário para cada cargo.
SELECT
    c.nome_cargo,
    c.area,
    c.nivel,
    COUNT(*) AS total_concursos,
    SUM(f.vagas) AS total_vagas,
    ROUND(AVG(f.salario), 2) AS salario_medio,
    MIN(f.salario) AS menor_salario,
    MAX(f.salario) AS maior_salario
-- Junta a tabela de fatos de concurso com a dimensão de cargo.
FROM fato_concurso f
JOIN dim_cargo c 
    ON f.id_cargo = c.id_cargo
-- Agrupa os resultados por nome, área e nível do cargo para obter métricas por cargo.
GROUP BY
    c.nome_cargo,
    c.area,
    c.nivel
-- Ordena os resultados para mostrar os cargos com maiores salários médios e mais vagas primeiro.
ORDER BY
    salario_medio DESC,
    total_vagas DESC;
