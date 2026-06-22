# Consultas Analíticas SQL

Esta pasta contém consultas SQL utilizadas para análise dos dados carregados no Data Warehouse do projeto Plataforma de Inteligência para Concursos Públicos.

## Objetivo

Organizar consultas analíticas que respondem perguntas de negócio sobre concursos públicos, como:

- Quantidade total de concursos.
- Total de vagas.
- Salário médio.
- Maiores salários.
- Análise por banca.
- Análise por estado.
- Análise por cargo.
- Evolução por ano.

## Arquivos

| Arquivo | Descrição |
|---|---|
| `01_kpis_gerais.sql` | Indicadores gerais do Data Warehouse |
| `02_analise_por_banca.sql` | Análise de concursos por banca |
| `03_analise_por_estado.sql` | Análise de concursos por estado e região |
| `04_analise_por_cargo.sql` | Análise de concursos por cargo |
| `05_top_salarios.sql` | Lista dos maiores salários |
| `06_evolucao_por_ano.sql` | Evolução anual de concursos, vagas e salários |
| `07_visao_completa_concursos.sql` | Consulta completa com todas as dimensões |
| `08_create_view_concursos_analytics.sql` | Criação da view analítica consolidada |
| `09_kpis_view_analytics.sql` | KPIs usando a view analítica |

## Como Executar

Exemplo usando Docker:

```bash
docker exec -i concursos_postgres psql -U concursos_user -d concursos_dw < sql/analytics/01_kpis_gerais.sql