import sys
from pathlib import Path

import pandas as pd
from sqlalchemy import text


def get_project_root() -> Path:
    """
    Retorna o diretório raiz do projeto.
    Útil para construir caminhos relativos robustos, garantindo
    que o código funcione independente de onde o script é executado.
    """
    # Resolve o caminho do arquivo atual (__file__) e sobe dois níveis de diretório (.parents[2])
    # Isso sai de 'src/loading/' e vai para 'plataforma-inteligencia-concursos/'
    return Path(__file__).resolve().parents[2]


# Garante que a raiz do projeto esteja no caminho de importacao do Python.
PROJECT_ROOT = get_project_root()
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))


# Importa a função para obter a conexão com o banco de dados.
from src.database.connection import get_engine


def get_latest_processed_file() -> Path:
    """
    Busca o arquivo CSV mais recente na pasta data/processed.
    """
    project_root = get_project_root()
    # Constrói o caminho para a pasta onde os dados tratados são salvos
    processed_dir = project_root / "data" / "processed"

    # Busca todos os arquivos que começam com 'concursos_processed_' e terminam com '.csv'
    processed_files = list(processed_dir.glob("concursos_processed_*.csv"))

    # Validação: caso não encontre nenhum arquivo, lança um erro explicando o que fazer
    if not processed_files:
        raise FileNotFoundError(
            "Nenhum arquivo tratado encontrado em data/processed. "
            "Execute primeiro: python -m src.transformation.transform_raw_data"
        )

    # Identifica o arquivo mais recente baseado na data de modificação (stat().st_mtime)
    latest_file = max(processed_files, key=lambda file: file.stat().st_mtime)

    return latest_file


def read_processed_csv(file_path: Path) -> pd.DataFrame:
    """
    Lê o arquivo CSV tratado e o carrega em um DataFrame do Pandas.
    """
    df = pd.read_csv(file_path)

    # Verifica se o arquivo lido possui dados (não está vazio)
    if df.empty:
        raise ValueError("O arquivo tratado está vazio.")

    return df


def insert_dimensions(df: pd.DataFrame) -> None:
    """
    Insere os registros únicos nas tabelas dimensão (banca, estado, cargo, orgao).
    Essas tabelas guardam os atributos descritivos do modelo estrela (Star Schema).
    """
    # Pega a engine do SQLAlchemy para conectar ao banco de dados
    engine = get_engine()

    # Inicia uma transação com o banco de dados usando o bloco 'with'.
    # Isso garante que a conexão seja fechada automaticamente e as mudanças comitadas no final.
    with engine.begin() as connection:
        
        # 1. Inserir Bancas
        # Extrai as bancas únicas do DataFrame, ignorando valores nulos (dropna)
        for banca in df["banca_padronizada"].dropna().unique():
            connection.execute(
                text("""
                    INSERT INTO dim_banca (nome_banca)
                    VALUES (:nome_banca)
                    -- Evita duplicação caso a banca já exista no banco
                    ON CONFLICT (nome_banca) DO NOTHING;
                """),
                {"nome_banca": banca},
            )

        # 2. Inserir Estados
        # Extrai pares únicos de (estado, região) do DataFrame
        estados = df[["estado", "regiao"]].drop_duplicates()
        for _, row in estados.iterrows():
            connection.execute(
                text("""
                    INSERT INTO dim_estado (sigla_estado, nome_estado, regiao)
                    VALUES (:sigla_estado, :nome_estado, :regiao)
                    -- Evita duplicação caso o estado (sigla) já exista
                    ON CONFLICT (sigla_estado) DO NOTHING;
                """),
                {
                    "sigla_estado": row["estado"],
                    "nome_estado": row["estado"], # Assume nome igual à sigla nesta implementação
                    "regiao": row["regiao"],
                },
            )

        # 3. Inserir Cargos
        # Extrai as combinações únicas de (cargo, area, nivel)
        cargos = df[["cargo", "area", "nivel"]].drop_duplicates()
        for _, row in cargos.iterrows():
            # Aqui é utilizada uma subquery com WHERE NOT EXISTS porque a constraint
            # de unicidade possivelmente abrange múltiplos campos e varia de SGBD para SGBD
            connection.execute(
                text("""
                    INSERT INTO dim_cargo (nome_cargo, area, nivel)
                    SELECT :nome_cargo, :area, :nivel
                    WHERE NOT EXISTS (
                        SELECT 1
                        FROM dim_cargo
                        WHERE nome_cargo = :nome_cargo
                          AND area = :area
                          AND nivel = :nivel
                    );
                """),
                {
                    "nome_cargo": row["cargo"],
                    "area": row["area"],
                    "nivel": row["nivel"],
                },
            )

        # 4. Inserir Órgãos
        # Extrai as combinações únicas de (orgao, esfera)
        orgaos = df[["orgao", "esfera"]].drop_duplicates()
        for _, row in orgaos.iterrows():
            connection.execute(
                text("""
                    INSERT INTO dim_orgao (nome_orgao, esfera)
                    VALUES (:nome_orgao, :esfera)
                    ON CONFLICT (nome_orgao) DO NOTHING;
                """),
                {
                    "nome_orgao": row["orgao"],
                    "esfera": row["esfera"],
                },
            )


def get_dimension_ids(connection, row: pd.Series) -> dict:
    """
    Busca os IDs gerados automaticamente nas tabelas dimensão para um registro de concurso específico.
    Isso é necessário para construir a tabela fato, que guarda apenas as referências (IDs) e os valores métricos.
    """
    # Consulta ID da banca
    id_banca = connection.execute(
        text("""
            SELECT id_banca
            FROM dim_banca
            WHERE nome_banca = :nome_banca;
        """),
        {"nome_banca": row["banca_padronizada"]},
    ).scalar_one() # Pega apenas o primeiro valor resultante da consulta

    # Consulta ID do estado
    id_estado = connection.execute(
        text("""
            SELECT id_estado
            FROM dim_estado
            WHERE sigla_estado = :sigla_estado;
        """),
        {"sigla_estado": row["estado"]},
    ).scalar_one()

    # Consulta ID do cargo
    id_cargo = connection.execute(
        text("""
            SELECT id_cargo
            FROM dim_cargo
            WHERE nome_cargo = :nome_cargo
              AND area = :area
              AND nivel = :nivel;
        """),
        {
            "nome_cargo": row["cargo"],
            "area": row["area"],
            "nivel": row["nivel"],
        },
    ).scalar_one()

    # Consulta ID do orgao
    id_orgao = connection.execute(
        text("""
            SELECT id_orgao
            FROM dim_orgao
            WHERE nome_orgao = :nome_orgao;
        """),
        {"nome_orgao": row["orgao"]},
    ).scalar_one()

    return {
        "id_banca": id_banca,
        "id_estado": id_estado,
        "id_cargo": id_cargo,
        "id_orgao": id_orgao,
    }


def insert_fact_table(df: pd.DataFrame) -> int:
    """
    Insere os registros consolidados na tabela fato_concurso.
    Retorna a quantidade de novos registros inseridos com sucesso.
    """
    engine = get_engine()
    inserted_count = 0

    with engine.begin() as connection:
        # Itera linha a linha no dataframe dos concursos processados
        for _, row in df.iterrows():
            # Recupera as referências (foreign keys) para este concurso específico
            dimension_ids = get_dimension_ids(connection, row)

            # Executa o insert, usando a técnica de WHERE NOT EXISTS para evitar duplicar
            # um concurso que já tenha sido carregado anteriormente no banco de dados.
            result = connection.execute(
                text("""
                    INSERT INTO fato_concurso (
                        id_banca,
                        id_estado,
                        id_cargo,
                        id_orgao,
                        ano,
                        vagas,
                        salario,
                        inscricao_inicio,
                        inscricao_fim,
                        data_prova,
                        url_edital
                    )
                    SELECT
                        :id_banca,
                        :id_estado,
                        :id_cargo,
                        :id_orgao,
                        :ano,
                        :vagas,
                        :salario,
                        :inscricao_inicio,
                        :inscricao_fim,
                        :data_prova,
                        :url_edital
                    WHERE NOT EXISTS (
                        SELECT 1
                        FROM fato_concurso
                        WHERE id_banca = :id_banca
                          AND id_estado = :id_estado
                          AND id_cargo = :id_cargo
                          AND id_orgao = :id_orgao
                          AND ano = :ano
                          AND url_edital = :url_edital
                    );
                """),
                {
                    "id_banca": dimension_ids["id_banca"],
                    "id_estado": dimension_ids["id_estado"],
                    "id_cargo": dimension_ids["id_cargo"],
                    "id_orgao": dimension_ids["id_orgao"],
                    "ano": int(row["ano"]),
                    "vagas": int(row["vagas"]),
                    "salario": float(row["salario"]),
                    "inscricao_inicio": row["inscricao_inicio"],
                    "inscricao_fim": row["inscricao_fim"],
                    "data_prova": row["data_prova"],
                    "url_edital": row["url_edital"],
                },
            )

            # rowcount retorna quantas linhas foram efetivamente afetadas pelo INSERT
            inserted_count += result.rowcount

    return inserted_count


def load_data() -> None:
    """
    Função principal (orquestradora) que executa o pipeline de carga (Load).
    """
    print("Iniciando carga dos dados no PostgreSQL...")

    # 1. Pega o arquivo processado mais recente
    latest_processed_file = get_latest_processed_file()
    print(f"Arquivo tratado encontrado: {latest_processed_file}")

    # 2. Transforma o CSV em um DataFrame do Pandas
    df = read_processed_csv(latest_processed_file)
    print(f"Registros lidos: {len(df)}")

    # 3. Alimenta as Tabelas Dimensão primeiro (para gerar os IDs necessários)
    insert_dimensions(df)
    print("Dimensões carregadas com sucesso!")

    # 4. Alimenta a Tabela Fato
    inserted_count = insert_fact_table(df)
    print("Tabela fato carregada com sucesso!")
    print(f"Novos registros inseridos na fato_concurso: {inserted_count}")


# Só executa as funções abaixo se o arquivo for rodado diretamente no terminal
if __name__ == "__main__":
    load_data()
