import os
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, regexp_replace
from dotenv import load_dotenv

# Carrega variáveis de ambiente do arquivo .env (usuário e senha do MinIO)
load_dotenv()

# ==============================================================================
# 1. Configuração da Sessão PySpark com conector S3A para comunicação com o MinIO
# ==============================================================================
# Definimos valores inteiros puros para todas as propriedades de pool/threads do S3A
# para prevenir o erro do Hadoop: NumberFormatException: For input string: "60s"
spark = SparkSession.builder \
    .appName("AgroBronzeToSilver") \
    .config("spark.jars.packages", "org.apache.hadoop:hadoop-aws:3.3.4,com.amazonaws:aws-java-sdk-bundle:1.12.262") \
    .config("spark.hadoop.fs.s3a.endpoint", "http://127.0.0.1:9000") \
    .config("spark.hadoop.fs.s3a.access.key", os.getenv('MINIO_ROOT_USER')) \
    .config("spark.hadoop.fs.s3a.secret.key", os.getenv('MINIO_ROOT_PASSWORD')) \
    .config("spark.hadoop.fs.s3a.path.style.access", "true") \
    .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
    .config("spark.hadoop.fs.s3a.aws.credentials.provider", "org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider") \
    .config("spark.hadoop.fs.s3a.connection.ssl.enabled", "false") \
    .config("spark.hadoop.fs.s3a.connection.timeout", "60000") \
    .config("spark.hadoop.fs.s3a.threads.keepalivetime", "60") \
    .config("spark.hadoop.fs.s3a.threads.max", "10") \
    .getOrCreate()

# Reduz a verbosidade dos logs do Spark para WARN, mantendo o terminal limpo
spark.sparkContext.setLogLevel("WARN")

def process_bronze_to_silver():
    """
    Função principal da pipeline de transformação:
    1. Leitura: Consome os dados brutos em JSON da camada Bronze no MinIO.
    2. Limpeza e Tipagem: Padroniza nomes de colunas, remove metadados/cabeçalhos e converte tipos.
    3. Escrita: Grava os dados na camada Silver em formato colunar Parquet otimizado.
    """
    print("Lendo dados da camada Bronze no MinIO...")
    
    # O Spark lê de forma distribuída todos os arquivos JSON salvos na partição ano=2022
    df_bronze = spark.read.json("s3a://agro-lake/bronze/sidra/pam/ano=2022/*.json")
    
    # Filtra registros com valor nulo na coluna bruta 'V' (Valor da métrica)
    df_bronze = df_bronze.filter(col("V").isNotNull())

    print("Limpando e tipando os dados...")
    
    # ==============================================================================
    # 2. Renomeação semântica de colunas do SIDRA e conversão de tipos
    # - D1N -> municipio / estado (Unidade Territorial)
    # - D2N -> cultura (tipo de produto agrícola)
    # - D3N -> ano de referência
    # - V   -> quantidade_produzida (remove separadores '.' e converte para número decimal/double)
    # - MN  -> unidade_medida (ex: Toneladas, Hectares)
    # ==============================================================================
    df_silver = df_bronze.select(
        col("D1N").alias("municipio"),
        col("D2N").alias("cultura"),
        col("D3N").alias("ano"),
        regexp_replace(col("V"), "\\.", "").cast("double").alias("quantidade_produzida"),
        col("MN").alias("unidade_medida")
    )

    # Remove o cabeçalho descritivo retornado pelo IBGE (onde a linha tem municipio == "Município")
    df_silver = df_silver.filter(col("municipio") != "Município")

    print("Gravando dados na camada Silver em formato Parquet...")
    
    # ==============================================================================
    # 3. Escrita na camada Silver em formato Parquet (colunar comprimido)
    # mode("overwrite"): garante idempotência, permitindo reexecuções sem duplicar dados
    # ==============================================================================
    df_silver.write \
        .mode("overwrite") \
        .parquet("s3a://agro-lake/silver/sidra/pam/ano=2022/")
        
    print("Processamento Silver concluído com sucesso!")
    
    # Exibe as primeiras 5 linhas processadas para auditoria visual
    df_silver.show(5, truncate=False)

if __name__ == "__main__":
    try:
        process_bronze_to_silver()
    finally:
        # Encerra a sessão Spark liberando memória e recursos
        spark.stop()
