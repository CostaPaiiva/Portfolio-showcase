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
13. Pipeline de Transformação
14. Pipeline de Carga
15. Consultas Analíticas SQL
16. Dependências Python
17. Etapas Concluídas
18. Comandos Utilizados
19. Próximas Etapas
20. Considerações Parciais
1. Visão Geral

A Plataforma de Inteligência para Concursos Públicos é um projeto de Engenharia de Dados desenvolvido com o objetivo de coletar, organizar, transformar, carregar e analisar dados relacionados a concursos públicos, especialmente na área de Tecnologia da Informação.

O projeto simula um ambiente real de dados, utilizando conceitos como:

Conceito	Aplicação no Projeto
ETL	Extração, transformação e carga dos dados
Data Warehouse	Armazenamento analítico no PostgreSQL
Modelagem dimensional	Esquema estrela com tabela fato e dimensões
Docker	Ambiente local reprodutível
SQL	Criação de tabelas, views e consultas analíticas
Python	Desenvolvimento dos pipelines
Pandas	Tratamento e padronização dos dados
SQLAlchemy	Integração entre Python e PostgreSQL
Documentação técnica	Registro das decisões e etapas do projeto

A proposta é construir uma solução capaz de centralizar dados de concursos públicos e permitir análises estratégicas sobre oportunidades, salários, bancas, cargos, órgãos, estados e evolução temporal.

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
Quais concursos possuem maior quantidade de vagas?	Priorização de oportunidades
Quais concursos apresentam os maiores salários?	Apoio à tomada de decisão

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
Criar pipeline de transformação com Pandas.
Padronizar cargos, bancas, datas e campos numéricos.
Gerar dados tratados em formato CSV.
Criar pipeline de carga no PostgreSQL.
Popular dimensões e tabela fato.
Criar consultas analíticas em SQL.
Criar view consolidada para ferramentas de BI.
Criar dashboards para visualização dos indicadores.
Documentar todas as etapas do projeto.
4. Tecnologias Utilizadas
Tecnologia	Finalidade
Python	Desenvolvimento dos pipelines ETL
PostgreSQL	Banco de dados analítico
Docker	Criação do ambiente local
Docker Compose	Orquestração dos serviços
SQL	Criação de tabelas, consultas, views e análises
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
Dados Processados
      ↓
Carga no PostgreSQL
      ↓
Data Warehouse
      ↓
Consultas SQL e View Analítica
      ↓
Dashboard Analítico
5.1 Descrição das Camadas
Camada	Descrição	Status
Fontes de Dados	Sites, APIs, arquivos ou editais	Simulada
Extração	Coleta dos dados com Python	Concluída
Data Lake Raw	Armazenamento dos dados brutos	Concluído
Transformação	Limpeza e padronização dos dados	Concluída
Dados Processados	Arquivos tratados em CSV	Concluído
Carga	Inserção dos dados tratados no PostgreSQL	Concluída
Data Warehouse	Banco analítico com fato e dimensões	Concluído
Consultas SQL	Análises sobre os dados	Concluída
View Analítica	Consolidação para BI	Concluída
Dashboard	Visualização dos indicadores	Pendente

Até esta etapa, o projeto já possui um fluxo ETL completo, com extração, transformação, carga no PostgreSQL e consultas analíticas SQL.

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
│   │   ├── __init__.py
│   │   └── transform_raw_data.py
│   ├── loading/
│   │   ├── __init__.py
│   │   └── load_processed_data.py
│   ├── database/
│   │   ├── __init__.py
│   │   ├── connection.py
│   │   └── test_connection.py
│   ├── utils/
│   │   └── __init__.py
│   └── __init__.py
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
sql	Scripts SQL estruturais
sql/analytics	Consultas SQL analíticas
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

Essa função retorna uma engine SQLAlchemy, que é reutilizada nas etapas de carga e validação do banco.

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
Etapa	Descrição
Simulação da coleta	Cria uma lista de concursos com dados estruturados
Geração de metadados	Adiciona origem, data/hora e quantidade de registros
Escrita em arquivo	Salva os dados em formato JSON
Armazenamento raw	Grava o arquivo na pasta data/raw

O pipeline foi desenvolvido para representar a camada raw de uma arquitetura de dados.

12.2 Saída Gerada

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
12.3 Arquivo de Amostra para Portfólio

Como os arquivos gerados em data/raw são ignorados pelo Git, foi criada a pasta:

data/sample/

Arquivo de exemplo:

data/sample/concursos_sample.json

Essa prática permite que recrutadores visualizem o formato dos dados sem precisar executar o pipeline imediatamente.

13. Pipeline de Transformação

Nesta etapa foi implementado o pipeline de transformação dos dados brutos extraídos na etapa anterior.

O script responsável é:

src/transformation/transform_raw_data.py

Esse pipeline tem como objetivo ler o arquivo JSON mais recente da pasta data/raw, validar sua estrutura, aplicar padronizações, criar colunas analíticas e salvar os dados tratados em formato CSV na pasta data/processed.

13.1 Objetivo da Transformação

A etapa de transformação converte os dados brutos em uma estrutura mais limpa, consistente e adequada para análise.

Processo	Descrição
Validação	Verificação da existência dos campos obrigatórios
Padronização	Normalização de textos, cargos e bancas
Conversão de tipos	Ajuste de campos numéricos e datas
Enriquecimento	Criação de novas colunas analíticas
Persistência	Salvamento dos dados tratados em CSV
13.2 Funcionamento do Pipeline
Etapa	Descrição
Busca do arquivo bruto	Localiza automaticamente o JSON mais recente em data/raw
Leitura dos dados	Lê o conteúdo da chave data do arquivo JSON
Validação estrutural	Confere se todas as colunas obrigatórias existem
Transformação dos dados	Aplica regras de limpeza, padronização e enriquecimento
Salvamento processado	Gera um arquivo CSV tratado em data/processed

Fluxo executado até esta etapa:

Extração
   ↓
Arquivo JSON em data/raw
   ↓
Transformação com Pandas
   ↓
Arquivo CSV em data/processed
13.3 Transformações Aplicadas
Transformação	Descrição
Padronização textual	Remove espaços extras dos campos de texto
Padronização de cargos	Cria uma categoria analítica para cargos semelhantes
Padronização de bancas	Normaliza variações nos nomes das bancas
Conversão numérica	Converte ano, vagas e salario para tipos adequados
Conversão de datas	Converte datas de inscrição e prova
Criação de faixa salarial	Classifica salários em intervalos analíticos
Cálculo de dias de inscrição	Calcula a duração do período de inscrição
Registro da transformação	Adiciona data e hora da transformação
13.4 Colunas Criadas
Coluna	Descrição
cargo_padronizado	Categoria padronizada do cargo
banca_padronizada	Nome padronizado da banca
salario_faixa	Classificação do salário em faixas
dias_inscricao	Quantidade de dias entre início e fim das inscrições
data_transformacao	Data e hora da execução do pipeline
13.5 Saída Gerada

O pipeline gera arquivos tratados na pasta:

data/processed/

O nome do arquivo segue o padrão:

concursos_processed_YYYY_MM_DD_HH_MM_SS.csv

Arquivo de amostra versionável:

data/sample/concursos_processed_sample.csv
14. Pipeline de Carga

Nesta etapa foi implementado o pipeline de carga dos dados tratados no PostgreSQL.

O script responsável é:

src/loading/load_processed_data.py

Esse pipeline lê o arquivo CSV mais recente da pasta data/processed, insere registros nas tabelas dimensão, recupera os IDs das dimensões e carrega os dados na tabela fato fato_concurso.

14.1 Objetivo da Carga

A etapa de carga representa a fase final do processo ETL.

Ela é responsável por persistir os dados tratados no Data Warehouse, permitindo consultas analíticas e futura integração com ferramentas de BI.

Processo	Descrição
Leitura do CSV tratado	Busca automaticamente o arquivo mais recente em data/processed
Inserção nas dimensões	Popula tabelas dim_banca, dim_estado, dim_cargo e dim_orgao
Busca de chaves	Recupera os IDs das dimensões
Inserção na fato	Popula a tabela fato_concurso
Controle de duplicidade	Evita inserir registros repetidos
14.2 Fluxo de Carga
Arquivo CSV em data/processed
      ↓
Leitura com Pandas
      ↓
Inserção nas dimensões
      ↓
Busca dos IDs dimensionais
      ↓
Inserção na fato_concurso
      ↓
Data Warehouse atualizado
14.3 Dimensões Carregadas
Tabela	Dados Inseridos
dim_banca	Bancas organizadoras padronizadas
dim_estado	Estados e regiões
dim_cargo	Cargos, áreas e níveis
dim_orgao	Órgãos e esferas administrativas
14.4 Tabela Fato Carregada

A tabela fato_concurso recebe os eventos principais do concurso.

Informação	Origem
IDs das dimensões	Consultas nas tabelas dimensão
Ano	CSV tratado
Vagas	CSV tratado
Salário	CSV tratado
Período de inscrição	CSV tratado
Data da prova	CSV tratado
URL do edital	CSV tratado
14.5 Controle Básico de Duplicidade

O pipeline utiliza uma verificação básica antes da inserção na tabela fato.

A combinação considerada para evitar duplicidade é:

Campo
id_banca
id_estado
id_cargo
id_orgao
ano
url_edital

Caso um registro com essa combinação já exista, ele não é inserido novamente.

14.6 Execução da Carga

Executar apenas a carga:

python src/loading/load_processed_data.py

Executar o ETL completo:

python src/extraction/extract_sample_data.py
python src/transformation/transform_raw_data.py
python src/loading/load_processed_data.py

Resultado esperado:

Iniciando carga dos dados no PostgreSQL...
Arquivo tratado encontrado: data/processed/concursos_processed_YYYY_MM_DD_HH_MM_SS.csv
Registros lidos: 6
Dimensões carregadas com sucesso!
Tabela fato carregada com sucesso!
Novos registros inseridos na fato_concurso: 6

Se o processo for executado novamente, a quantidade de novos registros pode ser 0, indicando que a proteção contra duplicidade funcionou.

15. Consultas Analíticas SQL

Após a carga dos dados no Data Warehouse, foram criadas consultas SQL analíticas para responder perguntas de negócio.

As consultas ficam organizadas na pasta:

sql/analytics/
15.1 Objetivo da Camada Analítica

A camada analítica tem como objetivo facilitar a exploração dos dados e preparar a base para construção de dashboards.

Ela permite analisar:

Indicadores gerais.
Concursos por banca.
Concursos por estado.
Concursos por cargo.
Maiores salários.
Evolução anual.
Visão consolidada dos concursos.
15.2 Arquivos Criados
Arquivo	Objetivo
01_kpis_gerais.sql	Indicadores gerais do Data Warehouse
02_analise_por_banca.sql	Análise de concursos por banca organizadora
03_analise_por_estado.sql	Análise de concursos por estado e região
04_analise_por_cargo.sql	Análise de concursos por cargo
05_top_salarios.sql	Lista dos concursos com maiores salários
06_evolucao_por_ano.sql	Evolução anual de concursos, vagas e salários
07_visao_completa_concursos.sql	Consulta completa com todas as dimensões
08_create_view_concursos_analytics.sql	Criação da view analítica consolidada
09_kpis_view_analytics.sql	KPIs usando a view analítica
15.3 KPIs Gerais

A consulta 01_kpis_gerais.sql calcula indicadores gerais como:

Indicador	Descrição
total_concursos	Quantidade de concursos carregados
total_vagas	Soma total de vagas
salario_medio	Média salarial
menor_salario	Menor salário registrado
maior_salario	Maior salário registrado
total_bancas	Quantidade de bancas distintas
total_estados	Quantidade de estados distintos
total_cargos	Quantidade de cargos distintos
total_orgaos	Quantidade de órgãos distintos
15.4 Análises por Dimensão

Foram criadas consultas específicas para análise por dimensão.

Dimensão	Consulta	Perguntas Respondidas
Banca	02_analise_por_banca.sql	Quais bancas mais aparecem? Quais possuem maior salário médio?
Estado	03_analise_por_estado.sql	Quais estados têm mais vagas e maiores salários?
Cargo	04_analise_por_cargo.sql	Quais cargos pagam melhor? Quais têm mais vagas?
Ano	06_evolucao_por_ano.sql	Como concursos, vagas e salários evoluem ao longo do tempo?
15.5 Top Salários

A consulta 05_top_salarios.sql lista os concursos com maiores salários.

Ela retorna informações como:

Campo	Descrição
Órgão	Instituição responsável
Cargo	Cargo ofertado
Área	Área de atuação
Nível	Nível exigido
Banca	Banca organizadora
Estado	Unidade federativa
Região	Região brasileira
Ano	Ano do concurso
Vagas	Quantidade de vagas
Salário	Salário inicial
Data da prova	Data prevista
URL do edital	Link de referência

Essa consulta é útil para dashboards e análises exploratórias.

15.6 View Analítica

Foi criada a view:

vw_concursos_analytics

Essa view consolida os dados da tabela fato com todas as dimensões.

Ela foi definida no arquivo:

sql/analytics/08_create_view_concursos_analytics.sql
15.7 Finalidade da View

A view vw_concursos_analytics facilita o consumo dos dados por ferramentas de BI.

Benefício	Descrição
Simplificação	Evita repetir joins em todas as consultas
Reutilização	Pode ser usada em dashboards e análises
Organização	Centraliza a visão analítica dos concursos
Integração	Facilita conexão com Power BI, Metabase ou Superset

Exemplo de consulta usando a view:

SELECT
    COUNT(*) AS total_concursos,
    SUM(vagas) AS total_vagas,
    ROUND(AVG(salario), 2) AS salario_medio
FROM vw_concursos_analytics;
15.8 Execução das Consultas

Exemplo usando Docker:

docker exec -i concursos_postgres psql -U concursos_user -d concursos_dw < sql/analytics/01_kpis_gerais.sql

Exemplo no PowerShell:

Get-Content sql/analytics/01_kpis_gerais.sql | docker exec -i concursos_postgres psql -U concursos_user -d concursos_dw

Criar a view analítica:

docker exec -i concursos_postgres psql -U concursos_user -d concursos_dw < sql/analytics/08_create_view_concursos_analytics.sql

Testar a view:

SELECT * FROM vw_concursos_analytics LIMIT 10;
16. Dependências Python

As dependências iniciais do projeto foram registradas no arquivo requirements.txt.

pandas
requests
beautifulsoup4
python-dotenv
sqlalchemy
psycopg2-binary
jupyter
16.1 Finalidade das Dependências
Biblioteca	Finalidade
pandas	Tratamento e manipulação de dados
requests	Requisições HTTP
beautifulsoup4	Extração de dados de páginas HTML
python-dotenv	Leitura de variáveis de ambiente
sqlalchemy	Conexão e interação com banco de dados
psycopg2-binary	Driver PostgreSQL
jupyter	Análises exploratórias
17. Etapas Concluídas
Etapa	Status
Criação da estrutura inicial do projeto	Concluído
Criação das pastas principais	Concluído
Configuração do Docker Compose	Concluído
Configuração do PostgreSQL	Concluído
Configuração do pgAdmin	Concluído
Criação do arquivo .env.example	Concluído
Criação do arquivo .gitignore	Concluído
Criação do arquivo requirements.txt	Concluído
Criação dos scripts SQL estruturais	Concluído
Criação das tabelas dimensionais	Concluído
Criação da tabela fato	Concluído
Inserção de dados simulados no banco	Concluído
Criação da conexão Python com PostgreSQL	Concluído
Criação do script de teste de conexão	Concluído
Criação do pipeline de extração	Concluído
Geração de dados brutos em JSON	Concluído
Criação de amostra em data/sample	Concluído
Criação do pipeline de transformação	Concluído
Validação de colunas obrigatórias	Concluído
Padronização de cargos e bancas	Concluído
Conversão de tipos e datas	Concluído
Criação de variáveis analíticas	Concluído
Geração de dados tratados em CSV	Concluído
Criação de amostra tratada em data/sample	Concluído
Criação do pipeline de carga	Concluído
Carga nas tabelas dimensão	Concluído
Carga na tabela fato	Concluído
Controle básico de duplicidade	Concluído
Criação das consultas analíticas SQL	Concluído
Criação da view vw_concursos_analytics	Concluído
Criação do README da pasta sql/analytics	Concluído
Atualização do README principal	Concluído
Atualização do relatório técnico	Concluído
18. Comandos Utilizados
18.1 Docker

Subir os containers:

docker compose up -d

Verificar containers:

docker ps

Acessar PostgreSQL via terminal:

docker exec -it concursos_postgres psql -U concursos_user -d concursos_dw
18.2 PostgreSQL

Listar tabelas:

\dt

Consultar tabela fato:

SELECT * FROM fato_concurso;

Contar registros nas tabelas:

SELECT COUNT(*) FROM dim_banca;
SELECT COUNT(*) FROM dim_estado;
SELECT COUNT(*) FROM dim_cargo;
SELECT COUNT(*) FROM dim_orgao;
SELECT COUNT(*) FROM fato_concurso;

Testar view analítica:

SELECT * FROM vw_concursos_analytics LIMIT 10;

Sair do PostgreSQL:

\q
18.3 Python

Criar ambiente virtual:

python -m venv .venv

Ativar ambiente virtual no Git Bash:

source .venv/Scripts/activate

Ativar ambiente virtual no PowerShell:

.venv\Scripts\Activate.ps1

Instalar dependências:

pip install -r requirements.txt

Testar conexão Python:

python src/database/test_connection.py

Executar pipeline de extração:

python src/extraction/extract_sample_data.py

Executar pipeline de transformação:

python src/transformation/transform_raw_data.py

Executar pipeline de carga:

python src/loading/load_processed_data.py

Executar ETL completo:

python src/extraction/extract_sample_data.py
python src/transformation/transform_raw_data.py
python src/loading/load_processed_data.py
18.4 Consultas Analíticas

Executar KPIs gerais:

docker exec -i concursos_postgres psql -U concursos_user -d concursos_dw < sql/analytics/01_kpis_gerais.sql

Executar análise por banca:

docker exec -i concursos_postgres psql -U concursos_user -d concursos_dw < sql/analytics/02_analise_por_banca.sql

Executar análise por estado:

docker exec -i concursos_postgres psql -U concursos_user -d concursos_dw < sql/analytics/03_analise_por_estado.sql

Executar top salários:

docker exec -i concursos_postgres psql -U concursos_user -d concursos_dw < sql/analytics/05_top_salarios.sql

Criar view analítica:

docker exec -i concursos_postgres psql -U concursos_user -d concursos_dw < sql/analytics/08_create_view_concursos_analytics.sql

Executar KPIs usando a view:

docker exec -i concursos_postgres psql -U concursos_user -d concursos_dw < sql/analytics/09_kpis_view_analytics.sql
19. Próximas Etapas

As próximas etapas do projeto serão:

Próxima Etapa	Descrição
Dashboard	Criar visualizações com os principais indicadores
Imagens do dashboard	Salvar evidências na pasta dashboards
Consultas adicionais	Criar análises por região, esfera e nível
Coleta real	Expandir para fontes públicas reais
Automação	Futuramente orquestrar o pipeline
Relatório final	Documentar o projeto completo
README final	Melhorar apresentação para portfólio
20. Considerações Parciais

Até esta etapa, o projeto já possui uma base sólida e funcional de Engenharia de Dados.

A estrutura criada permite organizar o fluxo completo, desde a entrada dos dados brutos até a análise em SQL.

A utilização de Docker facilita a reprodução do ambiente, enquanto o PostgreSQL permite armazenar os dados em um modelo analítico estruturado.

Com a criação do pipeline de extração, o projeto passou a executar uma etapa prática do fluxo de dados. Os dados brutos são gerados em JSON, armazenados na camada raw e documentados com metadados de extração.

Com a criação do pipeline de transformação, os dados brutos passaram a ser lidos, validados, padronizados e enriquecidos, gerando uma versão tratada em CSV.

Com a criação do pipeline de carga, o projeto completou o fluxo ETL, carregando os dados tratados no PostgreSQL, populando tabelas dimensão e tabela fato.

Com a criação das consultas analíticas SQL e da view vw_concursos_analytics, o Data Warehouse passou a responder perguntas de negócio e ficou preparado para integração com ferramentas de BI.

Esse projeto demonstra competências importantes para portfólio, como:

Organização de repositório.
Documentação técnica.
Banco de dados relacional.
SQL.
Docker.
Python.
Pandas.
SQLAlchemy.
Integração com PostgreSQL.
Modelagem dimensional.
Pipeline de extração.
Pipeline de transformação.
Pipeline de carga.
ETL completo.
Criação de consultas analíticas.
Criação de view para BI.
Boas práticas de Engenharia de Dados.