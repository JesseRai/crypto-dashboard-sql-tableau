CREATE TABLE crypto_clean (
  Currency    TEXT,
  date        DATE,
  Open        NUMERIC,
  High        NUMERIC,
  Low         NUMERIC,
  Close       NUMERIC,
  Volume      NUMERIC,
  "Market Cap"  NUMERIC
);

CREATE VIEW crypto_clean_nozero AS
SELECT *
FROM crypto_clean
WHERE Close > 0
  AND Open  > 0
  AND High  > 0
  AND Low   > 0;

select * from
(select 
	currency,
	date,
	close,
	round(((close / lag(close) over (partition by currency order by date)) -1) *100, 2) as "Daily Return %"
from crypto_clean_nozero)
where "Daily Return %" is not null;

CREATE OR REPLACE VIEW v_crypto_kpis2 AS
WITH base AS (
	SELECT
		currency,
		date,
		close,
		"Market Cap" as market_cap
	FROM crypto_clean_nozero
),

latest_date AS (
	SELECT
		currency,
		MAX(date) as max_date
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
	FROM BASE
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
	ROUND((lc.market_cap / tm.total_mcap) * 100, 2 ) AS dominance_pct
FROM latest_cap lc
LEFT JOIN vol_30d v USING (currency)
CROSS JOIN total_mcap tm;

CREATE OR REPLACE VIEW v_price_timeseries AS
SELECT
	currency,
	date,
	close,
	volume,
	"Market Cap" as market_cap,
	AVG(close) OVER (
		PARTITION BY currency
		ORDER BY date
		ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
		AS ma_7,
	AVG(close) OVER(
		PARTITION BY currency
		ORDER BY date
		ROWS BETWEEN 29 PRECEDING AND CURRENT ROW)
		AS ma_30
FROM crypto_clean_nozero;

SELECT
	currency,
	date,
	close,
	volume,
	market_cap,
	ROUND(ma_7, 2) as ma_7,
	ROUND(ma_30, 2) as ma_30
FROM v_price_timeseries;	
