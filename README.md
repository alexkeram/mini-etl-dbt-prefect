# 📊 Customer Churn Prediction & Segmentation

## 🚀 Project Overview
Этот проект посвящён задаче **обучения с учителем (supervised learning)** для прогнозирования снижения покупательской активности клиентов интернет-магазина «В один клик».  
Мы строим модель, которая предсказывает вероятность оттока клиента, и проводим сегментацию для персонализированных маркетинговых рекомендаций.  

Ключевые результаты:  
- **Лучшая модель:** SVC (ROC AUC = 0.902)  
- **Интерпретация признаков:** SHAP-анализ для понимания факторов оттока  
- **Сегментация:** выделены три группы клиентов с разной бизнес-значимостью  

---

## 📂 Data Sources
Проект использует четыре таблицы:  
- `market_file.csv` — маркетинговые, поведенческие и категориальные признаки  
- `market_money.csv` — помесячная выручка  
- `market_time.csv` — время на сайте по периодам  
- `money.csv` — итоговая прибыль клиента  

---

## ⚙️ Project Structure
```
teach-model/
│
├── data/                  # CSV-файлы (локально)
├── teach-model.ipynb      # Jupyter Notebook с кодом
├── requirements.txt       # список библиотек
└── README.md              # описание проекта
```

---

## 🔎 Workflow

### 1. Data Preprocessing
- Проверка типов данных, очистка от пропусков и дубликатов  
- Исправление опечаток, перекодировка категориальных значений  
- Удаление выбросов и клиентов без покупок  

### 2. Exploratory Data Analysis (EDA)
- Анализ распределений признаков  
- Корреляционный анализ (Spearman)  
- Выявление выбросов и аномалий  

### 3. Feature Engineering
- Объединение таблиц по `id`  
- Подготовка категориальных и числовых признаков  

### 4. Model Training
Модели с кросс-валидацией (`RandomizedSearchCV`):  
- Logistic Regression  
- Decision Tree  
- K-Nearest Neighbors  
- Support Vector Classifier (SVC)  

Метрика: **ROC AUC**  

### 5. Model Interpretation
- SHAP-анализ признаков для Logistic Regression  
- Определены ключевые драйверы оттока: вовлечённость, акции, неоплаченные корзины  

### 6. Customer Segmentation
Выделены 3 сегмента клиентов:  
- **A:** высокая прибыль и высокий риск оттока (критически важны для удержания)  
- **B:** высокая доля акционных покупок и средняя прибыль (риск скидочной зависимости)  
- **C:** товары для детей + повышенный риск (слабая стабильность категории)  

---

## 📈 Key Results

- **ROC AUC лучших моделей:**
  - SVC — 0.902  
  - Logistic Regression — 0.901  
  - KNN — 0.888  
  - Decision Tree — 0.873  

- **Факторы риска оттока:**
  - низкая вовлечённость (меньше страниц и категорий за визит)  
  - частые акции и неоплаченные корзины  
  - длительное воздействие маркетинговых кампаний  

- **Бизнес-рекомендации:**
  - для сегмента A — персонализация, премиум-сервис без скидок  
  - для сегмента B — ограничение акций, замена на кэшбэк/баллы  
  - для сегмента C — анализ категории «Товары для детей», UX-исследование  

---

## 🛠️ Installation & Usage

### 1. Клонировать репозиторий
```bash
git clone https://github.com/alexkeram/teach-model.git
cd teach-model
```

### 2. Создать виртуальное окружение
```bash
python -m venv .venv
source .venv/bin/activate   # Linux/Mac
.venv\Scripts\activate      # Windows
```

### 3. Установить зависимости
```bash
pip install -r requirements.txt
```

### 4. Запустить ноутбук
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
- [ ] Добавить baseline с простыми правилами для сравнения  
- [ ] Попробовать ансамблевые модели (Random Forest, XGBoost, CatBoost)  
- [ ] Вынести пайплайн в отдельный Python-модуль (`src/`)  
- [ ] Развернуть модель в API через FastAPI/Docker  

---

## 👤 Author
**Aleksandr Zhuravlev**
📌 Transitioning from Business Analysis → Data Science
