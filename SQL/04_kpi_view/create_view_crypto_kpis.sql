-- Create view with cryptocurrency KPIs: latest market cap, 30-day volatility, dominance share
CREATE OR REPLACE VIEW v_crypto_kpis2 AS
WITH base AS (
    SELECT
        currency,
        date,
        close,
        "Market Cap" AS market_cap
    FROM crypto_clean_nozero
),
latest_date AS (
    SELECT
        currency,
        MAX(date) AS max_date
    FROM base
    GROUP BY currency
),
latest_cap AS (
    SELECT
        b.currency,
        b.market_cap,
        b.date
    FROM base b
    JOIN latest_date ld
      ON b.currency = ld.currency AND b.date = ld.max_date
),
daily_ret AS (
    SELECT
        currency,
        date,
        (close / LAG(close) OVER (PARTITION BY currency ORDER BY date) - 1) AS r
    FROM base
),
vol_30d AS (
    SELECT
        d.currency,
        ROUND(STDDEV_SAMP(d.r) * 100, 2) AS vol_30d_pct
    FROM daily_ret d
    JOIN latest_date ld USING (currency)
    WHERE d.r IS NOT NULL
      AND d.date > ld.max_date - INTERVAL '30 days'
    GROUP BY d.currency
),
total_mcap AS (
    SELECT
        ld.max_date,
        SUM(b.market_cap) AS total_mcap
    FROM latest_date ld
    JOIN base b ON b.date = ld.max_date AND b.currency = ld.currency
    GROUP BY ld.max_date
)
SELECT
    lc.currency,
    lc.market_cap,
    v.vol_30d_pct,
    ROUND((lc.market_cap / tm.total_mcap) * 100, 2) AS dominance_pct
FROM latest_cap lc
LEFT JOIN vol_30d v USING (currency)
CROSS JOIN total_mcap tm;
