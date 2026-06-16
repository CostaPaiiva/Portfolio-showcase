-- ============================================================
-- 09_kpis_view_analytics.sql
-- Objetivo: Consultar KPIs usando a view vw_concursos_analytics.
-- ============================================================

-- Seleciona os principais KPIs (Indicadores Chave de Performance) utilizando a view analítica.
-- Calcula o total de concursos, soma as vagas, salário médio, menor e maior salário.
-- Também conta o número distinto de bancas, estados, cargos e órgãos presentes na view.
SELECT
    COUNT(*) AS total_concursos,
    SUM(vagas) AS total_vagas,
    ROUND(AVG(salario), 2) AS salario_medio,
    MIN(salario) AS menor_salario,
    MAX(salario) AS maior_salario,
    COUNT(DISTINCT nome_banca) AS total_bancas,
    COUNT(DISTINCT sigla_estado) AS total_estados,
    COUNT(DISTINCT nome_cargo) AS total_cargos,
    COUNT(DISTINCT nome_orgao) AS total_orgaos
FROM vw_concursos_analytics;
