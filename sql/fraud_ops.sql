-- Fraud Operations Analytics
-- SQL examples based on the Kaggle Credit Card Fraud dataset
-- Columns used:
-- Time   = seconds since first transaction
-- Amount = transaction amount
-- Class  = fraud flag (1 = fraud, 0 = non-fraud)

-- 0. Dataset summary

SELECT
    COUNT(*) AS total_transactions,
    SUM(Class) AS total_fraud_transactions,
    ROUND(AVG(Class) * 100, 3) AS overall_fraud_rate_pct,
    ROUND(MIN(Amount), 2) AS min_amount,
    ROUND(MAX(Amount), 2) AS max_amount,
    ROUND(AVG(Amount), 2) AS avg_amount
FROM creditcard;

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

-- 3. Fraud rate by transaction time gap

WITH gaps AS (
    SELECT
        Time,
        Class,
        Time - LAG(Time) OVER (ORDER BY Time) AS gap_seconds
    FROM creditcard
),
bucketed AS (
    SELECT
        CASE
            WHEN gap_seconds < 1 THEN 'under_1_sec'
            WHEN gap_seconds <= 10 THEN '1_to_10_sec'
            WHEN gap_seconds <= 60 THEN '10_to_60_sec'
            ELSE '60_plus_sec'
        END AS gap_bucket,
        Class
    FROM gaps
    WHERE gap_seconds IS NOT NULL
)
SELECT
    gap_bucket,
    COUNT(*) AS total_transactions,
    SUM(Class) AS fraud_transactions,
    ROUND(AVG(Class) * 100, 3) AS fraud_rate_pct
FROM bucketed
GROUP BY gap_bucket
HAVING COUNT(*) > 0
ORDER BY fraud_rate_pct DESC;
