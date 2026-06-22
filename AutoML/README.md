# AutoML

AutoML platform with a Streamlit web interface for tabular dataset ingestion, intelligent data preparation, automated model training, performance comparison, and report generation.

The project is structured to demonstrate a complete applied machine learning workflow with a strong focus on usability, automation, and professional presentation.

<p>
  <img alt="Python" src="https://img.shields.io/badge/Python-3.10%2B-blue">
  <img alt="Streamlit" src="https://img.shields.io/badge/Streamlit-UI-red">
  <img alt="Scikit-learn" src="https://img.shields.io/badge/Scikit--learn-ML-orange">
  <img alt="Plotly" src="https://img.shields.io/badge/Plotly-Visualizations-6f42c1">
  <img alt="Automation" src="https://img.shields.io/badge/Automation-AutoML-success">
</p>

## Overview

| Item | Description |
|---|---|
| Area | Machine Learning and Automation |
| Interface | Streamlit |
| Visualization | Plotly |
| Training stack | Scikit-learn, XGBoost, LightGBM, CatBoost |
| Purpose | AutoML pipeline for classification and regression |

## At a glance

| Signal | Value |
|---|---|
| Problem types | Classification and regression |
| Workflow | Upload -> process -> train -> rank -> export |
| Output | Best model, ranking, and report artifacts |
| Strength | One interface for multiple ML steps |

## What the platform does

- accepts tabular datasets
- automatically detects the problem type
- processes data with cleaning, imputation, encoding, and scaling
- trains multiple models in parallel
- compares metrics with cross-validation
- selects and saves the best model
- exports rankings, artifacts, and reports

## Project structure

```text
AutoML/
├── app.py
├── dashboard.py
├── data_processing.py
├── model_training.py
├── report_generator.py
├── requirements.txt
├── LICENSE
├── .gitignore
└── modelo.pkl
```

## Application flow

1. Upload the dataset
2. Select or detect the `target`
3. Process the data
4. Train with cross-validation
5. Evaluate, rank, and export results

## Main features

| Block | Features |
|---|---|
| Upload | CSV, TXT, and Excel support |
| Preparation | Cleaning, imputation, encoding, scaling, feature selection |
| Training | Classification, regression, ensembles, and tuning |
| Results | Ranking, metrics, charts, and best model selection |
| Export | CSV, `.pkl`, and PDF/TXT report output |

## Supported models

### Classification

- Logistic Regression
- Ridge Classifier
- SGD Classifier
- SVC, NuSVC, and LinearSVC
- KNN and Radius Neighbors
- Decision Tree, Extra Tree, and Random Forest
- Gradient Boosting, AdaBoost, Bagging, and Extra Trees
- HistGradientBoosting
- GaussianNB, BernoulliNB, and MultinomialNB
- Linear Discriminant Analysis
- Quadratic Discriminant Analysis
- MLP Classifier
- XGBoost, LightGBM, and CatBoost
- Voting Classifier

### Regression

- Linear Regression
- Ridge, Lasso, and ElasticNet
- SGD Regressor
- SVR, NuSVR, and LinearSVR
- KNN and Radius Neighbors Regressor
- Decision Tree, Extra Tree, and Random Forest Regressor
- Gradient Boosting, AdaBoost, Bagging, and Extra Trees Regressor
- HistGradientBoosting Regressor
- Kernel Ridge
- MLP Regressor
- XGBoost, LightGBM, and CatBoost Regressor
- Voting Regressor

## Metrics evaluated

| Type | Metrics |
|---|---|
| Classification | Accuracy, F1, Precision, Recall, ROC AUC |
| Regression | R2, RMSE, MAE, Explained Variance |
| General | Average time, fold standard deviation, and ranking |

## Internal organization

| File | Responsibility |
|---|---|
| `app.py` | Main application interface and flow |
| `data_processing.py` | Data cleaning, transformation, and preparation |
| `model_training.py` | Training, evaluation, ranking, and tuning |
| `dashboard.py` | Supporting visual dashboard |
| `report_generator.py` | Report generation |

## Technologies used

| Category | Tools |
|---|---|
| Language | Python |
| Interface | Streamlit |
| Data | Pandas, NumPy |
| ML | Scikit-learn, XGBoost, LightGBM, CatBoost |
| Visualization | Plotly |
| Serialization | Joblib |
| Optimization | Optuna |
| Reports | FPDF, ReportLab, Matplotlib |
| Additional dashboard | Dash, Bootstrap Components |

## How to run

### 1. Clone the repository

```bash
git clone https://github.com/CostaPaiiva/AutoML.git
cd AutoML
```

### 2. Create and activate a virtual environment

**Windows**

```bash
python -m venv venv
venv\Scripts\activate
```

**Linux / macOS**

```bash
python3 -m venv venv
source venv/bin/activate
```

### 3. Install dependencies

```bash
pip install -r requirements.txt
```

### 4. Run the application

```bash
streamlit run app.py
```

## Project strengths

- complete AutoML workflow
- clear separation between preparation, training, and reporting
- strong focus on visual experience
- applicable to both classification and regression
- useful artifacts for technical presentation

## Notes

- The project shows end-to-end product thinking, not only model training.
- The interface makes the workflow easy to understand without reading code first.
- The structure separates responsibilities clearly across modules.

## Next steps

- improve automatic feature selection
- expand ensemble strategy support
- standardize report outputs
- add dataset examples and UI screenshots
