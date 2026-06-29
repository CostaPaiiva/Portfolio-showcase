# Relatorio Tecnico do Sistema AutoML

## Objetivo
Este documento descreve o sistema AutoML presente neste repositório, explicando sua arquitetura, fluxo de uso, principais capacidades, dependencias e pontos de evolucao.

## Visao geral
O projeto e uma plataforma de AutoML para dados tabulares, com interface principal em Streamlit e uma interface analitica complementar em Dash. O sistema cobre o ciclo completo:

1. recebimento do dataset
2. identificacao do target
3. preparacao e limpeza dos dados
4. treinamento de varios modelos
5. validacao e comparacao de resultados
6. selecao do melhor modelo
7. exportacao de artefatos e relatorios

Na pratica, ele foi desenhado para demonstrar um fluxo completo de Machine Learning com foco em automacao e apresentacao profissional.

## Estrutura do repositorio

| Arquivo | Responsabilidade |
|---|---|
| `app.py` | Aplicacao principal em Streamlit e orquestracao do fluxo inteiro |
| `data_processing.py` | Pipeline de limpeza, transformacao, imputacao, encoding, escala e selecao de features |
| `model_training.py` | Treinamento, avaliacao, comparacao, tuning e ensemble de modelos |
| `dashboard.py` | Dashboard avancado em Dash com visualizacao de resultados |
| `report_generator.py` | Geracao de relatorios em PDF e TXT |
| `requirements.txt` | Dependencias do ambiente |
| `README.md` | Visao comercial e tecnica resumida do projeto |

## Arquitetura funcional
O sistema segue uma arquitetura em camadas:

### 1. Camada de interface
Responsavel por coletar o dataset, orientar o usuario e controlar o fluxo da aplicacao.

### 2. Camada de preparacao de dados
Responsavel por transformar o dataset bruto em dados prontos para treino.

### 3. Camada de treinamento
Responsavel por testar diversos algoritmos e encontrar o melhor modelo.

### 4. Camada de analise e relatorio
Responsavel por apresentar metricas, rankings, graficos e exportacoes.

## Fluxo completo do sistema

### Etapa 1: Upload
O usuario envia um arquivo tabular. O sistema suporta CSV, TXT e XLSX. Em seguida:

- mostra o preview dos dados
- identifica colunas e dimensoes
- tenta detectar o target automaticamente
- permite selecao manual quando necessario

### Etapa 2: Detecao do problema
O sistema tenta classificar o problema como:

- classificacao
- regressao

Essa decisao influencia o pipeline de preprocessing, os modelos usados e as metricas avaliadas.

### Etapa 3: Processamento
A camada de processamento executa:

- remocao de duplicatas
- tratamento de valores infinitos
- analise de missing values
- imputacao
- encoding de variaveis categoricas
- scaling de variaveis numericas
- criacao de features derivadas
- selecao de features relevantes

### Etapa 4: Treinamento
O treinador executa diversos modelos de forma automatizada e usa validacao cruzada para reduzir dependencia de uma unica divisao treino-teste.

Para classificacao e regressao, o sistema inclui modelos classicos e ensembles, alem de bibliotecas mais fortes como:

- scikit-learn
- XGBoost
- LightGBM
- CatBoost

### Etapa 5: Avaliacao
Os resultados sao organizados em ranking e comparados por metricas apropriadas ao tipo de problema:

- classificacao: accuracy, precision, recall, f1, roc_auc
- regressao: r2, rmse, mae, mse e metricas correlatas

### Etapa 6: Exportacao
O sistema permite:

- salvar o melhor modelo
- exportar ranking em CSV
- gerar relatorio PDF
- gerar fallback em TXT quando necessario

## O que o sistema faz bem

- cobre o fluxo completo de AutoML em uma unica experiencia
- suporta classificacao e regressao
- automatiza processamento e treinamento
- usa validacao cruzada
- gera comparacao entre varios modelos
- produz artefatos uteis para apresentacao tecnica
- tem foco forte em UX e visualizacao

## Dependencias principais

| Categoria | Ferramentas |
|---|---|
| Interface | Streamlit, Dash, Dash Bootstrap Components |
| Dados | Pandas, NumPy |
| ML | Scikit-learn, XGBoost, LightGBM, CatBoost |
| Otimizacao | Optuna |
| Visualizacao | Plotly |
| Serializacao | Joblib, Pickle |
| Relatorios | ReportLab |

## Leitura tecnica do codigo

### `app.py`
Este e o ponto central do sistema. Ele concentra:

- interface principal
- controle de estado
- detecao de target
- processamento simplificado e avançado
- treinamento
- resultados
- exportacao

O arquivo tambem possui classes embutidas para varias dessas responsabilidades. Isso faz o projeto funcionar como um monolito operacional, mesmo existindo modulos separados.

### `data_processing.py`
Implementa um pipeline mais organizado de preprocessing. O destaque e a combinacao de:

- limpeza avancada
- engenharia de features
- imputacao inteligente
- encoding automatico
- escalonamento
- selecao de features

### `model_training.py`
E o modulo responsavel por testar muitos modelos, medir desempenho e escolher o melhor. Ele tambem contem logica para:

- cross-validation
- ordenacao de modelos
- ensembles
- tuning com Optuna
- definicao de modelo vencedor

### `dashboard.py`
Oferece uma visualizacao analitica mais rica, com graficos e tabelas para explorar os resultados dos modelos.

### `report_generator.py`
E a camada de geracao de documentos. A proposta e entregar um relatorio pronto para compartilhamento, com resumo executivo, ranking e recomendacoes.

## Pontos de atencao encontrados no projeto

### 1. Duplicacao de responsabilidades
Ha forte sobreposicao entre `app.py` e os modulos separados. Isso aumenta custo de manutencao e risco de inconsistencias.

### 2. `app.py` muito grande
O arquivo principal tem milhares de linhas e concentra a maior parte da logica. Isso dificulta testes, evolucao e revisao de bugs.

### 3. Artefatos gerados nao versionados
O modelo salvo e outros artefatos derivados parecem ser tratados como saida de execucao, nao como parte do codigo-fonte.

### 4. Carga computacional alta
O sistema tenta treinar muitos modelos e pode ficar pesado em datasets grandes ou ambientes com poucos recursos.

### 5. Falta de validacao de dados mais robusta
Ainda ha espaco para validar schema, tipos, cardinalidade e qualidade do dataset antes do treinamento.

### 6. Observabilidade limitada
O sistema mostra mensagens para o usuario, mas ainda nao tem logs estruturados, rastreio de execucao ou auditoria de experimentos.

## Ideias de atualizacao

### Prioridade alta
1. Modularizar `app.py` e mover cada responsabilidade para um pacote separado.
2. Eliminar duplicacao entre o fluxo principal e os modulos auxiliares.
3. Criar testes automaticos para processamento, treino e geracao de relatorios.
4. Adicionar validacao de schema e qualidade dos dados antes do treino.
5. Registrar metadados de execucao, versao do dataset e configuracoes do experimento.

### Prioridade media
1. Adicionar explicabilidade com SHAP ou permutation importance.
2. Criar pagina de perfilamento de dados com estatisticas iniciais.
3. Permitir salvar e carregar pipelines completos, nao apenas o modelo final.
4. Melhorar o tratamento de datasets grandes com amostragem, cache e execucao assincrona.
5. Padronizar melhor a exportacao de relatorios em PDF, HTML e TXT.

### Prioridade baixa
1. Publicar exemplos de datasets para demonstracao.
2. Adicionar screenshots da interface no README.
3. Criar modo comparativo entre dois ou mais datasets.
4. Incluir historico de execucoes na interface.

## Evolucao recomendada da arquitetura
Uma evolucao saudavel seria separar o projeto em:

- `ui/` para interfaces
- `core/` para logica de negocio
- `pipelines/` para preprocessamento e treino
- `reports/` para exportacao
- `artifacts/` para saidas geradas
- `tests/` para validacao automatizada

Isso deixaria o sistema mais facil de manter e mais pronto para uso real.

## Conclusao
O AutoML do repositorio ja entrega um pipeline completo e funcional para datasets tabulares, com foco em automacao, comparacao de modelos e experiencia visual. O valor principal do projeto e mostrar um fluxo ponta a ponta, do upload ao relatorio.

O proximo salto de qualidade nao e adicionar mais modelos. E estruturar melhor o codigo, fortalecer validacao, criar testes, rastrear experimentos e preparar o sistema para evolucao sustentavel.
