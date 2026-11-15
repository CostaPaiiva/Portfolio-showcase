/* ==============================================================================
   MODELO DBT: fato_producao (Tabela de Fato)
   Camada: Gold
   Descrição: Tabela analítica central contendo as métricas de negócio agregadas
              (total produzido) vinculadas às chaves das dimensões (Star Schema).
   Origem: public.silver_producao + referências dbt (ref)
============================================================================== */

SELECT
    -- Chaves estrangeiras referenciando as dimensões
    d_estado.id_estado,
    d_cultura.id_cultura,
    
    -- Conversão explícita do ano para número inteiro
    s.ano::int AS ano,
    
    -- Métrica agregada: soma da produção agrícola
    SUM(s.valor) AS total_produzido
FROM public.silver_producao s

-- Junção com a dimensão de estados usando a função ref() do dbt (garante linhagem e ordem de execução)
LEFT JOIN {{ ref('dim_estado') }} d_estado 
    ON s.estado = d_estado.estado

-- Junção com a dimensão de culturas agrícolas
LEFT JOIN {{ ref('dim_cultura') }} d_cultura 
    ON s.cultura = d_cultura.cultura

-- Agrupamento pelos índices dimensionais e ano (1: id_estado, 2: id_cultura, 3: ano)
GROUP BY 1, 2, 3
