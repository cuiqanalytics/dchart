-- dchart recipes. Start dchart with the example data:
--
--   dchart --folder examples/data
--
-- Paste this file into the editor, put the cursor in a statement and press Ctrl+Enter
-- (Cmd+Enter on a Mac). Then pick the chart type named above it in Chart → Data → Chart type,
-- if dchart did not pick it already.

-- Bar: revenue by region (Style → Mark options → Value labels)
SELECT region, round(sum(amount)) AS revenue FROM 'orders.csv' GROUP BY region ORDER BY revenue DESC;

-- Bar with negative values: labels sit inside the end of each bar, in white or dark text
SELECT region, actual - plan AS vs_plan FROM 'plan_vs_actual.csv';

-- Stacked bar: revenue by region and channel. Set color to channel, and turn on Value labels
SELECT region, channel, round(sum(amount)) AS revenue FROM 'orders.csv' GROUP BY ALL ORDER BY region;

-- Grouped: the same, side by side
SELECT region, channel, round(sum(amount)) AS revenue FROM 'orders.csv' GROUP BY ALL ORDER BY region;

-- Line: monthly revenue per channel
SELECT date_trunc('month', order_date) AS month, channel, round(sum(amount)) AS revenue
FROM 'orders.csv' GROUP BY ALL ORDER BY month;

-- Trend + CI from precomputed bounds (picked up from ci_low / ci_high)
SELECT date_trunc('month', order_date) AS date, channel AS series,
       avg(amount) AS value,
       avg(amount) - 1.96 * stddev(amount) / sqrt(count(*)) AS ci_low,
       avg(amount) + 1.96 * stddev(amount) / sqrt(count(*)) AS ci_high
FROM 'orders.csv' GROUP BY ALL ORDER BY date;

-- Trend + CI computed from raw rows: set Band to "95% CI of the mean", and the y aggregate to mean
SELECT date_trunc('month', order_date) AS date, channel AS series, amount AS value FROM 'orders.csv';

-- Area: units per month, stacked by region, across the three yearly files (a glob)
SELECT month, region, units FROM 'sales/*.csv' ORDER BY month;

-- Scatter: order amount against how many orders each customer placed
SELECT customer_id, count(*) AS orders, sum(amount) AS spend, any_value(region) AS region
FROM 'orders.csv' GROUP BY customer_id;

-- Heatmap: events by hour and weekday (Style → Mark options → Value labels). The grid is
-- built first, so empty hours show as 0 and the axes keep this order
SELECT lpad(h::VARCHAR, 2, '0') AS hour, d.day AS weekday, count(e.ts) AS events
FROM range(24) t(h)
CROSS JOIN (VALUES (1, 'Mon'), (2, 'Tue'), (3, 'Wed'), (4, 'Thu'), (5, 'Fri'), (6, 'Sat'), (7, 'Sun')) d(n, day)
LEFT JOIN 'web_events.ndjson' e ON hour(e.ts::TIMESTAMP) = h AND isodow(e.ts::TIMESTAMP) = d.n
GROUP BY h, d.n, d.day ORDER BY d.n, h;

-- Pie: orders by channel
SELECT channel, count(*) AS orders FROM 'orders.csv' GROUP BY channel;

-- Histogram: order amounts
SELECT amount FROM 'orders.csv' WHERE amount < 3000;

-- Box: order amounts by product
SELECT product, amount FROM 'orders.csv';

-- Waterfall: a profit-and-loss bridge, with totals from the is_total column
SELECT label, value, is_total FROM 'pnl_bridge.csv' ORDER BY step;

-- Waterfall with the first and last rows as totals
SELECT * FROM (VALUES ('Opening', 1000), ('New sales', 420), ('Churn', -260),
  ('Discounts', -90), ('Closing', 1070)) t(label, value);

-- Combo: revenue as bars on the left axis, margin as a line on the right
SELECT month, revenue AS bar, margin AS line FROM 'monthly.parquet' WHERE month >= DATE '2025-01-01';

-- Deviation: green above plan, red below, sorted by value
SELECT region AS dimension, actual - plan AS value FROM 'plan_vs_actual.csv';

-- Bullet: set Bands to 150, 225, 300
SELECT metric AS dimension, actual AS value, goal AS target FROM 'kpis.csv';

-- Error bars: Bar type, then Error bars → lower / upper columns
SELECT dimension, value, lower, upper FROM 'estimates.csv';

-- Parameters: a Parameters bar appears above the editor. Try region = West, since = 2025-01-01
SELECT date_trunc('week', order_date) AS week, sum(amount) AS revenue
FROM 'orders.csv'
WHERE region = $region AND order_date >= $since
GROUP BY week ORDER BY week;

-- Tables: make a table, and it shows up under Tables in the sidebar
CREATE OR REPLACE TABLE customers AS
SELECT customer_id, any_value(region) AS region, count(*) AS orders, sum(amount) AS spend
FROM 'orders.csv' GROUP BY customer_id;
