import sys
from pathlib import Path

import pandas as pd
import plotly.express as px
import streamlit as st
from sqlalchemy import text


# ============================================================
# AJUSTE DE PATH DO PROJETO
# ============================================================

PROJECT_ROOT = Path(__file__).resolve().parents[1]

if str(PROJECT_ROOT) not in sys.path:
    sys.path.append(str(PROJECT_ROOT))


from src.database.connection import get_engine


# ============================================================
# CONFIGURAÇÕES INICIAIS
# ============================================================

st.set_page_config(
    page_title="Dashboard de Concursos Públicos",
    page_icon="📊",
    layout="wide",
)


# ============================================================
# CARREGAMENTO DOS DADOS
# ============================================================

@st.cache_data(ttl=60)
def load_data() -> pd.DataFrame:
    """
    Carrega os dados da view analítica criada na Parte 6.
    """

    engine = get_engine()

    query = text("""
        SELECT
            id_concurso,
            nome_orgao,
            esfera,
            nome_cargo,
            area,
            nivel,
            nome_banca,
            sigla_estado,
            nome_estado,
            regiao,
            ano,
            vagas,
            salario,
            inscricao_inicio,
            inscricao_fim,
            data_prova,
            url_edital,
            data_carga
        FROM vw_concursos_analytics;
    """)

    df = pd.read_sql(query, engine)

    return df


try:
    df = load_data()
except Exception as error:
    st.error("Erro ao carregar dados da view `vw_concursos_analytics`.")
    st.warning(
        "Verifique se o PostgreSQL está rodando, se o ETL foi executado "
        "e se a view `vw_concursos_analytics` foi criada."
    )
    st.exception(error)
    st.stop()


# ============================================================
# VALIDAÇÃO
# ============================================================

if df.empty:
    st.warning("A view `vw_concursos_analytics` não retornou dados.")
    st.stop()


# ============================================================
# TRATAMENTO BÁSICO
# ============================================================

df["salario"] = pd.to_numeric(df["salario"], errors="coerce")
df["vagas"] = pd.to_numeric(df["vagas"], errors="coerce")
df["ano"] = pd.to_numeric(df["ano"], errors="coerce")

df["inscricao_inicio"] = pd.to_datetime(df["inscricao_inicio"], errors="coerce")
df["inscricao_fim"] = pd.to_datetime(df["inscricao_fim"], errors="coerce")
df["data_prova"] = pd.to_datetime(df["data_prova"], errors="coerce")


# ============================================================
# SIDEBAR - FILTROS
# ============================================================

st.sidebar.title("🔎 Filtros")

estados = sorted(df["sigla_estado"].dropna().unique())
bancas = sorted(df["nome_banca"].dropna().unique())
anos = sorted(df["ano"].dropna().astype(int).unique())
niveis = sorted(df["nivel"].dropna().unique())
areas = sorted(df["area"].dropna().unique())
regioes = sorted(df["regiao"].dropna().unique())

estado_selecionado = st.sidebar.multiselect(
    "Estado",
    options=estados,
    default=estados,
)

banca_selecionada = st.sidebar.multiselect(
    "Banca",
    options=bancas,
    default=bancas,
)

ano_selecionado = st.sidebar.multiselect(
    "Ano",
    options=anos,
    default=anos,
)

nivel_selecionado = st.sidebar.multiselect(
    "Nível",
    options=niveis,
    default=niveis,
)

area_selecionada = st.sidebar.multiselect(
    "Área",
    options=areas,
    default=areas,
)

regiao_selecionada = st.sidebar.multiselect(
    "Região",
    options=regioes,
    default=regioes,
)


df_filtrado = df[
    (df["sigla_estado"].isin(estado_selecionado))
    & (df["nome_banca"].isin(banca_selecionada))
    & (df["ano"].astype("Int64").isin(ano_selecionado))
    & (df["nivel"].isin(nivel_selecionado))
    & (df["area"].isin(area_selecionada))
    & (df["regiao"].isin(regiao_selecionada))
]


# ============================================================
# TÍTULO
# ============================================================

st.title("📊 Plataforma de Inteligência para Concursos Públicos")

st.markdown(
    """
    Dashboard analítico desenvolvido a partir de um pipeline de Engenharia de Dados
    com **Python, PostgreSQL, Docker, SQLAlchemy, Pandas, SQL, Streamlit e Plotly**.
    """
)

st.divider()


# ============================================================
# KPIS PRINCIPAIS
# ============================================================

total_concursos = df_filtrado["id_concurso"].nunique()
total_vagas = int(df_filtrado["vagas"].sum()) if not df_filtrado.empty else 0
media_salarial = df_filtrado["salario"].mean()
maior_salario = df_filtrado["salario"].max()


def format_currency(value: float) -> str:
    """
    Formata valores monetários no padrão brasileiro.
    """

    if pd.isna(value):
        return "R$ 0,00"

    return f"R$ {value:,.2f}".replace(",", "X").replace(".", ",").replace("X", ".")


col1, col2, col3, col4 = st.columns(4)

col1.metric("Total de Concursos", total_concursos)
col2.metric("Total de Vagas", f"{total_vagas:,}".replace(",", "."))
col3.metric("Média Salarial", format_currency(media_salarial))
col4.metric("Maior Salário", format_currency(maior_salario))

st.divider()


# ============================================================
# GRÁFICOS - LINHA 1
# ============================================================

col_grafico1, col_grafico2 = st.columns(2)

with col_grafico1:
    st.subheader("Concursos por Estado")

    concursos_estado = (
        df_filtrado
        .groupby("sigla_estado", as_index=False)
        .agg(total_concursos=("id_concurso", "nunique"))
        .sort_values("total_concursos", ascending=False)
    )

    fig_estado = px.bar(
        concursos_estado,
        x="sigla_estado",
        y="total_concursos",
        text="total_concursos",
        title="Quantidade de Concursos por Estado",
    )

    fig_estado.update_layout(
        xaxis_title="Estado",
        yaxis_title="Total de Concursos",
    )

    st.plotly_chart(fig_estado, use_container_width=True)


with col_grafico2:
    st.subheader("Concursos por Banca")

    concursos_banca = (
        df_filtrado
        .groupby("nome_banca", as_index=False)
        .agg(total_concursos=("id_concurso", "nunique"))
        .sort_values("total_concursos", ascending=False)
        .head(10)
    )

    fig_banca = px.bar(
        concursos_banca,
        x="total_concursos",
        y="nome_banca",
        orientation="h",
        text="total_concursos",
        title="Top 10 Bancas com Mais Concursos",
    )

    fig_banca.update_layout(
        xaxis_title="Total de Concursos",
        yaxis_title="Banca",
        yaxis={"categoryorder": "total ascending"},
    )

    st.plotly_chart(fig_banca, use_container_width=True)


# ============================================================
# GRÁFICOS - LINHA 2
# ============================================================

col_grafico3, col_grafico4 = st.columns(2)

with col_grafico3:
    st.subheader("Concursos por Ano")

    concursos_ano = (
        df_filtrado
        .dropna(subset=["ano"])
        .groupby("ano", as_index=False)
        .agg(total_concursos=("id_concurso", "nunique"))
        .sort_values("ano")
    )

    fig_ano = px.line(
        concursos_ano,
        x="ano",
        y="total_concursos",
        markers=True,
        title="Evolução de Concursos por Ano",
    )

    fig_ano.update_layout(
        xaxis_title="Ano",
        yaxis_title="Total de Concursos",
    )

    st.plotly_chart(fig_ano, use_container_width=True)


with col_grafico4:
    st.subheader("Vagas por Nível")

    vagas_nivel = (
        df_filtrado
        .groupby("nivel", as_index=False)
        .agg(total_vagas=("vagas", "sum"))
        .sort_values("total_vagas", ascending=False)
    )

    fig_nivel = px.pie(
        vagas_nivel,
        names="nivel",
        values="total_vagas",
        title="Distribuição de Vagas por Nível",
    )

    st.plotly_chart(fig_nivel, use_container_width=True)


# ============================================================
# GRÁFICOS - LINHA 3
# ============================================================

col_grafico5, col_grafico6 = st.columns(2)

with col_grafico5:
    st.subheader("Salário Médio por Estado")

    salario_estado = (
        df_filtrado
        .groupby("sigla_estado", as_index=False)
        .agg(salario_medio=("salario", "mean"))
        .sort_values("salario_medio", ascending=False)
    )

    fig_salario_estado = px.bar(
        salario_estado,
        x="sigla_estado",
        y="salario_medio",
        text_auto=".2s",
        title="Salário Médio por Estado",
    )

    fig_salario_estado.update_layout(
        xaxis_title="Estado",
        yaxis_title="Salário Médio",
    )

    st.plotly_chart(fig_salario_estado, use_container_width=True)


with col_grafico6:
    st.subheader("Vagas por Região")

    vagas_regiao = (
        df_filtrado
        .groupby("regiao", as_index=False)
        .agg(total_vagas=("vagas", "sum"))
        .sort_values("total_vagas", ascending=False)
    )

    fig_regiao = px.bar(
        vagas_regiao,
        x="regiao",
        y="total_vagas",
        text="total_vagas",
        title="Total de Vagas por Região",
    )

    fig_regiao.update_layout(
        xaxis_title="Região",
        yaxis_title="Total de Vagas",
    )

    st.plotly_chart(fig_regiao, use_container_width=True)


# ============================================================
# TABELAS ANALÍTICAS
# ============================================================

st.divider()

col_tabela1, col_tabela2 = st.columns(2)

with col_tabela1:
    st.subheader("Top 10 Cargos por Vagas")

    top_cargos = (
        df_filtrado
        .groupby("nome_cargo", as_index=False)
        .agg(total_vagas=("vagas", "sum"))
        .sort_values("total_vagas", ascending=False)
        .head(10)
    )

    st.dataframe(top_cargos, use_container_width=True)


with col_tabela2:
    st.subheader("Top 10 Maiores Salários")

    top_salarios = (
        df_filtrado[
            [
                "nome_orgao",
                "nome_cargo",
                "nome_banca",
                "sigla_estado",
                "salario",
                "vagas",
                "ano",
            ]
        ]
        .sort_values("salario", ascending=False)
        .head(10)
    )

    st.dataframe(top_salarios, use_container_width=True)


# ============================================================
# BASE DETALHADA
# ============================================================

st.divider()

st.subheader("Base Analítica Completa")

with st.expander("Ver dados detalhados"):
    st.dataframe(df_filtrado, use_container_width=True)


# ============================================================
# RODAPÉ
# ============================================================

st.markdown("---")
st.markdown(
    """
    **Projeto de Engenharia de Dados:** Plataforma de Inteligência para Concursos Públicos  
    Desenvolvido com Docker, PostgreSQL, Python, Pandas, SQLAlchemy, SQL, Streamlit e Plotly.
    """
)