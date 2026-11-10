# dchart quick reference

## Flags
| Flag | Meaning |
|---|---|
| `-f`, `--folder DIR` | List DIR's data files (csv, tsv, txt, parquet, json, ndjson, jsonl, xlsx), subfolders included, and let queries name them by relative path |
| `-d`, `--db FILE` | Open or create a DuckDB database file, so tables you create are kept. Default: in memory |
| `-p`, `--port N` | Port to listen on. Default: 4322 |
| `-v`, `--version` | Print the version |
| `DCHART_CONFIG_DIR` | Where `charts.json` lives. Default: `~/.config/dchart` (Linux), `~/Library/Application Support/dchart` (macOS), `%APPDATA%\dchart` (Windows) |

## Keyboard shortcuts
Cmd replaces Ctrl on a Mac. Press `?` in the app for this list.

| Keys | What it does |
|---|---|
| Ctrl+Enter | Run the statement at the cursor, or the selection |
| Ctrl+Shift+Enter | Run the whole editor |
| Ctrl+Space | Show suggestions |
| Alt+1 / Alt+2 | Show results / the chart |
| Ctrl+S | Save the chart |
| Ctrl+Z / Ctrl+Shift+Z | Undo / redo a builder change |
| A | Annotate: click the chart to add a text box, drag one to move it |
| Esc | Close a popup, stop annotating, or bring back the editor after Focus |
| Click a header | Sort by that column |
| Click a cell, then Ctrl+C | Copy the value |
| Shift+click a row number | Copy the whole row |

## Files and queries
```sql
SELECT * FROM 'orders.csv';                 -- a file in --folder
SELECT * FROM 'sales/2024.csv';             -- in a subfolder
SELECT * FROM 'sales/*.csv';                -- every csv in sales/, as one table
SELECT * FROM 'orders.csv' WHERE region = $region;   -- $region gets an input box
```

- **Globs:** a folder with two or more files of one type gets a glob entry in the sidebar.
  Previewing it reads the files with `union_by_name`, so files with different columns
  still combine.
- **Parameters:**
  - A parameter's value goes in as a SQL literal. Numbers, `true`, `false` and `null` go
    in as they are; anything else is quoted.
  - `$` inside strings, comments and `$$…$$` is ignored.

## Chart types and the columns they look for
dchart fills a chart from your columns' names and types. These names are picked up
automatically, the same as in asql:

| Chart type | Columns |
|---|---|
| Bar, Grouped | a category, a number, optionally a second category as the colour |
| Line, Area | a date, a number, optionally a series |
| Trend + CI | `date`, `value`, `series`, and `ci_low` / `ci_high` (or `lower` / `upper`). Or computed from raw rows: 95% CI, ± std. error, ± std. dev., IQR |
| Scatter | two numbers, optionally a size and a colour |
| Heatmap | two categories and a number |
| Pie | a category and a number |
| Histogram | one number |
| Box | a category and a number |
| Waterfall | `label`, `value`, optionally `is_total`. Otherwise the first and last rows are the totals |
| Combo | `bar` and `line` (bars on the left axis, the line on the right) |
| Deviation | `dimension`, `value` (above zero in green, below in red) |
| Bullet | `dimension`, `value`, `target`, plus Bands such as `150, 225, 300` |

## Exports
| Where | What |
|---|---|
| Chart toolbar | **Copy PNG** |
| Chart ▾ menu | PNG, SVG; copy PNG, SVG, the Vega-Lite spec with data, or an asql chart block |
| Results → Export ▾ | CSV of the loaded rows; all rows as CSV, Parquet, Excel or JSON lines |
| Saved charts | Export every chart as one JSON file; Import adds charts from one |

The asql block lists anything asql has no key for on a `-- note:` line, along with column
aliases asql needs.
