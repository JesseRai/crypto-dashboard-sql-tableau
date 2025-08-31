# crypto-dashboard-sql-tableau

## About

crypto-dashboard-sql-tableau provides a data-processing and visualization pipeline for cryptocurrency prices. It uses PostgreSQL (via pgAdmin) and SQL scripts to construct tables, views and metrics from a Kaggle cryptocurrency price dataset. The processed data powers an interactive Tableau dashboard with price charts, moving averages and key performance indicators.

This repository showcases a simple pipeline for exploring and visualising cryptocurrency market data using **SQL** for data processing and **Tableau** for dashboard creation. It combines raw price data, a series of SQL queries to compute key metrics, and an interactive Tableau dashboard which can be explored online or recreated locally.

## Proposed Repository Structure

To make the SQL scripts easier to manage and understand, each logical step is split into its own directory. Within each directory there is a single `.sql` file containing the relevant statements.

```text
SQL/
├── 01_create_table/
│   └── create_crypto_clean.sql   # Creates the `crypto_clean` table
├── 02_clean_data/
│   └── create_view_crypto_clean_nozero.sql  # Defines the `crypto_clean_nozero` view for filtering zero values
├── 03_daily_returns/
│   └── query_daily_returns.sql   # Computes daily return percentages for each currency
├── 04_kpi_view/
│   └── create_view_crypto_kpis.sql   # Builds the `v_crypto_kpis2` view of key performance indicators
├── 05_timeseries_view/
│   └── create_view_price_timeseries.sql  # Defines the `v_price_timeseries` view with 7- and 30-day moving averages
└── 06_extract_timeseries/
    └── query_select_timeseries.sql   # Selects the final time-series data from the view
README.md    # This README
...
```

- **01_create_table/create_crypto_clean.sql** – Creates a table `crypto_clean` to hold the raw data with appropriate data types (currency, date, open, high, low, close, volume and market cap).
- **02_clean_data/create_view_crypto_clean_nozero.sql** – Defines a view `crypto_clean_nozero` that filters out records where the open, high, low or close prices are zero, ensuring downstream calculations are meaningful.
- **03_daily_returns/query_daily_returns.sql** – Computes daily return percentages for each currency using a window function (`LAG`). Results are rounded to two decimal places and null values are excluded.
- **04_kpi_view/create_view_crypto_kpis.sql** – Creates a view `v_crypto_kpis2` that aggregates several KPIs:
  - The latest market capitalisation for each currency
  - 30-day volatility (standard deviation of daily returns over the last 30 days, expressed as a percentage)
  - Market dominance (share), defined as the currency’s market cap divided by the total market cap on the latest date
- **05_timeseries_view/create_view_price_timeseries.sql** – Defines a view `v_price_timeseries` that calculates 7-day and 30-day moving averages of the closing price for each currency, enabling smoother trend visualisation.
- **06_extract_timeseries/query_select_timeseries.sql** – A final query that selects data from `v_price_timeseries` and rounds the moving averages for presentation.

## Data

The raw data comes from a Kaggle cryptocurrency price history dataset. Each record contains the currency name along with open, high, low and closing prices, trading volume and market capitalisation.
## SQL Processing (Reflected by the Proposed Structure) 

1. **Create table** – Run the script in `01_create_table/create_crypto_clean.sql` to create the `crypto_clean` table.
2. **Filter zero values** – Execute `02_clean_data/create_view_crypto_clean_nozero.sql` to build a view `crypto_clean_nozero` that filters out records where any of the prices (open, high, low, close) are zero.
3. **Compute daily returns** – Execute `03_daily_returns/query_daily_returns.sql` to compute daily return percentages for each currency using the `crypto_clean_nozero` view.
4. **Generate KPIs** – Execute `04_kpi_view/create_view_crypto_kpis.sql` to build the `v_crypto_kpis2` view with key performance indicators (latest market cap, 30‑day volatility and market dominance).
5. **Generate time series with moving averages** – Execute `05_timeseries_view/create_view_price_timeseries.sql` to define the `v_price_timeseries` view that includes 7‑day and 30‑day moving averages.
6. **Select final time series** – Execute `06_extract_timeseries/query_select_timeseries.sql` to select and round the moving averages for presentation.

## Tableau Dashboard

A Tableau dashboard built from the exported time-series CSVs provides an interactive way to explore the data. The dashboard is available on Tableau Public and can also be recreated locally using the CSV outputs. The main panels show:

- **Cryptocurrency selector** – choose from multiple currencies (e.g., Bitcoin, Ethereum) to update all visualisations simultaneously.
- **Top‑level metrics** – Displayed panels show:
  - **30‑day volatility** (in percent) for the selected currency
  - **Latest market cap** in USD
  - **Sample share** (market dominance) relative to the total crypto market
- **Date slider** – A range slider lets you focus on a specific time window within the available data.
- **Price & moving averages** – The main line chart plots the closing price along with 7‑day and 30‑day moving averages, revealing short‑ and medium‑term trends.
- **Weekly percentage returns** – A bar chart summarises weekly percentage returns, highlighting periods of strong gains or losses.

The Tableau dashboard uses CSV outputs from the SQL scripts, so results are synchronised with your data processing logic.

## Dashboard Preview

Below is a static preview of the interactive dashboard. The live version allows you to filter by cryptocurrency and adjust the date range.

![Crypto Dashboard Preview](dashboard.png)
