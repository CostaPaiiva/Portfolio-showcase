/* ==============================================================================
   MODELO DBT: dim_cultura (Tabela de Dimensão)
   Camada: Gold
   Descrição: Gera a dimensão de culturas agrícolas com Surrogate Key única (id_cultura).
   Origem: public.silver_producao
============================================================================== */

SELECT
    -- Cria um identificador único incremental (Surrogate Key) ordenado por nome
    ROW_NUMBER() OVER (ORDER BY cultura) AS id_cultura,
    cultura
FROM (
    -- Extrai apenas valores únicos de culturas da tabela Silver
    SELECT DISTINCT cultura 
    FROM public.silver_producao
) AS sub
