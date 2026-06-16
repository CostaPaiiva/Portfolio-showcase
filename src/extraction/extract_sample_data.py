import json
from datetime import datetime
from pathlib import Path


def get_sample_concursos_data() -> list[dict]:
    """
    Simula a extração de dados de concursos públicos.

    Em um cenário real, essa função poderia buscar dados de:
    - APIs públicas
    - Sites de bancas organizadoras
    - Páginas institucionais
    - Editais em PDF
    - Portais de concursos
    """

    concursos = [
        {
            "orgao": "TCE-PI",
            "cargo": "Auditor de Controle Externo - Tecnologia da Informação",
            "area": "TI",
            "nivel": "Superior",
            "banca": "FGV",
            "estado": "PI",
            "regiao": "Nordeste",
            "esfera": "Estadual",
            "ano": 2026,
            "vagas": 10,
            "salario": 18000.00,
            "inscricao_inicio": "2026-06-01",
            "inscricao_fim": "2026-07-01",
            "data_prova": "2026-08-15",
            "url_edital": "https://exemplo.com/edital-tce-pi",
        },
        {
            "orgao": "Banco do Brasil",
            "cargo": "Analista de Tecnologia da Informação",
            "area": "TI",
            "nivel": "Superior",
            "banca": "Cebraspe",
            "estado": "DF",
            "regiao": "Centro-Oeste",
            "esfera": "Federal",
            "ano": 2026,
            "vagas": 50,
            "salario": 9500.00,
            "inscricao_inicio": "2026-05-10",
            "inscricao_fim": "2026-06-20",
            "data_prova": "2026-08-01",
            "url_edital": "https://exemplo.com/edital-banco-brasil",
        },
        {
            "orgao": "Prefeitura de São Paulo",
            "cargo": "Técnico de Informática",
            "area": "TI",
            "nivel": "Médio",
            "banca": "FCC",
            "estado": "SP",
            "regiao": "Sudeste",
            "esfera": "Municipal",
            "ano": 2025,
            "vagas": 20,
            "salario": 6500.00,
            "inscricao_inicio": "2025-04-01",
            "inscricao_fim": "2025-05-01",
            "data_prova": "2025-06-20",
            "url_edital": "https://exemplo.com/edital-prefeitura-sp",
        },
        {
            "orgao": "TJ-CE",
            "cargo": "Analista de Dados",
            "area": "Dados",
            "nivel": "Superior",
            "banca": "Instituto AOCP",
            "estado": "CE",
            "regiao": "Nordeste",
            "esfera": "Estadual",
            "ano": 2026,
            "vagas": 5,
            "salario": 12000.00,
            "inscricao_inicio": "2026-03-15",
            "inscricao_fim": "2026-04-15",
            "data_prova": "2026-06-10",
            "url_edital": "https://exemplo.com/edital-tj-ce",
        },
        {
            "orgao": "TRT-15",
            "cargo": "Analista Judiciário - Tecnologia da Informação",
            "area": "TI",
            "nivel": "Superior",
            "banca": "FCC",
            "estado": "SP",
            "regiao": "Sudeste",
            "esfera": "Federal",
            "ano": 2026,
            "vagas": 8,
            "salario": 13500.00,
            "inscricao_inicio": "2026-07-01",
            "inscricao_fim": "2026-08-01",
            "data_prova": "2026-09-15",
            "url_edital": "https://exemplo.com/edital-trt-15",
        },
        {
            "orgao": "SEFAZ-CE",
            "cargo": "Auditor Fiscal - Tecnologia da Informação",
            "area": "TI",
            "nivel": "Superior",
            "banca": "Cebraspe",
            "estado": "CE",
            "regiao": "Nordeste",
            "esfera": "Estadual",
            "ano": 2026,
            "vagas": 12,
            "salario": 21000.00,
            "inscricao_inicio": "2026-02-01",
            "inscricao_fim": "2026-03-01",
            "data_prova": "2026-05-05",
            "url_edital": "https://exemplo.com/edital-sefaz-ce",
        },
    ]

    return concursos


def save_raw_data(data: list[dict]) -> Path:
    """
    Salva os dados brutos extraídos em formato JSON.
    """

    project_root = Path(__file__).resolve().parents[2]
    raw_dir = project_root / "data" / "raw"
    raw_dir.mkdir(parents=True, exist_ok=True)

    extraction_date = datetime.now().strftime("%Y_%m_%d_%H_%M_%S")
    output_file = raw_dir / f"concursos_raw_{extraction_date}.json"

    metadata = {
        "source": "sample_data",
        "extraction_datetime": datetime.now().isoformat(),
        "records_count": len(data),
        "data": data,
    }

    with open(output_file, "w", encoding="utf-8") as file:
        json.dump(metadata, file, ensure_ascii=False, indent=4)

    return output_file


def main() -> None:
    """
    Executa o pipeline de extração.
    """

    print("Iniciando extração de dados simulados...")

    concursos_data = get_sample_concursos_data()
    output_file = save_raw_data(concursos_data)

    print("Extração concluída com sucesso!")
    print(f"Registros extraídos: {len(concursos_data)}")
    print(f"Arquivo gerado: {output_file}")


if __name__ == "__main__":
    main()