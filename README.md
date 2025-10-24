# mini-etl-dbt-prefect

Reproducible ETL showing **raw → staging → marts** on **DuckDB** with **dbt**, orchestrated by **Prefect**.
Optimized for **local speed**, **one-click run**, and **quality via dbt tests**.

---

## What's in the analytical part

- Added **ML churn model (Logistic Regression, ROC AUC ≈ 0.93)** trained on marts-layer data.
- Introduced **customer segmentation** (A/B/C) based on churn risk, profit, and behavior.
- Implemented **Prefect + dbt + scikit-learn** integration for end-to-end reproducibility.
- Added **EDA**, **feature interpretation (SHAP)**, and **business recommendations** sections.

Results are documented in the final Jupyter notebook.

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
  - Single-command run: `make run`.

- **Data quality report**
  - Generate a short, human-readable report from `dbt test` results
> Scope intentionally minimal and fast for local demos and CI. No external infra or Prefect deployments required.

---

## Prerequisites

- **Python 3.12+**
- **Git**
- **GNU Make**
  - Windows: install via Chocolatey — `choco install make`
  - macOS (Xcode Command Line Tools) — `xcode-select --install`
  - Linux — your package manager (`sudo apt install make`, `sudo dnf install make`, etc.)

> If `make` is not available, see the **No-make fallback** below — but the recommended path is with `make`.

---

## 🚀 Setup & Run

```bash
git clone https://github.com/alexkeram/mini-etl-dbt-prefect
cd mini-etl-dbt-prefect
make init     # creates .venv, upgrades pip, installs deps, installs & runs pre-commit
make run      # runs Prefect flow: dbt deps → seed → run → test
# optionally
make test     # pytest + dbt test
```

That’s it — from clean clone to running flow in **two commands** (`make init`, `make run`).

---

## No‑make fallback (optional)

If you can’t (or somehow don’t want to) use `make`, you can run the same steps manually.
Below are shell-agnostic recipes (PowerShell / Bash).

### 1) Create a virtualenv and upgrade pip
```bash
# Use whichever command is available: python OR python3
python -m venv .venv || python3 -m venv .venv
./.venv/Scripts/python -m pip install --upgrade pip wheel || ./.venv/bin/python -m pip install --upgrade pip wheel
```

### 2) Install requirements and pre-commit hooks
```bash
./.venv/Scripts/python -m pip install -r requirements.txt || ./.venv/bin/python -m pip install -r requirements.txt
./.venv/Scripts/python -m pre_commit install || ./.venv/bin/python -m pre_commit install
./.venv/Scripts/python -m pre_commit run --all-files || ./.venv/bin/python -m pre_commit run --all-files
```

### 3) Run the flow
```bash
./.venv/Scripts/python -m flows.etl_flow || ./.venv/bin/python -m flows.etl_flow
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

The project already sets `DBT_PROFILES_DIR` to `./profiles` via the **Makefile**,
so no extra env setup is required for standard runs.

---

## Makefile targets

```make
init  # create venv, upgrade pip, install deps, install & run pre-commit
run   # Prefect flow: dbt deps → seed → run → test
test  # pytest + dbt test
lint  # ruff check
clean # remove caches
```

---

## Windows schedule

A venv-aware runner at `.venv/Scripts/run_etl.cmd` that:
- uses `.venv/Scripts/python.exe`,
- sets `DBT_PROFILES_DIR=./profiles`,
- runs `python -m flows.etl_flow`,
- logs to `./logs/cron.log`.

Install the scheduled task (02:00 daily):

```bash
make schedule
make schedule-status
make schedule-run   # trigger now to test; then check logs/cron.log
make unschedule     # remove
```
You can change the schedule time in the .venv\Scripts\register_tsk.ps1 file.
___


## Orchestration details (reference)

Flow entry point: `flows/etl_flow.py` runs the sequence
`dbt deps → dbt seed → dbt run → dbt test` with retries and logs.

Run with custom params if needed:
```bash
python -c "from flows.etl_flow import etl_flow; etl_flow(project_dir='.', threads=8, full_refresh=True)"
```

---

## Continuous Integration (CI)

`.github/workflows/ci.yml` runs on push/PR:
- **Ruff** (lint)
- **Pytest** (unit tests)

> dbt execution can be added to CI later, once models are stable and CI artifacts are sized appropriately.

## Data Quality Report

Generate a short, human-readable report from `dbt test` results:

```bash
make quality
# outputs:
# - reports/quality_report.md   (Markdown for humans)
# - reports/quality_report.json (JSON for tooling)
