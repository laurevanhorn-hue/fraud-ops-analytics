# Fraud Operations Analytics

## Project Overview
This project analyzes credit card transactions to identify patterns associated with fraudulent activity.  
The goal is to explore transaction behavior and highlight potential operational monitoring rules for fraud detection.

## Dataset

The dataset used in this project is publicly available on Kaggle:

Credit Card Fraud Detection Dataset  
https://www.kaggle.com/datasets/mlg-ulb/creditcardfraud

Download the file **creditcard.csv** and place it in the following local folder before running the notebook:

data/creditcard.csv

Note: The dataset is large (143MB), so it is not stored directly in this GitHub repository.

## Project Structure

## Fraud Patterns

Analysis of transaction amounts shows that fraud transactions are more common among smaller transaction values.

This suggests fraudsters may attempt to avoid detection by performing many small purchases instead of large ones.

## Fraud rate by transaction amount

![Fraud rate by amount](images/fraud_rate_by_amount.png)

Fraud activity is concentrated in the smallest transaction ranges.  
This pattern suggests attackers may perform low-value transactions to avoid detection or test stolen cards.

## Fraud activity by hour

![Fraud rate by hour](images/fraud_rate_by_hour.png)

We analyzed fraud frequency across hourly buckets derived from the transaction timestamp (`Time`).

**Method**
- Converted the dataset’s `Time` (seconds since first transaction) into hourly buckets.
- Computed fraud rate per hour using pandas `groupby`.

**Observation**
- Fraud rate spikes around hour **2**, reaching ~**1.3%**, while most hours remain near **0.1–0.2%**.

**Interpretation**
- Fraud attempts may cluster during low-activity periods (e.g., late-night hours) when monitoring or user activity is lower.

**Operational implication**
- Fraud detection systems may benefit from increased monitoring or stricter alert thresholds during these periods.

  **Core logic (Python / pandas)**

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

