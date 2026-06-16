# Plataforma de Inteligência para Concursos Públicos

<div align="justify">
Projeto de Engenharia de Dados desenvolvido para coletar, tratar, armazenar e analisar dados de concursos públicos, com foco em cargos de Tecnologia da Informação, Ciência de Dados, Engenharia de Dados e áreas correlatas.

A proposta é simular uma solução real de dados, passando por etapas como extração, tratamento, modelagem dimensional, carga em Data Warehouse e futura construção de dashboards analíticos.
</div>

## Sumário
- [Objetivo](#objetivo)
- [Problema de Negócio](#problema-de-negócio)
- [Arquitetura do Projeto](#arquitetura-do-projeto)
- [Tecnologias Utilizadas](#tecnologias-utilizadas)
- [Estrutura de Pastas](#estrutura-de-pastas)
- [Modelo de Dados](#modelo-de-dados)
- [Como Executar o Projeto](#como-executar-o-projeto)
- [Testes Realizados](#testes-realizados)
- [Status do Projeto](#status-do-projeto)
- [Próximas Etapas](#próximas-etapas)
- [Autor](#autor)

## Objetivo

<div align="justify">
Construir uma plataforma analítica capaz de responder perguntas como:

- Quais bancas mais organizam concursos de TI?
- Quais estados possuem os melhores salários?
- Quais cargos aparecem com maior frequência?
- Qual é a evolução salarial dos concursos públicos de tecnologia?
- Quais órgãos mais ofertam vagas na área de TI?
- Como os concursos se distribuem por estado, banca, órgão e área?
</div>

## Problema de Negócio

<div align="justify">
As informações sobre concursos públicos estão espalhadas em diferentes fontes, como sites de bancas, portais institucionais, páginas de notícias e editais em PDF.

Isso dificulta análises consolidadas, como comparar salários, identificar bancas mais frequentes, acompanhar oportunidades por estado e entender tendências da área pública para profissionais de tecnologia.

Este projeto propõe centralizar esses dados em um Data Warehouse, permitindo consultas analíticas e visualização de indicadores.
</div>

## Arquitetura do Projeto

```text
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
```

### Arquitetura atual

Até o momento, o projeto já possui:

| Camada | Status | Descrição |
|---|---|---|
| Estrutura de pastas | Concluída | Organização inicial do projeto |
| Banco PostgreSQL | Concluído | Banco local executando via Docker |
| pgAdmin | Concluído | Interface gráfica para administração |
| Modelo dimensional | Concluído | Tabelas dimensão e tabela fato |
| Dados de teste | Concluído | Dados simulados para validação |
| Conexão Python | Concluída | SQLAlchemy conectado ao PostgreSQL |
| Extração de dados | Pendente | Próxima etapa |
| Transformação ETL | Pendente | Próximas etapas |
| Dashboard | Pendente | Etapa futura |

## Tecnologias Utilizadas

| Tecnologia | Finalidade |
|---|---|
| Python | Desenvolvimento dos pipelines de dados |
| PostgreSQL | Banco de dados analítico |
| Docker | Criação do ambiente local |
| Docker Compose | Orquestração dos containers |
| SQL | Modelagem, consultas e manipulação de dados |
| Pandas | Tratamento e análise de dados |
| SQLAlchemy | Conexão Python com PostgreSQL |
| psycopg2 | Driver PostgreSQL para Python |
| python-dotenv | Leitura de variáveis de ambiente |
| pgAdmin | Administração visual do banco |
| Git e GitHub | Versionamento e portfólio |

## Estrutura de Pastas

```text
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
```

### Descrição das principais pastas

| Pasta | Descrição |
|---|---|
| data/raw | Dados brutos coletados das fontes |
| data/processed | Dados tratados e padronizados |
| data/warehouse | Dados finais preparados para análise |
| docs | Documentação técnica do projeto |
| notebooks | Análises exploratórias |
| src/extraction | Scripts de extração |
| src/transformation | Scripts de transformação |
| src/loading | Scripts de carga no banco |
| src/database | Conexão com PostgreSQL |
| sql | Scripts SQL do banco |
| dashboards | Arquivos e imagens de dashboards |

## Modelo de Dados

<div align="justify">
O projeto utiliza modelagem dimensional em formato de esquema estrela.
</div>

### Tabela fato

| Tabela | Descrição |
|---|---|
| fato_concurso | Armazena os eventos principais dos concursos |

### Tabelas dimensão

| Tabela | Descrição |
|---|---|
| dim_banca | Informações das bancas organizadoras |
| dim_estado | Informações dos estados |
| dim_cargo | Informações dos cargos |
| dim_orgao | Informações dos órgãos públicos |

### Visão simplificada do modelo

```text
dim_banca   dim_estado   dim_cargo   dim_orgao
     \          |           |           /
      \         |           |          /
              fato_concurso
```

### Campos principais da tabela fato

| Campo | Descrição |
|---|---|
| id_concurso | Identificador do concurso |
| id_banca | Chave da banca organizadora |
| id_estado | Chave do estado |
| id_cargo | Chave do cargo |
| id_orgao | Chave do órgão |
| ano | Ano do concurso |
| vagas | Quantidade de vagas |
| salario | Salário inicial |
| inscricao_inicio | Data inicial de inscrição |
| inscricao_fim | Data final de inscrição |
| data_prova | Data da prova |
| url_edital | Link do edital |
| data_carga | Data de carregamento no banco |

## Como Executar o Projeto

### 1. Clonar o repositório

```bash
git clone URL_DO_REPOSITORIO
cd plataforma-inteligencia-concursos
```

### 2. Criar o arquivo .env

<div align="justify">
Copie o arquivo .env.example:
</div>

```bash
cp .env.example .env
```

<div align="justify">
No Windows CMD:
</div>

```cmd
copy .env.example .env
```

<div align="justify">
Conteúdo esperado:
</div>

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=concursos_dw
DB_USER=concursos_user
DB_PASSWORD=concursos_pass
```

### 3. Subir os containers

```bash
docker compose up -d
```

### 4. Verificar containers

```bash
docker ps
```

<div align="justify">
Resultado esperado:
</div>

```text
concursos_postgres
concursos_pgadmin
```

### 5. Acessar o pgAdmin

<div align="justify">
Acesse no navegador: http://localhost:8080
</div>

**Credenciais:**

| Campo | Valor |
|---|---|
| Email | admin@concursos.com |
| Senha | admin123 |

**Configuração do servidor no pgAdmin:**

| Campo | Valor |
|---|---|
| Host | postgres |
| Porta | 5432 |
| Database | concursos_dw |
| User | concursos_user |
| Password | concursos_pass |

<div align="justify">
Dentro do pgAdmin, o host correto é postgres, pois o pgAdmin e o PostgreSQL estão na mesma rede Docker.
</div>

## Pipeline de Extração

O pipeline de extração foi implementado no arquivo:

```text
src/extraction/extract_sample_data.py

Nesta etapa, são gerados dados simulados de concursos públicos em formato JSON.

O script executa as seguintes ações:

Simula a coleta de dados de concursos.
Adiciona metadados da extração.
Salva os dados brutos na pasta data/raw.
Gera um arquivo JSON com data e hora da execução.

Exemplo de execução:

python src/extraction/extract_sample_data.py

Exemplo de saída:

Iniciando extração de dados simulados...
Extração concluída com sucesso!
Registros extraídos: 6
Arquivo gerado: data/raw/concursos_raw_YYYY_MM_DD_HH_MM_SS.json

Os arquivos gerados em data/raw não são versionados no GitHub, pois representam dados brutos de execução.

Para fins de demonstração no portfólio, foi criada a pasta:

data/sample/

Essa pasta contém um pequeno exemplo do formato dos dados extraídos.


Atenção: quando colar no README, cuidado com os blocos de código dentro de blocos de código. Se o GitHub quebrar a visualização, me mande que eu ajusto.

---

# 7. Atualizar o relatório

No arquivo:

```text
docs/relatorio.md
```
## Testes Realizados

### Testar banco pelo terminal

```bash
docker exec -it concursos_postgres psql -U concursos_user -d concursos_dw
```

**Listar tabelas:**

```sql
\dt
```

**Consultar dados de teste:**

```sql
SELECT * FROM fato_concurso;
```

**Sair:**

```sql
\q
```

### Criar ambiente virtual Python

```bash
python -m venv .venv
```

<div align="justify">
Ativar no Git Bash:
</div>

```bash
source .venv/Scripts/activate
```

<div align="justify">
Ativar no PowerShell:
</div>

```powershell
.venv\Scripts\Activate.ps1
```

<div align="justify">
Instalar dependências:
</div>

```bash
pip install -r requirements.txt
```

### Testar conexão Python com PostgreSQL

<div align="justify">
Entre na pasta:
</div>

```bash
cd src/database
```

<div align="justify">
Execute:
</div>

```bash
python test_connection.py
```

<div align="justify">
Resultado esperado:
</div>

```text
Conexão realizada com sucesso!
Tabelas encontradas no banco:
- dim_banca
- dim_cargo
- dim_estado
- dim_orgao
- fato_concurso
```

## Status do Projeto

| Etapa | Status |
|---|---|
| Estrutura inicial criada | Concluído |
| Ambiente Docker configurado | Concluído |
| Banco PostgreSQL criado | Concluído |
| pgAdmin configurado | Concluído |
| Modelo dimensional criado | Concluído |
| Dados de teste inseridos | Concluído |
| Conexão Python com PostgreSQL | Concluído |
| Script de teste de conexão | Concluído |
| Pipeline de extração | Concluído |
| Geração de dados brutos em JSON | Concluído |
| Pipeline de transformação | Concluído |
| Geração de dados tratados em CSV | Concluído |
| Pipeline de carga | Concluído |
| Carga nas dimensões | Concluído |
| Carga na tabela fato | Concluído |
| Consultas analíticas SQL | Pendente |
| Dashboard | Pendente |
| Relatório final | Em andamento |

## Pipeline de Extração

Nesta etapa foi criado o primeiro pipeline de extração do projeto.

O script responsável é:

```text
src/extraction/extract_sample_data.py

A função desse script é simular a coleta de dados de concursos públicos, representando a primeira camada do fluxo de Engenharia de Dados.

Em um cenário real, essa etapa poderia coletar informações de:

APIs públicas.
Sites de bancas organizadoras.
Páginas institucionais.
Editais em PDF.
Portais agregadores de concursos.
Dados extraídos

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
Saída gerada

O pipeline gera arquivos JSON na pasta:

data/raw/

O nome do arquivo segue o padrão:

concursos_raw_YYYY_MM_DD_HH_MM_SS.json

Cada arquivo gerado contém metadados da extração, como:

Metadado	Descrição
source	Origem dos dados
extraction_datetime	Data e hora da extração
records_count	Quantidade de registros extraídos
data	Lista de concursos extraídos
Importância da etapa

A etapa de extração representa o início do pipeline de dados.

Ela garante que os dados sejam capturados e armazenados em sua forma bruta antes de qualquer transformação.

Essa prática é comum em arquiteturas de dados, pois permite rastreabilidade, auditoria e reprocessamento dos dados caso necessário.


Também atualize a seção **Etapas Concluídas** adicionando:

```md
| Criação do pipeline de extração | Concluído |
| Geração de dados brutos em JSON | Concluído |
| Criação de amostra em `data/sample` | Concluído |
```
## Pipeline de Transformação

O pipeline de transformação foi implementado no arquivo:

```text
src/transformation/transform_raw_data.py

Nesta etapa, o script lê o arquivo JSON mais recente da pasta data/raw, aplica padronizações e salva os dados tratados em data/processed.

Transformações realizadas
Transformação	Descrição
Leitura do JSON bruto	Busca automaticamente o arquivo mais recente em data/raw
Validação de colunas	Verifica se todos os campos obrigatórios existem
Padronização textual	Remove espaços extras e normaliza campos
Padronização de cargos	Cria a coluna cargo_padronizado
Padronização de bancas	Cria a coluna banca_padronizada
Conversão de tipos	Converte ano, vagas, salário e datas
Faixa salarial	Cria a coluna salario_faixa
Cálculo de dias	Cria a coluna dias_inscricao
Registro de transformação	Cria a coluna data_transformacao
Executar transformação
python src/transformation/transform_raw_data.py
Saída esperada
Transformação concluída com sucesso!
Registros transformados: 6
Arquivo tratado gerado: data/processed/concursos_processed_YYYY_MM_DD_HH_MM_SS.csv

Para demonstração no GitHub, foi criado o arquivo:

data/sample/concursos_processed_sample.csv

Atenção: ao colar no README, se o bloco de código quebrar por causa dos blocos internos, me mande que eu ajusto o README completo depois.

---

# 8. Atualizar o relatório

Depois vamos atualizar o relatório completo, mas já deixe anotado que entrou uma nova etapa:

```md
## Pipeline de Transformação

Nesta etapa foi implementado o pipeline de transformação dos dados brutos.

O script responsável é:

```text
src/transformation/transform_raw_data.py

Esse pipeline lê o arquivo JSON mais recente da pasta data/raw, valida sua estrutura, aplica padronizações e salva os dados tratados em formato CSV na pasta data/processed.

Transformações aplicadas
Transformação	Descrição
Validação de colunas obrigatórias	Garante que os campos esperados estejam presentes
Padronização textual	Remove espaços extras e normaliza campos de texto
Padronização de cargos	Agrupa nomes semelhantes em categorias analíticas
Padronização de bancas	Corrige variações de nomes das bancas
Conversão de tipos	Converte campos numéricos e datas
Classificação salarial	Cria faixas salariais
Cálculo de período de inscrição	Calcula os dias entre início e fim das inscrições
Registro da transformação	Adiciona data e hora da transformação
Saída gerada

O arquivo tratado é salvo em:

data/processed/

Com o padrão de nome:

concursos_processed_YYYY_MM_DD_HH_MM_SS.csv

Essa etapa representa a camada de dados processados do projeto, preparando as informações para carga no Data Warehouse.


---

# 9. Rodar tudo em sequência

Agora você pode rodar o fluxo completo até aqui:

```bash
python src/extraction/extract_sample_data.py
python src/transformation/transform_raw_data.py

Depois confira:

ls data/raw
ls data/processed

No Windows CMD:

dir data\raw
dir data\processed
```
## Pipeline de Carga

O pipeline de carga foi implementado no arquivo:

```text
src/loading/load_processed_data.py

Nesta etapa, o script lê o arquivo CSV mais recente da pasta data/processed e carrega as informações no PostgreSQL.

Processo de carga
Etapa	Descrição
Leitura do CSV tratado	Busca automaticamente o arquivo mais recente em data/processed
Inserção de dimensões	Popula dim_banca, dim_estado, dim_cargo e dim_orgao
Busca de chaves	Recupera os IDs das dimensões
Inserção na fato	Popula a tabela fato_concurso
Controle básico de duplicidade	Evita inserir registros repetidos com mesma banca, estado, cargo, órgão, ano e edital
Executar carga
python src/loading/load_processed_data.py
Executar ETL completo
python src/extraction/extract_sample_data.py
python src/transformation/transform_raw_data.py
python src/loading/load_processed_data.py

---

# 7. Atualizar o relatório depois

Depois vamos atualizar o `relatorio.md` completo com a mesma formatação bonita, incluindo a nova seção:

```text
Pipeline de Carga

## Próximas Etapas

As próximas etapas do projeto serão:

- Criar processo de transformação e padronização dos dados.
- Ler os arquivos brutos da pasta `data/raw`.
- Gerar dados tratados na pasta `data/processed`.
- Criar processo de carga automatizada no PostgreSQL.
- Criar consultas analíticas.
- Criar dashboard com indicadores.
- Expandir o projeto para coleta de dados reais.
- Finalizar relatório técnico.

## Diferenciais do Projeto

<div align="justify">
Este projeto demonstra conhecimentos práticos em:

- Engenharia de Dados.
- Organização de projeto profissional.
- Docker e ambientes reprodutíveis.
- Banco de dados PostgreSQL.
- Modelagem dimensional.
- SQL.
- Python aplicado a dados.
- ETL.
- Documentação técnica.
- Versionamento com Git e GitHub.
</div>

## Autor

<div align="justify">
Projeto desenvolvido como parte de um portfólio profissional de Engenharia de Dados.

Área de foco: Engenharia de Dados, Ciência de Dados, Análise de Dados e Inteligência Artificial.
</div>
