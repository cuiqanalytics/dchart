# dchart

**Query in. Publication-ready chart out.**

`dchart` is a SQL editor and chart builder that runs in your browser, on your machine. Query
your CSV, Parquet and JSON files with DuckDB, pick one of 14 chart types, and the chart comes
out styled for a report or a paper. DuckDB, Vega-Lite and the editor are all inside one
binary, so it works offline and your data never leaves your laptop.

```bash
curl -fsSL https://cuiqanalytics.github.io/dchart/install.sh | sh   # macOS, Linux
dchart --folder ~/.local/lib/dchart/examples/data
# then open http://localhost:4322
```

On Windows, in PowerShell: `irm https://cuiqanalytics.github.io/dchart/install.ps1 | iex`.

---

## Install
| Platform | Builds |
|---|---|
| macOS | Apple silicon (arm64), Intel (x86-64) |
| Linux | x86-64, arm64 (glibc 2.34 or newer: Ubuntu 22.04+, Debian 12+, RHEL 9+; not Alpine) |
| Windows | x86-64 |

**macOS and Linux:**

```bash
curl -fsSL https://cuiqanalytics.github.io/dchart/install.sh | sh
```

The script picks the build for your machine. It puts dchart, its DuckDB library and the
examples in `~/.local/lib/dchart`, and links `~/.local/bin/dchart`. If `~/.local/bin` isn't on
your PATH, it tells you the line to add.

**Windows**, in PowerShell:

```powershell
irm https://cuiqanalytics.github.io/dchart/install.ps1 | iex
```

That installs to `%LOCALAPPDATA%\dchart` and adds the folder to your user PATH. Open a new
terminal afterwards so the PATH change applies.

Neither script needs admin rights. There's no account and no telemetry.

**Upgrade** by running the install command again. It replaces the old version with the latest
release. Your saved charts are kept.

**Uninstall:**
- macOS and Linux: `rm -rf ~/.local/lib/dchart ~/.local/bin/dchart`
- Windows: delete `%LOCALAPPDATA%\dchart` and remove it from your user PATH.

**By hand:** download the archive for your platform from the
[latest release](https://github.com/cuiqanalytics/dchart/releases/latest) and check it
against `SHA256SUMS`. Unpack it anywhere and run `dchart` (`dchart.exe`) from that folder.
Keep `libduckdb` next to it, because that's where dchart looks for it. On macOS, an archive
downloaded in a browser is quarantined. Clear that before running it:
`xattr -dr com.apple.quarantine dchart-cli-macos-*`.

## Quick start
```bash
dchart                                   # http://localhost:4322, an in-memory database
dchart --folder data/                    # list data/'s files (subfolders too) in the sidebar
dchart --db sales.duckdb                 # keep the tables you create in a database file
dchart --port 5000 -f data/ -d sales.duckdb
```

With `--folder`, queries name files by their path inside the folder:
`SELECT * FROM 'orders.csv'`, or `FROM 'sales/*.csv'` for a folder of files read as one table.

### Try the examples
The install includes made-up data for every chart type in `~/.local/lib/dchart/examples`
(`%LOCALAPPDATA%\dchart\examples` on Windows):

- `recipes.sql`: one query per chart type. Paste it into the editor, put the cursor in a
  query and press Ctrl+Enter.
- `charts.json`: the same charts, styled and saved. Import it under **Saved charts** in the
  sidebar.

## What it does
- **An editor that knows your files.**
  - Run the statement under the cursor, with progress and a Stop button for long queries.
  - `$name` parameters get input boxes.
  - History, autocomplete, and errors that point at the failing line.
- **Fourteen chart types:** bar, grouped, line, trend + CI, area, scatter, heatmap, pie,
  histogram, box, waterfall, combo, deviation and bullet. They're filled in from your
  columns' names and types.
- **A publication theme by default:**
  - a left-aligned title and subtitle, quiet gridlines and humanized axis titles;
  - value labels that stay legible: inside a bar in white or dark ink by contrast, outside
    when they don't fit.
- **Reference lines and annotations:** lines at a value or a statistic, shaded bands, and
  text boxes you place with a click and drag clear of the data.
- **Exports:**
  - PNG and SVG; the Vega-Lite spec;
  - every row as CSV, Parquet, Excel or JSON lines (through DuckDB `COPY`);
  - an [asql](https://www.asql.dev/) chart block for a report.
- **Saved charts** with thumbnails. You can rename, filter, import and export them.
- **Localhost only.** Its API answers only its own page, so other websites can't run SQL
  through it.

See [QUICK_REFERENCE.md](QUICK_REFERENCE.md) for the flags, shortcuts, chart types and
column-name hints.

## Files
- **Saved charts:** `charts.json` in `~/.config/dchart` (Linux), `~/Library/Application Support/dchart`
  (macOS) or `%APPDATA%\dchart` (Windows). Set `DCHART_CONFIG_DIR` to use another folder.
- **Builder state and history:** kept in the browser, per port.
- **Excel export:** needs DuckDB's excel extension. Run `INSTALL excel;` once, with internet
  access.

## License
Free to use. See [LICENSE](LICENSE). Charts and exports you make are yours.
