SELECT
    currency,
    date,
    close,
    volume,
    market_cap,
    ROUND(ma_7, 2) AS ma_7,
    ROUND(ma_30, 2) AS ma_30
FROM v_price_timeseries;
