import json
from datetime import datetime
from pathlib import Path

import pandas as pd


REQUIRED_COLUMNS = [
    "orgao",
    "cargo",
    "area",
    "nivel",
    "banca",
    "estado",
    "regiao",
    "esfera",
    "ano",
    "vagas",
    "salario",
    "inscricao_inicio",
    "inscricao_fim",
    "data_prova",
    "url_edital",
]


def get_project_root() -> Path:
    """
    Retorna o diretorio raiz do projeto.
    """

    # Sobe dois niveis a partir de src/transformation/ ate a raiz do projeto.
    return Path(__file__).resolve().parents[2]


def get_latest_raw_file() -> Path:
    """
    Busca o arquivo JSON mais recente na pasta data/raw.
    """

    # Localiza a pasta de dados brutos do projeto.
    project_root = get_project_root()
    raw_dir = project_root / "data" / "raw"

    # Procura todos os arquivos gerados pela extracao.
    raw_files = list(raw_dir.glob("concursos_raw_*.json"))

    if not raw_files:
        raise FileNotFoundError(
            "Nenhum arquivo bruto encontrado em data/raw. "
            "Execute primeiro: python src/extraction/extract_sample_data.py"
        )

    # Seleciona o arquivo mais recente pelo timestamp de modificacao.
    latest_file = max(raw_files, key=lambda file: file.stat().st_mtime)

    return latest_file


def read_raw_json(file_path: Path) -> pd.DataFrame:
    """
    Le o arquivo JSON bruto e retorna um DataFrame com os dados.
    """

    # Abre o JSON bruto e carrega o conteudo em memoria.
    with open(file_path, "r", encoding="utf-8") as file:
        raw_content = json.load(file)

    # A chave data guarda a lista de registros extraidos.
    data = raw_content.get("data", [])

    if not data:
        raise ValueError("O arquivo bruto nao contem dados na chave 'data'.")

    # Converte a lista de dicionarios em DataFrame para facilitar as transformacoes.
    df = pd.DataFrame(data)

    return df


def validate_required_columns(df: pd.DataFrame) -> None:
    """
    Valida se todas as colunas obrigatorias existem no DataFrame.
    """

    # Garante que todas as colunas esperadas existem antes de seguir.
    missing_columns = [column for column in REQUIRED_COLUMNS if column not in df.columns]

    if missing_columns:
        raise ValueError(f"Colunas obrigatorias ausentes: {missing_columns}")


def normalize_text(value: object) -> str:
    """
    Padroniza textos removendo espacos extras.
    """

    if pd.isna(value):
        return ""

    # Remove espacos extras e converte tudo para string.
    return str(value).strip()


def standardize_cargo(cargo: str) -> str:
    """
    Cria uma versao padronizada do cargo para facilitar analises.
    """

    # Normaliza o texto para aplicar regras de padronizacao.
    cargo_upper = cargo.upper()

    if "AUDITOR" in cargo_upper and "TI" in cargo_upper:
        return "AUDITOR_TI"

    if "AUDITOR" in cargo_upper and "TECNOLOGIA" in cargo_upper:
        return "AUDITOR_TI"

    if "ANALISTA" in cargo_upper and "DADOS" in cargo_upper:
        return "ANALISTA_DADOS"

    if "ANALISTA" in cargo_upper and "TECNOLOGIA" in cargo_upper:
        return "ANALISTA_TI"

    if "ANALISTA" in cargo_upper and "INFORMACAO" in cargo_upper:
        return "ANALISTA_TI"

    if "TECNICO" in cargo_upper and "INFORMATICA" in cargo_upper:
        return "TECNICO_INFORMATICA"

    return cargo_upper.replace(" ", "_")


def standardize_banca(banca: str) -> str:
    """
    Padroniza nomes de bancas organizadoras.
    """

    # Padroniza o nome da banca para evitar duplicidades de escrita.
    banca_upper = banca.upper().strip()

    mapping = {
        "FGV": "FGV",
        "CEBRASPE": "CEBRASPE",
        "CESPE": "CEBRASPE",
        "FCC": "FCC",
        "FUNDACAO CARLOS CHAGAS": "FCC",
        "INSTITUTO AOCP": "INSTITUTO AOCP",
        "AOCP": "INSTITUTO AOCP",
    }

    return mapping.get(banca_upper, banca_upper)


def transform_data(df: pd.DataFrame) -> pd.DataFrame:
    """
    Executa as transformacoes principais nos dados.
    """

    # Valida a estrutura antes de aplicar qualquer regra de negocio.
    validate_required_columns(df)

    # Trabalha sobre uma copia para nao alterar o DataFrame original.
    df_transformed = df.copy()

    text_columns = [
        "orgao",
        "cargo",
        "area",
        "nivel",
        "banca",
        "estado",
        "regiao",
        "esfera",
        "url_edital",
    ]

    # Limpa os campos textuais mais usados nas analises.
    for column in text_columns:
        df_transformed[column] = df_transformed[column].apply(normalize_text)

    # Cria colunas derivadas para facilitar agrupamentos e filtros.
    df_transformed["cargo_padronizado"] = df_transformed["cargo"].apply(standardize_cargo)
    df_transformed["banca_padronizada"] = df_transformed["banca"].apply(standardize_banca)

    # Converte colunas numericas para tipos adequados.
    df_transformed["ano"] = pd.to_numeric(df_transformed["ano"], errors="coerce").astype("Int64")
    df_transformed["vagas"] = pd.to_numeric(df_transformed["vagas"], errors="coerce").astype("Int64")
    df_transformed["salario"] = pd.to_numeric(df_transformed["salario"], errors="coerce")

    date_columns = ["inscricao_inicio", "inscricao_fim", "data_prova"]

    # Converte as datas para o tipo data, descartando horarios.
    for column in date_columns:
        df_transformed[column] = pd.to_datetime(
            df_transformed[column],
            errors="coerce",
        ).dt.date

    # Classifica o salario em faixas para analise gerencial.
    df_transformed["salario_faixa"] = pd.cut(
        df_transformed["salario"],
        bins=[0, 7000, 12000, 18000, float("inf")],
        labels=[
            "Ate 7 mil",
            "De 7 mil a 12 mil",
            "De 12 mil a 18 mil",
            "Acima de 18 mil",
        ],
    )

    # Calcula a duracao do periodo de inscricao em dias.
    df_transformed["dias_inscricao"] = (
        pd.to_datetime(df_transformed["inscricao_fim"])
        - pd.to_datetime(df_transformed["inscricao_inicio"])
    ).dt.days

    # Registra quando a transformacao foi executada.
    df_transformed["data_transformacao"] = datetime.now().isoformat()

    # Ordena os dados para facilitar leitura e validacao posterior.
    df_transformed = df_transformed.sort_values(
        by=["ano", "estado", "orgao"],
        ascending=[False, True, True],
    )

    return df_transformed


def save_processed_data(df: pd.DataFrame) -> Path:
    """
    Salva os dados transformados na pasta data/processed.
    """

    # Define a pasta de saida dos dados tratados.
    project_root = get_project_root()
    processed_dir = project_root / "data" / "processed"
    processed_dir.mkdir(parents=True, exist_ok=True)

    # Gera um nome de arquivo unico para nao sobrescrever execucoes anteriores.
    transformation_date = datetime.now().strftime("%Y_%m_%d_%H_%M_%S")
    output_file = processed_dir / f"concursos_processed_{transformation_date}.csv"

    # Salva o DataFrame em CSV com codificacao adequada para o Excel.
    df.to_csv(output_file, index=False, encoding="utf-8-sig")

    return output_file


def main() -> None:
    """
    Executa o pipeline de transformacao.
    """

    print("Iniciando transformacao dos dados...")

    # Busca o ultimo arquivo bruto gerado pela etapa de extracao.
    latest_raw_file = get_latest_raw_file()
    print(f"Arquivo bruto encontrado: {latest_raw_file}")

    # Carrega e transforma os registros.
    raw_df = read_raw_json(latest_raw_file)
    print(f"Registros lidos: {len(raw_df)}")

    transformed_df = transform_data(raw_df)
    output_file = save_processed_data(transformed_df)

    print("Transformacao concluida com sucesso!")
    print(f"Registros transformados: {len(transformed_df)}")
    print(f"Arquivo tratado gerado: {output_file}")


if __name__ == "__main__":
    main()
