Relatório Técnico — Plataforma de Inteligência para Concursos Públicos










Sumário
1. Visão Geral
2. Problema de Negócio
3. Objetivos
4. Tecnologias Utilizadas
5. Arquitetura da Solução
6. Estrutura do Projeto
7. Ambiente Docker
8. Modelo de Dados
9. Data Warehouse
10. Pipeline ETL
11. Consultas Analíticas SQL
12. Dashboard Analítico
13. Execução do Projeto
14. Evidências do Projeto
15. Etapas Concluídas
16. Competências Demonstradas
17. Próximas Melhorias
18. Considerações Finais
1. Visão Geral

A Plataforma de Inteligência para Concursos Públicos é um projeto de Engenharia de Dados desenvolvido para simular uma solução completa de coleta, tratamento, armazenamento, análise e visualização de dados relacionados a concursos públicos.

O foco principal do projeto está em concursos voltados para áreas como:

Tecnologia da Informação.
Ciência de Dados.
Engenharia de Dados.
Análise de Dados.
Desenvolvimento de Sistemas.
Áreas correlatas de tecnologia no setor público.

A proposta é construir uma base analítica capaz de centralizar informações de concursos e permitir análises estratégicas sobre bancas, órgãos, cargos, estados, salários, vagas e evolução temporal.

1.1 Resumo Executivo
Item	Descrição
Nome do projeto	Plataforma de Inteligência para Concursos Públicos
Categoria	Engenharia de Dados
Status	Versão 1.0 concluída
Banco de dados	PostgreSQL
Ambiente	Docker
Linguagem principal	Python
Processamento	Pandas
Conexão com banco	SQLAlchemy
Visualização	Streamlit e Plotly
Modelagem	Esquema estrela
Entrega final	ETL completo + Data Warehouse + SQL Analytics + Dashboard
2. Problema de Negócio

As informações sobre concursos públicos normalmente estão distribuídas em diversas fontes, como:

Sites de bancas organizadoras.
Portais institucionais.
Portais de notícias.
Editais em PDF.
Diários oficiais.
Agregadores de concursos.

Essa dispersão torna difícil responder perguntas importantes de maneira rápida e confiável.

2.1 Dores Identificadas
Dor	Impacto
Dados espalhados em várias fontes	Dificulta análise consolidada
Informações em formatos diferentes	Exige tratamento manual
Falta de visão histórica	Dificulta análise de tendências
Comparação salarial manual	Processo lento e sujeito a erros
Ausência de visão por banca	Dificulta direcionamento de estudos
Falta de dashboard centralizado	Reduz capacidade de tomada de decisão
2.2 Perguntas Analíticas

A plataforma foi planejada para responder perguntas como:

Pergunta Analítica	Valor Gerado
Quais bancas mais organizam concursos de TI?	Apoio ao planejamento de estudos
Quais estados possuem os melhores salários?	Comparação de oportunidades
Quais cargos aparecem com maior frequência?	Identificação de tendências
Quais órgãos mais ofertam vagas de tecnologia?	Priorização de concursos
Como os salários evoluem ao longo dos anos?	Análise histórica
Quais concursos possuem maior quantidade de vagas?	Priorização estratégica
Quais concursos apresentam maiores salários?	Apoio à tomada de decisão
Quais regiões concentram mais oportunidades?	Análise geográfica
3. Objetivos
3.1 Objetivo Geral

Construir uma solução de Engenharia de Dados capaz de centralizar informações de concursos públicos em um Data Warehouse, permitindo consultas analíticas e visualização dos dados em um dashboard interativo.

3.2 Objetivos Específicos
Criar uma arquitetura local utilizando Docker.
Configurar PostgreSQL e pgAdmin.
Criar um modelo dimensional em esquema estrela.
Implementar pipeline de extração de dados.
Armazenar dados brutos em formato JSON.
Implementar pipeline de transformação com Pandas.
Gerar dados tratados em formato CSV.
Implementar pipeline de carga no PostgreSQL.
Popular tabelas dimensão e tabela fato.
Criar consultas SQL analíticas.
Criar uma view consolidada para consumo analítico.
Criar dashboard interativo com Streamlit e Plotly.
Documentar o projeto de forma profissional para GitHub.
4. Tecnologias Utilizadas
Tecnologia	Finalidade
Python	Desenvolvimento dos pipelines ETL
Pandas	Tratamento, limpeza e padronização dos dados
PostgreSQL	Banco de dados relacional e analítico
Docker	Criação de ambiente local reprodutível
Docker Compose	Orquestração dos containers
SQL	Criação de tabelas, consultas e views
SQLAlchemy	Integração entre Python e PostgreSQL
psycopg2	Driver PostgreSQL para Python
python-dotenv	Leitura de variáveis de ambiente
pgAdmin	Administração visual do banco
Streamlit	Criação do dashboard web
Plotly	Visualizações interativas
Git	Versionamento do código
GitHub	Publicação do projeto como portfólio
5. Arquitetura da Solução

A arquitetura foi projetada para representar um fluxo real de Engenharia de Dados, partindo da ingestão dos dados até a entrega visual para análise.

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
5.1 Camadas da Arquitetura
Camada	Descrição	Status
Fontes de dados	Dados simulados de concursos públicos	Concluído
Extração	Geração dos dados brutos em JSON	Concluído
Raw	Armazenamento dos dados sem tratamento	Concluído
Transformação	Limpeza, padronização e enriquecimento	Concluído
Processed	Dados tratados em CSV	Concluído
Carga	Inserção dos dados no PostgreSQL	Concluído
Data Warehouse	Modelo estrela com fato e dimensões	Concluído
SQL Analytics	Consultas analíticas organizadas	Concluído
View Analítica	Consolidação para BI e dashboard	Concluído
Dashboard	Visualização interativa dos indicadores	Concluído
6. Estrutura do Projeto
plataforma-inteligencia-concursos/
│
├── dashboard/
│   └── app.py
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
├── dashboards/
├── docker-compose.yml
├── .env.example
├── .gitignore
├── README.md
└── requirements.txt
6.1 Descrição das Pastas
Pasta	Finalidade
dashboard	Aplicação Streamlit do dashboard
data/raw	Dados brutos gerados pelo pipeline de extração
data/processed	Dados tratados gerados pelo pipeline de transformação
data/warehouse	Camada reservada para dados analíticos finais
data/sample	Amostras versionáveis para demonstração no GitHub
docs	Documentação técnica do projeto
notebooks	Espaço reservado para análises exploratórias
src/extraction	Scripts de extração
src/transformation	Scripts de transformação
src/loading	Scripts de carga
src/database	Conexão com PostgreSQL
src/utils	Funções auxiliares
sql	Scripts SQL estruturais
sql/analytics	Consultas SQL analíticas
dashboards	Prints e evidências visuais do dashboard
7. Ambiente Docker

O projeto utiliza Docker para garantir que o ambiente seja reprodutível e fácil de executar localmente.

O arquivo docker-compose.yml configura dois serviços principais:

Serviço	Função
PostgreSQL	Banco de dados principal do Data Warehouse
pgAdmin	Interface gráfica para administração do banco
7.1 Configurações do PostgreSQL
Campo	Valor
Banco	concursos_dw
Usuário	concursos_user
Senha	concursos_pass
Porta	5432
Container	concursos_postgres
7.2 Configurações do pgAdmin
Campo	Valor
URL	http://localhost:8080
Email	admin@concursos.com
Senha	admin123
Container	concursos_pgadmin

Dentro do pgAdmin, o host correto para conexão com o banco é:

postgres

Isso acontece porque PostgreSQL e pgAdmin estão executando dentro da mesma rede Docker.

8. Modelo de Dados

O projeto utiliza modelagem dimensional em formato de esquema estrela.

Esse modelo é adequado para cenários analíticos, pois facilita consultas por dimensões como banca, estado, cargo e órgão.

dim_banca   dim_estado   dim_cargo   dim_orgao
     \          |           |           /
      \         |           |          /
              fato_concurso
8.1 Tabela Fato
Tabela	Descrição
fato_concurso	Armazena os eventos principais dos concursos

Principais métricas:

Métrica	Descrição
vagas	Quantidade de vagas
salario	Salário inicial
ano	Ano do concurso
data_prova	Data da prova
8.2 Tabelas Dimensão
Tabela	Descrição
dim_banca	Informações das bancas organizadoras
dim_estado	Informações dos estados e regiões
dim_cargo	Informações dos cargos, áreas e níveis
dim_orgao	Informações dos órgãos e esferas administrativas
9. Data Warehouse

O Data Warehouse foi implementado em PostgreSQL e estruturado para permitir análises por diferentes perspectivas.

9.1 Tabelas Criadas
Tabela	Tipo	Finalidade
dim_banca	Dimensão	Análise por banca organizadora
dim_estado	Dimensão	Análise por estado e região
dim_cargo	Dimensão	Análise por cargo, área e nível
dim_orgao	Dimensão	Análise por órgão e esfera
fato_concurso	Fato	Métricas principais dos concursos
9.2 Exemplos de Análises Possíveis
Perspectiva	Exemplo de Análise
Banca	Bancas com maior quantidade de concursos
Estado	Estados com maior salário médio
Cargo	Cargos com mais vagas
Órgão	Órgãos que mais ofertam concursos
Ano	Evolução de concursos ao longo do tempo
Região	Distribuição regional das oportunidades
10. Pipeline ETL

O projeto implementa um pipeline completo de Extração, Transformação e Carga.

Extract
   ↓
Transform
   ↓
Load
10.1 Pipeline de Extração

Arquivo:

src/extraction/extract_sample_data.py

Responsável por simular a coleta de dados de concursos públicos.

A saída da extração é salva em:

data/raw/

O arquivo gerado segue o padrão:

concursos_raw_YYYY_MM_DD_HH_MM_SS.json
10.1.1 Dados Extraídos
Campo	Descrição
orgao	Órgão responsável pelo concurso
cargo	Cargo ofertado
area	Área de atuação
nivel	Nível exigido
banca	Banca organizadora
estado	Estado
regiao	Região brasileira
esfera	Esfera administrativa
ano	Ano do concurso
vagas	Quantidade de vagas
salario	Salário inicial
inscricao_inicio	Data inicial da inscrição
inscricao_fim	Data final da inscrição
data_prova	Data da prova
url_edital	Link do edital
10.2 Pipeline de Transformação

Arquivo:

src/transformation/transform_raw_data.py

Responsável por ler o JSON bruto mais recente, validar a estrutura, padronizar informações e gerar um arquivo CSV tratado.

A saída é salva em:

data/processed/

O arquivo gerado segue o padrão:

concursos_processed_YYYY_MM_DD_HH_MM_SS.csv
10.2.1 Transformações Realizadas
Transformação	Descrição
Validação de colunas	Verifica se os campos obrigatórios existem
Padronização textual	Remove espaços extras
Padronização de cargos	Agrupa cargos semelhantes
Padronização de bancas	Normaliza nomes de bancas
Conversão numérica	Ajusta ano, vagas e salario
Conversão de datas	Converte datas para formato adequado
Faixa salarial	Classifica salários por intervalo
Dias de inscrição	Calcula duração do período de inscrição
Data de transformação	Registra a execução do pipeline
10.2.2 Colunas Criadas
Coluna	Finalidade
cargo_padronizado	Categoria analítica do cargo
banca_padronizada	Nome padronizado da banca
salario_faixa	Faixa salarial
dias_inscricao	Duração do período de inscrição
data_transformacao	Data e hora da transformação
10.3 Pipeline de Carga

Arquivo:

src/loading/load_processed_data.py

Responsável por carregar os dados tratados no PostgreSQL.

10.3.1 Processo de Carga
Etapa	Descrição
Leitura do CSV tratado	Busca o arquivo mais recente em data/processed
Inserção nas dimensões	Popula dim_banca, dim_estado, dim_cargo e dim_orgao
Busca dos IDs	Recupera as chaves das dimensões
Inserção na fato	Popula fato_concurso
Controle de duplicidade	Evita registros repetidos
10.3.2 Controle de Duplicidade

A carga na tabela fato considera a seguinte combinação para evitar duplicações:

Campo
id_banca
id_estado
id_cargo
id_orgao
ano
url_edital

Caso um concurso com essa combinação já exista, ele não é inserido novamente.

11. Consultas Analíticas SQL

Após a carga dos dados no PostgreSQL, foram criadas consultas SQL para exploração analítica dos dados.

As consultas estão localizadas em:

sql/analytics/
11.1 Arquivos SQL Criados
Arquivo	Objetivo
01_kpis_gerais.sql	Indicadores gerais do Data Warehouse
02_analise_por_banca.sql	Análise por banca organizadora
03_analise_por_estado.sql	Análise por estado e região
04_analise_por_cargo.sql	Análise por cargo
05_top_salarios.sql	Concursos com maiores salários
06_evolucao_por_ano.sql	Evolução anual de concursos, vagas e salários
07_visao_completa_concursos.sql	Consulta completa com todas as dimensões
08_create_view_concursos_analytics.sql	Criação da view analítica
09_kpis_view_analytics.sql	KPIs usando a view analítica
11.2 KPIs Criados
Indicador	Descrição
Total de concursos	Quantidade de concursos carregados
Total de vagas	Soma das vagas ofertadas
Salário médio	Média salarial dos concursos
Menor salário	Menor salário registrado
Maior salário	Maior salário registrado
Total de bancas	Quantidade de bancas distintas
Total de estados	Quantidade de estados distintos
Total de cargos	Quantidade de cargos distintos
Total de órgãos	Quantidade de órgãos distintos
11.3 View Analítica

Foi criada a view:

vw_concursos_analytics

Ela consolida os dados da tabela fato com as dimensões.

11.3.1 Benefícios da View
Benefício	Descrição
Simplificação	Evita repetir joins complexos
Reutilização	Serve para consultas, dashboards e BI
Organização	Centraliza a visão analítica
Performance lógica	Facilita consumo dos dados
Integração	Pode ser usada em Power BI, Metabase, Superset ou Streamlit
12. Dashboard Analítico

O dashboard foi desenvolvido com Streamlit e Plotly.

Arquivo:

dashboard/app.py

A fonte principal de dados é a view:

vw_concursos_analytics
12.1 Objetivo do Dashboard

Transformar os dados carregados no PostgreSQL em uma interface visual e interativa, permitindo análise rápida dos concursos públicos.

12.2 Funcionalidades Implementadas
Funcionalidade	Descrição
KPIs principais	Total de concursos, vagas, média salarial e maior salário
Filtros interativos	Estado, banca, ano, nível, área e região
Concursos por estado	Gráfico de barras
Concursos por banca	Ranking das bancas
Concursos por ano	Evolução temporal
Vagas por nível	Distribuição por nível
Salário médio por estado	Comparação salarial
Vagas por região	Distribuição regional
Top cargos por vagas	Ranking dos cargos com mais vagas
Top salários	Concursos com maiores salários
Base completa	Tabela detalhada com os dados analíticos
12.3 Fluxo Final do Projeto
Extração
   ↓
Transformação
   ↓
Carga
   ↓
Data Warehouse
   ↓
SQL Analytics
   ↓
Dashboard

A criação do dashboard fecha a primeira versão completa do projeto, entregando uma camada visual para consumo dos dados.

13. Execução do Projeto
13.1 Subir os Containers
docker compose up -d
13.2 Criar Ambiente Virtual
python -m venv .venv

Ativar no Git Bash:

source .venv/Scripts/activate

Ativar no PowerShell:

.venv\Scripts\Activate.ps1
13.3 Instalar Dependências
pip install -r requirements.txt
13.4 Executar ETL Completo
python src/extraction/extract_sample_data.py
python src/transformation/transform_raw_data.py
python src/loading/load_processed_data.py
13.5 Criar View Analítica
docker exec -i concursos_postgres psql -U concursos_user -d concursos_dw < sql/analytics/08_create_view_concursos_analytics.sql
13.6 Executar Consulta de KPIs
docker exec -i concursos_postgres psql -U concursos_user -d concursos_dw < sql/analytics/01_kpis_gerais.sql
13.7 Executar Dashboard
streamlit run dashboard/app.py

Acesse no navegador:

http://localhost:8501
14. Evidências do Projeto

Para fortalecer o portfólio no GitHub, recomenda-se salvar imagens do dashboard na pasta:

dashboards/

Sugestões de arquivos:

dashboards/dashboard_home.png
dashboards/dashboard_filtros.png
dashboards/dashboard_graficos.png
dashboards/dashboard_tabelas.png

Essas imagens ajudam recrutadores a visualizar rapidamente o resultado final do projeto.

15. Etapas Concluídas
Etapa	Status
Estrutura inicial do projeto	Concluído
Configuração do Docker	Concluído
Configuração do PostgreSQL	Concluído
Configuração do pgAdmin	Concluído
Criação do modelo dimensional	Concluído
Criação dos scripts SQL estruturais	Concluído
Inserção de dados simulados	Concluído
Conexão Python com PostgreSQL	Concluído
Pipeline de extração	Concluído
Geração de dados brutos em JSON	Concluído
Pipeline de transformação	Concluído
Geração de dados tratados em CSV	Concluído
Pipeline de carga	Concluído
Carga nas dimensões	Concluído
Carga na tabela fato	Concluído
Controle básico de duplicidade	Concluído
Consultas analíticas SQL	Concluído
Criação da view vw_concursos_analytics	Concluído
Criação do dashboard Streamlit	Concluído
Documentação técnica	Concluído
Versão 1.0 para portfólio	Concluído
16. Competências Demonstradas

Este projeto demonstra competências práticas importantes para atuação em Engenharia de Dados.

Competência	Aplicação no Projeto
Python	Criação dos pipelines
Pandas	Transformação dos dados
SQL	Consultas analíticas e modelagem
PostgreSQL	Data Warehouse
Docker	Ambiente reprodutível
SQLAlchemy	Integração Python com banco
Modelagem dimensional	Esquema estrela
ETL	Pipeline completo
Data Warehouse	Estrutura analítica
Streamlit	Dashboard interativo
Plotly	Visualizações
Git/GitHub	Versionamento e portfólio
Documentação	README e relatório técnico
17. Próximas Melhorias

Embora a versão 1.0 esteja concluída, o projeto pode evoluir com melhorias.

Melhoria	Descrição
Coleta real	Buscar dados em sites ou APIs públicas
Extração de PDF	Ler editais automaticamente
Orquestração	Adicionar Airflow ou Prefect
Data Lake com Parquet	Salvar dados em formato otimizado
Camada staging	Criar tabelas intermediárias no banco
Testes automatizados	Validar pipelines com pytest
Qualidade de dados	Adicionar validações e checks
Logs estruturados	Monitorar execuções dos pipelines
Deploy do dashboard	Publicar a aplicação em ambiente gratuito
CI/CD	Automatizar validações no GitHub Actions
18. Considerações Finais

A Plataforma de Inteligência para Concursos Públicos atingiu sua primeira versão completa.

O projeto contempla um fluxo de Engenharia de Dados de ponta a ponta:

Coleta
  ↓
Armazenamento bruto
  ↓
Transformação
  ↓
Carga
  ↓
Data Warehouse
  ↓
SQL Analytics
  ↓
Dashboard

A solução demonstra domínio prático de ferramentas e conceitos importantes para Engenharia de Dados, como Docker, PostgreSQL, SQL, Python, Pandas, SQLAlchemy, modelagem dimensional, ETL, consultas analíticas e visualização de dados.

Além disso, o projeto foi organizado com foco em portfólio, contendo estrutura clara de pastas, documentação técnica, scripts reutilizáveis e uma entrega visual por meio do dashboard.
.