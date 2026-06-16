# Relatório Técnico — Plataforma de Inteligência para Concursos Públicos

## 1. Introdução

A Plataforma de Inteligência para Concursos Públicos é um projeto de Engenharia de Dados desenvolvido com o objetivo de coletar, organizar, transformar e analisar dados relacionados a concursos públicos, especialmente na área de Tecnologia da Informação.

O projeto busca simular um ambiente real de dados, utilizando conceitos como ETL, Data Warehouse, modelagem dimensional, automação de pipelines e visualização analítica.

## 2. Problema

As informações sobre concursos públicos estão distribuídas em diferentes fontes, como sites de bancas organizadoras, portais de notícias, páginas institucionais e editais em PDF.

Essa dispersão dificulta análises como:

- Identificar bancas mais frequentes.
- Comparar salários por estado.
- Analisar cargos mais ofertados.
- Observar tendências salariais.
- Avaliar oportunidades por área de atuação.

## 3. Objetivo Geral

Construir uma solução de Engenharia de Dados capaz de centralizar informações de concursos públicos em um Data Warehouse, permitindo análises estratégicas e geração de dashboards.

## 4. Objetivos Específicos

- Criar uma arquitetura local usando Docker.
- Configurar um banco PostgreSQL para armazenamento analítico.
- Modelar um Data Warehouse com esquema estrela.
- Criar pipelines de extração, transformação e carga.
- Desenvolver dashboards para análise dos dados.
- Documentar todas as etapas do projeto.

## 5. Tecnologias Utilizadas

- Python
- PostgreSQL
- Docker
- SQL
- Pandas
- pgAdmin
- Power BI ou ferramenta equivalente

## 6. Arquitetura Inicial

```text
Fontes de Dados
      ↓
Extração
      ↓
Dados Brutos
      ↓
Transformação
      ↓
Data Warehouse
      ↓
Dashboard
7. Etapa Atual

Nesta etapa inicial, foi criada a estrutura base do projeto, incluindo diretórios, arquivos de configuração, ambiente Docker, banco PostgreSQL e scripts SQL para criação das tabelas dimensionais e tabela fato.

8. Modelo de Dados

O projeto utiliza modelagem dimensional com esquema estrela.

Tabela fato:

fato_concurso

Tabelas dimensão:

dim_banca
dim_estado
dim_cargo
dim_orgao
9. Próximas Etapas
Criar script Python para conexão com o banco.
Criar pipeline de extração de dados.
Criar processo de transformação e padronização.
Carregar os dados tratados no PostgreSQL.
Criar dashboard analítico.

---

# 13. Testar se o banco foi criado

Depois que rodar:

```bash
docker compose up -d

Entre no PostgreSQL pelo terminal:

docker exec -it concursos_postgres psql -U concursos_user -d concursos_dw

Depois rode:

\dt

Você deve ver:

dim_banca
dim_estado
dim_cargo
dim_orgao
fato_concurso

Para testar os dados:

SELECT * FROM fato_concurso;

Para sair:

\q