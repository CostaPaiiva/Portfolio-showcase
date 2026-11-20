"""
==============================================================================
DAG AIRFLOW: pipeline_agro_completo
==============================================================================
Descrição: Orquestra o ciclo completo de engenharia de dados do agro:
  1. Ingestão dos dados da API SIDRA/IBGE -> MinIO S3 (Camada Bronze)
  2. Limpeza, tipagem e conversão para Parquet via PySpark -> MinIO S3 (Camada Silver)
  3. Carga dos dados tratados no PostgreSQL via PySpark JDBC (Staging para o DW)
  4. Transformação analítica e modelagem dimensional em Star Schema via dbt (Camada Gold)
==============================================================================
"""

from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator

# ==============================================================================
# CONFIGURAÇÃO DE ARGUMENTOS PADRÃO (default_args)
# ==============================================================================
# Define regras de tolerância a falhas e políticas de repetição para todas as tasks
default_args = {
    'owner': 'agro_data',                  # Proprietário da pipeline para identificação na UI
    'retries': 2,                          # Em caso de falha em qualquer task, tenta executar mais 2 vezes
    'retry_delay': timedelta(minutes=5),   # Intervalo de 5 minutos entre cada tentativa de repetição
}

# ==============================================================================
# DEFINIÇÃO DA DAG
# ==============================================================================
with DAG(
    dag_id='pipeline_agro_completo',       # Identificador único da DAG na interface do Airflow
    default_args=default_args,             # Aplica os argumentos de tolerância definidos acima
    description='Pipeline end-to-end: SIDRA -> MinIO -> PySpark -> Postgres -> dbt',
    start_date=datetime(2026, 1, 1),       # Data de início do agendamento (marco zero)
    schedule_interval='@monthly',          # Frequência de execução: executa automaticamente todo mês
    catchup=False,                         # False evita executar retrospectivamente execuções passadas
    tags=['agro', 'pyspark', 'dbt', 'minio', 'sidra'] # Tags para filtragem rápida na interface web
) as dag:

    # --------------------------------------------------------------------------
    # TASK 1: Ingestão de Dados Brutos (Raw / Bronze)
    # --------------------------------------------------------------------------
    # Executa o script python que consome a API do IBGE/SIDRA e grava o JSON
    # bruto diretamente no bucket 'agro-lake' do MinIO com partição temporal.
    task_ingest = BashOperator(
        task_id='ingest_sidra',
        bash_command='cd /opt/airflow && python src/ingest_sidra.py',
    )

    # --------------------------------------------------------------------------
    # TASK 2: Processamento e Limpeza com PySpark (Silver)
    # --------------------------------------------------------------------------
    # Lê os JSONs brutos do MinIO via driver S3A, remove cabeçalhos governamentais,
    # trata tipos de dados (strings numéricas para double) e salva em formato colunar Parquet.
    task_silver = BashOperator(
        task_id='spark_bronze_to_silver',
        bash_command='cd /opt/airflow && python src/bronze_to_silver.py',
    )

    # --------------------------------------------------------------------------
    # TASK 3: Carga da Camada Silver no PostgreSQL (Data Warehouse)
    # --------------------------------------------------------------------------
    # Lê os arquivos Parquet da camada Silver no MinIO e grava na tabela relacional
    # 'silver_producao' no PostgreSQL utilizando escrita paralela via JDBC do Spark.
    task_load_postgres = BashOperator(
        task_id='spark_to_postgres',
        bash_command='cd /opt/airflow && python src/spark_to_postgres.py',
    )

    # --------------------------------------------------------------------------
    # TASK 4: Modelagem Dimensional Star Schema com dbt (Gold)
    # --------------------------------------------------------------------------
    # Executa as transformações SQL do dbt, gerando as dimensões (dim_estado, dim_cultura)
    # e a tabela fato analítica (fato_producao) no schema 'gold' para consumo pelo Superset/Power BI.
    # O parâmetro '--profiles-dir .' garante que o dbt encontre o profiles.yml na mesma pasta.
    task_dbt_gold = BashOperator(
        task_id='dbt_build_gold',
        bash_command='cd /opt/airflow/dbt_agro && dbt run --profiles-dir .',
    )

    # ==========================================================================
    # DEFINIÇÃO DO FLUXO DE DEPENDÊNCIA (LINHAGEM DAS TAREFAS)
    # ==========================================================================
    # O operador '>>' define a ordem estrita de execução:
    # A task seguinte só inicia se a anterior for concluída com sucesso.
    task_ingest >> task_silver >> task_load_postgres >> task_dbt_gold
