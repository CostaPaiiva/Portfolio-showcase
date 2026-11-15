/* ==============================================================================
   MODELO DBT: dim_estado (Tabela de Dimensão)
   Camada: Gold
   Descrição: Gera a dimensão geográfica de estados com Surrogate Key única (id_estado).
   Origem: public.silver_producao
============================================================================== */

SELECT
    -- Cria um identificador único incremental (Surrogate Key) ordenado alfabeticamente
    ROW_NUMBER() OVER (ORDER BY estado) AS id_estado,
    estado
FROM (
    -- Extrai apenas estados únicos da tabela Silver
    SELECT DISTINCT estado 
    FROM public.silver_producao
) AS sub
