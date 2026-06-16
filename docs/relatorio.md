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
10. Dados de Teste
11. Conexão Python com PostgreSQL
12. Pipeline de Extração
13. Dependências Python
14. Etapas Concluídas
15. Comandos Utilizados
16. Próximas Etapas
17. Considerações Parciais
1. Visão Geral

A Plataforma de Inteligência para Concursos Públicos é um projeto de Engenharia de Dados desenvolvido com o objetivo de coletar, organizar, transformar e analisar dados relacionados a concursos públicos, especialmente na área de Tecnologia da Informação.

O projeto simula um ambiente real de dados, utilizando conceitos como:

Conceito	Aplicação no Projeto
ETL	Extração, transformação e carga dos dados
Data Warehouse	Armazenamento analítico no PostgreSQL
Modelagem dimensional	Esquema estrela com tabela fato e dimensões
Docker	Ambiente local reprodutível
SQL	Criação de tabelas e consultas analíticas
Python	Desenvolvimento dos pipelines
Documentação técnica	Registro das decisões e etapas do projeto

A proposta é construir uma solução capaz de centralizar dados de concursos públicos e permitir análises estratégicas sobre oportunidades, salários, bancas, cargos, órgãos e distribuição geográfica.

2. Problema de Negócio

As informações sobre concursos públicos estão distribuídas em diferentes fontes, como:

Sites de bancas organizadoras.
Portais de notícias.
Páginas institucionais.
Editais em PDF.
Diários oficiais.
Agregadores de concursos.

Essa dispersão dificulta análises consolidadas e comparativas.

Perguntas que a plataforma busca responder
Pergunta Analítica	Valor Gerado
Quais bancas organizam mais concursos de TI?	Direcionamento de estudos por banca
Quais estados possuem os melhores salários?	Comparação de oportunidades
Quais cargos aparecem com maior frequência?	Identificação de tendências
Quais órgãos mais ofertam vagas de TI?	Priorização de editais
Como os salários evoluem ao longo dos anos?	Análise de valorização da área
Quais regiões concentram mais oportunidades?	Visão geográfica do mercado público

Sem uma solução centralizada, essas informações precisam ser consultadas manualmente, tornando o processo lento, repetitivo e sujeito a erros.

3. Objetivos
3.1 Objetivo Geral

Construir uma solução de Engenharia de Dados capaz de centralizar informações de concursos públicos em um Data Warehouse, permitindo análises estratégicas e futura geração de dashboards.

3.2 Objetivos Específicos
Criar uma arquitetura local utilizando Docker.
Configurar um banco PostgreSQL para armazenamento analítico.
Modelar um Data Warehouse com esquema estrela.
Criar tabelas dimensão e tabela fato.
Inserir dados simulados para validação inicial.
Criar conexão entre Python e PostgreSQL.
Criar pipeline de extração de dados.
Armazenar dados brutos em formato JSON.
Criar pipelines de transformação e carga.
Desenvolver consultas analíticas em SQL.
Criar dashboards para visualização dos indicadores.
Documentar todas as etapas do projeto.
4. Tecnologias Utilizadas
Tecnologia	Finalidade
Python	Desenvolvimento dos pipelines ETL
PostgreSQL	Banco de dados analítico
Docker	Criação do ambiente local
Docker Compose	Orquestração dos serviços
SQL	Criação de tabelas, consultas e modelagem
Pandas	Tratamento e manipulação de dados
SQLAlchemy	Conexão entre Python e PostgreSQL
psycopg2	Driver PostgreSQL para Python
python-dotenv	Leitura de variáveis de ambiente
pgAdmin	Administração visual do banco
Git e GitHub	Versionamento e publicação do projeto
5. Arquitetura da Solução

A arquitetura foi planejada para representar um fluxo real de Engenharia de Dados.

Fontes de Dados
      ↓
Extração com Python
      ↓
Data Lake Raw
      ↓
Transformação e Padronização
      ↓
Data Warehouse PostgreSQL
      ↓
Consultas SQL
      ↓
Dashboard Analítico
5.1 Descrição das Camadas
Camada	Descrição	Status
Fontes de Dados	Sites, APIs, arquivos ou editais	Simulada
Extração	Coleta dos dados com Python	Concluída
Data Lake Raw	Armazenamento dos dados brutos	Concluído
Transformação	Limpeza e padronização dos dados	Pendente
Data Warehouse	Banco analítico PostgreSQL	Parcialmente concluído
Consultas SQL	Análises sobre os dados	Pendente
Dashboard	Visualização dos indicadores	Pendente

Até esta etapa, o projeto já possui a estrutura base, o ambiente Docker, o banco PostgreSQL, o modelo dimensional, a conexão Python e o primeiro pipeline de extração.

6. Estrutura do Projeto
plataforma-inteligencia-concursos/
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
│   │   ├── __init__.py
│   │   └── extract_sample_data.py
│   ├── transformation/
│   │   └── __init__.py
│   ├── loading/
│   │   └── __init__.py
│   ├── database/
│   │   ├── __init__.py
│   │   ├── connection.py
│   │   └── test_connection.py
│   ├── utils/
│   │   └── __init__.py
│   └── __init__.py
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
6.1 Descrição das Pastas
Pasta	Finalidade
data/raw	Armazena dados brutos gerados pelo pipeline de extração
data/processed	Armazena dados tratados e padronizados
data/warehouse	Armazena dados finais analíticos
data/sample	Armazena amostras pequenas para demonstração no GitHub
docs	Documentação técnica
notebooks	Análises exploratórias
src/extraction	Scripts de extração
src/transformation	Scripts de transformação
src/loading	Scripts de carga
src/database	Conexão com o banco
src/utils	Funções auxiliares
sql	Scripts SQL
dashboards	Dashboards e imagens analíticas
7. Ambiente Docker

Foi utilizado Docker para criar um ambiente local padronizado com PostgreSQL e pgAdmin.

O arquivo docker-compose.yml define dois serviços principais:

Serviço	Função
PostgreSQL	Banco de dados do Data Warehouse
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

Dentro do pgAdmin, o host utilizado para conexão com o PostgreSQL é:

postgres

Isso ocorre porque os dois serviços estão executando na mesma rede Docker criada pelo Docker Compose.

8. Modelo de Dados

O projeto utiliza modelagem dimensional, também conhecida como esquema estrela.

Esse tipo de modelagem é comum em projetos de Data Warehouse, pois facilita consultas analíticas e construção de dashboards.

8.1 Visão Simplificada
dim_banca   dim_estado   dim_cargo   dim_orgao
     \          |           |           /
      \         |           |          /
              fato_concurso

A tabela fato_concurso concentra os eventos principais, enquanto as dimensões armazenam informações descritivas sobre bancas, estados, cargos e órgãos.

9. Data Warehouse

O Data Warehouse foi criado inicialmente com uma tabela fato e quatro tabelas dimensão.

9.1 Tabela dim_banca

Armazena informações sobre as bancas organizadoras dos concursos.

Campo	Tipo	Descrição
id_banca	SERIAL	Identificador da banca
nome_banca	VARCHAR	Nome da banca organizadora

Exemplos:

FGV.
Cebraspe.
FCC.
Instituto AOCP.
9.2 Tabela dim_estado

Armazena informações sobre os estados brasileiros relacionados aos concursos.

Campo	Tipo	Descrição
id_estado	SERIAL	Identificador do estado
sigla_estado	CHAR(2)	Sigla do estado
nome_estado	VARCHAR	Nome do estado
regiao	VARCHAR	Região do Brasil

Exemplos:

Sigla	Estado	Região
PI	Piauí	Nordeste
SP	São Paulo	Sudeste
DF	Distrito Federal	Centro-Oeste
CE	Ceará	Nordeste
9.3 Tabela dim_cargo

Armazena informações sobre os cargos ofertados nos concursos.

Campo	Tipo	Descrição
id_cargo	SERIAL	Identificador do cargo
nome_cargo	VARCHAR	Nome do cargo
area	VARCHAR	Área de atuação
nivel	VARCHAR	Nível exigido

Exemplos:

Analista de Tecnologia da Informação.
Auditor de Controle Externo - TI.
Técnico de Informática.
Analista de Dados.
9.4 Tabela dim_orgao

Armazena informações sobre os órgãos públicos responsáveis pelos concursos.

Campo	Tipo	Descrição
id_orgao	SERIAL	Identificador do órgão
nome_orgao	VARCHAR	Nome do órgão
esfera	VARCHAR	Esfera administrativa

Exemplos:

Órgão	Esfera
TCE-PI	Estadual
Prefeitura de São Paulo	Municipal
Banco do Brasil	Federal
TJ-CE	Estadual
9.5 Tabela fato_concurso

Tabela central do modelo estrela.

Ela armazena as métricas e eventos principais relacionados aos concursos públicos.

Campo	Tipo	Descrição
id_concurso	SERIAL	Identificador do concurso
id_banca	INT	Chave estrangeira da banca
id_estado	INT	Chave estrangeira do estado
id_cargo	INT	Chave estrangeira do cargo
id_orgao	INT	Chave estrangeira do órgão
ano	INT	Ano do concurso
vagas	INT	Quantidade de vagas
salario	NUMERIC	Salário inicial
inscricao_inicio	DATE	Início das inscrições
inscricao_fim	DATE	Fim das inscrições
data_prova	DATE	Data da prova
url_edital	TEXT	Link do edital
data_carga	TIMESTAMP	Data de carga no banco
10. Dados de Teste

Foram inseridos dados simulados para validar a estrutura inicial do banco de dados.

Órgão	Cargo	Banca	Estado	Salário
TCE-PI	Auditor de Controle Externo - TI	FGV	PI	R$ 18.000,00
Banco do Brasil	Analista de Tecnologia da Informação	Cebraspe	DF	R$ 9.500,00
Prefeitura de São Paulo	Técnico de Informática	FCC	SP	R$ 6.500,00
TJ-CE	Analista de Dados	Instituto AOCP	CE	R$ 12.000,00

Esses dados permitem testar consultas SQL e validar os relacionamentos entre as tabelas dimensão e a tabela fato.

11. Conexão Python com PostgreSQL

Nesta etapa foi criada a camada de conexão entre a aplicação Python e o banco PostgreSQL.

Foram utilizadas as bibliotecas:

Biblioteca	Função
SQLAlchemy	Criação da engine de conexão
python-dotenv	Leitura das variáveis do arquivo .env
psycopg2	Driver PostgreSQL

O arquivo responsável pela conexão é:

src/database/connection.py

As variáveis utilizadas são:

DB_HOST=localhost
DB_PORT=5432
DB_NAME=concursos_dw
DB_USER=concursos_user
DB_PASSWORD=concursos_pass

A função principal criada foi:

get_engine()

Essa função retorna uma engine SQLAlchemy, que será reutilizada nas próximas etapas do projeto para executar consultas, inserir dados e carregar informações no Data Warehouse.

11.1 Teste de Conexão

Para validar a comunicação entre Python e PostgreSQL, foi criado o script:

src/database/test_connection.py

Esse script executa uma consulta no catálogo do PostgreSQL para listar todas as tabelas existentes no schema público.

Resultado esperado:

Conexão realizada com sucesso!
Tabelas encontradas no banco:
- dim_banca
- dim_cargo
- dim_estado
- dim_orgao
- fato_concurso

Esse teste confirma que:

O container PostgreSQL está funcionando.
O banco concursos_dw foi criado corretamente.
As tabelas foram criadas pelos scripts SQL.
O Python consegue se conectar ao banco.
A configuração do .env está correta.
12. Pipeline de Extração

Nesta etapa foi criado o primeiro pipeline de extração do projeto.

O script responsável é:

src/extraction/extract_sample_data.py

A função desse script é simular a coleta de dados de concursos públicos, representando a primeira camada do fluxo de Engenharia de Dados.

Em um cenário real, essa etapa poderia coletar informações de:

APIs públicas.
Sites de bancas organizadoras.
Páginas institucionais.
Editais em PDF.
Portais agregadores de concursos.
12.1 Funcionamento do Pipeline

O script executa as seguintes etapas:

Etapa	Descrição
Simulação da coleta	Cria uma lista de concursos com dados estruturados
Geração de metadados	Adiciona origem, data/hora e quantidade de registros
Escrita em arquivo	Salva os dados em formato JSON
Armazenamento raw	Grava o arquivo na pasta data/raw

O pipeline foi desenvolvido para representar a camada raw de uma arquitetura de dados.

Nessa camada, os dados são armazenados em seu formato original, sem transformações ou padronizações complexas.

12.2 Dados Extraídos

Os dados simulados possuem informações como:

Campo	Descrição
orgao	Órgão responsável pelo concurso
cargo	Cargo ofertado
area	Área de atuação
nivel	Nível exigido
banca	Banca organizadora
estado	Estado do concurso
regiao	Região brasileira
esfera	Esfera administrativa
ano	Ano do concurso
vagas	Quantidade de vagas
salario	Salário inicial
inscricao_inicio	Data inicial das inscrições
inscricao_fim	Data final das inscrições
data_prova	Data da prova
url_edital	Link do edital
12.3 Saída Gerada

O pipeline gera arquivos JSON na pasta:

data/raw/

O nome do arquivo segue o padrão:

concursos_raw_YYYY_MM_DD_HH_MM_SS.json

Cada arquivo gerado contém metadados da extração:

Metadado	Descrição
source	Origem dos dados
extraction_datetime	Data e hora da extração
records_count	Quantidade de registros extraídos
data	Lista de concursos extraídos

Exemplo simplificado da estrutura gerada:

{
    "source": "sample_data",
    "extraction_datetime": "2026-06-16T00:00:00",
    "records_count": 6,
    "data": [
        {
            "orgao": "TCE-PI",
            "cargo": "Auditor de Controle Externo - Tecnologia da Informação",
            "area": "TI",
            "nivel": "Superior",
            "banca": "FGV",
            "estado": "PI",
            "regiao": "Nordeste",
            "esfera": "Estadual",
            "ano": 2026,
            "vagas": 10,
            "salario": 18000.00
        }
    ]
}
12.4 Arquivo de Amostra para Portfólio

Como os arquivos gerados em data/raw são ignorados pelo Git, foi criada a pasta:

data/sample/

Essa pasta armazena uma pequena amostra versionável dos dados extraídos.

O objetivo é permitir que recrutadores e avaliadores visualizem o formato dos dados sem precisar executar o pipeline imediatamente.

Arquivo de exemplo:

data/sample/concursos_sample.json

Essa prática é útil em projetos de portfólio, pois melhora a compreensão do fluxo de dados e demonstra preocupação com documentação e reprodutibilidade.

12.5 Importância da Etapa

A etapa de extração representa o início do pipeline de dados.

Ela garante que os dados sejam capturados e armazenados em sua forma bruta antes de qualquer transformação.

Essa prática é comum em arquiteturas de dados porque permite:

Benefício	Descrição
Rastreabilidade	Permite identificar a origem dos dados
Auditoria	Facilita validação posterior
Reprocessamento	Possibilita executar novamente as transformações
Separação de responsabilidades	Mantém extração e transformação independentes
Organização	Estrutura o fluxo ETL de forma clara

Com essa etapa concluída, o projeto passa a ter um fluxo inicial de ingestão de dados, preparando a base para a próxima fase: transformação e padronização.

13. Dependências Python

As dependências iniciais do projeto foram registradas no arquivo requirements.txt.

pandas
requests
beautifulsoup4
python-dotenv
sqlalchemy
psycopg2-binary
jupyter
13.1 Finalidade das Dependências
Biblioteca	Finalidade
pandas	Tratamento e manipulação de dados
requests	Requisições HTTP
beautifulsoup4	Extração de dados de páginas HTML
python-dotenv	Leitura de variáveis de ambiente
sqlalchemy	Conexão e interação com banco de dados
psycopg2-binary	Driver PostgreSQL
jupyter	Análises exploratórias
14. Etapas Concluídas
Etapa	Status
Criação da estrutura inicial do projeto	Concluído
Criação das pastas principais	Concluído
Configuração do Docker Compose	Concluído
Configuração do PostgreSQL	Concluído
Configuração do pgAdmin	Concluído
Criação do arquivo .env.example	Concluído
Criação do arquivo .gitignore	Concluído
Criação do arquivo requirements.txt	Concluído
Criação dos scripts SQL	Concluído
Criação das tabelas dimensionais	Concluído
Criação da tabela fato	Concluído
Inserção de dados simulados no banco	Concluído
Criação da conexão Python com PostgreSQL	Concluído
Criação do script de teste de conexão	Concluído
Criação do pipeline de extração	Concluído
Geração de dados brutos em JSON	Concluído
Criação de amostra em data/sample	Concluído
Atualização do README	Concluído
Atualização do relatório técnico	Concluído
15. Comandos Utilizados
15.1 Docker

Subir os containers:

docker compose up -d

Verificar containers:

docker ps

Acessar PostgreSQL via terminal:

docker exec -it concursos_postgres psql -U concursos_user -d concursos_dw
15.2 PostgreSQL

Listar tabelas:

\dt

Consultar tabela fato:

SELECT * FROM fato_concurso;

Sair do PostgreSQL:

\q
15.3 Python

Criar ambiente virtual:

python -m venv .venv

Ativar ambiente virtual no Git Bash:

source .venv/Scripts/activate

Ativar ambiente virtual no PowerShell:

.venv\Scripts\Activate.ps1

Instalar dependências:

pip install -r requirements.txt

Testar conexão Python:

cd src/database
python test_connection.py

Executar pipeline de extração:

python src/extraction/extract_sample_data.py

Verificar arquivo gerado no Linux, macOS ou Git Bash:

ls data/raw

Verificar arquivo gerado no Windows CMD:

dir data\raw
16. Próximas Etapas

As próximas etapas do projeto serão:

Próxima Etapa	Descrição
Transformação dos dados	Ler o JSON bruto e padronizar os campos
Validação dos dados	Verificar campos obrigatórios e tipos
Salvamento em data/processed	Gerar arquivo tratado
Carga no PostgreSQL	Inserir os dados tratados no Data Warehouse
Consultas analíticas	Criar queries para análise
Dashboard	Visualizar indicadores do projeto
Coleta real	Expandir para fontes públicas reais
Relatório final	Documentar todas as etapas concluídas
17. Considerações Parciais

Até esta etapa, o projeto já possui uma base sólida para evolução.

A estrutura criada permite organizar o fluxo completo de Engenharia de Dados, desde a entrada dos dados brutos até a futura geração de dashboards.

A utilização de Docker facilita a reprodução do ambiente, enquanto o PostgreSQL permite armazenar os dados em um modelo analítico estruturado.

A conexão Python com PostgreSQL prepara o projeto para as próximas etapas de ETL, nas quais os dados serão extraídos, transformados e carregados automaticamente no Data Warehouse.

Com a criação do pipeline de extração, o projeto deixa de ser apenas uma estrutura estática e passa a executar uma etapa prática do fluxo de dados. Os dados brutos são gerados em JSON, armazenados na camada raw e documentados com metadados de extração.

Esse projeto também já demonstra competências importantes para portfólio, como:

Organização de repositório.
Documentação técnica.
Banco de dados relacional.
SQL.
Docker.
Python.
Integração com PostgreSQL.
Modelagem dimensional.
Pipeline inicial de dados.
Boas práticas de Engenharia de Dados.