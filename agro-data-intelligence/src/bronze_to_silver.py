import os
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, regexp_replace
from dotenv import load_dotenv

# Carrega variáveis de ambiente do arquivo .env (usuário e senha do MinIO)
load_dotenv()

# ==============================================================================
# 1. Configuração da Sessão PySpark com conector S3A para comunicação com o MinIO
# ==============================================================================
# O Hadoop 3.5.0 empacotado no PySpark 4.x define valores padrão com unidades de tempo
# como "30s", "60s" e "24h". O driver hadoop-aws 3.3.4 faz parse desses campos usando
# getInt/getLong estritos (sem suporte à unidade de tempo). Portanto, sobrepomos
# explicitamente todas as chaves de timeout/duração para valores puramente numéricos.
# Obtém endpoint do MinIO dinamicamente (padrão 'http://minio:9000' na rede Docker ou configurável via .env)
minio_endpoint = os.getenv('MINIO_ENDPOINT', 'http://minio:9000')

spark = SparkSession.builder \
    .appName("AgroBronzeToSilver") \
    .config("spark.jars.packages", "org.apache.hadoop:hadoop-aws:3.3.4,com.amazonaws:aws-java-sdk-bundle:1.12.262") \
    .config("spark.hadoop.fs.s3a.endpoint", minio_endpoint) \
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

# Reduz a verbosidade dos logs do Spark para WARN, mantendo o terminal limpo
spark.sparkContext.setLogLevel("WARN")

def process_bronze_to_silver():
    """
    Função principal da pipeline de transformação:
    1. Leitura: Consome os dados brutos em JSON da camada Bronze no MinIO (usando multiline=true).
    2. Limpeza e Tipagem: Padroniza nomes de colunas, remove metadados/cabeçalhos e converte tipos.
    3. Escrita: Grava os dados na camada Silver em formato colunar Parquet otimizado.
    """
    print("Lendo dados da camada Bronze no MinIO...")
    
    # O SIDRA grava arrays JSON com múltiplos registros, necessitando de multiline=true
    df_bronze = spark.read \
        .option("multiline", "true") \
        .json("s3a://agro-lake/bronze/sidra/pam/ano=2022/*.json")
    
    print("Limpando e tipando os dados...")
    
    # ==============================================================================
    # 2. Renomeação semântica e limpeza:
    # Remove linhas de cabeçalho do IBGE ("Unidade da Federação") e valores sem medição
    # - D1N -> estado / municipio (Unidade Territorial)
    # - D4N -> cultura (tipo de produto agrícola)
    # - D2N -> variavel (Quantidade produzida ou Área colhida)
    # - D3N -> ano de referência
    # - V   -> valor (remove separadores '.' e converte para double)
    # - MN  -> unidade_medida (ex: Toneladas, Hectares)
    # ==============================================================================
    df_filtered = df_bronze.filter(
        (col("D1N") != "Unidade da Federação") &
        (col("V").isNotNull()) &
        (~col("V").isin("-", "..", "..."))
    )

    df_silver = df_filtered.select(
        col("D1N").alias("estado"),
        col("D4N").alias("cultura"),
        col("D2N").alias("variavel"),
        col("D3N").alias("ano"),
        regexp_replace(col("V"), "\\.", "").cast("double").alias("valor"),
        col("MN").alias("unidade_medida")
    )

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
