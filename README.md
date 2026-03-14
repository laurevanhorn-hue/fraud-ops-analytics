## Project Overview

This project analyzes a public credit card transaction dataset (284k transactions) to identify behavioral patterns associated with fraudulent activity. It focuses on transaction-level signals such as timing, amount distribution, and rapid transaction bursts.

The goal is to explore transaction behavior and highlight potential operational monitoring rules for fraud detection.

---

## Fraud Operations Analytics

### Tools Used
- Python (pandas)
- SQL
- Jupyter / Google Colab
- GitHub

### Focus Areas
- fraud frequency by transaction size
- fraud activity over time
- rapid transaction bursts

---

## Dataset

The dataset used in this project is publicly available on Kaggle:

**Credit Card Fraud Detection Dataset**  
https://www.kaggle.com/datasets/mlg-ulb/creditcardfraud

Download the file `creditcard.csv` and place it in:

data/creditcard.csv

**Note:** The dataset is large (~143MB), so it is not stored in this repository.

---

## How to Run This Project

1. Clone the repository
2. Install dependencies:

pip install -r requirements.txt

3. Place the dataset file:

data/creditcard.csv

4. Open the notebook:

notebooks/fraud_ops.ipynb
---
## Project Structure

fraud-ops-analytics/
│
├── notebooks/
│ └── fraud_ops.ipynb
│
├── images/
│ ├── fraud_rate_by_amount.png
│ ├── fraud_rate_by_hour.png
│ └── d4_fraud_rate_by_gap.png
│
├── sql/
│ └── fraud_ops.sql
│
└── README.md


- `notebooks/` — full Python analysis  
- `images/` — visualizations  
- `sql/` — SQL equivalents  


## Fraud Patterns

### Fraud Rate by Transaction Amount

![Fraud rate by amount](images/fraud_rate_by_amount.png)

Fraudulent transactions are more common among smaller transaction values.  
This suggests fraudsters may attempt to avoid detection by performing many small purchases instead of large ones.

---

### Fraud Activity by Hour

![Fraud rate by hour](images/fraud_rate_by_hour.png)

Fraud frequency was analyzed across hourly buckets derived from the `Time` column.

**Method**
- Converted `Time` (seconds since first transaction) into hourly buckets  
- Calculated fraud rate using `groupby`

**Observation**
- Fraud spikes around hour **2** (~**1.3%**)  
- Most hours remain near **0.1–0.2%**

**Interpretation**
- Fraud attempts may cluster during low-activity periods (e.g., late night)

**Operational implication**
- Monitoring systems may benefit from stricter alert thresholds during these hours

---

### Core Logic (Python / pandas)

```python
df['hour'] = (df['Time'] // 3600) % 24

fraud_by_hour = (
    df.groupby('hour')['Class']
      .agg(['count','sum','mean'])
      .rename(columns={
          'count':'transactions',
          'sum':'frauds',
          'mean':'fraud_rate'
      })
)
## D4 — Rapid Transaction Bursts

Fraudulent activity can occur as bursts of transactions within very short time intervals. Attackers may attempt multiple charges quickly to test stolen cards or exploit automated systems.

### Method

- Sorted transactions by `Time`
- Calculated previous transaction time
- Computed the gap between consecutive transactions
- Grouped transactions into time buckets:
  - under 1 second
  - 1 to 10 seconds
  - 10 to 60 seconds

### Key Finding

The highest fraud rate was observed in the **1–10 second** bucket (~0.70%), followed by the **10–60 second** bucket (~0.59%).

Transactions under 1 second had a lower fraud rate (~0.22%), indicating that fraud is not associated with the fastest possible activity, but with short bursts over several seconds.

The 1–10 second bucket also contained over **5,000 transactions**, making this pattern statistically meaningful.

### Operational Insight

Fraud detection systems may benefit from monitoring clusters of transactions occurring within short time windows (**1–10 seconds**), as this pattern shows elevated fraud risk.

### Visualization

### SQL Analysis

The project also includes SQL versions of the main analyses in `sql/fraud_ops.sql`, including:

- fraud rate by transaction amount bucket
- fraud rate by hour
- fraud rate by transaction time gap using `LAG()`

These queries mirror the pandas analysis and demonstrate equivalent analytical logic in SQL.
---

## Key Findings

### 1. Fraud by transaction amount  
Fraud is more common in smaller transactions.

### 2. Fraud by time of activity  
Fraud spikes during early hours.

### 3. Rapid transaction bursts  
Fraud tends to occur in short sequences rather than isolated events.

### Implications for monitoring systems

- detect clusters of small transactions  
- increase monitoring during low-activity hours  
- flag rapid repeated transaction patterns  

