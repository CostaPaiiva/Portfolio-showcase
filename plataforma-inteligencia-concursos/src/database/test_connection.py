from sqlalchemy import text

from src.database.connection import get_engine

def test_connection() -> None:
    """
    Testa a conexão com o PostgreSQL e lista as tabelas do schema public do banco.
    """

    # Obtém a engine de conexão configurada no módulo connection.py
    engine = get_engine()

    # Define a query SQL para buscar o nome de todas as tabelas no schema 'public'.
    # Utiliza a função text() do SQLAlchemy para envolver a string SQL bruta.
    query = text("""
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'public'
        ORDER BY table_name;
    """)

    try:
        # Abre a conexão utilizando um gerenciador de contexto (with),
        # o que garante que a conexão será fechada automaticamente ao final do bloco.
        with engine.connect() as connection:
            # Executa a query na conexão aberta
            result = connection.execute(query)

            print("Conexão realizada com sucesso!")
            print("Tabelas encontradas no banco:")

            # Itera sobre os resultados (linhas retornadas) e exibe o nome de cada tabela
            for row in result:
                print(f"- {row.table_name}")

    except Exception as error:
        # Em caso de falha na conexão ou execução, captura e exibe a mensagem de erro
        print("Erro ao conectar no banco:")
        print(error)


# Garante que o teste só será executado se o arquivo for rodado diretamente 
# (e não caso seja importado como módulo em outro script)
if __name__ == "__main__":
    test_connection()