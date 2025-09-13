# mini-etl-dbt-prefect

A tiny, reproducible ETL showing **raw → staging → marts** on **DuckDB** with **dbt**, orchestrated by **Prefect**.
We optimize for **local speed**, **one-click run**, and **quality via dbt tests**.

---

## Why this stack

- **DuckDB + dbt**: fast local DWH for demos and CI; zero external infra required.
- **Prefect as code**: Python flow to run `dbt deps/run/test` with retries and logs (added later).
- **Quality**: only **dbt tests** (not_null / unique / relationships + a simple custom check).
- **Reproducible**: `Makefile` + `pre-commit` + minimal CI from day one.

> This README captures **Day 1** deliverables only. dbt models, Prefect flow details, and docs arrive on Days 2–5.

---

## Prerequisites (Windows)

- **Python 3.11**
- **Git for Windows** (includes **Git Bash**)
- **GNU Make** (recommended on Windows)
  - With Chocolatey: `choco install make`
  - Or use Git Bash which typically includes `make` on many setups

> In JetBrains **DataSpell**: set the project interpreter to `.\.venv\Scripts\python.exe` after creating the venv.

---

## Quickstart

```powershell
# 1) Create and activate a local virtualenv (PowerShell)
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip

# 2) Install dependencies and enable pre-commit hooks
pip install -r requirements.txt
pre-commit install

# 3) One-click actions (requires `make`)
make init   # install deps + pre-commit run on all files (once)
make lint   # ruff check (auto-fix simple issues)
make fmt    # black formatting
make test   # pytest -q (has a smoke test today)
make run    # placeholder ETL flow (real Prefect flow on Day 4)
```

**No `make`?** Use the equivalent PowerShell commands:
```powershell
# init
pip install -r requirements.txt
pre-commit install

# run
python -m flows.etl_flow

# test
pytest -q

# format + lint
black .
ruff check . --fix
```

---

## Project Layout (Day 1)

```
mini-etl-dbt-prefect/
  flows/
    etl_flow.py          # Prefect flow placeholder (real flow on Day 4)
  tests/
    test_smoke.py        # lightweight smoke test so CI is green on Day 1
  requirements.txt
  Makefile
  .pre-commit-config.yaml
  .github/
    workflows/
      ci.yml             # minimal CI: ruff + pytest
  README.md
```

---

## Files Added/Updated Today

### 1) `requirements.txt`

```txt
# core
dbt-core>=1.6,<2.0
dbt-duckdb>=1.6,<2.0
duckdb>=1.0.0
prefect>=2.14

# quality & tooling
pytest>=7.4
ruff>=0.4
black>=24.4
pre-commit>=3.6
```

> Purpose: lock in core tools for Day 1 and coming days (dbt, DuckDB, Prefect, pytest, ruff, black, pre-commit).

---

### 2) `.pre-commit-config.yaml`

```yaml
repos:
  - repo: https://github.com/psf/black
    rev: 24.8.0
    hooks:
      - id: black
        language_version: python3

  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.6.9
    hooks:
      - id: ruff
        args: [--fix]
```

> Purpose: enforce consistent code style and quick feedback **before** pushing (auto-fixes included).

---

### 3) `flows/etl_flow.py` (placeholder)

```python
# flows/etl_flow.py
def main():
    print("ETL flow placeholder (Day 1). Real Prefect flow will appear on Day 4.")

if __name__ == "__main__":
    main()
```

> Purpose: make `python -m flows.etl_flow` and `make run` do something today, so the repo is runnable.

---

### 4) `tests/test_smoke.py`

```python
# tests/test_smoke.py
def test_smoke():
    assert True
```

> Purpose: let `pytest -q` pass in CI even before real tests are added (Day 6).

---

### 5) `Makefile`

```make
.PHONY: init run test fmt lint

init:
	python -m pip install --upgrade pip
	pip install -r requirements.txt
	pre-commit install
	pre-commit run --all-files || true

run:
	python -m flows.etl_flow

test:
	pytest -q

fmt:
	black .

lint:
	ruff check . --fix
```

> Purpose: **one-click run** for common tasks locally and in CI.

> Windows note: if you don’t want to install `make`, use the PowerShell equivalents shown in **Quickstart**.

---

### 6) GitHub Actions CI — `.github/workflows/ci.yml`

```yaml
name: ci

on:
  push:
  pull_request:

jobs:
  lint-and-test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.11"

      - name: Install deps
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt

      - name: Ruff
        run: ruff check . --output-format=github

      - name: Pytest
        run: pytest -q
```

> Purpose: fast quality signal on every push/PR. Today it runs `ruff` and `pytest` only.

---

## One-Click Verification Checklist (Day 1)

- [ ] `make init` finishes without errors (hooks installed, initial formatting applied).
- [ ] `make lint` passes (or auto-fixes and passes on re-run).
- [ ] `make test` shows `1 passed`.
- [ ] `make run` prints the placeholder line.
- [ ] GitHub Actions shows a green run on the latest commit (Ruff + Pytest).

---

## Roadmap (Two Weeks)

**Week 1**
- Day 2 — `dbt init` on DuckDB; `profiles.yml` pointing to `warehouse.duckdb`.
- Day 3 — dbt tests (not_null, unique, relationships, + one custom expression).
- Day 4 — Prefect flow calling `dbt deps → run → test` with retries and logging.
- Day 5 — `dbt docs generate` locally + README v1 with architecture diagram.
- Day 6 — Python sanity tests (non-empty CSV, required columns, simple aggregate invariant).
- Day 7 — Clean clone test; ensure `make init/run/test` works from scratch.

**Week 2**
- Incremental models: `materialized: incremental`, `strategy: delete+insert`, `unique_key`, `on_schema_change: append_new_columns`.
- CI extension to include `dbt run/test` (Day 12).
- Polishing and final README/docs.
