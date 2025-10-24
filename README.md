# mini-etl-dbt-prefect

Reproducible ETL on DuckDB with dbt, orchestrated by Prefect. Optimized for local speed, one‑click run, and quality via dbt tests.

---

## What's in the analytical part

- ML churn model (Logistic Regression, ROC AUC ~0.93) trained on marts-layer data.
- Customer segmentation (A/B/C) based on churn risk, profit, and behavior.
- Prefect + dbt + scikit-learn integration for end-to-end reproducibility.
- EDA, feature interpretation (SHAP), and business recommendations.
- Results are documented in the final Jupyter notebook.

### Supervised Learning — model quality
- Goal: predict probability of a decrease in customer activity and identify segments for personalized marketing.
- Pipeline: dbt, Prefect, DuckDB, scikit-learn (reproducible, one‑click setup).
- Model: ROC AUC ~0.93 enables early churn detection.
- Focus segments:
  - Segment A: retention of high‑value customers.
  - Segment B: margin optimization among promo‑sensitive clients.

---

## What this repository delivers

- Environment and tooling
  - Reproducible local setup: requirements.txt, virtualenv, Makefile targets.
  - Code quality gates: pre-commit (Black and Ruff) and minimal CI (Ruff and Pytest).

- Data warehouse (local)
  - dbt and DuckDB project with project-local profiles and seeds (CSV to DuckDB file).
  - Clean staging models (typing, renaming, deduplication and filters) and simple marts (dimension and fact).

- Data quality
  - dbt tests: not_null, unique, relationships, and a custom check via dbt_utils.expression_is_true (for example, numeric non‑negativity, date lower bound).

- Orchestration
  - Prefect flow as code running dbt deps, dbt seed, dbt run, dbt test with retries and informative logs.
  - Single‑command run: make run.

- Data quality report
  - Generates a short, human‑readable report from dbt test results.

---

## Prerequisites

- Python 3.12+
- Git
- GNU Make
  - Windows: Chocolatey — choco install make
  - macOS: Xcode Command Line Tools — xcode-select --install
  - Linux: your package manager (for example, sudo apt install make)

---

## Setup and run

```bash
git clone https://github.com/alexkeram/mini-etl-dbt-prefect
cd mini-etl-dbt-prefect
make init     # creates .venv, upgrades pip, installs deps, installs and runs pre-commit
make run      # runs Prefect flow: dbt deps, seed, run, test
```

From clean clone to running flow in two commands.

---

## Configuration

### DuckDB and dbt

- Project file: dbt_project.yml
- Local profile: profiles/profiles.yml (project‑local for reproducibility)


The project sets DBT_PROFILES_DIR=./profiles via the Makefile, so no extra environment setup is required for standard runs.

---

## Makefile commands

Core:
- init: create venv, upgrade pip, install dependencies, install pre‑commit, run pre‑commit locally if not in CI
- run: run the Prefect ETL flow
- test: run pytest, then dbt test
- lint: ruff check
- clean: remove caches
- clean-venv: remove .venv

dbt helpers:
- dbt-deps: dbt deps
- dbt-seed: dbt seed
- dbt-run: dbt run
- dbt-test: dbt test
- dbt-debug: dbt debug

Docs:
- docs: dbt docs generate (artifacts in ./target)
- docs-serve: dbt docs serve on port 8080

Windows scheduler:
- schedule: register Windows Task Scheduler job
- unschedule: remove the task
- schedule-run: trigger now
- schedule-status: show status

Quality report:
- quality: run dbt tests and generate reports/quality_report.md and .json
- quality-open: open the Markdown report on Windows

---

## Windows schedule

A venv‑aware runner uses .venv/Scripts/python.exe, sets DBT_PROFILES_DIR=./profiles, runs python -m flows.etl_flow, and logs to ./logs/cron.log.

Install the scheduled task (02:00 daily):
```bash
make schedule
make schedule-status
make schedule-run
make unschedule
```
Change the schedule time in scripts/register_task.ps1.

---

## Orchestration details

Flow entry point: flows/etl_flow.py runs the sequence dbt deps, dbt seed, dbt run, dbt test with retries and logs.

Run with custom parameters if needed:
```bash
python -c "from flows.etl_flow import etl_flow; etl_flow(project_dir='.', threads=8, full_refresh=True)"
```

---

## Continuous Integration

.github/workflows/ci.yml runs on push or pull request:
- Setup Python 3.12
- make init
- make lint
- make pytest-only
- make dbt-deps
- make dbt-seed
- make dbt-run
- make dbt-test

Any lint, test, or dbt failure fails the CI and blocks the PR.

---

## Data quality report

Generate a report from dbt test results:
```bash
make quality
# outputs:
# - reports/quality_report.md
# - reports/quality_report.json
```
