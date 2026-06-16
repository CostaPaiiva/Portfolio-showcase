Plataforma de Inteligência para Concursos Públicos








Projeto de Engenharia de Dados desenvolvido para coletar, tratar, armazenar e analisar dados de concursos públicos, com foco em cargos de Tecnologia da Informação, Ciência de Dados, Engenharia de Dados e áreas correlatas.

A proposta é simular uma solução real de dados, passando por etapas como extração, tratamento, modelagem dimensional, carga em Data Warehouse e futura construção de dashboards analíticos.

Sumário
Objetivo
Problema de Negócio
Arquitetura do Projeto
Tecnologias Utilizadas
Estrutura de Pastas
Modelo de Dados
Como Executar o Projeto
Testes Realizados
Status do Projeto
Próximas Etapas
Autor
Objetivo

Construir uma plataforma analítica capaz de responder perguntas como:

Quais bancas mais organizam concursos de TI?
Quais estados possuem os melhores salários?
Quais cargos aparecem com maior frequência?
Qual é a evolução salarial dos concursos públicos de tecnologia?
Quais órgãos mais ofertam vagas na área de TI?
Como os concursos se distribuem por estado, banca, órgão e área?
Problema de Negócio

As informações sobre concursos públicos estão espalhadas em diferentes fontes, como sites de bancas, portais institucionais, páginas de notícias e editais em PDF.

Isso dificulta análises consolidadas, como comparar salários, identificar bancas mais frequentes, acompanhar oportunidades por estado e entender tendências da área pública para profissionais de tecnologia.

Este projeto propõe centralizar esses dados em um Data Warehouse, permitindo consultas analíticas e visualização de indicadores.

Arquitetura do Projeto
Fontes de Dados
      ↓
Extração com Python
      ↓
Data Lake Raw
      ↓
Transformação e Padronização
      ↓
PostgreSQL / Data Warehouse
      ↓
Consultas SQL
      ↓
Dashboard Analítico
Arquitetura atual

Até o momento, o projeto já possui:

Camada	Status	Descrição
Estrutura de pastas	Concluída	Organização inicial do projeto
Banco PostgreSQL	Concluído	Banco local executando via Docker
pgAdmin	Concluído	Interface gráfica para administração
Modelo dimensional	Concluído	Tabelas dimensão e tabela fato
Dados de teste	Concluído	Dados simulados para validação
Conexão Python	Concluída	SQLAlchemy conectado ao PostgreSQL
Extração de dados	Pendente	Próxima etapa
Transformação ETL	Pendente	Próximas etapas
Dashboard	Pendente	Etapa futura
Tecnologias Utilizadas
Tecnologia	Finalidade
Python	Desenvolvimento dos pipelines de dados
PostgreSQL	Banco de dados analítico
Docker	Criação do ambiente local
Docker Compose	Orquestração dos containers
SQL	Modelagem, consultas e manipulação de dados
Pandas	Tratamento e análise de dados
SQLAlchemy	Conexão Python com PostgreSQL
psycopg2	Driver PostgreSQL para Python
python-dotenv	Leitura de variáveis de ambiente
pgAdmin	Administração visual do banco
Git e GitHub	Versionamento e portfólio
Estrutura de Pastas
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
│   │   ├── connection.py
│   │   └── test_connection.py
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
Descrição das principais pastas
Pasta	Descrição
data/raw	Dados brutos coletados das fontes
data/processed	Dados tratados e padronizados
data/warehouse	Dados finais preparados para análise
docs	Documentação técnica do projeto
notebooks	Análises exploratórias
src/extraction	Scripts de extração
src/transformation	Scripts de transformação
src/loading	Scripts de carga no banco
src/database	Conexão com PostgreSQL
sql	Scripts SQL do banco
dashboards	Arquivos e imagens de dashboards
Modelo de Dados

O projeto utiliza modelagem dimensional em formato de esquema estrela.

Tabela fato
Tabela	Descrição
fato_concurso	Armazena os eventos principais dos concursos
Tabelas dimensão
Tabela	Descrição
dim_banca	Informações das bancas organizadoras
dim_estado	Informações dos estados
dim_cargo	Informações dos cargos
dim_orgao	Informações dos órgãos públicos
Visão simplificada do modelo
dim_banca   dim_estado   dim_cargo   dim_orgao
     \          |           |           /
      \         |           |          /
              fato_concurso
Campos principais da tabela fato
Campo	Descrição
id_concurso	Identificador do concurso
id_banca	Chave da banca organizadora
id_estado	Chave do estado
id_cargo	Chave do cargo
id_orgao	Chave do órgão
ano	Ano do concurso
vagas	Quantidade de vagas
salario	Salário inicial
inscricao_inicio	Data inicial de inscrição
inscricao_fim	Data final de inscrição
data_prova	Data da prova
url_edital	Link do edital
data_carga	Data de carregamento no banco
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
4. Verificar containers
docker ps

Resultado esperado:

concursos_postgres
concursos_pgadmin
5. Acessar o pgAdmin

Acesse no navegador:

http://localhost:8080

Credenciais:

Campo	Valor
Email	admin@concursos.com
Senha	admin123

Configuração do servidor no pgAdmin:

Campo	Valor
Host	postgres
Porta	5432
Database	concursos_dw
User	concursos_user
Password	concursos_pass

Dentro do pgAdmin, o host correto é postgres, pois o pgAdmin e o PostgreSQL estão na mesma rede Docker.

Testes Realizados
Testar banco pelo terminal
docker exec -it concursos_postgres psql -U concursos_user -d concursos_dw

Listar tabelas:

\dt

Consultar dados de teste:

SELECT * FROM fato_concurso;

Sair:

\q
Criar ambiente virtual Python
python -m venv .venv

Ativar no Git Bash:

source .venv/Scripts/activate

Ativar no PowerShell:

.venv\Scripts\Activate.ps1

Instalar dependências:

pip install -r requirements.txt
Testar conexão Python com PostgreSQL

Entre na pasta:

cd src/database

Execute:

python test_connection.py

Resultado esperado:

Conexão realizada com sucesso!
Tabelas encontradas no banco:
- dim_banca
- dim_cargo
- dim_estado
- dim_orgao
- fato_concurso
Status do Projeto
Etapa	Status
Estrutura inicial criada	Concluído
Ambiente Docker configurado	Concluído
Banco PostgreSQL criado	Concluído
pgAdmin configurado	Concluído
Modelo dimensional criado	Concluído
Dados de teste inseridos	Concluído
Conexão Python com PostgreSQL	Concluído
Script de teste de conexão	Concluído
Pipeline de extração	Pendente
Pipeline de transformação	Pendente
Carga automatizada	Pendente
Dashboard	Pendente
Relatório final	Em andamento
Próximas Etapas
Criar pipeline de extração com dados simulados em JSON.
Salvar os dados brutos na pasta data/raw.
Criar processo de transformação e padronização dos dados.
Carregar os dados tratados no PostgreSQL.
Criar consultas SQL analíticas.
Construir dashboard com indicadores.
Expandir a coleta para fontes reais.
Finalizar relatório técnico.
Diferenciais do Projeto

Este projeto demonstra conhecimentos práticos em:

Engenharia de Dados.
Organização de projeto profissional.
Docker e ambientes reprodutíveis.
Banco de dados PostgreSQL.
Modelagem dimensional.
SQL.
Python aplicado a dados.
ETL.
Documentação técnica.
Versionamento com Git e GitHub.
Autor

Projeto desenvolvido como parte de um portfólio profissional de Engenharia de Dados.

Área de foco: Engenharia de Dados, Ciência de Dados, Análise de Dados e Inteligência Artificial.