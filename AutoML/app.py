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
    page_icon="ðŸ¤–",
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
        Detecta a coluna target automaticamente com inteligÃªncia
        Retorna: (target_col, X, y, confidence_score, problem_type)
        """
        if user_hint and user_hint in data.columns:
            X = data.drop(columns=[user_hint]).copy()
            y = data[user_hint].copy()
            problem_type = TargetDetector.detect_problem_type(y)
            return user_hint, X, y, 1.0, problem_type

        st.info("ðŸ” Analisando dataset para detectar target automaticamente...")

        scores = {}

        for col in data.columns:
            score = TargetDetector.analyze_column(data[col], col)
            scores[col] = score

        sorted_scores = sorted(scores.items(), key=lambda x: x[1], reverse=True)

        st.write("ðŸ“Š **AnÃ¡lise automÃ¡tica:**")
        analysis_df = pd.DataFrame(sorted_scores, columns=['Coluna', 'Score Target'])

        col1, col2 = st.columns(2)
        with col1:
            st.dataframe(analysis_df.head(10), use_container_width=True)

        with col2:
            if len(sorted_scores) > 0:
                top_col = sorted_scores[0][0]
            try:
                fig = px.histogram(data, x=top_col, title=f"DistribuiÃ§Ã£o: {top_col}")
                st.plotly_chart(fig, use_container_width=True)
            except Exception:
                st.write(f"*NÃ£o foi possÃ­vel criar grÃ¡fico para {top_col}*")

        top_candidates = [col for col, score in sorted_scores[:3] if score > 0.3]

        if not top_candidates:
            st.warning("âš ï¸ NÃ£o consegui detectar target automaticamente.")
            target_col = data.columns[-1]
            confidence = 0.1
        else:
            st.write("ðŸŽ¯ **Candidatos a target (escolha ou confirme):**")
            target_col = st.selectbox(
            "Selecione a coluna target:",
            options=top_candidates + ["âš ï¸ Nenhuma das acima"],                                         
            index=0,                                       
            key="auto_target_select"                                        
            )

            if target_col == "âš ï¸ Nenhuma das acima":
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

        st.success(f"âœ… Target detectado: **{target_col}** (confianÃ§a: {confidence:.2f})")
        st.success(f"ðŸ“Š Tipo de problema: **{problem_type.upper()}**")
        st.write(f"ðŸ“ DimensÃµes: X={X.shape}, y={y.shape}")

        return target_col, X, y, confidence, problem_type

    @staticmethod
    def analyze_column(column, col_name):
        """Analisa uma coluna e retorna score de ser target"""
        score = 0                                       

        try:
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
        """Detecta se Ã© classificaÃ§Ã£o ou regressÃ£o de forma robusta"""
        try:
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
        """Executa a aplicaÃ§Ã£o com tratamento de erros"""
        try:
            st.title("ðŸ¤– AutoML")
            st.markdown("""
            <div class='cv-badge'>âœ… VALIDAÃ‡ÃƒO CRUZADA ATIVADA</div>
            Sistema profissional com **validaÃ§Ã£o cruzada** e **30+ modelos**!
            """, unsafe_allow_html=True)

            self.show_progress()

            try:
                if st.session_state.step == 1:
                    self.step_upload()
                elif st.session_state.step == 2:
                    self.step_process()
                elif st.session_state.step == 3:
                    self.step_train()
                elif st.session_state.step == 4:
                    self.step_results()
            except Exception as e:
                st.error(f"âŒ Erro na etapa {st.session_state.step}: {str(e)}")
                if st.button("ðŸ”„ Reiniciar AplicaÃ§Ã£o", key="restart_app_error"):
                    self.reset_app()

        except Exception as e:
            st.error(f"âŒ Erro crÃ­tico: {str(e)}")
            st.info("Recarregue a pÃ¡gina para tentar novamente.")

    def show_progress(self):
        """Barra de progresso simples"""
        steps = [" Upload", " Processar", " Treinar", "ðŸ“Š Resultados"]
        current = st.session_state.step - 1

        html = """
        <div style="display: flex; justify-content: space-between; margin: 20px 0;">
        """

        for i, step in enumerate(steps):
            if i < current:
                html += f'<div style="padding: 10px; background: #4CAF50; color: white; border-radius: 5px; text-align: center; flex: 1; margin: 0 5px;">{step} âœ…</div>'
            elif i == current:
                html += f'<div style="padding: 10px; background: #2196F3; color: white; border-radius: 5px; text-align: center; flex: 1; margin: 0 5px;">{step}</div>'
            else:
                html += f'<div style="padding: 10px; background: #f0f0f0; color: #666; border-radius: 5px; text-align: center; flex: 1; margin: 0 5px;">{step}</div>'

        html += "</div>"
        st.markdown(html, unsafe_allow_html=True)

    def step_upload(self):
        """Upload do dataset SIMPLIFICADO para evitar erro do Streamlit"""
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

                st.success(f" Dataset carregado: {data.shape[0]} linhas Ã— {data.shape[1]} colunas")

                if st.checkbox(" Visualizar dados", key="show_preview_upload"):
                    st.dataframe(data.head(), use_container_width=True)

                st.subheader(" SeleÃ§Ã£o do Target")

                use_auto = st.checkbox(" Usar detecÃ§Ã£o automÃ¡tica", value=True, key="use_auto_detect")

                if use_auto:
                    try:
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

                        st.success("âœ… Target detectado automaticamente!")

                    except Exception as e:
                        st.error(f"âŒ DetecÃ§Ã£o automÃ¡tica falhou: {str(e)}")
                        st.info("Por favor, selecione manualmente:")
                        use_auto = False

                if not use_auto or not st.session_state.get('auto_detected', False):
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

                    st.success(f"âœ… Target selecionado: {target_col}")
                    st.success(f" Tipo: {problem_type.upper()}")

                st.markdown("---")

                col1, col2 = st.columns(2)
                with col1:
                    if st.button("ðŸ”„ Novo Upload", type="secondary", key="new_upload_simple_btn"):
                        keys_to_keep = ['app_initialized', 'last_rerun', 'n_folds', 'cv_strategy', 'random_state', 'parallel']
                        keys_to_remove = [k for k in st.session_state.keys() if k not in keys_to_keep]
                        for key in keys_to_remove:
                            del st.session_state[key]
                        time.sleep(0.5)
                        st.rerun()

                with col2:
                    if st.button("ðŸ”§ Continuar â†’", type="primary", key="continue_upload_btn"):
                        if 'target_col' not in st.session_state:
                            st.error("âŒ Selecione um target primeiro!")
                        else:
                            if len(st.session_state.X) < 10:
                                st.error("âŒ Muito poucas amostras (mÃ­nimo 10)")
                            else:
                                st.session_state.step = 2
                                time.sleep(0.5)
                                st.rerun()

            except Exception as e:
                st.error(f"âŒ Erro ao processar arquivo: {str(e)}")

                try:
                    uploaded_file.seek(0)                                              
                    data = pd.read_csv(uploaded_file, encoding='latin-1')
                    st.success("âœ… Carregado com encoding alternativo")
                    st.session_state.data = data
                    st.rerun()
                except Exception:
                    st.error("âŒ NÃ£o foi possÃ­vel ler o arquivo.")

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

                    st.success(f"âœ… Target selecionado: {target_col}")
                    st.success(f" Tipo: {problem_type.upper()}")

                st.markdown("---")

                col1, col2 = st.columns(2)
                with col1:
                    if st.button("ðŸ”„ Novo Upload", type="secondary", key="new_upload_simple_btn"):
                        keys_to_keep = ['app_initialized', 'last_rerun', 'n_folds', 'cv_strategy', 'random_state', 'parallel']
                        keys_to_remove = [k for k in st.session_state.keys() if k not in keys_to_keep]
                        for key in keys_to_remove:
                            del st.session_state[key]
                        time.sleep(0.5)
                        st.rerun()

                with col2:
                    if st.button("ðŸ”§ Continuar â†’", type="primary", key="continue_upload_btn"):
                        if 'target_col' not in st.session_state:
                            st.error("âŒ Selecione um target primeiro!")
                        else:
                            if len(st.session_state.X) < 10:
                                st.error("âŒ Muito poucas amostras (mÃ­nimo 10)")
                            else:
                                st.session_state.step = 2
                                time.sleep(0.5)
                                st.rerun()

            except Exception as e:
                st.error(f"âŒ Erro ao processar arquivo: {str(e)}")

                try:
                    uploaded_file.seek(0)
                    data = pd.read_csv(uploaded_file, encoding='latin-1')
                    st.success("âœ… Carregado com encoding alternativo")
                    st.session_state.data = data
                    st.rerun()
                except Exception:
                    st.error("âŒ NÃ£o foi possÃ­vel ler o arquivo.")

    def step_process(self):
        """Processamento SIMPLIFICADO"""
        st.header("ðŸ”§ Processamento de Dados")

        if 'data' not in st.session_state or st.session_state.data is None:
            st.warning("âš ï¸ Nenhum dataset carregado.")
            if st.button("â¬…ï¸ Voltar para Upload", key="back_to_upload_process"):
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
                    processor = PowerfulDataProcessor()

                    X, y, problem_type = processor.process(
                        st.session_state.data,
                        st.session_state.target_col
                    )

                    st.session_state.X = X
                    st.session_state.y = y
                    st.session_state.problem_type = problem_type
                    st.session_state.processed = True

                    st.success("âœ… Processamento concluÃ­do!")

                    with st.expander("ðŸ“‹ Resultados do Processamento"):
                        col1, col2 = st.columns(2)
                        with col1:
                            st.write("**Features (X):**")
                            st.write(f"- DimensÃµes: {X.shape}")
                            st.write(f"- Tipo: {type(X)}")
                        with col2:
                            st.write("**Target (y):**")
                            st.write(f"- DimensÃµes: {y.shape}")
                            st.write(f"- Tipo: {problem_type.upper()}")
                            if problem_type == 'classification':
                                st.write(f"- Classes: {len(np.unique(y))}")

                    time.sleep(1)

                except Exception as e:
                    st.error(f"âŒ Erro no processamento: {str(e)}")
                    try:
                        X = st.session_state.data.drop(columns=[st.session_state.target_col]).values
                        y = st.session_state.data[st.session_state.target_col].values

                        st.session_state.X = X
                        st.session_state.y = y
                        st.session_state.processed = True

                        st.success("âœ… Processamento simples realizado")
                    except Exception:
                        st.error("âŒ NÃ£o foi possÃ­vel processar os dados.")

        if st.session_state.get('processed', False):
            st.markdown("---")
            if st.button(" Ir para Treinamento â†’", type="primary", key="go_to_train_btn"):
                st.session_state.step = 3
                time.sleep(0.5)
                st.rerun()

        if st.button("â¬…ï¸ Voltar", key="back_from_process_btn"):
            st.session_state.step = 1
            time.sleep(0.5)
            st.rerun()

    def step_train(self):
        """Treinamento com fix"""
        st.header(" Treinamento com VALIDAÃ‡ÃƒO CRUZADA")

        if not st.session_state.get('processed', False):
            st.warning("Dados nÃ£o processados.")
            if st.button("â¬…ï¸ Voltar", key="back_to_process_train"):
                st.session_state.step = 2
                time.sleep(0.1)
                st.rerun()
            return

        with st.expander(" EstatÃ­sticas do Dataset"):
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
                    st.metric("Target MÃ©dia", f"{np.mean(st.session_state.y):.2f}")
            with col4:
                if st.session_state.problem_type == 'regression':
                    st.metric("Target Std", f"{np.std(st.session_state.y):.2f}")
                else:
                    class_dist = pd.Series(st.session_state.y).value_counts().iloc[0] / len(st.session_state.y) * 100
                    st.metric("Classe MajoritÃ¡ria", f"{class_dist:.1f}%")

        with st.container():
            st.info(" **VALIDAÃ‡ÃƒO CRUZADA ATIVADA**")

            with st.expander("âš™ï¸ ConfiguraÃ§Ãµes da ValidaÃ§Ã£o Cruzada"):
                col1, col2 = st.columns(2)
                with col1:
                    n_folds = st.slider(
                        "NÃºmero de folds",
                        3,
                        10,
                        st.session_state.get('n_folds', 5),
                        help="Mais folds = mais robusto, mas mais lento",
                        key="n_folds_slider_train"
                    )
                    cv_strategy = st.selectbox(
                        "EstratÃ©gia CV",
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
                        help="Usa todos os cores da CPU (mais rÃ¡pido)",
                        key="parallel_checkbox_train"
                    )

                st.session_state.n_folds = n_folds
                st.session_state.cv_strategy = cv_strategy
                st.session_state.random_state = random_state
                st.session_state.parallel = parallel

            st.warning("âš ï¸ O treinamento testarÃ¡ **15+ modelos** e pode levar alguns minutos.")

            if st.button(" INICIAR TREINAMENTO COMPLETO", type="primary", key="start_training_main_btn"):
                self._execute_training()

        if st.button("â¬…ï¸ Voltar para Processamento", key="back_to_process_train_2"):
            st.session_state.step = 2
            time.sleep(0.1)
            st.rerun()

    def _execute_training(self):
        """Executa treinamento em container separado"""
        with st.spinner("Treinando 15+ modelos..."):
            try:
                X = st.session_state.X
                y = st.session_state.y
                problem_type = st.session_state.problem_type

                trainer = UltraCompleteTrainer(problem_type)
                trainer.n_folds = int(st.session_state.get('n_folds', 5))

                results, best_model_name = trainer.train_safe(X, y)

                st.session_state.results = results
                st.session_state.trainer = trainer
                st.session_state.best_model_name = best_model_name
                st.session_state.best_model = trainer.best_model

                st.success("âœ… Treinamento concluÃ­do!")

                time.sleep(1)
                st.session_state.step = 4
                st.rerun()

            except Exception as e:
                st.error(f"âŒ Erro no treinamento: {str(e)}")

    def step_results(self):
        """Resultados"""
        st.header(" Resultados")

        if 'results' not in st.session_state:
            st.warning("Nenhum resultado disponÃ­vel.")
            if st.button("â¬…ï¸ Voltar", key="back_to_train_results"):
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
                with st.expander(" MÃ©tricas Detalhadas"):
                    model_options = list(results.keys())
                    selected_model = st.selectbox(
                        "Selecione um modelo para ver mÃ©tricas detalhadas:",
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
                                        delta=f"Â± {float(metrics.get(f'{metric_name}_std', 0)):.4f}" if f'{metric_name}_std' in metrics else None
                                    )
                                metric_count += 1

                        if 'cv_type' in metrics:
                            st.write("---")
                            st.write(f"**EstratÃ©gia CV:** {metrics['cv_type']}")
                            st.write(f"**NÃºmero de folds:** {metrics.get('n_folds', 5)}")
                            st.write(f"**Tempo mÃ©dio de treino:** {float(metrics.get('fit_time', 0)):.2f}s")
                            st.write(f"**Tempo mÃ©dio de score:** {float(metrics.get('score_time', 0)):.2f}s")

            st.subheader(" Exportar Resultados")

            col1, col2, col3 = st.columns(3)

            with col1:
                if st.button(" Exportar CSV", key="export_csv_results_btn"):
                    try:
                        ranking_df = trainer.get_ranking()
                        csv_data = ranking_df.to_csv(index=False).encode('utf-8')

                        st.download_button(
                            "â¬‡ï¸ Baixar CSV",                           
                            csv_data,                          
                            f"ranking_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv",                   
                            "text/csv",                        
                            key="download_csv_results_btn"                
                        )
                    except Exception as e:
                        st.error(f"Erro CSV: {e}")

            with col2:
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
                                    "â¬‡ï¸ Baixar Modelo",                           
                                    model_bytes,                          
                                    model_filename,                   
                                    "application/octet-stream",                                               
                                    key=f"download_model_{timestamp}"                
                                )
                                st.success(f"âœ… Modelo salvo: {model_filename}")
                        except Exception as e:
                            st.error(f"âŒ Erro ao salvar: {str(e)}")

            with col3:
                if st.button(" Gerar RelatÃ³rio", key="generate_report_btn"):
                    with st.spinner("Gerando relatÃ³rio..."):
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
                                    "â¬‡ï¸ Baixar RelatÃ³rio",                           
                                    file_bytes,                          
                                    os.path.basename(report_path),                        
                                    mime_type,                        
                                    key="download_report_btn"                
                                )
                            else:
                                st.warning("NÃ£o foi possÃ­vel gerar o relatÃ³rio.")
                        except Exception as e:
                            st.error(f"âŒ Erro no relatÃ³rio: {str(e)}")

            st.markdown("---")
            col1, col2 = st.columns([1, 3])

            with col1:
                if st.button("â¬…ï¸ Voltar", key="back_to_train_final"):
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
            st.error(f"âŒ Erro nos resultados: {str(e)}")
            if st.button(" Reiniciar AplicaÃ§Ã£o", key="restart_app_results"):
                for key in list(st.session_state.keys()):
                    del st.session_state[key]
                st.rerun()

    def _clear_state(self):
        """Limpa estado de forma segura"""
        keys_to_preserve = ['app_initialized', 'last_rerun', 'n_folds', 'cv_strategy', 'random_state', 'parallel']
        keys_to_remove = [k for k in st.session_state.keys() if k not in keys_to_preserve]

        for key in keys_to_remove:
            del st.session_state[key]

    def _clear_training_state(self):
        """Limpa apenas estado de treinamento"""
        training_keys = ['results', 'trainer', 'best_model', 'processed', 'X', 'y']
        for key in training_keys:
            if key in st.session_state:
                del st.session_state[key]

    def reset_app(self):
        """Reinicia aplicaÃ§Ã£o completamente"""
        for key in list(st.session_state.keys()):
            del st.session_state[key]
        st.rerun()

def main():
    app = UltraRobustApp()
    app.run()

if __name__ == "__main__":
    main()


