-- make-data.sql: generates the example data in data/. Run from this folder:
--
--   duckdb < make-data.sql
--
-- The data is made up. Every "random" number comes from hash(), not random(), so running the
-- script again writes the same files.

-- u(i, salt) is a uniform number in [0, 1), the same on every run for the same arguments
CREATE MACRO u(i, salt) AS (hash(i, salt) % 1000000) / 1000000.0;
CREATE MACRO pick(list, i, salt) AS list[1 + floor(u(i, salt) * len(list))::INT];

-- orders.csv: two years of orders
COPY (
  WITH o AS (
    SELECT i AS order_id,
           DATE '2024-01-01' + floor(u(i, 'day') * 731)::INT AS order_date,
           pick(['North', 'South', 'East', 'West'], i, 'region') AS region,
           CASE WHEN u(i, 'ch') < 0.55 THEN 'Online' WHEN u(i, 'ch') < 0.85 THEN 'Retail' ELSE 'Partner' END AS channel,
           pick(['Basic', 'Plus', 'Pro', 'Team', 'Enterprise'], i, 'product') AS product,
           1 + floor(u(i, 'cust') * 400)::INT AS customer_id,
           u(i, 'amt') AS a
    FROM range(1, 2001) t(i)
  )
  SELECT order_id, order_date, region, channel, product,
         CASE WHEN amount < 250 THEN 'small' WHEN amount < 1000 THEN 'medium' ELSE 'large' END AS deal_size,
         amount, customer_id
  FROM (
    SELECT *,
           -- skewed amounts that grow a little over time and depend on the product
           round((60 + 2400 * a * a * a) * (1 + (order_date - DATE '2024-01-01') / 1460.0)
                 * CASE product WHEN 'Enterprise' THEN 2.2 WHEN 'Team' THEN 1.5 WHEN 'Pro' THEN 1.2 ELSE 1 END, 2) AS amount
    FROM o
  )
  ORDER BY order_id
) TO 'data/orders.csv' (HEADER);

-- sales/<year>.csv: monthly sales by region, one file per year; 2025 adds a discount column
CREATE TABLE sales AS
SELECT month, region,
       (80 + floor(u(month::VARCHAR || region, 'units') * 60) + extract(month FROM month) * 3)::INT AS units
FROM range(DATE '2023-01-01', DATE '2026-01-01', INTERVAL 1 MONTH) m(month),
     (VALUES ('North'), ('South'), ('East'), ('West')) r(region);
ALTER TABLE sales ALTER month TYPE DATE;
COPY (SELECT month, region, units, units * 49 AS revenue FROM sales WHERE year(month) = 2023 ORDER BY ALL)
  TO 'data/sales/2023.csv' (HEADER);
COPY (SELECT month, region, units, units * 52 AS revenue FROM sales WHERE year(month) = 2024 ORDER BY ALL)
  TO 'data/sales/2024.csv' (HEADER);
COPY (SELECT month, region, units, units * 55 AS revenue,
             round(0.02 + u(month::VARCHAR || region, 'disc') * 0.08, 3) AS discount
      FROM sales WHERE year(month) = 2025 ORDER BY ALL)
  TO 'data/sales/2025.csv' (HEADER);

-- monthly.parquet: revenue and margin per month (the combo chart's bar and line)
COPY (
  SELECT month::DATE AS month,
         round(42000 + n * 1800 + u(n, 'rev') * 9000) AS revenue,
         round(0.18 + n * 0.004 + u(n, 'mar') * 0.05, 3) AS margin
  FROM (SELECT DATE '2024-01-01' + INTERVAL (n) MONTH AS month, n FROM range(24) t(n))
  ORDER BY month
) TO 'data/monthly.parquet' (FORMAT parquet);

-- plan_vs_actual.csv: plan and actual per region (a deviation chart of actual - plan)
COPY (
  SELECT * FROM (VALUES
    ('North', 520, 584), ('North-East', 310, 287), ('East', 450, 496), ('South-East', 280, 241),
    ('South', 600, 655), ('South-West', 240, 252), ('West', 410, 362), ('North-West', 190, 214)
  ) t(region, plan, actual)
) TO 'data/plan_vs_actual.csv' (HEADER);

-- kpis.csv: actual against goal, in thousands (a bullet chart with bands 150, 225, 300)
COPY (
  SELECT * FROM (VALUES
    ('Revenue (k$)', 268, 250), ('Gross profit (k$)', 121, 140), ('New customers', 212, 200),
    ('Renewals', 176, 225), ('Support tickets closed', 284, 260)
  ) t(metric, actual, goal)
) TO 'data/kpis.csv' (HEADER);

-- estimates.csv: an estimate with its 95% interval per group (bars with error bars)
COPY (
  SELECT * FROM (VALUES
    ('Control', 12.4, 10.9, 13.9), ('Variant A', 14.1, 12.5, 15.7), ('Variant B', 13.2, 11.4, 15.0),
    ('Variant C', 15.6, 13.6, 17.6)
  ) t(dimension, value, lower, upper)
) TO 'data/estimates.csv' (HEADER);

-- pnl_bridge.csv: a profit-and-loss bridge (a waterfall; totals marked in is_total)
COPY (
  SELECT * FROM (VALUES
    (1, 'Revenue', 1200, true), (2, 'Cost of sales', -480, false), (3, 'Operating costs', -310, false),
    (4, 'Other income', 45, false), (5, 'Tax', -95, false), (6, 'Net income', 360, true)
  ) t(step, label, value, is_total)
) TO 'data/pnl_bridge.csv' (HEADER);

-- web_events.ndjson: page events over four weeks, busier on weekday afternoons
COPY (
  SELECT ts, user_id, event, page
  FROM (
    SELECT TIMESTAMP '2025-03-03 00:00:00'
             + INTERVAL (floor(u(i, 'd') * 28)::INT) DAY
             + INTERVAL (floor(8 + 14 * sqrt(u(i, 'h')) - 4 * u(i, 'h2'))::INT % 24) HOUR
             + INTERVAL (floor(u(i, 'm') * 60)::INT) MINUTE AS ts,
           1 + floor(u(i, 'user') * 600)::INT AS user_id,
           CASE WHEN u(i, 'ev') < 0.7 THEN 'view' WHEN u(i, 'ev') < 0.93 THEN 'click' ELSE 'purchase' END AS event,
           pick(['/', '/pricing', '/docs', '/blog', '/signup'], i, 'page') AS page,
           u(i, 'keep') AS keep
    FROM range(1, 4001) t(i)
  )
  -- fewer events at weekends
  WHERE isodow(ts) <= 5 OR keep < 0.45
  ORDER BY ts, user_id
) TO 'data/web_events.ndjson' (FORMAT json);
