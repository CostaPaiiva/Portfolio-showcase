import streamlit as st
import pandas as pd
import numpy as np
import plotly.express as px
import plotly.graph_objects as go
import time
import joblib
from datetime import datetime
import os
from data_processing import PowerfulDataProcessor
from model_training import UltraCompleteTrainer
from report_generator import PDFReportGenerator as ModularPDFReportGenerator
import warnings
warnings.filterwarnings('ignore')


st.set_page_config(
    page_title="AutoML",
    page_icon="A",
    layout="wide"
)

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

class TargetDetector:
    """Detecta automaticamente a coluna target"""

    @staticmethod
    def detect_target(data, user_hint=None):
        """
        Detecta a coluna target automaticamente com inteligncia
        Retorna: (target_col, X, y, confidence_score, problem_type)
        """
        # Se houver uma dica explcita, ela tem prioridade sobre a heurstica.
        if user_hint and user_hint in data.columns:
            X = data.drop(columns=[user_hint]).copy()
            y = data[user_hint].copy()
            problem_type = TargetDetector.detect_problem_type(y)
            return user_hint, X, y, 1.0, problem_type

        # Sem dica, avalia todas as colunas e monta um ranking de probabilidade.
        st.info(" Analisando dataset para detectar target automaticamente...")

        scores = {}

        for col in data.columns:
            score = TargetDetector.analyze_column(data[col], col)
            scores[col] = score

        sorted_scores = sorted(scores.items(), key=lambda x: x[1], reverse=True)

        st.write(" **Anlise automtica:**")
        analysis_df = pd.DataFrame(sorted_scores, columns=['Coluna', 'Score Target'])

        col1, col2 = st.columns(2)
        with col1:
            st.dataframe(analysis_df.head(10), use_container_width=True)

        with col2:
            if len(sorted_scores) > 0:
                top_col = sorted_scores[0][0]
            try:
                fig = px.histogram(data, x=top_col, title=f"Distribuio: {top_col}")
                st.plotly_chart(fig, use_container_width=True)
            except Exception:
                st.write(f"*No foi possvel criar grfico para {top_col}*")

        top_candidates = [col for col, score in sorted_scores[:3] if score > 0.3]

        if not top_candidates:
            st.warning(" No consegui detectar target automaticamente.")
            target_col = data.columns[-1]
            confidence = 0.1
        else:
            # Mostra os candidatos mais fortes para confirmao manual.
            st.write(" **Candidatos a target (escolha ou confirme):**")
            target_col = st.selectbox(
            "Selecione a coluna target:",
            options=top_candidates + [" Nenhuma das acima"],                                         
            index=0,                                       
            key="auto_target_select"                                        
            )

            if target_col == " Nenhuma das acima":
                target_col = st.selectbox(
                    "Selecione manualmente:",
                    options=data.columns.tolist(),                                               
                    index=len(data.columns) - 1,                                        
                    key="manual_fallback_select"                                        
                )
                confidence = 0.5                                                        
            else:
                confidence = scores[target_col]                                                              

        X = data.drop(columns=[target_col]).copy()
        y = data[target_col].copy()

        problem_type = TargetDetector.detect_problem_type(y)

        st.success(f" Target detectado: **{target_col}** (confiana: {confidence:.2f})")
        st.success(f" Tipo de problema: **{problem_type.upper()}**")
        st.write(f" Dimenses: X={X.shape}, y={y.shape}")

        return target_col, X, y, confidence, problem_type

    @staticmethod
    def analyze_column(column, col_name):
        """Analisa uma coluna e retorna score de ser target"""
        score = 0                                       

        try:
            # Heurstica simples: cardinalidade, nome, entropia, nulos e padres de ID/data.
            n_unique = column.nunique()                                                  
            n_total = len(column)                                                 
            unique_ratio = n_unique / n_total if n_total > 0 else 0                                            

            if n_unique <= 10:                                                                                         
                score += 0.3                         
            elif unique_ratio > 0.9:                                                                                                      
                score += 0.2                         

            target_keywords = ['target', 'label', 'class', 'score', 'rating',
                               'price', 'value', 'output', 'result', 'y']                                                    
            col_lower = col_name.lower()                                              
            if any(keyword in col_lower for keyword in target_keywords):                                                            
                score += 0.4                                                        

            if n_unique > 1:                                     
                value_counts = column.value_counts(normalize=True)                                                             
                try:
                    entropy = -sum(p * np.log(p) for p in value_counts if p > 0)                                
                    max_entropy = np.log(n_unique)                                                                          
                    if max_entropy > 0:                           
                        normalized_entropy = entropy / max_entropy                        
                        if normalized_entropy < 0.7:                                                                                        
                            score += 0.2                         
                except Exception:
                    pass                                        

            if pd.api.types.is_numeric_dtype(column):                                             
                try:
                    if column.abs().max() > 1000:                                                                 
                        score += 0.1                         
                except Exception:
                    pass                                             

            missing_ratio = column.isna().sum() / n_total if n_total > 0 else 0                                             
            if missing_ratio > 0.3:                                                                                      
                score -= 0.3                        

            if any(x in col_lower for x in ['id', 'code', 'num', 'index', 'key']):                                           
                score -= 0.4                                        

            if n_unique == n_total and n_total > 100:                                                                                     
                score -= 0.5                                      

            date_keywords = ['date', 'time', 'day', 'month', 'year']                                           
            if any(x in col_lower for x in date_keywords):                                                               
                score -= 0.3                                                     

            score = max(0, min(1, score))                                          

        except Exception:
            score = 0                                                   

        return round(score, 3)                                                     

    @staticmethod
    def detect_problem_type(y):
        """Detecta se  classificao ou regresso de forma robusta"""
        try:
            # Inferncia conservadora para classificar problema em regresso ou classificao.
            y_numeric = pd.to_numeric(y, errors='coerce')
            not_na = y_numeric.notna().sum()

            if not_na / len(y) < 0.8:
                return 'classification'

            y_clean = y_numeric.dropna()
            if len(y_clean) == 0:
                return 'classification'

            unique_vals = len(y_clean.unique())

            if unique_vals <= 5:
                try:
                    if all(y_clean.astype(int) == y_clean):
                        return 'classification'                                                                               
                    else:
                        return 'regression'                                                                            
                except Exception:
                    return 'classification'                                                                                

            elif unique_vals <= 20:
                value_counts = y_clean.value_counts(normalize=True)
                if (value_counts > 0.25).any():
                    try:
                        if all(y_clean.astype(int) == y_clean):
                            return 'classification'                          
                        else:
                            return 'regression'                     
                    except Exception:
                        return 'classification'                                           
                else:
                    return 'regression'                                      
            else:
                return 'regression'

        except Exception:
            try:
                if hasattr(y, 'dtype'):
                    if y.dtype == 'object' or len(y.unique()) <= 10:
                        return 'classification'                           
                    else:
                        return 'regression'                                       
                else:
                    unique_vals = len(np.unique(y))
                    if unique_vals <= 10:
                        return 'classification'                           
                    else:
                        return 'regression'                                       
            except Exception:
                return 'regression'                                                          

class UltraRobustApp:
    def __init__(self):
        # Estado global da sesso  inicializado apenas uma vez.
        if 'app_initialized' not in st.session_state:
            st.session_state.app_initialized = True
            st.session_state.step = 1
            st.session_state.data = None
            st.session_state.processed = False
            st.session_state.processor_type = "POWERFULL"
            st.session_state.trainer_type = "ULTRA_COMPLETE"
            st.session_state.last_rerun = time.time()
            st.session_state.n_folds = 5
            st.session_state.cv_strategy = "Auto (Recomendado)"
            st.session_state.random_state = 42
            st.session_state.parallel = True

    def safe_rerun(self, delay=0.1):
        """Rerun seguro com delay"""
        # Evita reruns muito prximos que podem causar comportamento instvel.
        current_time = time.time()
        if current_time - st.session_state.last_rerun > 0.5:
            time.sleep(delay)
            st.session_state.last_rerun = current_time
            try:
                st.rerun()
            except Exception:
                st.rerun()
        else:
            time.sleep(0.5)
            st.rerun()


    def run(self):
        """Executa a aplicao com tratamento de erros"""
        try:
            # Entrada principal do app.
            st.title(" AutoML")
            st.markdown("""
            <div class='cv-badge'>OK - VALIDACAO CRUZADA ATIVADA</div>
            Sistema profissional com validacao cruzada e 30+ modelos!
            """, unsafe_allow_html=True)

            self.show_progress()

            try:
                # Roteia para a etapa corrente do fluxo.
                if st.session_state.step == 1:
                    self.step_upload()
                elif st.session_state.step == 2:
                    self.step_process()
                elif st.session_state.step == 3:
                    self.step_train()
                elif st.session_state.step == 4:
                    self.step_results()
            except Exception as e:
                # Erro isolado da etapa atual.
                st.error(f" Erro na etapa {st.session_state.step}: {str(e)}")
                if st.button(" Reiniciar Aplicao", key="restart_app_error"):
                    self.reset_app()

        except Exception as e:
            # Fallback final para falhas inesperadas fora do fluxo normal.
            st.error(f" Erro crtico: {str(e)}")
            st.info("Recarregue a pgina para tentar novamente.")

    def show_progress(self):
        """Barra de progresso simples"""
        # Indicador visual das quatro etapas do pipeline.
        steps = ["Upload", "Processar", "Treinar", "Resultados"]
        current = st.session_state.step - 1

        html = """
        <div style="display: flex; justify-content: space-between; margin: 20px 0;">
        """

        for i, step in enumerate(steps):
            if i < current:
                html += f'<div style="padding: 10px; background: #4CAF50; color: white; border-radius: 5px; text-align: center; flex: 1; margin: 0 5px;">{step} OK</div>'
            elif i == current:
                html += f'<div style="padding: 10px; background: #2196F3; color: white; border-radius: 5px; text-align: center; flex: 1; margin: 0 5px;">{step}</div>'
            else:
                html += f'<div style="padding: 10px; background: #f0f0f0; color: #666; border-radius: 5px; text-align: center; flex: 1; margin: 0 5px;">{step}</div>'

        html += "</div>"
        st.markdown(html, unsafe_allow_html=True)

    def step_upload(self):
        """Upload do dataset SIMPLIFICADO para evitar erro do Streamlit"""
        # Etapa 1: carregar os dados e definir o target.
        st.header(" Upload do Dataset")

        with st.container():
            uploaded_file = st.file_uploader(
                "Escolha um arquivo CSV",
                type=['csv', 'txt', 'xlsx'],
                help="Suporta CSV, TXT e Excel",
                key="main_file_uploader"
            )

        if uploaded_file:
            try:
                if uploaded_file.name.endswith('.csv') or uploaded_file.name.endswith('.txt'):
                    data = pd.read_csv(uploaded_file)
                elif uploaded_file.name.endswith('.xlsx'):
                    data = pd.read_excel(uploaded_file)
                else:
                    data = pd.read_csv(uploaded_file)

                st.success(f" Dataset carregado: {data.shape[0]} linhas  {data.shape[1]} colunas")

                if st.checkbox(" Visualizar dados", key="show_preview_upload"):
                    st.dataframe(data.head(), use_container_width=True)

                st.subheader(" Seleo do Target")

                use_auto = st.checkbox(" Usar deteco automtica", value=True, key="use_auto_detect")

                if use_auto:
                    try:
                        # Tenta uma definio automtica do target.
                        target_col, X, y, confidence, problem_type = TargetDetector.detect_target(data)

                        col1, col2 = st.columns(2)
                        with col1:
                            st.metric(" Target", target_col)
                        with col2:
                            st.metric(" Tipo", problem_type.upper())

                        st.session_state.target_col = target_col
                        st.session_state.X = X
                        st.session_state.y = y
                        st.session_state.problem_type = problem_type
                        st.session_state.auto_detected = True
                        st.session_state.data = data

                        st.success(" Target detectado automaticamente!")

                    except Exception as e:
                        st.error(f" Deteco automtica falhou: {str(e)}")
                        st.info("Por favor, selecione manualmente:")
                        use_auto = False

                if not use_auto or not st.session_state.get('auto_detected', False):
                    # Fallback manual caso a deteco automtica no seja suficiente.
                    target_options = data.columns.tolist()
                    default_idx = len(target_options) - 1

                    for i, col in enumerate(target_options):
                        col_lower = col.lower()
                        if any(kw in col_lower for kw in ['target', 'label', 'class', 'y', 'price', 'value']):
                            default_idx = i
                            break

                    target_col = st.selectbox(
                        "Selecione a coluna target:",
                        target_options,
                        index=default_idx,
                        key="manual_target_selector_upload"
                    )

                    X = data.drop(columns=[target_col]).copy()
                    y = data[target_col].copy()

                    try:
                        problem_type = TargetDetector.detect_problem_type(y)
                    except Exception:
                        if y.dtype == 'object' or len(y.unique()) <= 10:
                            problem_type = 'classification'
                        else:
                            problem_type = 'regression'

                    st.session_state.target_col = target_col
                    st.session_state.X = X
                    st.session_state.y = y
                    st.session_state.problem_type = problem_type
                    st.session_state.auto_detected = False
                    st.session_state.data = data

                    st.success(f" Target selecionado: {target_col}")
                    st.success(f" Tipo: {problem_type.upper()}")

                st.markdown("---")

                col1, col2 = st.columns(2)
                with col1:
                    if st.button(" Novo Upload", type="secondary", key="new_upload_simple_btn"):
                        keys_to_keep = ['app_initialized', 'last_rerun', 'n_folds', 'cv_strategy', 'random_state', 'parallel']
                        keys_to_remove = [k for k in st.session_state.keys() if k not in keys_to_keep]
                        for key in keys_to_remove:
                            del st.session_state[key]
                        time.sleep(0.5)
                        st.rerun()

                with col2:
                    if st.button(" Continuar ", type="primary", key="continue_upload_btn"):
                        if 'target_col' not in st.session_state:
                            st.error(" Selecione um target primeiro!")
                        else:
                            if len(st.session_state.X) < 10:
                                st.error(" Muito poucas amostras (mnimo 10)")
                            else:
                                st.session_state.step = 2
                                time.sleep(0.5)
                                st.rerun()

            except Exception as e:
                # Encaminha para leitura alternativa quando o parser padro falhar.
                st.error(f" Erro ao processar arquivo: {str(e)}")

                try:
                    uploaded_file.seek(0)                                              
                    data = pd.read_csv(uploaded_file, encoding='latin-1')
                    st.success(" Carregado com encoding alternativo")
                    st.session_state.data = data
                    st.rerun()
                except Exception:
                    st.error(" No foi possvel ler o arquivo.")

                    X = data.drop(columns=[target_col]).copy()
                    y = data[target_col].copy()

                    try:
                        problem_type = TargetDetector.detect_problem_type(y)
                    except Exception:
                        if y.dtype == 'object' or len(y.unique()) <= 10:
                            problem_type = 'classification'
                        else:
                            problem_type = 'regression'

                    st.session_state.target_col = target_col
                    st.session_state.X = X
                    st.session_state.y = y
                    st.session_state.problem_type = problem_type
                    st.session_state.auto_detected = False
                    st.session_state.data = data

                    st.success(f" Target selecionado: {target_col}")
                    st.success(f" Tipo: {problem_type.upper()}")

                st.markdown("---")

                col1, col2 = st.columns(2)
                with col1:
                    if st.button(" Novo Upload", type="secondary", key="new_upload_simple_btn"):
                        keys_to_keep = ['app_initialized', 'last_rerun', 'n_folds', 'cv_strategy', 'random_state', 'parallel']
                        keys_to_remove = [k for k in st.session_state.keys() if k not in keys_to_keep]
                        for key in keys_to_remove:
                            del st.session_state[key]
                        time.sleep(0.5)
                        st.rerun()

                with col2:
                    if st.button(" Continuar ", type="primary", key="continue_upload_btn"):
                        if 'target_col' not in st.session_state:
                            st.error(" Selecione um target primeiro!")
                        else:
                            if len(st.session_state.X) < 10:
                                st.error(" Muito poucas amostras (mnimo 10)")
                            else:
                                st.session_state.step = 2
                                time.sleep(0.5)
                                st.rerun()

            except Exception as e:
                st.error(f" Erro ao processar arquivo: {str(e)}")

                try:
                    uploaded_file.seek(0)
                    data = pd.read_csv(uploaded_file, encoding='latin-1')
                    st.success(" Carregado com encoding alternativo")
                    st.session_state.data = data
                    st.rerun()
                except Exception:
                    st.error(" No foi possvel ler o arquivo.")

    def step_process(self):
        """Processamento SIMPLIFICADO"""
        # Etapa 2: preparao dos dados antes do treino.
        st.header(" Processamento de Dados")

        if 'data' not in st.session_state or st.session_state.data is None:
            st.warning(" Nenhum dataset carregado.")
            if st.button(" Voltar para Upload", key="back_to_upload_process"):
                st.session_state.step = 1
                time.sleep(0.5)
                st.rerun()
            return

        col1, col2, col3 = st.columns(3)
        with col1:
            st.metric("Amostras", st.session_state.data.shape[0])
        with col2:
            st.metric("Features", st.session_state.data.shape[1] - 1)
        with col3:
            st.metric("Target", st.session_state.target_col)

        if st.button("Treinamento", type="primary", key="process_execute_btn"):
            with st.spinner("Processando dados..."):
                try:
                    # Usa o mdulo centralizado de processamento.
                    processor = PowerfulDataProcessor()

                    X, y, problem_type = processor.process(
                        st.session_state.data,
                        st.session_state.target_col
                    )

                    st.session_state.X = X
                    st.session_state.y = y
                    st.session_state.problem_type = problem_type
                    st.session_state.processed = True

                    # Mostra um resumo rpido do que foi produzido.
                    st.success(" Processamento concludo!")

                    with st.expander(" Resultados do Processamento"):
                        col1, col2 = st.columns(2)
                        with col1:
                            st.write("**Features (X):**")
                            st.write(f"- Dimenses: {X.shape}")
                            st.write(f"- Tipo: {type(X)}")
                        with col2:
                            st.write("**Target (y):**")
                            st.write(f"- Dimenses: {y.shape}")
                            st.write(f"- Tipo: {problem_type.upper()}")
                            if problem_type == 'classification':
                                st.write(f"- Classes: {len(np.unique(y))}")

                    time.sleep(1)

                except Exception as e:
                    # Se o processamento avanado falhar, tenta um fallback mnimo.
                    st.error(f" Erro no processamento: {str(e)}")
                    try:
                        X = st.session_state.data.drop(columns=[st.session_state.target_col]).values
                        y = st.session_state.data[st.session_state.target_col].values

                        st.session_state.X = X
                        st.session_state.y = y
                        st.session_state.processed = True

                        st.success(" Processamento simples realizado")
                    except Exception:
                        st.error(" No foi possvel processar os dados.")

        if st.session_state.get('processed', False):
            st.markdown("---")
            if st.button(" Ir para Treinamento ", type="primary", key="go_to_train_btn"):
                st.session_state.step = 3
                time.sleep(0.5)
                st.rerun()

        if st.button(" Voltar", key="back_from_process_btn"):
            st.session_state.step = 1
            time.sleep(0.5)
            st.rerun()

    def step_train(self):
        """Treinamento com fix"""
        # Etapa 3: configuraes e execuo do treino.
        st.header(" Treinamento com VALIDAO CRUZADA")

        if not st.session_state.get('processed', False):
            st.warning("Dados no processados.")
            if st.button(" Voltar", key="back_to_process_train"):
                st.session_state.step = 2
                time.sleep(0.1)
                st.rerun()
            return

        with st.expander(" Estatsticas do Dataset"):
            col1, col2, col3, col4 = st.columns(4)
            with col1:
                st.metric("Amostras", len(st.session_state.X))
            with col2:
                st.metric("Features", st.session_state.X.shape[1] if hasattr(st.session_state.X, "shape") else 0)
            with col3:
                if st.session_state.problem_type == 'classification':
                    unique_classes = len(np.unique(st.session_state.y))
                    st.metric("Classes", unique_classes)
                else:
                    st.metric("Target Mdia", f"{np.mean(st.session_state.y):.2f}")
            with col4:
                if st.session_state.problem_type == 'regression':
                    st.metric("Target Std", f"{np.std(st.session_state.y):.2f}")
                else:
                    class_dist = pd.Series(st.session_state.y).value_counts().iloc[0] / len(st.session_state.y) * 100
                    st.metric("Classe Majoritria", f"{class_dist:.1f}%")

        with st.container():
            st.info(" **VALIDAO CRUZADA ATIVADA**")

            with st.expander(" Configuraes da Validao Cruzada"):
                # Ajustes do treino sem sair da interface.
                col1, col2 = st.columns(2)
                with col1:
                    n_folds = st.slider(
                        "Nmero de folds",
                        3,
                        10,
                        st.session_state.get('n_folds', 5),
                        help="Mais folds = mais robusto, mas mais lento",
                        key="n_folds_slider_train"
                    )
                    cv_strategy = st.selectbox(
                        "Estratgia CV",
                        ["Auto (Recomendado)", "Stratified K-Fold", "K-Fold"],
                        index=["Auto (Recomendado)", "Stratified K-Fold", "K-Fold"].index(st.session_state.get('cv_strategy', "Auto (Recomendado)")),
                        help="Auto escolhe a melhor baseado nos dados",
                        key="cv_strategy_select_train"
                    )
                with col2:
                    random_state = st.number_input(
                        "Random State",
                        0,
                        100,
                        st.session_state.get('random_state', 42),
                        key="random_state_input_train"
                    )
                    parallel = st.checkbox(
                        "Treinamento Paralelo",
                        value=st.session_state.get('parallel', True),
                        help="Usa todos os cores da CPU (mais rpido)",
                        key="parallel_checkbox_train"
                    )

                st.session_state.n_folds = n_folds
                st.session_state.cv_strategy = cv_strategy
                st.session_state.random_state = random_state
                st.session_state.parallel = parallel

            st.warning(" O treinamento testar **15+ modelos** e pode levar alguns minutos.")

            if st.button(" INICIAR TREINAMENTO COMPLETO", type="primary", key="start_training_main_btn"):
                # Dispara o treino com os parmetros da sesso.
                self._execute_training()

        if st.button(" Voltar para Processamento", key="back_to_process_train_2"):
            st.session_state.step = 2
            time.sleep(0.1)
            st.rerun()

    def _execute_training(self):
        """Executa treinamento em container separado"""
        with st.spinner("Treinando 15+ modelos..."):
            try:
                # Recupera o conjunto j processado da sesso.
                X = st.session_state.X
                y = st.session_state.y
                problem_type = st.session_state.problem_type

                trainer = UltraCompleteTrainer(problem_type)
                trainer.n_folds = int(st.session_state.get('n_folds', 5))

                # Executa o ranking e seleciona o melhor modelo.
                results, best_model_name = trainer.train_safe(X, y)

                st.session_state.results = results
                st.session_state.trainer = trainer
                st.session_state.best_model_name = best_model_name
                st.session_state.best_model = trainer.best_model

                # Avana para a tela final aps o treino concluir.
                st.success(" Treinamento concludo!")

                time.sleep(1)
                st.session_state.step = 4
                st.rerun()

            except Exception as e:
                st.error(f" Erro no treinamento: {str(e)}")

    def step_results(self):
        """Resultados"""
        # Etapa 4: resumo, ranking e exportaes.
        st.header(" Resultados")

        if 'results' not in st.session_state:
            st.warning("Nenhum resultado disponvel.")
            if st.button(" Voltar", key="back_to_train_results"):
                st.session_state.step = 3
                time.sleep(0.1)
                st.rerun()
            return

        try:
            results = st.session_state.results
            trainer = st.session_state.trainer
            problem_type = st.session_state.problem_type

            best_name = trainer.best_model_name
            if best_name and best_name in results:
                best_metrics = results[best_name]

                # Resumo visual do modelo vencedor.
                col1, col2, col3 = st.columns(3)
                with col1:
                    st.metric(" Melhor Modelo", best_name)
                with col2:
                    if problem_type == 'classification':
                        score = best_metrics.get('accuracy', best_metrics.get('f1', 0))
                    else:
                        score = best_metrics.get('r2', best_metrics.get('explained_variance', 0))
                    st.metric(" Score", f"{float(score):.4f}")
                with col3:
                    st.metric(" Modelos Treinados", len(results))

            with st.expander(" Ranking Completo"):
                # Tabela consolidada e grfico dos melhores modelos.
                ranking_df = trainer.get_ranking()
                ranking_display = ranking_df.copy()
                if 'Score' in ranking_display.columns:
                    ranking_display['Score'] = ranking_display['Score'].map(lambda x: f"{float(x):.4f}")
                st.dataframe(ranking_display, use_container_width=True)

                if not ranking_df.empty:
                    fig = px.bar(
                        ranking_df.head(15),                                           
                        x='Modelo',                                         
                        y='Score',                                          
                        title='Top 15 Modelos',                       
                        color='Score',                                               
                        color_continuous_scale='Viridis'                                      
                    )
                    st.plotly_chart(fig, use_container_width=True)

            if 'best_model' in st.session_state and st.session_state.best_model is not None:
                with st.expander(" Mtricas Detalhadas"):
                    # Permite inspecionar qualquer modelo sem poluir a tela principal.
                    model_options = list(results.keys())
                    selected_model = st.selectbox(
                        "Selecione um modelo para ver mtricas detalhadas:",
                        model_options,
                        key="model_select_detailed_results"
                    )

                    if selected_model in results:
                        metrics = results[selected_model]

                        cols = st.columns(4)
                        metric_count = 0

                        for metric_name, value in metrics.items():
                            if isinstance(value, (int, float, np.floating, np.integer)) and '_std' not in metric_name:
                                with cols[metric_count % 4]:
                                    st.metric(
                                        label=metric_name.upper(),
                                        value=f"{float(value):.4f}",
                                        delta=f" {float(metrics.get(f'{metric_name}_std', 0)):.4f}" if f'{metric_name}_std' in metrics else None
                                    )
                                metric_count += 1

                        if 'cv_type' in metrics:
                            st.write("---")
                            st.write(f"**Estratgia CV:** {metrics['cv_type']}")
                            st.write(f"**Nmero de folds:** {metrics.get('n_folds', 5)}")
                            st.write(f"**Tempo mdio de treino:** {float(metrics.get('fit_time', 0)):.2f}s")
                            st.write(f"**Tempo mdio de score:** {float(metrics.get('score_time', 0)):.2f}s")

            st.subheader(" Exportar Resultados")

            col1, col2, col3 = st.columns(3)

            with col1:
                # Exporta o ranking em CSV.
                if st.button(" Exportar CSV", key="export_csv_results_btn"):
                    try:
                        ranking_df = trainer.get_ranking()
                        csv_data = ranking_df.to_csv(index=False).encode('utf-8')

                        st.download_button(
                            " Baixar CSV",                           
                            csv_data,                          
                            f"ranking_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv",                   
                            "text/csv",                        
                            key="download_csv_results_btn"                
                        )
                    except Exception as e:
                        st.error(f"Erro CSV: {e}")

            with col2:
                # Salva o melhor modelo em disco e expe download.
                if st.button(" Salvar Modelo", key="save_model_results_btn"):
                    if trainer.best_model is not None:
                        try:
                            os.makedirs('models', exist_ok=True)
                            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
                            model_filename = f"modelo_{best_name.replace(' ', '_')}_{timestamp}.pkl"
                            model_path = f"models/{model_filename}"

                            joblib.dump(trainer.best_model, model_path)

                            if os.path.exists(model_path):
                                with open(model_path, 'rb') as f:
                                    model_bytes = f.read()

                                st.download_button(
                                    " Baixar Modelo",                           
                                    model_bytes,                          
                                    model_filename,                   
                                    "application/octet-stream",                                               
                                    key=f"download_model_{timestamp}"                
                                )
                                st.success(f" Modelo salvo: {model_filename}")
                        except Exception as e:
                            st.error(f" Erro ao salvar: {str(e)}")

            with col3:
                # Gera o relatrio consolidado no mdulo centralizado.
                if st.button(" Gerar Relatrio", key="generate_report_btn"):
                    with st.spinner("Gerando relatrio..."):
                        try:
                            data_info = {
                                'dataset_name': 'Dataset Processado',
                                'n_samples': st.session_state.X.shape[0] if 'X' in st.session_state and hasattr(st.session_state.X, 'shape') else 'N/A',                       
                                'n_features': st.session_state.X.shape[1] if 'X' in st.session_state and hasattr(st.session_state.X, 'shape') and len(st.session_state.X.shape) > 1 else 'N/A',                       
                            }

                            report_path = ModularPDFReportGenerator.generate_report(
                                results,                          
                                trainer,                       
                                problem_type,                    
                                data_info                            
                            )

                            if report_path and os.path.exists(report_path):
                                with open(report_path, 'rb') as f:
                                    file_bytes = f.read()

                                ext = os.path.splitext(report_path)[1].lower()
                                mime_type = "application/pdf" if ext == ".pdf" else "text/plain"

                                st.download_button(
                                    " Baixar Relatrio",                           
                                    file_bytes,                          
                                    os.path.basename(report_path),                        
                                    mime_type,                        
                                    key="download_report_btn"                
                                )
                            else:
                                st.warning("No foi possvel gerar o relatrio.")
                        except Exception as e:
                            st.error(f" Erro no relatrio: {str(e)}")

            st.markdown("---")
            col1, col2 = st.columns([1, 3])

            with col1:
                if st.button(" Voltar", key="back_to_train_final"):
                    st.session_state.step = 3
                    time.sleep(0.1)
                    st.rerun()

            with col2:
                if st.button(" Novo Dataset", type="primary", key="new_dataset_btn"):
                    training_keys = ['results', 'trainer', 'best_model', 'processed', 'X', 'y',
                                     'problem_type', 'auto_detected', 'target_col', 'data']
                    for key in training_keys:
                        if key in st.session_state:
                            del st.session_state[key]

                    st.session_state.step = 1
                    time.sleep(0.2)
                    st.rerun()

        except Exception as e:
            st.error(f" Erro nos resultados: {str(e)}")
            if st.button(" Reiniciar Aplicao", key="restart_app_results"):
                for key in list(st.session_state.keys()):
                    del st.session_state[key]
                st.rerun()

    def _clear_state(self):
        """Limpa estado de forma segura"""
        # Preserva apenas o estado global do app.
        keys_to_preserve = ['app_initialized', 'last_rerun', 'n_folds', 'cv_strategy', 'random_state', 'parallel']
        keys_to_remove = [k for k in st.session_state.keys() if k not in keys_to_preserve]

        for key in keys_to_remove:
            del st.session_state[key]

    def _clear_training_state(self):
        """Limpa apenas estado de treinamento"""
        # Remove apenas os artefatos da etapa de treino.
        training_keys = ['results', 'trainer', 'best_model', 'processed', 'X', 'y']
        for key in training_keys:
            if key in st.session_state:
                del st.session_state[key]

    def reset_app(self):
        """Reinicia aplicao completamente"""
        # Limpeza total para reiniciar o fluxo do zero.
        for key in list(st.session_state.keys()):
            del st.session_state[key]
        st.rerun()

def main():
    app = UltraRobustApp()
    app.run()

if __name__ == "__main__":
    main()



