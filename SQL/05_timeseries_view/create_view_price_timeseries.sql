-- Create view to compute price timeseries with moving averages
CREATE OR REPLACE VIEW v_price_timeseries AS
SELECT
    currency,
    date,
    close,
    volume,
    "Market Cap" AS market_cap,
    AVG(close) OVER (
        PARTITION BY currency
        ORDER BY date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS ma_7,
    AVG(close) OVER (
        PARTITION BY currency
        ORDER BY date
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) AS ma_30
FROM crypto_clean_nozero;
