# 📊 Customer Churn Prediction & Segmentation

## 🚀 Project Overview
This project is dedicated to the problem of ** learning with the teacher (Supervated Learning) ** to predict the customer activity of customers of the online store "into one click".
We build a model that predicts the probability of a client’s outflow, and conduct segmentation for personalized marketing recommendations.

Key results:
- ** Best model: ** SVC (ROC AUC = 0.902)
- ** Interpretation of signs: ** shap analysis for understanding the factors of outflow
- ** segmentation: ** Highlighted three groups of customers with different business significant

---

## 📂 Data Sources
The project uses four tables:
- `market_file.csv` - marketing, behavioral and categorical signs
- `market_money.csv` - estate revenue
- `market_time.csv` - time on the site for the period
- `money.csv` - the final profit of the client

---

## ⚙️ Project Structure
```
teach-model/
│
├ ─ Data/ # csv files (locally)
├ ─ Teach-model.ipynb # jupyter notebo with code
├── Recuirements.txt # List of Library
└── Readme.md # Description of the project
```

---

## 🔎 Workflow

### 1. Data Preprocessing
- Verification of data types, cleaning from passes and duplicates
- correction of typos, transcoding categorical values
- Removing emissions and customers without purchases

### 2. Exploratory Data Analysis (EDA)
- Analysis of the distributions of signs
- correlation analysis (Spearman)
- identification of emissions and anomalies

### 3. Feature Engineering
- Association of tables by `ID`
- preparation of categorical and numerical features

### 4. Model Training
Models with cross-novel (`RandomizedSearchcv`):
- Logistic Regression  
- Decision Tree  
- K-Nearest Neighbors  
- Support Vector Classifier (SVC)  

Metric: ** ROC AUC **

### 5. Model Interpretation
- Shap analysis of signs for Logistic Regression
- Determined key drivers of outflow: involvement, promotions, unpaid baskets

### 6. Customer Segmentation
3 segments of customers are allocated:
- ** a: ** high profit and high risk of outflow (critical for holding)
- ** b: ** high share of promotional purchases and average profit (risk of discount dependence)
- ** C: ** products for children + increased risk (weak stability of category)

---

## 📈 Key Results

- ** ROC AUC Best Models: **
  - SVC — 0.902  
  - Logistic Regression — 0.901  
  - KNN — 0.888  
  - Decision Tree — 0.873  

- ** Risk factors of outflow: **
- low involvement (fewer pages and categories for a visit)
- Frequent promotions and unpaid baskets
- prolonged exposure to marketing campaigns

- ** Business recommendations: **
- for the segment a- personalization, premium service without discounts
- for the segment b - restriction of shares, replacement with cashback/points
- for the C segment- analysis of the category "Products for children", UX research

---

## 🛠️ Installation & Usage

### 1. To clone a repository
```bash
git clone https://github.com/alexkeram/teach-model.git
cd teach-model
```

### 2. Create a virtual environment
```bash
python -m venv .venv
source .venv/bin/activate   # Linux/Mac
.venv\Scripts\activate      # Windows
```

### 3. Install dependencies
```bash
pip install -r requirements.txt
```

### 4. Launch a laptop
```bash
jupyter notebook teach-model.ipynb
```

---

## 📦 Requirements
- Python 3.9+  
- pandas, numpy  
- scikit-learn  
- matplotlib, seaborn  
- shap  

---

## 🧭 Roadmap
- [] Add Baseline with simple rules for comparison
- [] try ensemble models (Random Forest, XGBOOST, CATBOOST)
- [] Take Pyaplane into a separate Python Module (`SRC/`)
- [] Expand the model in the API via Fastapi/Docker

---

## 👤 Author
**Aleksandr Zhuravlev**
📌 Transitioning from Business Analysis → Data Science
