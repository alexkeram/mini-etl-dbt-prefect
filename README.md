# mini-etl-dbt-prefect

Reproducible ETL showing **raw → staging → marts** on **DuckDB** with **dbt**, orchestrated by **Prefect**.
We optimize for **local speed**, **one-click run**, and **quality via dbt tests**.

---

## What this repository delivers (current state)

- **Environment & Tooling**
  - Reproducible local setup: `requirements.txt`, virtualenv, **Makefile** targets.
  - Code quality gates: **pre-commit** (Black + Ruff) and **minimal CI** (Ruff + Pytest).

- **Data Warehouse (local)**
  - **dbt + DuckDB** project with project-local **profiles** and seeds (CSV → DuckDB file).
  - Clean **staging** models (typing, renaming, dedup/filters) and simple **marts** (dimension/fact).

- **Data Quality**
  - **dbt tests**: `not_null`, `unique`, `relationships`, and a custom check via
    `dbt_utils.expression_is_true` (e.g., numeric non-negativity, date lower-bound).

- **Orchestration**
  - **Prefect flow as code** running `dbt deps → dbt run → dbt test` with **retries** and **informative logs**.
  - Single-command run: `python -m flows.etl_flow` or `make run`.

> Scope intentionally minimal and fast for local demos and CI. No external infra or Prefect deployments required.

---

## Prerequisites (Windows)

- **Python 3.11**
- **Git for Windows** (includes **Git Bash**)
- **GNU Make** (recommended; optional)
  - With Chocolatey: `choco install make`
- JetBrains **DataSpell** (optional): set interpreter to `.\.venv\Scripts\python.exe` after creating the venv.

---

## Quickstart

### Create and activate a virtualenv
```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
```

### Install dependencies & pre-commit
```powershell
pip install -r requirements.txt
pre-commit install
pre-commit run --all-files
```

### One-click actions (with `make`)
```powershell
make init   # install deps + run pre-commit on all files
make lint   # ruff check (auto-fix simple issues)
make test   # pytest -q + dbt tests (when configured)
make run    # Prefect flow: dbt deps → run → test
make clean  # clean cached files
```

**No `make`?** Use the equivalents:
```powershell
# init
pip install -r requirements.txt
pre-commit install
pre-commit run --all-files

# run
python -m flows.etl_flow

# tests
pytest -q
dbt test
```

---

## Configuration

### DuckDB & dbt

- Project file: `dbt_project.yml`
- Local profile: `profiles/profiles.yml` (project-local for reproducibility)

Example `profiles/profiles.yml`:
```yaml
mini_etl_profile:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: ./warehouse.duckdb
      schema: analytics
      threads: 4
```

Set the profile location for the current PowerShell session:
```powershell
$Env:DBT_PROFILES_DIR = "$(Get-Location)\profiles"
dbt debug   # should end with "Connection test: OK"
```

### Seeds (CSV → DuckDB)

- Place demo/real CSVs under `seeds/` (UTF-8).
- If your CSVs use `;` as a delimiter or contain non-ASCII headers, configure in `dbt_project.yml`:
```yaml
seeds:
  mini_etl_dbt_prefect:
    +delimiter: ";"
```

Load seeds:
```powershell
dbt seed
```

---

## Models

- **Staging** (`models/staging/*`): cleaning & typing (e.g., `replace(',', '.')` for decimals, `cast(...)` to date/number, column renames to English).
- **Marts** (`models/marts/*`): analytics-friendly models (dimensions/facts).



Run models:
```powershell
dbt run
```



---

## Orchestration (Prefect)

**Flow-as-code** that runs `dbt deps → dbt run → dbt test` with retries and logs.

- Entry point: `flows/etl_flow.py`
- Run from project root:
```powershell
python -m flows.etl_flow
```
- Parameters (edit at the bottom of `flows/etl_flow.py` or call the function directly):
  - `project_dir` (default `.`)
  - `target` (optional; from `profiles.yml`)
  - `threads` (default `4`)
  - `full_refresh` (default `False`)

Example one-off run with custom params:
```powershell
python -c "from flows.etl_flow import etl_flow; etl_flow(project_dir='.', threads=8, full_refresh=True)"
```

---

## Makefile targets

```make
init:  # install deps + run pre-commit on all files
lint:  # ruff check (auto-fix simple issues)
test:  # pytest -q (+ dbt test if configured)
run:   # python -m flows.etl_flow
clean: # rm -rf .ruff_cache .pytest_cache
```

---

## Continuous Integration (CI)

`.github/workflows/ci.yml` runs on every push/PR:
- **Ruff** (lint)
- **Pytest** (unit tests)

> dbt execution can be added to CI later, once models are stable and CI artifacts are sized appropriately.

---

## What's next

- Generate **dbt docs** locally and add a simple **raw→staging→marts** diagram to the README.
- Add **3 Pytest sanity checks** (non‑empty CSV, expected columns in `fct_orders`, `sum(amount) > 0`) and keep them in CI.
- Do a **clean‑clone smoke run** (`make init/run/test`) and tighten the README where needed.

**Then:**
- Add a couple of **custom dbt tests** and document quality gates.
- Set up an **OS cron** example to run `python -m flows.etl_flow` on a schedule.
- Implement **incremental models** (delete+insert, `unique_key`, `on_schema_change: append_new_columns`).
- Produce a tiny **quality report** from `target/test_results.json`.
- **Extend CI** to run `dbt deps/run/test`.
- Final polish and a lightweight release tag.
