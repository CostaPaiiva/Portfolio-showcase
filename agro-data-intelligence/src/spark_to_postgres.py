import os
from pyspark.sql import SparkSession
from dotenv import load_dotenv

# Carrega variáveis de ambiente do arquivo .env (senhas do MinIO e PostgreSQL)
load_dotenv()

# ==============================================================================
# 1. Configuração da Sessão PySpark com drivers S3A (MinIO) e JDBC (PostgreSQL)
# ==============================================================================
# - hadoop-aws / aws-java-sdk-bundle: Conexão e leitura dos Parquets no MinIO.
# - org.postgresql:postgresql:42.6.0: Driver JDBC para escrita direta no Postgres.
# - Overrides numéricos de timeout para evitar NumberFormatException no Hadoop 3.5+.
spark = SparkSession.builder \
    .appName("SparkToPostgres") \
    .config("spark.jars.packages", "org.apache.hadoop:hadoop-aws:3.3.4,com.amazonaws:aws-java-sdk-bundle:1.12.262,org.postgresql:postgresql:42.6.0") \
    .config("spark.hadoop.fs.s3a.endpoint", "http://127.0.0.1:9000") \
    .config("spark.hadoop.fs.s3a.access.key", os.getenv('MINIO_ROOT_USER')) \
    .config("spark.hadoop.fs.s3a.secret.key", os.getenv('MINIO_ROOT_PASSWORD')) \
    .config("spark.hadoop.fs.s3a.path.style.access", "true") \
    .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
    .config("spark.hadoop.fs.s3a.aws.credentials.provider", "org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider") \
    .config("spark.hadoop.fs.s3a.connection.establish.timeout", "30000") \
    .config("spark.hadoop.fs.s3a.connection.timeout", "60000") \
    .config("spark.hadoop.fs.s3a.threads.keepalivetime", "60000") \
    .config("spark.hadoop.fs.s3a.connection.ttl", "300000") \
    .config("spark.hadoop.fs.s3a.assumed.role.session.duration", "1800") \
    .config("spark.hadoop.fs.s3a.multipart.purge.age", "86400") \
    .getOrCreate()

# Reduz logs do Spark para WARN para manter a saída limpa
spark.sparkContext.setLogLevel("WARN")

def run_silver_to_postgres():
    """
    Função para carregar os dados da camada Silver (Parquet no MinIO)
    para o Data Warehouse relacional (PostgreSQL via JDBC).
    """
    print("Lendo Parquet da Silver no MinIO...")
    # Lê os dados limpos e tipados gerados pelo pipeline anterior
    df_silver = spark.read.parquet("s3a://agro-lake/silver/sidra/pam/ano=2022/")

    print("Enviando para o Postgres (tabela silver_producao)...")
    # JDBC URL conectando ao PostgreSQL local na porta 15432
    jdbc_url = "jdbc:postgresql://127.0.0.1:15432/agro"
    properties = {
        "user": os.getenv('POSTGRES_USER', 'agro_admin'),
        "password": os.getenv('POSTGRES_PASSWORD'),
        "driver": "org.postgresql.Driver"
    }

    # Salva no banco de dados sobrescrevendo a tabela se já existir (idempotência)
    df_silver.write.jdbc(
        url=jdbc_url,
        table="silver_producao",
        mode="overwrite",
        properties=properties
    )

    print("Dados carregados no Postgres com sucesso na tabela 'silver_producao'!")

if __name__ == "__main__":
    try:
        run_silver_to_postgres()
    finally:
        # Libera recursos e memória da sessão Spark
        spark.stop()
