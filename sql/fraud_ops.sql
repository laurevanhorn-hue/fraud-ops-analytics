-- Fraud Operations Analytics
-- SQL examples based on the Kaggle Credit Card Fraud dataset
-- Columns used:
-- Time   = seconds since first transaction
-- Amount = transaction amount
-- Class  = fraud flag (1 = fraud, 0 = non-fraud)

-- 1. Fraud rate by transaction amount bucket

WITH amount_buckets AS (
    SELECT
        CASE
            WHEN Amount < 10 THEN 'under_10'
            WHEN Amount < 50 THEN '10_to_49'
            WHEN Amount < 100 THEN '50_to_99'
            ELSE '100_plus'
        END AS amount_bucket,
        Class
    FROM creditcard
)
SELECT
    amount_bucket,
    COUNT(*) AS total_transactions,
    SUM(Class) AS fraud_transactions,
    ROUND(AVG(Class) * 100, 3) AS fraud_rate_pct
FROM amount_buckets
GROUP BY amount_bucket
ORDER BY fraud_rate_pct DESC;

-- 2. Fraud rate by hour

WITH hourly_transactions AS (
    SELECT
        CAST(FLOOR(Time / 3600) % 24 AS INT) AS hour_bucket,
        Class
    FROM creditcard
)
SELECT
    hour_bucket,
    COUNT(*) AS total_transactions,
    SUM(Class) AS fraud_transactions,
    ROUND(AVG(Class) * 100, 3) AS fraud_rate_pct
FROM hourly_transactions
GROUP BY hour_bucket
ORDER BY hour_bucket;
