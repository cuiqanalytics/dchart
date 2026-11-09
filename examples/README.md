# dchart examples

Made-up data for trying every chart type. From the folder that holds `examples/`:

```bash
dchart --folder examples/data
```

Then open http://localhost:4322 and use any of these:

- **`recipes.sql`**: one query per chart type. Paste it into the editor, put the cursor in a
  statement and press Ctrl+Enter (Cmd+Enter on a Mac). The comment above each query names
  the chart type to pick, and the setting to change if one is needed.
- **`charts.json`**: the same charts, already styled and saved. In the sidebar, under
  **Saved charts**, click **Import** and pick this file. Then click a chart to open it.
  The charts read the files in `data/`, so start dchart with `--folder examples/data`.
- **The Files list**: click a file to preview it. `sales/*.csv` reads the three yearly
  files as one table, and 2025's extra `discount` column is filled with NULL for 2023 and 2024.

To keep the tables you create between runs, add a database file:

```bash
dchart --folder examples/data --db examples/demo.duckdb
```

## The files in `data/`

| File | Rows | What it holds | Used for |
|---|---|---|---|
| `orders.csv` | 2,000 | order_id, order_date (2024–2025), region, channel, product, deal_size, amount, customer_id | bar, stacked, grouped, line, trend + CI, scatter, pie, histogram, box, parameters |
| `sales/2023.csv`, `2024.csv`, `2025.csv` | 48 each | month, region, units, revenue; 2025 adds discount | area, the `sales/*.csv` glob |
| `monthly.parquet` | 24 | month, revenue, margin | combo |
| `plan_vs_actual.csv` | 8 | region, plan, actual | deviation, negative bar labels |
| `kpis.csv` | 5 | metric, actual, goal | bullet |
| `estimates.csv` | 4 | dimension, value, lower, upper | error bars |
| `pnl_bridge.csv` | 6 | step, label, value, is_total | waterfall |
| `web_events.ndjson` | 3,351 | ts, user_id, event, page (JSON lines) | heatmap |

`make-data.sql` generates all of them. Its "random" numbers come from `hash()`, so running
it again writes the same files:

```bash
cd examples && duckdb < make-data.sql
```
