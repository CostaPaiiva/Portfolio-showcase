# Agro Data Intelligence Brasil

Plataforma de Engenharia de Dados end-to-end para consolidação e análise de dados públicos do agronegócio brasileiro. O projeto implementa uma arquitetura moderna de **Lakehouse** (camadas Bronze, Silver e Gold), orquestração de pipelines e dashboards analíticos.

## 🎯 Problema de Negócio
Dados do agronegócio (IBGE, INMET, CONAB) são fragmentados. O objetivo desta plataforma é integrar a produção agrícola municipal e dados climáticos para responder a perguntas como:
- *Qual a evolução da produtividade de soja no MT nos últimos 10 anos?*
- *Como a precipitação afeta a produção em municípios específicos?*

## 🏗️ Arquitetura da Solução

```text
[ APIs Públicas (SIDRA/IBGE) ]
             │
             ▼
       [ Airflow ] (Orquestração)
             │
             ▼
    [ MinIO (S3) / Bronze ] (JSON Bruto Imutável)
             │
             ▼
     [ PySpark / Silver ] (Parquet Limpo e Tipado)
             │
             ▼
       [ dbt / Gold ] (Modelagem Star Schema)
             │
             ▼
     [ PostgreSQL ] (Serving Layer)
             │
      ┌──────┴──────┐
      ▼             ▼
 [ Superset ]   [ Power BI ]
```

## 🛠️ Stack Tecnológico
- **Ingestão:** Python (`requests`, `boto3`)
- **Orquestração:** Apache Airflow (`LocalExecutor`)
- **Armazenamento:** MinIO (Object Storage S3-compatível)
- **Processamento:** Apache Spark / PySpark
- **Transformação/Modelagem:** dbt (Data Build Tool)
- **Banco Analítico (Serving):** PostgreSQL
- **Visualização:** Apache Superset
- **Infraestrutura:** Docker / Docker Compose, Linux VPS, Tailscale (VPN)

## 📂 Estrutura do Repositório
- `dags/`: Definição dos pipelines no Airflow.
- `src/`: Scripts de ingestão e processamento (Python/Spark).
- `dbt_agro/`: Modelos SQL, testes e documentação do dbt.
- `docker/`: Scripts de inicialização do banco.
- `docker-compose.yml`: Definição da infraestrutura local.

## 🚀 Como Executar Localmente
1. Clone o repositório.
2. Crie um arquivo `.env` com as credenciais (veja `.env.example`).
3. Suba a infraestrutura: `docker compose up -d --build`
4. Acesse o Airflow (`localhost:18080`) e dispare a DAG `pipeline_agro_completo`.
5. Acesse o Superset (`localhost:8088`) para visualizar os dashboards.

## 💡 Decisões Arquiteturais (ADRs)
- **Por que MinIO?** Simula o AWS S3 localmente, permitindo o desenvolvimento de uma arquitetura de Data Lake sem custos de nuvem.
- **Por que Spark para o Silver?** Embora o volume atual não exija processamento distribuído, a camada foi desenhada para escalar para dados climáticos (INMET diário) e ser portável para Databricks no futuro.
- **Por que dbt para a camada Gold?** Separa a lógica de modelagem dimensional (SQL) do processamento pesado (Spark), trazendo governança, testes e lineage.
- **Por que não usar Kafka/Streaming?** As fontes são inerentemente batch (anual/mensal). Adicionar streaming seria over-engineering para o problema.
