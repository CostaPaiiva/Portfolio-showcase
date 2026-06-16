import os
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.engine import Engine


def get_database_url() -> str:
    """
    Monta a URL de conexão com o PostgreSQL usando variáveis do arquivo .env.

    Retorna:
        str: A string de conexão formatada para o SQLAlchemy.
    """

    # Carrega as variáveis de ambiente definidas no arquivo .env para o ambiente atual
    load_dotenv()

    # Obtém as credenciais e informações do banco de dados das variáveis de ambiente.
    # Caso alguma variável não exista, utiliza valores padrão (default).
    db_host = os.getenv("DB_HOST", "localhost")
    db_port = os.getenv("DB_PORT", "5432")
    db_name = os.getenv("DB_NAME", "concursos_dw")
    db_user = os.getenv("DB_USER", "concursos_user")
    db_password = os.getenv("DB_PASSWORD", "concursos_pass")

    # Formata a URL de conexão usando o driver psycopg2 para PostgreSQL
    database_url = (
        f"postgresql+psycopg2://{db_user}:{db_password}"
        f"@{db_host}:{db_port}/{db_name}"
    )

    return database_url


def get_engine() -> Engine:
    """
    Cria e retorna uma engine SQLAlchemy para conexão com o banco.
    A engine é o ponto de partida para qualquer aplicação SQLAlchemy.

    Retorna:
        Engine: Objeto engine do SQLAlchemy configurado para o banco de dados.
    """

    # Obtém a URL de conexão formatada
    database_url = get_database_url()

    # Cria a engine do SQLAlchemy utilizando a URL
    engine = create_engine(database_url)

    return engine