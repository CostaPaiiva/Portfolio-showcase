
# Plataforma AutoML profissional desenvolvida em Streamlit para automatizar
# todo o pipeline de Machine Learning, desde o upload e preparação dos dados
# até o treinamento, validação e comparação de múltiplos modelos.
# O sistema identifica automaticamente a variável target, aplica técnicas
# avançadas de pré-processamento e engenharia de atributos, executa validação
# cruzada para maior confiabilidade dos resultados, seleciona o melhor modelo
# e permite a exportação de relatórios e artefatos prontos para uso.


# Importa a biblioteca Streamlit para criar a interface web
import streamlit as st
# Importa a biblioteca Pandas para manipulação e análise de dados
import pandas as pd
# Importa a biblioteca NumPy para operações numéricas, especialmente com arrays
import numpy as np
# Importa a biblioteca Plotly Express para criar visualizações interativas de forma simples
import plotly.express as px
# Importa a biblioteca Plotly Graph Objects para criar gráficos mais complexos e customizados
import plotly.graph_objects as go
# Importa a biblioteca Time para funcionalidades relacionadas ao tempo, como pausas
import time
# Importa a biblioteca Base64 para codificação e decodificação de dados
import base64
# Importa a biblioteca Joblib para salvar e carregar modelos de Machine Learning de forma eficiente
import joblib
# Importa a classe datetime do módulo datetime para trabalhar com datas e horas
from datetime import datetime
# Importa o módulo OS para interagir com o sistema operacional, como criar diretórios
import os
# Importa implementacoes centralizadas para reduzir duplicacao entre arquivos
from data_processing import PowerfulDataProcessor
from model_training import UltraCompleteTrainer
from report_generator import PDFReportGenerator as ModularPDFReportGenerator
# Importa a biblioteca warnings para controlar avisos de depreciação ou outros
import warnings
# Ignora todos os avisos para manter a saída limpa
warnings.filterwarnings('ignore')


# ========== CONFIGURAÇÃO DA PÁGINA ==========
st.set_page_config(
    page_title="AutoML",
    page_icon="🤖",
    layout="wide"
)

# ========== CSS PERSONALIZADO ==========
st.markdown("""
<style>
    .main-header {
        font-size: 2.5rem;
        color: #1E88E5;
        text-align: center;
        margin-bottom: 2rem;
    }
    .stButton > button {
        width: 100%;
        font-weight: bold;
    }
    .success-box {
        background-color: #d4edda;
        border: 1px solid #c3e6cb;
        color: #155724;
        padding: 15px;
        border-radius: 5px;
        margin: 10px 0;
    }
    .error-box {
        background-color: #f8d7da;
        border: 1px solid #f5c6cb;
        color: #721c24;
        padding: 15px;
        border-radius: 5px;
        margin: 10px 0;
    }
    .power-card {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        padding: 20px;
        border-radius: 10px;
        color: white;
        margin: 10px 0;
        text-align: center;
    }
    .model-badge {
        display: inline-block;
        padding: 3px 8px;
        margin: 2px;
        border-radius: 12px;
        font-size: 0.8em;
        background-color: #e3f2fd;
        color: #1565c0;
    }
    .cv-badge {
        background: linear-gradient(135deg, #4CAF50 0%, #2E7D32 100%);
        color: white;
        padding: 5px 10px;
        border-radius: 15px;
        font-weight: bold;
        display: inline-block;
        margin: 5px;
    }
</style>
""", unsafe_allow_html=True)

# ========== DETECTOR INTELIGENTE DE TARGET ==========
class TargetDetector:
    """Detecta automaticamente a coluna target"""

    @staticmethod
    def detect_target(data, user_hint=None):
        """
        Detecta a coluna target automaticamente com inteligência
        Retorna: (target_col, X, y, confidence_score, problem_type)
        """
        # Verifica se uma sugestão de coluna target foi fornecida e se ela existe no DataFrame.
        if user_hint and user_hint in data.columns:
            # Se a sugestão existe, cria um DataFrame 'X' (features) removendo a coluna target sugerida.
            X = data.drop(columns=[user_hint]).copy()
            # Cria uma Série 'y' (target) com os valores da coluna target sugerida.
            y = data[user_hint].copy()
            # Detecta o tipo de problema (classificação ou regressão) com base na série 'y'.
            problem_type = TargetDetector.detect_problem_type(y)
            # Retorna a coluna target, os dados X e y, uma confiança alta (1.0) e o tipo de problema.
            return user_hint, X, y, 1.0, problem_type

        st.info("🔍 Analisando dataset para detectar target automaticamente...")

        scores = {}

        # Itera sobre cada coluna no DataFrame de entrada 'data'.
        for col in data.columns:
            # Chama o método estático 'analyze_column' para obter uma pontuação de "target" para a coluna atual.
            score = TargetDetector.analyze_column(data[col], col)
            # Armazena a pontuação no dicionário 'scores', usando o nome da coluna como chave.
            scores[col] = score

        # Classifica as colunas com base em suas pontuações de "target" em ordem decrescente.
        sorted_scores = sorted(scores.items(), key=lambda x: x[1], reverse=True)

        # Exibe um cabeçalho para a seção de análise automática no Streamlit.
        st.write("📊 **Análise automática:**")
        # Cria um DataFrame Pandas a partir das pontuações ordenadas para exibição.
        analysis_df = pd.DataFrame(sorted_scores, columns=['Coluna', 'Score Target'])

        # Divide a interface do Streamlit em duas colunas.
        col1, col2 = st.columns(2)
        with col1:
            # Exibe as 10 principais colunas com suas pontuações de "target" em um DataFrame.
            st.dataframe(analysis_df.head(10), use_container_width=True)

        with col2:
            # Verifica se há pontuações de colunas disponíveis.
            if len(sorted_scores) > 0:
            # Obtém o nome da coluna com a maior pontuação.
                top_col = sorted_scores[0][0]
            try:
                # Tenta criar e exibir um histograma da distribuição da coluna principal.
                fig = px.histogram(data, x=top_col, title=f"Distribuição: {top_col}")
                st.plotly_chart(fig, use_container_width=True)
            except Exception:
                # Em caso de erro ao gerar o gráfico, exibe uma mensagem.
                st.write(f"*Não foi possível criar gráfico para {top_col}*")

        # Filtra os principais candidatos a target, pegando os 3 primeiros com score acima de 0.3.
        top_candidates = [col for col, score in sorted_scores[:3] if score > 0.3]

        # Verifica se não há candidatos de target fortes.
        if not top_candidates:
            # Exibe um aviso se a detecção automática falhou.
            st.warning("⚠️ Não consegui detectar target automaticamente.")
            # Define a última coluna como target padrão.
            target_col = data.columns[-1]
            # Define uma baixa confiança.
            confidence = 0.1
        else:
            # Exibe um cabeçalho para a seleção de target.
            st.write("🎯 **Candidatos a target (escolha ou confirme):**")
            # Permite ao usuário selecionar a coluna target a partir dos candidatos ou escolher "Nenhuma das acima".
            target_col = st.selectbox(
            "Selecione a coluna target:",
            options=top_candidates + ["⚠️ Nenhuma das acima"], # Adiciona a opção de fallback manual.
            index=0, # Define o primeiro item como padrão.
            key="auto_target_select" # Chave única para o widget Streamlit.
            )

            # Verifica se o usuário selecionou a opção de fallback manual.
            if target_col == "⚠️ Nenhuma das acima":
                # Se sim, apresenta um novo selectbox com todas as colunas para seleção manual.
                target_col = st.selectbox(
                    "Selecione manualmente:",
                    options=data.columns.tolist(), # Opções são todas as colunas do DataFrame.
                    index=len(data.columns) - 1, # Define a última coluna como padrão.
                    key="manual_fallback_select" # Chave única para o widget Streamlit.
                )
                confidence = 0.5 # Define uma confiança média para a seleção manual.
            else:
                confidence = scores[target_col] # Se uma coluna foi selecionada, usa a pontuação calculada.

        # Separa as features (X) removendo a coluna target.
        X = data.drop(columns=[target_col]).copy()
        # Separa o target (y) pegando a coluna target.
        y = data[target_col].copy()

        # Detecta o tipo de problema (classificação ou regressão) com base na série 'y'.
        problem_type = TargetDetector.detect_problem_type(y)

        # Exibe mensagens de sucesso no Streamlit com a coluna target detectada/selecionada, confiança e tipo de problema.
        st.success(f"✅ Target detectado: **{target_col}** (confiança: {confidence:.2f})")
        st.success(f"📊 Tipo de problema: **{problem_type.upper()}**")
        st.write(f"📐 Dimensões: X={X.shape}, y={y.shape}")

        # Retorna a coluna target, os dados X e y, a pontuação de confiança e o tipo de problema.
        return target_col, X, y, confidence, problem_type

    @staticmethod
    def analyze_column(column, col_name):
        """Analisa uma coluna e retorna score de ser target"""
        score = 0 # Inicializa o score da coluna como 0.

        try:
            n_unique = column.nunique() # Calcula o número de valores únicos na coluna.
            n_total = len(column) # Obtém o número total de elementos na coluna.
            unique_ratio = n_unique / n_total if n_total > 0 else 0 # Calcula a proporção de valores únicos.

            if n_unique <= 10: # Se o número de valores únicos for pequeno (até 10), sugere que pode ser uma classe.
                score += 0.3 # Adiciona 0.3 ao score.
            elif unique_ratio > 0.9: # Se a proporção de valores únicos for muito alta (quase todos únicos), sugere que não é um ID.
                score += 0.2 # Adiciona 0.2 ao score.

            target_keywords = ['target', 'label', 'class', 'score', 'rating',
                               'price', 'value', 'output', 'result', 'y'] # Define palavras-chave comuns para colunas target.
            col_lower = col_name.lower() # Converte o nome da coluna para minúsculas.
            if any(keyword in col_lower for keyword in target_keywords): # Verifica se alguma palavra-chave está no nome da coluna.
                score += 0.4 # Adiciona 0.4 ao score se encontrar uma palavra-chave.

            if n_unique > 1: # Se houver mais de um valor único.
                value_counts = column.value_counts(normalize=True) # Calcula a contagem de frequência normalizada dos valores.
                try:
                    entropy = -sum(p * np.log(p) for p in value_counts if p > 0) # Calcula a entropia da coluna.
                    max_entropy = np.log(n_unique) # Calcula a entropia máxima possível para o número de valores únicos.
                    if max_entropy > 0: # Evita divisão por zero.
                        normalized_entropy = entropy / max_entropy # Normaliza a entropia.
                        if normalized_entropy < 0.7: # Se a entropia normalizada for baixa, sugere que é um target (classes bem definidas).
                            score += 0.2 # Adiciona 0.2 ao score.
                except Exception:
                    pass # Ignora erros no cálculo da entropia.

            if pd.api.types.is_numeric_dtype(column): # Verifica se a coluna é de tipo numérico.
                try:
                    if column.abs().max() > 1000: # Se o valor máximo absoluto for muito alto, sugere regressão.
                        score += 0.1 # Adiciona 0.1 ao score.
                except Exception:
                    pass # Ignora erros ao verificar o valor máximo.

            missing_ratio = column.isna().sum() / n_total if n_total > 0 else 0 # Calcula a proporção de valores ausentes.
            if missing_ratio > 0.3: # Se houver muitos valores ausentes, diminui o score (menos provável de ser target).
                score -= 0.3 # Subtrai 0.3 do score.

            if any(x in col_lower for x in ['id', 'code', 'num', 'index', 'key']): # Verifica palavras-chave comuns para IDs.
                score -= 0.4 # Diminui o score se parecer ser um ID.

            if n_unique == n_total and n_total > 100: # Se todos os valores forem únicos e há muitas linhas, sugere um ID/identificador.
                score -= 0.5 # Diminui o score significativamente.

            date_keywords = ['date', 'time', 'day', 'month', 'year'] # Define palavras-chave comuns para datas.
            if any(x in col_lower for x in date_keywords): # Verifica se o nome da coluna contém palavras-chave de data.
                score -= 0.3 # Diminui o score se parecer ser uma coluna de data.

            score = max(0, min(1, score)) # Garante que o score esteja entre 0 e 1.

        except Exception:
            score = 0 # Em caso de qualquer erro, define o score como 0.

        return round(score, 3) # Retorna o score arredondado para 3 casas decimais.

    @staticmethod
    def detect_problem_type(y):
        """Detecta se é classificação ou regressão de forma robusta"""
        try:
            # Tenta converter a série 'y' para numérica, substituindo valores não numéricos por NaN.
            y_numeric = pd.to_numeric(y, errors='coerce')
            # Conta o número de valores não nulos na série numérica.
            not_na = y_numeric.notna().sum()

            # Se a proporção de valores não nulos for menor que 80%, assume classificação (dados muito bagunçados).
            if not_na / len(y) < 0.8:
                return 'classification'

            # Remove os valores nulos da série numérica para análise.
            y_clean = y_numeric.dropna()
            # Se a série limpa estiver vazia após remover NaNs, assume classificação.
            if len(y_clean) == 0:
                return 'classification'

            # Obtém o número de valores únicos na série limpa.
            unique_vals = len(y_clean.unique())

            # Se o número de valores únicos for menor ou igual a 5.
            if unique_vals <= 5:
                try:
                    # Verifica se todos os valores podem ser convertidos para inteiros sem perda de informação.
                    if all(y_clean.astype(int) == y_clean):
                        return 'classification' # Se sim, e com poucos valores únicos, é provável que seja classificação.
                    else:
                        return 'regression' # Se não, e mesmo com poucos valores únicos (float), pode ser regressão.
                except Exception:
                    return 'classification' # Em caso de erro na conversão para int, assume classificação como fallback.

            # Se o número de valores únicos estiver entre 6 e 20.
            elif unique_vals <= 20:
                # Calcula a contagem de frequência normalizada de cada valor.
                value_counts = y_clean.value_counts(normalize=True)
                # Se algum valor único representa mais de 25% dos dados.
                if (value_counts > 0.25).any():
                    try:
                        # Verifica se todos os valores podem ser convertidos para inteiros sem perda de informação.
                        if all(y_clean.astype(int) == y_clean):
                            return 'classification' # Sugere classificação.
                        else:
                            return 'regression' # Sugere regressão.
                    except Exception:
                        return 'classification' # Em caso de erro, sugere classificação.
                else:
                    return 'regression' # Caso contrário, sugere regressão.
            # Se o número de valores únicos for maior que 20, é provável que seja regressão.
            else:
                return 'regression'

        except Exception:
            try:
                # Se 'y' tiver um atributo 'dtype' (é uma série ou DataFrame).
                if hasattr(y, 'dtype'):
                    # Se o tipo de dado for 'object' (string) ou tiver poucos valores únicos (<= 10).
                    if y.dtype == 'object' or len(y.unique()) <= 10:
                        return 'classification' # Retorna classificação.
                    else:
                        return 'regression' # Caso contrário, retorna regressão.
                else:
                    # Se não for uma série/DataFrame, tenta obter o número de valores únicos de um array NumPy.
                    unique_vals = len(np.unique(y))
                    # Se tiver poucos valores únicos (<= 10).
                    if unique_vals <= 10:
                        return 'classification' # Retorna classificação.
                    else:
                        return 'regression' # Caso contrário, retorna regressão.
            except Exception:
                return 'regression' # Como fallback final, retorna regressão se tudo falhar.

# ========== APLICAÇÃO PRINCIPAL COM FIXES ==========
class UltraRobustApp:
    # Construtor da classe UltraRobustApp.
    def __init__(self):
        # Verifica se 'app_initialized' não está no st.session_state (primeira execução).
        if 'app_initialized' not in st.session_state:
            # Inicializa a flag 'app_initialized' como True.
            st.session_state.app_initialized = True
            # Define a etapa inicial da aplicação como 1 (Upload).
            st.session_state.step = 1
            # Inicializa 'data' como None.
            st.session_state.data = None
            # Inicializa 'processed' como False.
            st.session_state.processed = False
            # Define o tipo de processador de dados a ser usado.
            st.session_state.processor_type = "POWERFULL"
            # Define o tipo de treinador de modelos a ser usado.
            st.session_state.trainer_type = "ULTRA_COMPLETE"
            # Registra o tempo da última execução para controle de reruns.
            st.session_state.last_rerun = time.time()
            # Define o número padrão de folds para validação cruzada.
            st.session_state.n_folds = 5
            # Define a estratégia padrão de validação cruzada.
            st.session_state.cv_strategy = "Auto (Recomendado)"
            # Define o estado aleatório padrão para reprodutibilidade.
            st.session_state.random_state = 42
            # Habilita o treinamento paralelo por padrão.
            st.session_state.parallel = True

    # Método para executar um rerun seguro da aplicação.
    def safe_rerun(self, delay=0.1):
        """Rerun seguro com delay"""
        # Obtém o tempo atual.
        current_time = time.time()
        # Verifica se o tempo desde o último rerun é maior que 0.5 segundos.
        if current_time - st.session_state.last_rerun > 0.5:
            # Espera um pequeno atraso.
            time.sleep(delay)
            # Atualiza o tempo do último rerun.
            st.session_state.last_rerun = current_time
            try:
                # Tenta executar st.rerun().
                st.rerun()
            except Exception:
                # Em caso de erro, tenta novamente.
                st.rerun()
        else:
            # Se o rerun for muito rápido, espera 0.5 segundos e tenta novamente.
            time.sleep(0.5)
            st.rerun()


    def run(self):
        """Executa a aplicação com tratamento de erros"""
        try:
            # Define o título principal da aplicação Streamlit.
            st.title("🤖 AutoML")
            # Exibe um markdown com um selo de "Validação Cruzada Ativada" e uma breve descrição.
            st.markdown("""
            <div class='cv-badge'>✅ VALIDAÇÃO CRUZADA ATIVADA</div>
            Sistema profissional com **validação cruzada** e **30+ modelos**!
            """, unsafe_allow_html=True)

            # Chama o método para exibir a barra de progresso das etapas.
            self.show_progress()

            try:
                # Verifica qual é a etapa atual do fluxo da aplicação.
                if st.session_state.step == 1:
                    # Se for a etapa 1, chama o método para upload do dataset.
                    self.step_upload()
                elif st.session_state.step == 2:
                    # Se for a etapa 2, chama o método para processamento dos dados.
                    self.step_process()
                elif st.session_state.step == 3:
                    # Se for a etapa 3, chama o método para treinamento dos modelos.
                    self.step_train()
                elif st.session_state.step == 4:
                    # Se for a etapa 4, chama o método para exibir os resultados.
                    self.step_results()
            except Exception as e:
                # Captura e exibe um erro específico da etapa atual.
                st.error(f"❌ Erro na etapa {st.session_state.step}: {str(e)}")
                # Oferece um botão para reiniciar a aplicação em caso de erro na etapa.
                if st.button("🔄 Reiniciar Aplicação", key="restart_app_error"):
                    # Chama o método para reiniciar a aplicação.
                    self.reset_app()

        except Exception as e:
            # Captura e exibe um erro crítico que possa ocorrer na execução geral da aplicação.
            st.error(f"❌ Erro crítico: {str(e)}")
            # Informa ao usuário para recarregar a página.
            st.info("Recarregue a página para tentar novamente.")

    def show_progress(self):
        """Barra de progresso simples"""
        # Define os nomes das etapas da aplicação.
        steps = [" Upload", " Processar", " Treinar", "📊 Resultados"]
        # Obtém a etapa atual (subtrai 1 para indexação baseada em zero).
        current = st.session_state.step - 1

        # Inicia a string HTML para a barra de progresso.
        html = """
        <div style="display: flex; justify-content: space-between; margin: 20px 0;">
        """

        # Itera sobre cada etapa para construir a representação visual.
        for i, step in enumerate(steps):
            # Se a etapa já foi concluída, exibe-a em verde.
            if i < current:
                html += f'<div style="padding: 10px; background: #4CAF50; color: white; border-radius: 5px; text-align: center; flex: 1; margin: 0 5px;">{step} ✅</div>'
            # Se for a etapa atual, exibe-a em azul.
            elif i == current:
                html += f'<div style="padding: 10px; background: #2196F3; color: white; border-radius: 5px; text-align: center; flex: 1; margin: 0 5px;">{step}</div>'
            # Se a etapa ainda não foi alcançada, exibe-a em cinza claro.
            else:
                html += f'<div style="padding: 10px; background: #f0f0f0; color: #666; border-radius: 5px; text-align: center; flex: 1; margin: 0 5px;">{step}</div>'

        # Fecha a div HTML.
        html += "</div>"
        # Renderiza o HTML no Streamlit, permitindo tags HTML.
        st.markdown(html, unsafe_allow_html=True)

    def step_upload(self):
        """Upload do dataset SIMPLIFICADO para evitar erro do Streamlit"""
        # Define o cabeçalho para a etapa de upload.
        st.header(" Upload do Dataset")

        # Cria um container para o uploader de arquivo.
        with st.container():
            # Exibe o widget de upload de arquivo.
            uploaded_file = st.file_uploader(
                "Escolha um arquivo CSV",
                type=['csv', 'txt', 'xlsx'],
                help="Suporta CSV, TXT e Excel",
                key="main_file_uploader"
            )

        # Verifica se um arquivo foi carregado.
        if uploaded_file:
            try:
                # Verifica a extensão do arquivo para determinar o método de leitura.
                if uploaded_file.name.endswith('.csv') or uploaded_file.name.endswith('.txt'):
                    # Lê o arquivo como CSV ou TXT.
                    data = pd.read_csv(uploaded_file)
                # Se a extensão for .xlsx (Excel).
                elif uploaded_file.name.endswith('.xlsx'):
                    # Lê o arquivo como Excel.
                    data = pd.read_excel(uploaded_file)
                # Como fallback, tenta ler como CSV.
                else:
                    data = pd.read_csv(uploaded_file)

                # Exibe uma mensagem de sucesso com as dimensões do dataset carregado.
                st.success(f" Dataset carregado: {data.shape[0]} linhas × {data.shape[1]} colunas")

                # Cria um checkbox para visualizar os dados.
                if st.checkbox(" Visualizar dados", key="show_preview_upload"):
                    # Exibe as primeiras 5 linhas do DataFrame em uma tabela.
                    st.dataframe(data.head(), use_container_width=True)

                # Define um subtítulo para a seleção da coluna target.
                st.subheader(" Seleção do Target")

                # Cria um checkbox para ativar ou desativar a detecção automática.
                use_auto = st.checkbox(" Usar detecção automática", value=True, key="use_auto_detect")

                # Se a detecção automática estiver ativada.
                if use_auto:
                    try:
                        # Chama o detector de target para identificar a coluna target e o tipo de problema.
                        target_col, X, y, confidence, problem_type = TargetDetector.detect_target(data)

                        # Divide o layout em duas colunas para exibir métricas.
                        col1, col2 = st.columns(2)
                        with col1:
                            # Exibe a coluna target detectada.
                            st.metric(" Target", target_col)
                        with col2:
                            # Exibe o tipo de problema detectado.
                            st.metric(" Tipo", problem_type.upper())

                        # Armazena as informações do target na sessão do Streamlit.
                        st.session_state.target_col = target_col
                        # Armazena o DataFrame de features (X) na sessão do Streamlit.
                        st.session_state.X = X
                        # Armazena a série target (y) na sessão do Streamlit.
                        st.session_state.y = y
                        # Armazena o tipo de problema detectado na sessão do Streamlit.
                        st.session_state.problem_type = problem_type
                        # Define a flag 'auto_detected' como True para indicar que a detecção foi automática.
                        st.session_state.auto_detected = True
                        # Armazena o DataFrame original completo na sessão do Streamlit.
                        st.session_state.data = data

                        # Exibe uma mensagem de sucesso para a detecção automática.
                        st.success("✅ Target detectado automaticamente!")

                    except Exception as e:
                        # Em caso de falha na detecção automática, exibe um erro.
                        st.error(f"❌ Detecção automática falhou: {str(e)}")
                        # Informa ao usuário para selecionar manualmente.
                        st.info("Por favor, selecione manualmente:")
                        # Desativa a detecção automática para forçar a seleção manual.
                        use_auto = False

                # Se a detecção automática não for usada ou falhar.
                if not use_auto or not st.session_state.get('auto_detected', False):
                    # Obtém a lista de todas as colunas do DataFrame.
                    target_options = data.columns.tolist()
                    # Define um índice padrão para a seleção manual (última coluna).
                    default_idx = len(target_options) - 1

                    # Itera sobre as colunas para encontrar uma que possa ser um target por palavras-chave.
                    for i, col in enumerate(target_options):
                        # Converte o nome da coluna para minúsculas.
                        col_lower = col.lower()
                        # Verifica se o nome da coluna contém palavras-chave comuns de target.
                        if any(kw in col_lower for kw in ['target', 'label', 'class', 'y', 'price', 'value']):
                            # Se encontrar, define este índice como padrão.
                            default_idx = i
                            break

                    # Exibe um selectbox (caixa de seleção) no Streamlit para permitir que o usuário escolha a coluna target.
                    target_col = st.selectbox(
                        # Título do selectbox, instruindo o usuário a selecionar a coluna target.
                        "Selecione a coluna target:",
                        # As opções disponíveis no selectbox são a lista de todas as colunas do DataFrame.
                        target_options,
                        # Define qual opção será pré-selecionada por padrão, com base no 'default_idx' calculado.
                        index=default_idx,
                        # Atribui uma chave única ao widget para garantir seu funcionamento correto no Streamlit.
                        key="manual_target_selector_upload"
                    )

                    # Separa as features (X) removendo a coluna target selecionada.
                    X = data.drop(columns=[target_col]).copy()
                    # Separa o target (y) pegando a coluna target selecionada.
                    y = data[target_col].copy()

                    try:
                        # Tenta detectar o tipo de problema (classificação/regressão) da coluna target.
                        problem_type = TargetDetector.detect_problem_type(y)
                    except Exception:
                        # Se a detecção robusta falhar, usa um fallback simples.
                        if y.dtype == 'object' or len(y.unique()) <= 10:
                            # Se for tipo 'object' ou tiver poucas classes, assume classificação.
                            problem_type = 'classification'
                        else:
                            # Caso contrário, assume regressão.
                            problem_type = 'regression'

                    # Armazena as informações do target na sessão do Streamlit.
                    # Armazena o nome da coluna target selecionada pelo usuário na sessão do Streamlit.
                    st.session_state.target_col = target_col
                    # Armazena o DataFrame de features (X) resultante da separação na sessão do Streamlit.
                    st.session_state.X = X
                    # Armazena a série target (y) resultante da separação na sessão do Streamlit.
                    st.session_state.y = y
                    # Armazena o tipo de problema (classificação ou regressão) detectado para a coluna target na sessão do Streamlit.
                    st.session_state.problem_type = problem_type
                    # Define a flag 'auto_detected' como False na sessão do Streamlit, indicando que a seleção da coluna target foi manual.
                    st.session_state.auto_detected = False # Indica que a seleção foi manual.
                    # Armazena o DataFrame original completo (com a coluna target antes da separação) na sessão do Streamlit.
                    st.session_state.data = data

                    # Exibe mensagens de sucesso com a coluna target selecionada e o tipo de problema.
                    st.success(f"✅ Target selecionado: {target_col}")
                    st.success(f" Tipo: {problem_type.upper()}")

                # Adiciona uma linha divisória para separação visual.
                st.markdown("---")

                # Divide o layout em duas colunas para botões de navegação.
                col1, col2 = st.columns(2)
                with col1:
                    # Botão para iniciar um novo upload, limpando o estado da sessão.
                    if st.button("🔄 Novo Upload", type="secondary", key="new_upload_simple_btn"):
                        # Define as chaves do st.session_state a serem preservadas.
                        keys_to_keep = ['app_initialized', 'last_rerun', 'n_folds', 'cv_strategy', 'random_state', 'parallel']
                        # Identifica as chaves a serem removidas.
                        keys_to_remove = [k for k in st.session_state.keys() if k not in keys_to_keep]
                        # Remove as chaves identificadas.
                        for key in keys_to_remove:
                            del st.session_state[key]
                        # Pequeno atraso antes do rerun.
                        time.sleep(0.5)
                        # Reinicia a aplicação.
                        st.rerun()

                with col2:
                    # Botão para continuar para a próxima etapa (processamento).
                    if st.button("🔧 Continuar →", type="primary", key="continue_upload_btn"):
                        # Verifica se uma coluna target foi selecionada.
                        if 'target_col' not in st.session_state:
                            # Exibe um erro se o target não foi selecionado.
                            st.error("❌ Selecione um target primeiro!")
                        else:
                            # Verifica se o dataset tem amostras suficientes.
                            if len(st.session_state.X) < 10:
                                # Exibe um erro se o número de amostras for muito baixo.
                                st.error("❌ Muito poucas amostras (mínimo 10)")
                            else:
                                # Define a próxima etapa como 2 (processamento).
                                st.session_state.step = 2
                                # Pequeno atraso antes do rerun.
                                time.sleep(0.5)
                                # Reinicia a aplicação para carregar a próxima etapa.
                                st.rerun()

            except Exception as e:
                # Captura e exibe qualquer erro que ocorra durante o processamento do arquivo.
                st.error(f"❌ Erro ao processar arquivo: {str(e)}")

                try:
                    # Tenta novamente ler o arquivo usando um encoding alternativo (latin-1).
                    uploaded_file.seek(0) # Volta o ponteiro do arquivo para o início.
                    data = pd.read_csv(uploaded_file, encoding='latin-1')
                    # Mensagem de sucesso se o encoding alternativo funcionar.
                    st.success("✅ Carregado com encoding alternativo")
                    # Armazena os dados na sessão.
                    st.session_state.data = data
                    # Reinicia a aplicação para processar os dados recarregados.
                    st.rerun()
                except Exception:
                    # Se mesmo o encoding alternativo falhar, exibe um erro final.
                    st.error("❌ Não foi possível ler o arquivo.")

                    # Separa as features (X) removendo a coluna target selecionada.
                    X = data.drop(columns=[target_col]).copy()
                    # Separa o target (y) pegando a coluna target selecionada.
                    y = data[target_col].copy()

                    try:
                        # Tenta detectar o tipo de problema (classificação/regressão) da coluna target.
                        problem_type = TargetDetector.detect_problem_type(y)
                    except Exception:
                        # Se a detecção robusta falhar, usa um fallback simples.
                        if y.dtype == 'object' or len(y.unique()) <= 10:
                            # Se for tipo 'object' ou tiver poucas classes, assume classificação.
                            problem_type = 'classification'
                        else:
                            # Caso contrário, assume regressão.
                            problem_type = 'regression'

                    # Armazena o nome da coluna target selecionada pelo usuário na sessão do Streamlit.
                    st.session_state.target_col = target_col
                    # Armazena o DataFrame de features (X) resultante da separação na sessão do Streamlit.
                    st.session_state.X = X
                    # Armazena a série target (y) resultante da separação na sessão do Streamlit.
                    st.session_state.y = y
                    # Armazena o tipo de problema (classificação ou regressão) detectado para a coluna target na sessão do Streamlit.
                    st.session_state.problem_type = problem_type
                    # Define a flag 'auto_detected' como False na sessão do Streamlit, indicando que a seleção da coluna target foi manual.
                    st.session_state.auto_detected = False
                    # Armazena o DataFrame original completo (com a coluna target antes da separação) na sessão do Streamlit.
                    st.session_state.data = data

                    # Exibe uma mensagem de sucesso no Streamlit informando a coluna target selecionada.
                    st.success(f"✅ Target selecionado: {target_col}")
                    # Exibe uma mensagem de sucesso no Streamlit informando o tipo de problema detectado.
                    st.success(f" Tipo: {problem_type.upper()}")

                # Adiciona uma linha divisória horizontal para separar visualmente as seções.
                st.markdown("---")

                # Cria duas colunas na interface do Streamlit para organizar os botões de navegação.
                col1, col2 = st.columns(2)
                with col1:
                    # Cria um botão para iniciar um novo upload de dataset.
                    if st.button("🔄 Novo Upload", type="secondary", key="new_upload_simple_btn"):
                        # Define uma lista de chaves do st.session_state que devem ser preservadas.
                        keys_to_keep = ['app_initialized', 'last_rerun', 'n_folds', 'cv_strategy', 'random_state', 'parallel']
                        # Identifica as chaves na sessão que não estão na lista de preservação.
                        keys_to_remove = [k for k in st.session_state.keys() if k not in keys_to_keep]
                        # Itera sobre as chaves a serem removidas e as deleta do st.session_state.
                        for key in keys_to_remove:
                            del st.session_state[key]
                        # Adiciona um pequeno atraso para permitir que o Streamlit processe a mudança de estado.
                        time.sleep(0.5)
                        # Força um novo rerun da aplicação, recarregando a primeira etapa.
                        st.rerun()

                with col2:
                    # Cria um botão para continuar para a próxima etapa (processamento de dados).
                    if st.button("🔧 Continuar →", type="primary", key="continue_upload_btn"):
                        # Verifica se a coluna target foi definida na sessão do Streamlit.
                        if 'target_col' not in st.session_state:
                            # Se não foi, exibe uma mensagem de erro.
                            st.error("❌ Selecione um target primeiro!")
                        else:
                            # Se a coluna target foi definida, verifica se há um número suficiente de amostras.
                            if len(st.session_state.X) < 10:
                                # Se o número de amostras for menor que 10, exibe uma mensagem de erro.
                                st.error("❌ Muito poucas amostras (mínimo 10)")
                            else:
                                # Se tudo estiver ok, define a próxima etapa como 2 (processamento).
                                st.session_state.step = 2
                                # Adiciona um pequeno atraso para o Streamlit.
                                time.sleep(0.5)
                                # Força um novo rerun da aplicação para carregar a etapa de processamento.
                                st.rerun()

            except Exception as e:
                # Captura qualquer exceção que ocorra durante o processamento inicial do arquivo ou detecção de target.
                st.error(f"❌ Erro ao processar arquivo: {str(e)}")

                try:
                    # Tenta reposicionar o ponteiro do arquivo para o início, caso a primeira leitura falhe.
                    uploaded_file.seek(0)
                    # Tenta ler o arquivo CSV novamente, desta vez usando a codificação 'latin-1'.
                    data = pd.read_csv(uploaded_file, encoding='latin-1')
                    # Exibe uma mensagem de sucesso se o arquivo for carregado com a codificação alternativa.
                    st.success("✅ Carregado com encoding alternativo")
                    # Armazena os dados lidos na sessão do Streamlit.
                    st.session_state.data = data
                    # Força um novo rerun para processar os dados carregados com sucesso.
                    st.rerun()
                except Exception:
                    # Se mesmo a tentativa com codificação alternativa falhar, exibe uma mensagem de erro final.
                    st.error("❌ Não foi possível ler o arquivo.")

    def step_process(self):
        """Processamento SIMPLIFICADO"""
        # Define o cabeçalho da seção de processamento de dados.
        st.header("🔧 Processamento de Dados")

        # Verifica se um dataset foi carregado na sessão ou se ele é None.
        if 'data' not in st.session_state or st.session_state.data is None:
            # Exibe um aviso se não houver dataset.
            st.warning("⚠️ Nenhum dataset carregado.")
            # Cria um botão para voltar à etapa de upload.
            if st.button("⬅️ Voltar para Upload", key="back_to_upload_process"):
                # Define a etapa atual como 1.
                st.session_state.step = 1
                # Adiciona um pequeno atraso.
                time.sleep(0.5)
                # Força um rerun da aplicação.
                st.rerun()
            # Retorna da função se não houver dados.
            return

        # Cria três colunas na interface do Streamlit para exibir métricas rápidas do dataset.
        col1, col2, col3 = st.columns(3)
        with col1:
            # Exibe o número de amostras (linhas) do dataset.
            st.metric("Amostras", st.session_state.data.shape[0])
        with col2:
            # Exibe o número de features (colunas menos a coluna target).
            st.metric("Features", st.session_state.data.shape[1] - 1)
        with col3:
            # Exibe o nome da coluna target.
            st.metric("Target", st.session_state.target_col)

        # Cria um botão principal para iniciar o treinamento.
        if st.button("Treinamento", type="primary", key="process_execute_btn"):
            # Exibe um spinner de carregamento enquanto os dados estão sendo processados.
            with st.spinner("Processando dados..."):
                try:
                    # Instancia a classe PowerfulDataProcessor para realizar o processamento avançado.
                    processor = PowerfulDataProcessor()

                    # Chama o método 'process' do processador de dados, passando o dataset e a coluna target.
                    # Ele retorna os dados X (features) e y (target) já processados, e o tipo de problema detectado.
                    X, y, problem_type = processor.process(
                        st.session_state.data,
                        st.session_state.target_col
                    )

                    # Armazena os dados de features (X) processados na sessão do Streamlit.
                    st.session_state.X = X
                    # Armazena os dados de target (y) processados na sessão do Streamlit.
                    st.session_state.y = y
                    # Armazena o tipo de problema detectado na sessão do Streamlit.
                    st.session_state.problem_type = problem_type
                    # Define a flag 'processed' como True para indicar que o processamento foi concluído.
                    st.session_state.processed = True

                    st.success("✅ Processamento concluído!")

                    # Cria um expansor para "Resultados do Processamento"
                    with st.expander("📋 Resultados do Processamento"):
                        # Divide o espaço em duas colunas para exibir informações de X e y
                        col1, col2 = st.columns(2)
                        with col1:
                            # Título para as informações das features (X)
                            st.write("**Features (X):**")
                            # Exibe as dimensões do DataFrame ou array de features X
                            st.write(f"- Dimensões: {X.shape}")
                            # Exibe o tipo do objeto X (e.g., pandas.DataFrame, numpy.ndarray)
                            st.write(f"- Tipo: {type(X)}")
                        with col2:
                            # Título para as informações do target (y)
                            st.write("**Target (y):**")
                            # Exibe as dimensões da série ou array target y
                            st.write(f"- Dimensões: {y.shape}")
                            # Exibe o tipo de problema (CLASSIFICATION ou REGRESSION) em maiúsculas
                            st.write(f"- Tipo: {problem_type.upper()}")
                            # Se for um problema de classificação, exibe o número de classes únicas
                            if problem_type == 'classification':
                                st.write(f"- Classes: {len(np.unique(y))}")

                    # Adiciona um pequeno atraso de 1 segundo para melhorar a experiência do usuário
                    time.sleep(1)

                # Captura qualquer exceção que ocorra durante o processamento avançado
                except Exception as e:
                    # Exibe uma mensagem de erro no Streamlit
                    st.error(f"❌ Erro no processamento: {str(e)}")
                    try:
                        # Tenta um processamento de fallback simples: converte o DataFrame para valores numpy
                        # Remove a coluna target do DataFrame original e pega os valores (features X)
                        X = st.session_state.data.drop(columns=[st.session_state.target_col]).values
                        # Pega a coluna target do DataFrame original e seus valores (target y)
                        y = st.session_state.data[st.session_state.target_col].values

                        # Armazena os dados X processados (simplesmente convertidos para numpy) na sessão
                        st.session_state.X = X
                        # Armazena os dados y processados (simplesmente convertidos para numpy) na sessão
                        st.session_state.y = y
                        # Define a flag 'processed' como True, indicando que o processamento (mesmo que simples) foi concluído
                        st.session_state.processed = True

                        # Exibe uma mensagem de sucesso para o processamento simples
                        st.success("✅ Processamento simples realizado")
                    # Captura exceções que ocorram durante o fallback simples
                    except Exception:
                        # Exibe uma mensagem de erro se o processamento simples também falhar
                        st.error("❌ Não foi possível processar os dados.")

        # Verifica se os dados foram processados (seja de forma avançada ou simples)
        if st.session_state.get('processed', False):
            # Adiciona uma linha divisória horizontal para separar visualmente as seções
            st.markdown("---")
            # Cria um botão para avançar para a etapa de treinamento
            if st.button(" Ir para Treinamento →", type="primary", key="go_to_train_btn"):
                # Define a próxima etapa como 3 (treinamento)
                st.session_state.step = 3
                # Adiciona um pequeno atraso
                time.sleep(0.5)
                # Força um rerun da aplicação para carregar a próxima etapa
                st.rerun()

        # Cria um botão para voltar à etapa anterior (upload)
        if st.button("⬅️ Voltar", key="back_from_process_btn"):
            # Define a etapa atual como 1
            st.session_state.step = 1
            # Adiciona um pequeno atraso
            time.sleep(0.5)
            # Força um rerun da aplicação para carregar a etapa anterior
            st.rerun()

    # Define o método para a etapa de treinamento
    def step_train(self):
        """Treinamento com fix"""
        # Define o cabeçalho da seção de treinamento
        st.header(" Treinamento com VALIDAÇÃO CRUZADA")

        # Verifica se os dados foram processados (se a flag 'processed' é False ou não existe na sessão)
        if not st.session_state.get('processed', False):
            # Exibe um aviso se os dados não foram processados
            st.warning("Dados não processados.")
            # Cria um botão para voltar à etapa de processamento
            if st.button("⬅️ Voltar", key="back_to_process_train"):
                # Define a etapa atual como 2
                st.session_state.step = 2
                # Adiciona um pequeno atraso
                time.sleep(0.1)
                # Força um rerun da aplicação
                st.rerun()
            # Retorna da função se os dados não foram processados
            return

        # Cria um expansor para exibir estatísticas do dataset
        with st.expander(" Estatísticas do Dataset"):
            # Cria quatro colunas para exibir diferentes métricas
            col1, col2, col3, col4 = st.columns(4)
            with col1:
                # Exibe o número de amostras (linhas) no dataset X
                st.metric("Amostras", len(st.session_state.X))
            with col2:
                # Exibe o número de features (colunas) no dataset X, verificando se X tem o atributo 'shape'
                st.metric("Features", st.session_state.X.shape[1] if hasattr(st.session_state.X, "shape") else 0)
            with col3:
                # Se o problema for classificação
                if st.session_state.problem_type == 'classification':
                    # Calcula o número de classes únicas no target y
                    unique_classes = len(np.unique(st.session_state.y))
                    # Exibe o número de classes
                    st.metric("Classes", unique_classes)
                else:
                    # Se for regressão, exibe a média do target y formatada com duas casas decimais
                    st.metric("Target Média", f"{np.mean(st.session_state.y):.2f}")
            with col4:
                # Se o problema for regressão
                if st.session_state.problem_type == 'regression':
                    # Exibe o desvio padrão do target y formatado com duas casas decimais
                    st.metric("Target Std", f"{np.std(st.session_state.y):.2f}")
                else:
                    # Se for classificação, calcula a porcentagem da classe majoritária
                    class_dist = pd.Series(st.session_state.y).value_counts().iloc[0] / len(st.session_state.y) * 100
                    # Exibe a porcentagem da classe majoritária formatada com uma casa decimal
                    st.metric("Classe Majoritária", f"{class_dist:.1f}%")

        with st.container():
            st.info(" **VALIDAÇÃO CRUZADA ATIVADA**")

            # Cria um expansor no Streamlit para agrupar as configurações de validação cruzada, tornando a interface mais organizada.
            with st.expander("⚙️ Configurações da Validação Cruzada"):
                # Divide o espaço disponível dentro do expansor em duas colunas para dispor os widgets de configuração.
                col1, col2 = st.columns(2)
                # Inicia o bloco de código para a primeira coluna.
                with col1:
                    # Cria um slider no Streamlit para permitir ao usuário selecionar o número de folds para a validação cruzada.
                    n_folds = st.slider(
                        # Título do slider exibido ao usuário.
                        "Número de folds",
                        # Valor mínimo do slider.
                        3,
                        # Valor máximo do slider.
                        10,
                        # Valor padrão do slider, obtido do st.session_state ou 5 se não existir.
                        st.session_state.get('n_folds', 5),
                        # Texto de ajuda que aparece ao passar o mouse sobre o slider.
                        help="Mais folds = mais robusto, mas mais lento",
                        # Chave única para este widget no Streamlit, garantindo seu estado.
                        key="n_folds_slider_train"
                    )
                    # Cria um selectbox no Streamlit para permitir ao usuário escolher a estratégia de validação cruzada.
                    cv_strategy = st.selectbox(
                        # Título do selectbox.
                        "Estratégia CV",
                        # Lista de opções disponíveis para seleção.
                        ["Auto (Recomendado)", "Stratified K-Fold", "K-Fold"],
                        # Define o índice da opção pré-selecionada, baseado no st.session_state ou "Auto (Recomendado)".
                        index=["Auto (Recomendado)", "Stratified K-Fold", "K-Fold"].index(st.session_state.get('cv_strategy', "Auto (Recomendado)")),
                        # Texto de ajuda para o selectbox.
                        help="Auto escolhe a melhor baseado nos dados",
                        # Chave única para este widget.
                        key="cv_strategy_select_train"
                    )
                # Inicia o bloco de código para a segunda coluna.
                with col2:
                    # Cria um campo de entrada numérico no Streamlit para permitir ao usuário definir o 'random state'.
                    random_state = st.number_input(
                        # Título do campo de entrada.
                        "Random State",
                        # Valor mínimo permitido.
                        0,
                        # Valor máximo permitido.
                        100,
                        # Valor padrão do campo de entrada, obtido do st.session_state ou 42 se não existir.
                        st.session_state.get('random_state', 42),
                        # Chave única para este widget.
                        key="random_state_input_train"
                    )
                    # Cria um checkbox no Streamlit para permitir que o usuário ative ou desative o treinamento paralelo.
                    parallel = st.checkbox(
                        # Título do checkbox.
                        "Treinamento Paralelo",
                        # Valor padrão do checkbox, obtido do st.session_state (True se não existir).
                        value=st.session_state.get('parallel', True),
                        # Texto de ajuda que aparece ao passar o mouse sobre o checkbox.
                        help="Usa todos os cores da CPU (mais rápido)",
                        # Chave única para este widget no Streamlit.
                        key="parallel_checkbox_train"
                    )

                # Atualiza o número de folds na sessão do Streamlit com o valor selecionado no slider.
                st.session_state.n_folds = n_folds
                # Atualiza a estratégia de validação cruzada na sessão do Streamlit com o valor selecionado no selectbox.
                st.session_state.cv_strategy = cv_strategy
                # Atualiza o random state na sessão do Streamlit com o valor inserido no campo numérico.
                st.session_state.random_state = random_state
                # Atualiza a configuração de treinamento paralelo na sessão do Streamlit com o valor do checkbox.
                st.session_state.parallel = parallel

            # Exibe um aviso no Streamlit informando que o treinamento testará muitos modelos e pode levar tempo.
            st.warning("⚠️ O treinamento testará **15+ modelos** e pode levar alguns minutos.")

            # Cria um botão principal no Streamlit para iniciar o treinamento completo.
            if st.button(" INICIAR TREINAMENTO COMPLETO", type="primary", key="start_training_main_btn"):
                # Se o botão for clicado, chama o método auxiliar '_execute_training' para iniciar o processo.
                self._execute_training()

        # Cria um botão para voltar à etapa de processamento de dados.
        if st.button("⬅️ Voltar para Processamento", key="back_to_process_train_2"):
            # Define a etapa atual na sessão do Streamlit para 2 (processamento).
            st.session_state.step = 2
            # Adiciona um pequeno atraso para permitir que o Streamlit processe a mudança de estado.
            time.sleep(0.1)
            # Força um novo rerun da aplicação para carregar a etapa anterior.
            st.rerun()

    # Define um método auxiliar para executar o treinamento em um container separado.
    def _execute_training(self):
        """Executa treinamento em container separado"""
        # Exibe um spinner de carregamento no Streamlit com a mensagem "Treinando 15+ modelos...".
        with st.spinner("Treinando 15+ modelos..."):
            try:
                # Recupera os dados de features (X) da sessão do Streamlit.
                X = st.session_state.X
                # Recupera os dados de target (y) da sessão do Streamlit.
                y = st.session_state.y
                # Recupera o tipo de problema (classificação/regressão) da sessão do Streamlit.
                problem_type = st.session_state.problem_type

                # Instancia a classe UltraCompleteTrainer com o tipo de problema.
                trainer = UltraCompleteTrainer(problem_type)
                # Define o número de folds para o treinador, obtendo o valor da sessão (padrão 5).
                trainer.n_folds = int(st.session_state.get('n_folds', 5))

                # Chama o método 'train_safe' do treinador para iniciar o treinamento com validação cruzada.
                # Retorna os resultados de todos os modelos e o nome do melhor modelo.
                results, best_model_name = trainer.train_safe(X, y)

                # Armazena o dicionário de resultados de todos os modelos na sessão do Streamlit.
                st.session_state.results = results
                # Armazena o objeto do treinador (com o melhor modelo e ranking) na sessão do Streamlit.
                st.session_state.trainer = trainer
                # Armazena o nome do melhor modelo na sessão do Streamlit.
                st.session_state.best_model_name = best_model_name # Correção: armazenar o nome, não o objeto do modelo aqui
                # Armazena o objeto do melhor modelo treinado (se houver) na sessão do Streamlit.
                st.session_state.best_model = trainer.best_model # Armazenar o objeto do modelo treinado

                # Exibe uma mensagem de sucesso no Streamlit indicando que o treinamento foi concluído.
                st.success("✅ Treinamento concluído!")

                # Adiciona um pequeno atraso de 1 segundo para melhorar a experiência do usuário.
                time.sleep(1)
                # Define a próxima etapa na sessão do Streamlit para 4 (resultados).
                st.session_state.step = 4
                # Força um novo rerun da aplicação para carregar a etapa de resultados.
                st.rerun()

            # Captura qualquer exceção que ocorra durante o processo de treinamento.
            except Exception as e:
                # Exibe uma mensagem de erro no Streamlit com os detalhes da exceção.
                st.error(f"❌ Erro no treinamento: {str(e)}")

    def step_results(self):
        """Resultados"""
        # Define o cabeçalho principal da seção de resultados.
        st.header(" Resultados")

        # Verifica se 'results' (resultados do treinamento) não existe na sessão do Streamlit.
        if 'results' not in st.session_state:
            # Exibe um aviso informando que não há resultados disponíveis.
            st.warning("Nenhum resultado disponível.")
            # Cria um botão para voltar à etapa de treinamento.
            if st.button("⬅️ Voltar", key="back_to_train_results"):
                # Define a etapa atual na sessão do Streamlit para 3 (treinamento).
                st.session_state.step = 3
                # Adiciona um pequeno atraso para permitir que o Streamlit processe a mudança de estado.
                time.sleep(0.1)
                # Força um novo rerun da aplicação para carregar a etapa anterior.
                st.rerun()
            # Retorna da função se não houver resultados.
            return

        try:
            # Recupera o dicionário de resultados de todos os modelos da sessão do Streamlit.
            results = st.session_state.results
            # Recupera o objeto do treinador de modelos da sessão do Streamlit.
            trainer = st.session_state.trainer
            # Recupera o tipo de problema (classificação ou regressão) da sessão do Streamlit.
            problem_type = st.session_state.problem_type

            # Obtém o nome do melhor modelo a partir do objeto 'trainer'.
            best_name = trainer.best_model_name
            # Verifica se o nome do melhor modelo existe e se ele está presente nos resultados.
            if best_name and best_name in results:
                # Obtém as métricas do melhor modelo.
                best_metrics = results[best_name]

                # Cria três colunas na interface do Streamlit para exibir métricas-chave do melhor modelo.
                col1, col2, col3 = st.columns(3)
                with col1:
                    # Exibe o nome do melhor modelo como uma métrica.
                    st.metric(" Melhor Modelo", best_name)
                with col2:
                    # Se o problema for de classificação.
                    if problem_type == 'classification':
                        # Tenta obter a acurácia ou o F1-score como métrica principal.
                        score = best_metrics.get('accuracy', best_metrics.get('f1', 0))
                    else:
                        # Se for de regressão, tenta obter o R2-score ou a variância explicada.
                        score = best_metrics.get('r2', best_metrics.get('explained_variance', 0))
                    # Exibe o score do melhor modelo, formatado com 4 casas decimais.
                    st.metric(" Score", f"{float(score):.4f}")
                with col3:
                    # Exibe o número total de modelos que foram treinados.
                    st.metric(" Modelos Treinados", len(results))

            # Cria um expansor no Streamlit para exibir o "Ranking Completo" dos modelos.
            with st.expander(" Ranking Completo"):
                # Obtém o DataFrame de ranking dos modelos a partir do objeto 'trainer'.
                ranking_df = trainer.get_ranking()
                # Cria uma cópia do DataFrame de ranking para exibição.
                ranking_display = ranking_df.copy()
                # Verifica se a coluna 'Score' existe no DataFrame de exibição.
                if 'Score' in ranking_display.columns:
                    # Formata os valores da coluna 'Score' para 4 casas decimais.
                    ranking_display['Score'] = ranking_display['Score'].map(lambda x: f"{float(x):.4f}")
                # Exibe o DataFrame de ranking formatado no Streamlit.
                st.dataframe(ranking_display, use_container_width=True)

                # Verifica se o DataFrame de ranking não está vazio.
                if not ranking_df.empty:
                    # Cria um gráfico de barras usando Plotly Express para os top 15 modelos.
                    fig = px.bar(
                        ranking_df.head(15), # Pega os 15 primeiros modelos do ranking.
                        x='Modelo', # Define o eixo X como o nome do modelo.
                        y='Score', # Define o eixo Y como o score do modelo.
                        title='Top 15 Modelos', # Título do gráfico.
                        color='Score', # Colore as barras com base no valor do score.
                        color_continuous_scale='Viridis' # Define a escala de cores contínua.
                    )
                    # Exibe o gráfico Plotly no Streamlit.
                    st.plotly_chart(fig, use_container_width=True)

            # Verifica se o melhor modelo foi armazenado na sessão e não é None.
            if 'best_model' in st.session_state and st.session_state.best_model is not None:
                # Cria um expansor para exibir "Métricas Detalhadas" de um modelo selecionado.
                with st.expander(" Métricas Detalhadas"):
                    # Obtém uma lista dos nomes de todos os modelos disponíveis nos resultados.
                    model_options = list(results.keys())
                    # Cria um selectbox para permitir ao usuário escolher um modelo para ver suas métricas detalhadas.
                    selected_model = st.selectbox(
                        "Selecione um modelo para ver métricas detalhadas:",
                        model_options,
                        key="model_select_detailed_results"
                    )

                    # Se um modelo foi selecionado e está presente nos resultados.
                    if selected_model in results:
                        # Obtém as métricas do modelo selecionado.
                        metrics = results[selected_model]

                        # Cria um layout de colunas no Streamlit (4 colunas).
                        cols = st.columns(4)
                        # Inicializa um contador de métricas.
                        metric_count = 0

                        # Itera sobre cada métrica e seu valor para o modelo selecionado.
                        for metric_name, value in metrics.items():
                            # Verifica se o valor da métrica é numérico e se não é um desvio padrão (que será exibido como delta).
                            if isinstance(value, (int, float, np.floating, np.integer)) and '_std' not in metric_name:
                                # Usa a coluna atual (baseado no resto da divisão do contador por 4).
                                with cols[metric_count % 4]:
                                    # Exibe a métrica formatada com o nome em maiúsculas e o valor com 4 casas decimais.
                                    st.metric(
                                        label=metric_name.upper(),
                                        value=f"{float(value):.4f}",
                                        # Adiciona o desvio padrão como um 'delta' (mudança) se ele existir.
                                        delta=f"± {float(metrics.get(f'{metric_name}_std', 0)):.4f}" if f'{metric_name}_std' in metrics else None
                                    )
                                # Incrementa o contador de métricas.
                                metric_count += 1

                        # Verifica se o tipo de CV (validação cruzada) está presente nas métricas.
                        if 'cv_type' in metrics:
                            # Adiciona uma linha divisória para separar as informações.
                            st.write("---")
                            # Exibe a estratégia de validação cruzada utilizada.
                            st.write(f"**Estratégia CV:** {metrics['cv_type']}")
                            # Exibe o número de folds utilizados, com 5 como valor padrão.
                            st.write(f"**Número de folds:** {metrics.get('n_folds', 5)}")
                            # Exibe o tempo médio de treinamento, formatado com 2 casas decimais.
                            st.write(f"**Tempo médio de treino:** {float(metrics.get('fit_time', 0)):.2f}s")
                            # Exibe o tempo médio de pontuação, formatado com 2 casas decimais.
                            st.write(f"**Tempo médio de score:** {float(metrics.get('score_time', 0)):.2f}s")

            # Define um subtítulo para a seção de exportação de resultados.
            st.subheader(" Exportar Resultados")

            # Cria três colunas na interface do Streamlit para os botões de exportação.
            col1, col2, col3 = st.columns(3)

            with col1:
                # Cria um botão para exportar o ranking como CSV.
                if st.button(" Exportar CSV", key="export_csv_results_btn"):
                    try:
                        # Obtém o DataFrame de ranking dos modelos.
                        ranking_df = trainer.get_ranking()
                        # Converte o DataFrame para CSV e codifica em UTF-8.
                        csv_data = ranking_df.to_csv(index=False).encode('utf-8')

                        # Cria um botão de download para o arquivo CSV.
                        st.download_button(
                            "⬇️ Baixar CSV", # Texto exibido no botão.
                            csv_data, # Dados a serem baixados.
                            f"ranking_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv", # Nome do arquivo.
                            "text/csv", # Tipo MIME do arquivo.
                            key="download_csv_results_btn" # Chave única.
                        )
                    except Exception as e:
                        # Exibe uma mensagem de erro se a exportação CSV falhar.
                        st.error(f"Erro CSV: {e}")

            with col2:
                # Cria um botão para salvar o melhor modelo.
                if st.button(" Salvar Modelo", key="save_model_results_btn"):
                    # Verifica se o objeto do melhor modelo existe.
                    if trainer.best_model is not None:
                        try:
                            # Cria o diretório 'models' se ele não existir.
                            os.makedirs('models', exist_ok=True)
                            # Gera um timestamp para o nome do arquivo.
                            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
                            # Cria o nome do arquivo do modelo, substituindo espaços no nome do modelo por underscores.
                            model_filename = f"modelo_{best_name.replace(' ', '_')}_{timestamp}.pkl"
                            # Define o caminho completo para salvar o modelo.
                            model_path = f"models/{model_filename}"

                            # Salva o melhor modelo usando joblib.
                            joblib.dump(trainer.best_model, model_path)

                            # Verifica se o arquivo do modelo foi salvo com sucesso.
                            if os.path.exists(model_path):
                                # Abre o arquivo do modelo em modo de leitura binária.
                                with open(model_path, 'rb') as f:
                                    # Lê os bytes do arquivo.
                                    model_bytes = f.read()

                                # Cria um botão de download para o arquivo do modelo.
                                st.download_button(
                                    "⬇️ Baixar Modelo", # Texto exibido no botão.
                                    model_bytes, # Dados a serem baixados.
                                    model_filename, # Nome do arquivo.
                                    "application/octet-stream", # Tipo MIME genérico para arquivos binários.
                                    key=f"download_model_{timestamp}" # Chave única.
                                )
                                # Exibe uma mensagem de sucesso.
                                st.success(f"✅ Modelo salvo: {model_filename}")
                        except Exception as e:
                            # Exibe uma mensagem de erro se o salvamento do modelo falhar.
                            st.error(f"❌ Erro ao salvar: {str(e)}")

            with col3:
                # Cria um botão para gerar um relatório (PDF ou TXT).
                if st.button(" Gerar Relatório", key="generate_report_btn"):
                    # Exibe um spinner de carregamento enquanto o relatório está sendo gerado.
                    with st.spinner("Gerando relatório..."):
                        try:
                            # Prepara um dicionário com informações do dataset para o relatório.
                            data_info = {
                                'dataset_name': 'Dataset Processado',
                                'n_samples': st.session_state.X.shape[0] if 'X' in st.session_state and hasattr(st.session_state.X, 'shape') else 'N/A', # Número de amostras.
                                'n_features': st.session_state.X.shape[1] if 'X' in st.session_state and hasattr(st.session_state.X, 'shape') and len(st.session_state.X.shape) > 1 else 'N/A', # Número de features.
                            }

                            # Chama o gerador de relatório para criar o arquivo.
                            report_path = ModularPDFReportGenerator.generate_report(
                                results, # Resultados dos modelos.
                                trainer, # Objeto do treinador.
                                problem_type, # Tipo de problema.
                                data_info # Informações do dataset.
                            )

                            # Verifica se o caminho do relatório foi retornado e se o arquivo existe.
                            if report_path and os.path.exists(report_path):
                                # Abre o arquivo do relatório em modo de leitura binária.
                                with open(report_path, 'rb') as f:
                                    # Lê os bytes do arquivo.
                                    file_bytes = f.read()

                                # Obtém a extensão do arquivo e determina o tipo MIME.
                                ext = os.path.splitext(report_path)[1].lower()
                                mime_type = "application/pdf" if ext == ".pdf" else "text/plain"

                                # Cria um botão de download para o relatório.
                                st.download_button(
                                    "⬇️ Baixar Relatório", # Texto exibido no botão.
                                    file_bytes, # Dados a serem baixados.
                                    os.path.basename(report_path), # Nome base do arquivo.
                                    mime_type, # Tipo MIME do arquivo.
                                    key="download_report_btn" # Chave única.
                                )
                            else:
                                # Exibe um aviso se o relatório não puder ser gerado.
                                st.warning("Não foi possível gerar o relatório.")
                        except Exception as e:
                            # Exibe uma mensagem de erro se a geração do relatório falhar.
                            st.error(f"❌ Erro no relatório: {str(e)}")

            # Adiciona uma linha divisória para separação visual.
            st.markdown("---")
            # Cria duas colunas para os botões de navegação, com proporções diferentes (1 para o primeiro, 3 para o segundo).
            col1, col2 = st.columns([1, 3])

            with col1:
                # Cria um botão para voltar à etapa de treinamento.
                if st.button("⬅️ Voltar", key="back_to_train_final"):
                    # Define a etapa atual na sessão do Streamlit como 3 (treinamento).
                    st.session_state.step = 3
                    # Adiciona um pequeno atraso.
                    time.sleep(0.1)
                    # Força um rerun da aplicação.
                    st.rerun()

            with col2:
                # Cria um botão para iniciar um novo dataset.
                if st.button(" Novo Dataset", type="primary", key="new_dataset_btn"):
                    # Define uma lista de chaves de estado relacionadas ao treinamento e dados.
                    training_keys = ['results', 'trainer', 'best_model', 'processed', 'X', 'y',
                                     'problem_type', 'auto_detected', 'target_col', 'data']
                    # Itera sobre as chaves e as deleta da sessão do Streamlit se existirem.
                    for key in training_keys:
                        if key in st.session_state:
                            del st.session_state[key]

                    # Define a etapa atual como 1 (upload).
                    st.session_state.step = 1
                    # Adiciona um pequeno atraso.
                    time.sleep(0.2)
                    # Força um rerun da aplicação para a primeira etapa.
                    st.rerun()

        except Exception as e:
            # Captura qualquer exceção que ocorra na etapa de resultados.
            st.error(f"❌ Erro nos resultados: {str(e)}")
            # Cria um botão para reiniciar a aplicação em caso de erro.
            if st.button(" Reiniciar Aplicação", key="restart_app_results"):
                # Itera sobre todas as chaves na sessão e as deleta.
                for key in list(st.session_state.keys()):
                    del st.session_state[key]
                # Força um rerun da aplicação.
                st.rerun()

    def _clear_state(self):
        """Limpa estado de forma segura"""
        # Define uma lista de chaves do st.session_state que devem ser preservadas entre reruns.
        keys_to_preserve = ['app_initialized', 'last_rerun', 'n_folds', 'cv_strategy', 'random_state', 'parallel']
        # Identifica todas as chaves na sessão que não estão na lista de preservação.
        keys_to_remove = [k for k in st.session_state.keys() if k not in keys_to_preserve]

        # Itera sobre as chaves a serem removidas e as deleta da sessão.
        for key in keys_to_remove:
            del st.session_state[key]

    def _clear_training_state(self):
        """Limpa apenas estado de treinamento"""
        # Define uma lista de chaves de estado especificamente relacionadas ao processo de treinamento.
        training_keys = ['results', 'trainer', 'best_model', 'processed', 'X', 'y']
        # Itera sobre essas chaves.
        for key in training_keys:
            # Se a chave existe na sessão, ela é deletada.
            if key in st.session_state:
                del st.session_state[key]

    def reset_app(self):
        """Reinicia aplicação completamente"""
        # Itera sobre todas as chaves presentes no st.session_state.
        for key in list(st.session_state.keys()):
            # Deleta cada chave do st.session_state, limpando completamente o estado da sessão.
            del st.session_state[key]
        # Força um novo rerun da aplicação, que iniciará do zero.
        st.rerun()

        # ========== EXECUÇÃO DA APLICAÇÃO ==========
def main():
    app = UltraRobustApp()
    app.run()

if __name__ == "__main__":
    main()

