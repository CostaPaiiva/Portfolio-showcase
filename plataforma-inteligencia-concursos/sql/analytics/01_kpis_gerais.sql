-- ============================================================
-- 01_kpis_gerais.sql
-- Objetivo: Consultar indicadores gerais do Data Warehouse.
-- ============================================================

-- Seleciona os principais KPIs (Indicadores Chave de Performance) gerais dos concursos.
-- Conta o total de concursos, soma as vagas, calcula o salário médio, menor e maior salário.
-- Também conta o número distinto de bancas, estados, cargos e órgãos presentes nos dados.
SELECT
    COUNT(*) AS total_concursos,
    SUM(f.vagas) AS total_vagas,
    ROUND(AVG(f.salario), 2) AS salario_medio,
    MIN(f.salario) AS menor_salario,
    MAX(f.salario) AS maior_salario,
    COUNT(DISTINCT f.id_banca) AS total_bancas,
    COUNT(DISTINCT f.id_estado) AS total_estados,
    COUNT(DISTINCT f.id_cargo) AS total_cargos,
    COUNT(DISTINCT f.id_orgao) AS total_orgaos
FROM fato_concurso f;
