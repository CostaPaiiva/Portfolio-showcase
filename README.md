# Plataforma de Inteligência para Concursos Públicos

Projeto de Engenharia de Dados desenvolvido para coletar, tratar, armazenar e analisar dados de concursos públicos, com foco em cargos de Tecnologia da Informação, Ciência de Dados, Engenharia de Dados e áreas correlatas.

## Objetivo

Construir uma plataforma analítica capaz de responder perguntas como:

- Quais bancas mais organizam concursos de TI?
- Quais estados possuem os melhores salários?
- Quais cargos aparecem com maior frequência?
- Qual é a evolução salarial dos concursos públicos de tecnologia?
- Quais órgãos mais ofertam vagas na área de TI?

## Arquitetura Inicial

```text
Fontes de Dados
      ↓
Extração com Python
      ↓
Data Lake Raw
      ↓
Transformação ETL
      ↓
PostgreSQL / Data Warehouse
      ↓
Dashboard Analítico