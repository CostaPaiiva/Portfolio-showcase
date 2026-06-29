# Relatorio Executivo AutoML

## Resumo
Plataforma AutoML para dados tabulares com interface em Streamlit. O sistema recebe datasets, identifica o target, processa os dados, treina varios modelos, compara resultados e exporta relatorios.

## Principais capacidades
- upload de CSV, TXT e XLSX
- deteccao automatica ou manual do target
- limpeza, imputacao, encoding e escala
- treinamento com validacao cruzada
- ranking de modelos
- salvamento do melhor modelo
- exportacao de relatorio

## Stack
- Python
- Streamlit
- Pandas e NumPy
- Scikit-learn
- XGBoost, LightGBM e CatBoost
- Plotly
- Joblib
- Optuna

## Fluxo
1. carregar dataset
2. selecionar target
3. processar dados
4. treinar modelos
5. comparar metricas
6. exportar artefatos

## Pontos fortes
- cobre o ciclo completo de ML
- tem boa apresentacao visual
- atende classificacao e regressao
- entrega artefatos uteis para demonstracao

## Direcao recomendada
- reduzir duplicacao entre arquivos
- centralizar logica de negocio
- adicionar testes
- melhorar validacao de dados
- registrar metadados de execucao
