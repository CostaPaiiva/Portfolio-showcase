# Relatório do Projeto — Plataforma de Inteligência para Concursos Públicos

## 1. Objetivo do projeto

O objetivo deste projeto é desenvolver uma plataforma de engenharia de dados voltada para a coleta, organização, tratamento e análise de informações sobre concursos públicos.

A proposta é simular um ambiente real de dados, utilizando etapas como extração, transformação, carga, armazenamento e visualização de dados.

## 2. Tecnologias utilizadas

- Python
- SQL
- Docker
- ETL
- Data Warehouse
- Git e GitHub
- Dashboard
- VS Code

## 3. Estrutura inicial do projeto

plataforma-inteligencia-concursos/
│
├── data/
│   ├── raw/
│   ├── processed/
│   └── warehouse/
│
├── docs/
│   └── relatorio.md
│
├── notebooks/
│
├── src/
│   ├── extraction/
│   ├── transformation/
│   ├── loading/
│   ├── database/
│   └── utils/
│
├── sql/
│   ├── 01_create_tables.sql
│   └── 02_insert_sample_data.sql
│
├── dashboards/
│
├── docker-compose.yml
├── .env.example
├── .gitignore
├── README.md
└── requirements.txt

## 4. Para que serve cada pasta

data/raw

Aqui ficam os dados brutos coletados dos sites, APIs ou arquivos.

Exemplo:

edital_tce_pi_2026.json
concursos_2026_06_15.csv

data/processed

Aqui ficam os dados tratados, limpos e padronizados.

Exemplo:

concursos_tratados.csv
cargos_padronizados.csv
data/warehouse

Aqui podemos salvar arquivos finais no formato analítico, como .parquet ou .csv.

src/extraction

Scripts de coleta de dados.

Exemplo:

coletar_concursos.py
src/transformation

Scripts de limpeza e transformação.

Exemplo:

limpar_dados.py
padronizar_cargos.py
src/loading

Scripts para carregar os dados no banco PostgreSQL.

Exemplo:

carregar_postgres.py
src/database

Conexão com banco de dados.

Exemplo:

connection.py
sql

Scripts SQL para criar tabelas e inserir dados de teste.

docs

Aqui ficará o relatório do projeto.