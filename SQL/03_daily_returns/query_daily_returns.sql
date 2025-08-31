-- Query daily percentage returns for each currency from the cleaned data
SELECT *
FROM (
    SELECT
        currency,
        date,
        close,
        ROUND(((close / LAG(close) OVER (PARTITION BY currency ORDER BY date)) - 1) * 100, 2) AS "Daily Return %"
    FROM crypto_clean_nozero
) AS sub
WHERE "Daily Return %" IS NOT NULL;
