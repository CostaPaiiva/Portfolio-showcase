import requests
import json
import time
import logging
import os
from datetime import datetime
import boto3
from botocore.client import Config
from botocore.exceptions import ClientError
from dotenv import load_dotenv

# Carrega as variáveis do arquivo .env
load_dotenv()

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Endpoint da API SIDRA (PAM - Produção Agrícola Municipal - Tabela 1612)
# t/1612 = Pesquisa PAM, n3/all = Todos os Estados, v/214,216 = Quantidade Produzida e Área Colhida, p/2022 = Ano 2022, c81/all = Todas as culturas
URL = "https://apisidra.ibge.gov.br/values/t/1612/n3/all/v/214,216/p/2022/c81/all"

# Configuração do cliente MinIO (S3)
s3_client = boto3.client(
    's3',
    endpoint_url='http://127.0.0.1:9000',
    aws_access_key_id=os.getenv('MINIO_ROOT_USER'),
    aws_secret_access_key=os.getenv('MINIO_ROOT_PASSWORD'),
    config=Config(signature_version='s3v4'),
    region_name='us-east-1'
)

BUCKET_NAME = 'agro-lake'

def ensure_bucket_exists():
    """Cria o bucket no MinIO se ele não existir."""
    try:
        s3_client.head_bucket(Bucket=BUCKET_NAME)
        logging.info(f"Bucket '{BUCKET_NAME}' já existe.")
    except ClientError as e:
        error_code = e.response['Error']['Code']
        if error_code == '404':
            logging.info(f"Criando bucket '{BUCKET_NAME}'...")
            s3_client.create_bucket(Bucket=BUCKET_NAME)
        else:
            logging.error(f"Erro ao verificar o bucket: {e}")
            raise

def fetch_sidra_data(url, max_retries=3):
    for attempt in range(max_retries):
        try:
            logging.info(f"Tentativa {attempt + 1} de baixar dados do SIDRA...")
            response = requests.get(url, timeout=10)
            if response.status_code in [429, 500, 502, 503, 504]:
                logging.warning(f"API retornou {response.status_code}. Tentando novamente em {2 ** attempt}s...")
                time.sleep(2 ** attempt)
                continue
            response.raise_for_status()
            logging.info("Download concluído com sucesso!")
            return response.json()
        except requests.exceptions.RequestException as e:
            logging.error(f"Erro na requisição: {e}")
    return None

def upload_to_minio_bronze(data):
    """Salva o JSON bruto diretamente no MinIO."""
    if not data:
        return
        
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    # Chave (key) do objeto: pastas virtuais + nome do arquivo
    object_key = f"bronze/sidra/pam/ano=2022/dados_{timestamp}.json"
    
    # Converte o JSON para string de bytes
    json_bytes = json.dumps(data, ensure_ascii=False).encode('utf-8')
    
    logging.info(f"Enviando dados para MinIO: s3://{BUCKET_NAME}/{object_key}")
    
    try:
        s3_client.put_object(
            Bucket=BUCKET_NAME,
            Key=object_key,
            Body=json_bytes,
            ContentType='application/json'
        )
        logging.info("Upload para o MinIO concluído com sucesso!")
    except Exception as e:
        logging.error(f"Falha no upload para o MinIO: {e}")

if __name__ == "__main__":
    logging.info("Iniciando pipeline de ingestão do SIDRA para o Data Lake")
    ensure_bucket_exists()
    
    dados = fetch_sidra_data(URL)
    if dados:
        logging.info(f"Total de registros recebidos: {len(dados) - 1}")
        upload_to_minio_bronze(dados)
    else:
        logging.error("Pipeline falhou: nenhum dado foi recebido.")
