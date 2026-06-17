Plataforma de Inteligência para Concursos Públicos










Sobre o Projeto

A Plataforma de Inteligência para Concursos Públicos é um projeto de Engenharia de Dados desenvolvido para coletar, tratar, armazenar, analisar e visualizar dados de concursos públicos.

O projeto simula um fluxo real de dados, desde a geração dos dados brutos até a visualização em um dashboard interativo.

O foco principal está em concursos voltados para áreas como:

Tecnologia da Informação;
Ciência de Dados;
Engenharia de Dados;
Análise de Dados;
Desenvolvimento de Sistemas;
Áreas correlatas de tecnologia no setor público.
Resultado Final
Entrega	Descrição
Pipeline de Extração	Geração de dados brutos em JSON
Pipeline de Transformação	Limpeza, padronização e enriquecimento dos dados
Pipeline de Carga	Inserção dos dados tratados no PostgreSQL
Data Warehouse	Modelo dimensional com tabela fato e dimensões
SQL Analytics	Consultas analíticas para KPIs e rankings
View Analítica	View consolidada para consumo em BI
Dashboard	Interface visual com Streamlit e Plotly
Documentação	README e relatório técnico para portfólio
Demonstração do Dashboard

Os prints abaixo devem estar na pasta dashboard/, conforme sua estrutura atual do projeto.

Visão Geral
Indicadores e Gráficos
Filtros Interativos
Análises Visuais
Sumário
Sobre o Projeto
Resultado Final
Demonstração do Dashboard
Problema de Negócio
Objetivos
Arquitetura da Solução
Tecnologias Utilizadas
Estrutura de Pastas
Modelo de Dados
Pipeline ETL
Consultas Analíticas SQL
Dashboard Analítico
Como Executar o Projeto
Status do Projeto
Competências Demonstradas
Próximas Melhorias
Autor
Problema de Negócio

As informações sobre concursos públicos estão distribuídas em diversas fontes, como:

Sites de bancas organizadoras;
Portais institucionais;
Portais de notícias;
Editais em PDF;
Diários oficiais;
Agregadores de concursos.

Essa dispersão dificulta análises consolidadas, como comparar salários, identificar bancas mais frequentes, acompanhar oportunidades por estado e entender tendências da área pública para profissionais de tecnologia.

Este projeto propõe centralizar esses dados em um Data Warehouse, permitindo consultas analíticas e visualização de indicadores em um dashboard.

Objetivos

Construir uma plataforma analítica capaz de responder perguntas como:

Pergunta Analítica	Valor Gerado
Quais bancas mais organizam concursos de TI?	Direcionamento de estudos
Quais estados possuem os melhores salários?	Comparação de oportunidades
Quais cargos aparecem com maior frequência?	Identificação de tendências
Quais órgãos mais ofertam vagas de tecnologia?	Priorização de editais
Como os salários evoluem ao longo dos anos?	Análise histórica
Quais concursos possuem maior remuneração?	Apoio à tomada de decisão
Quais regiões concentram mais oportunidades?	Análise geográfica
Arquitetura da Solução
Fontes de Dados
      ↓
Extração com Python
      ↓
Camada Raw — JSON
      ↓
Transformação com Pandas
      ↓
Camada Processed — CSV
      ↓
Carga no PostgreSQL
      ↓
Data Warehouse
      ↓
Consultas SQL
      ↓
View Analítica
      ↓
Dashboard Streamlit
Camadas Implementadas
Camada	Status	Descrição
Estrutura do Projeto	Concluída	Organização profissional do repositório
Banco PostgreSQL	Concluído	Banco local executando via Docker
pgAdmin	Concluído	Interface gráfica para administração do banco
Modelo Dimensional	Concluído	Tabelas dimensão e tabela fato
Extração	Concluída	Geração de dados brutos em JSON
Transformação	Concluída	Limpeza, padronização e enriquecimento
Carga	Concluída	Inserção dos dados tratados no PostgreSQL
SQL Analytics	Concluído	Consultas analíticas organizadas
View Analítica	Concluída	View vw_concursos_analytics
Dashboard	Concluído	Interface interativa com Streamlit
Tecnologias Utilizadas
Tecnologia	Finalidade
Python	Desenvolvimento dos pipelines de dados
Pandas	Tratamento e manipulação dos dados
PostgreSQL	Banco de dados analítico
Docker	Criação do ambiente local
Docker Compose	Orquestração dos containers
SQL	Modelagem, consultas e análises
SQLAlchemy	Conexão Python com PostgreSQL
psycopg2	Driver PostgreSQL para Python
python-dotenv	Leitura de variáveis de ambiente
pgAdmin	Administração visual do banco
Streamlit	Construção do dashboard
Plotly	Visualização interativa dos dados
Git e GitHub	Versionamento e portfólio
Estrutura de Pastas
plataforma-inteligencia-concursos/
│
├── dashboard/
│   ├── app.py
│   ├── dashboard_home.png
│   ├── dashboard_graficos.png
│   ├── dashboard_filtros.png
│   └── dashboard_graficos2.png
│
├── data/
│   ├── raw/
│   ├── processed/
│   ├── warehouse/
│   └── sample/
│
├── docs/
│   └── relatorio.md
│
├── notebooks/
│
├── src/
│   ├── extraction/
│   │   └── extract_sample_data.py
│   ├── transformation/
│   │   └── transform_raw_data.py
│   ├── loading/
│   │   └── load_processed_data.py
│   ├── database/
│   │   ├── connection.py
│   │   └── test_connection.py
│   └── utils/
│
├── sql/
│   ├── analytics/
│   │   ├── README.md
│   │   ├── 01_kpis_gerais.sql
│   │   ├── 02_analise_por_banca.sql
│   │   ├── 03_analise_por_estado.sql
│   │   ├── 04_analise_por_cargo.sql
│   │   ├── 05_top_salarios.sql
│   │   ├── 06_evolucao_por_ano.sql
│   │   ├── 07_visao_completa_concursos.sql
│   │   ├── 08_create_view_concursos_analytics.sql
│   │   └── 09_kpis_view_analytics.sql
│   ├── 01_create_tables.sql
│   └── 02_insert_sample_data.sql
│
├── docker-compose.yml
├── .env.example
├── .gitignore
├── README.md
└── requirements.txt
Modelo de Dados

O projeto utiliza modelagem dimensional em formato de esquema estrela.

dim_banca   dim_estado   dim_cargo   dim_orgao
     \          |           |           /
      \         |           |          /
              fato_concurso
Tabela Fato
Tabela	Descrição
fato_concurso	Armazena os eventos principais dos concursos
Tabelas Dimensão
Tabela	Descrição
dim_banca	Informações das bancas organizadoras
dim_estado	Informações dos estados e regiões
dim_cargo	Informações dos cargos, áreas e níveis
dim_orgao	Informações dos órgãos públicos e esferas administrativas
Principais Métricas
Métrica	Descrição
vagas	Quantidade de vagas ofertadas
salario	Salário inicial
ano	Ano do concurso
data_prova	Data prevista da prova
Pipeline ETL

O projeto implementa um fluxo completo de Extração, Transformação e Carga.

Extract
   ↓
Transform
   ↓
Load
Extração
Item	Descrição
Arquivo	src/extraction/extract_sample_data.py
Entrada	Dados simulados de concursos públicos
Saída	Arquivos JSON na pasta data/raw/
Amostra	data/sample/concursos_sample.json
Transformação
Item	Descrição
Arquivo	src/transformation/transform_raw_data.py
Entrada	JSON bruto mais recente
Saída	CSV tratado na pasta data/processed/
Amostra	data/sample/concursos_processed_sample.csv
Transformações Realizadas
Transformação	Descrição
Validação de colunas	Confere campos obrigatórios
Padronização textual	Remove espaços extras
Padronização de cargos	Cria categorias analíticas
Padronização de bancas	Normaliza nomes
Conversão de tipos	Ajusta números e datas
Faixa salarial	Classifica salários
Dias de inscrição	Calcula duração do período
Data de transformação	Registra execução
Carga
Item	Descrição
Arquivo	src/loading/load_processed_data.py
Entrada	CSV tratado mais recente
Saída	Dados carregados no PostgreSQL
Destino	Tabelas dimensão e tabela fato
Processo de Carga
Etapa	Descrição
Leitura do CSV tratado	Busca o arquivo mais recente em data/processed
Carga nas dimensões	Popula dim_banca, dim_estado, dim_cargo e dim_orgao
Busca de IDs	Recupera chaves dimensionais
Carga na fato	Popula fato_concurso
Controle de duplicidade	Evita registros repetidos
Consultas Analíticas SQL

As consultas analíticas ficam em:

sql/analytics/
Arquivo	Objetivo
01_kpis_gerais.sql	Indicadores gerais
02_analise_por_banca.sql	Análise por banca
03_analise_por_estado.sql	Análise por estado
04_analise_por_cargo.sql	Análise por cargo
05_top_salarios.sql	Top concursos por salário
06_evolucao_por_ano.sql	Evolução anual
07_visao_completa_concursos.sql	Visão completa dos concursos
08_create_view_concursos_analytics.sql	Criação da view analítica
09_kpis_view_analytics.sql	KPIs usando a view
View Analítica

Foi criada a view:

vw_concursos_analytics

Essa view consolida a tabela fato e as dimensões, servindo como base para consultas, ferramentas de BI e dashboard.

Dashboard Analítico

O dashboard foi desenvolvido com Streamlit e Plotly.

Item	Descrição
Arquivo	dashboard/app.py
Fonte de dados	vw_concursos_analytics
Framework	Streamlit
Visualização	Plotly
Banco	PostgreSQL
Funcionalidades
Recurso	Descrição
KPIs principais	Total de concursos, vagas, média salarial e maior salário
Filtros interativos	Estado, banca, ano, nível, área e região
Concursos por estado	Gráfico de barras
Concursos por banca	Ranking das bancas
Concursos por ano	Evolução temporal
Vagas por nível	Distribuição por nível
Salário médio por estado	Comparação salarial
Vagas por região	Distribuição regional
Top cargos por vagas	Ranking dos cargos com mais vagas
Top salários	Maiores remunerações
Base analítica completa	Tabela detalhada dos dados
Como Executar o Projeto
1. Clonar o repositório
git clone URL_DO_REPOSITORIO
cd plataforma-inteligencia-concursos
2. Criar o arquivo .env

Copie o arquivo .env.example:

cp .env.example .env

No Windows CMD:

copy .env.example .env

Conteúdo esperado:

DB_HOST=localhost
DB_PORT=5432
DB_NAME=concursos_dw
DB_USER=concursos_user
DB_PASSWORD=concursos_pass
3. Subir os containers
docker compose up -d

Verificar:

docker compose ps
4. Instalar dependências

Criar ambiente virtual:

python -m venv .venv

Ativar no Git Bash:

source .venv/Scripts/activate

Ativar no PowerShell:

.venv\Scripts\Activate.ps1

Instalar dependências:

pip install -r requirements.txt
5. Executar o ETL completo
python src/extraction/extract_sample_data.py
python src/transformation/transform_raw_data.py
python src/loading/load_processed_data.py
6. Criar a view analítica
docker exec -i concursos_postgres psql -U concursos_user -d concursos_dw < sql/analytics/08_create_view_concursos_analytics.sql
7. Executar consultas analíticas
docker exec -i concursos_postgres psql -U concursos_user -d concursos_dw < sql/analytics/01_kpis_gerais.sql
8. Executar o dashboard
streamlit run dashboard/app.py

Acesse no navegador:

http://localhost:8501
Status do Projeto
Etapa	Status
Estrutura inicial criada	Concluído
Ambiente Docker configurado	Concluído
Banco PostgreSQL criado	Concluído
pgAdmin configurado	Concluído
Modelo dimensional criado	Concluído
Dados de teste inseridos	Concluído
Conexão Python com PostgreSQL	Concluído
Pipeline de extração	Concluído
Pipeline de transformação	Concluído
Pipeline de carga	Concluído
Consultas analíticas SQL	Concluído
View analítica para BI	Concluído
Dashboard Streamlit	Concluído
Relatório técnico	Concluído
Versão 1.0 para portfólio	Concluído
Competências Demonstradas
Competência	Aplicação
Engenharia de Dados	Construção de pipeline completo
Python	Scripts de extração, transformação e carga
Pandas	Tratamento e padronização dos dados
SQL	Consultas analíticas e modelagem
PostgreSQL	Data Warehouse relacional
Docker	Ambiente local reprodutível
SQLAlchemy	Integração entre Python e banco
Modelagem Dimensional	Esquema estrela
Streamlit	Dashboard interativo
Plotly	Gráficos interativos
Git e GitHub	Versionamento e portfólio
Documentação Técnica	README e relatório do projeto
Próximas Melhorias
Melhoria	Descrição
Coleta real	Buscar dados em páginas públicas ou APIs
Extração de PDF	Ler editais automaticamente
Orquestração	Adicionar Airflow ou Prefect
Data Lake	Salvar arquivos em formato Parquet
Testes automatizados	Criar validações com pytest
Deploy do dashboard	Publicar em ambiente gratuito
Qualidade de dados	Adicionar checks de consistência
CI/CD	Automatizar validações no GitHub Actions
Autor

Projeto desenvolvido como parte de um portfólio profissional de Engenharia de Dados.

Áreas de foco: Engenharia de Dados, Ciência de Dados, Análise de Dados, Inteligência Artificial e Desenvolvimento de Soluções com Dados.