# Cross-platform venv executables
export DBT_PROFILES_DIR := $(CURDIR)/profiles
DBT := dbt
DBT_ENV := DBT_PROFILES_DIR="$(CURDIR)/profiles"

ifeq ($(OS),Windows_NT)
PY := .venv/Scripts/python.exe
PIP := .venv/Scripts/pip.exe
ACT := .venv/Scripts/activate
SHELL := bash
else
PY := .venv/bin/python
PIP := .venv/bin/pip
ACT := .venv/bin/activate
endif

.PHONY: init lint test run clean dbt-seed dbt-run dbt-test dbt-debug

init:
	@echo ">>> Creating/Updating venv & installing hooks"
	@$(PIP) install -r requirements.txt
	@pre-commit install
	@pre-commit run --all-files
	@echo ">>> Done. Venv ready, pre-commit installed."

lint:
	@echo ">>> Ruff check"
	@$(PY) -m ruff check .

test:
	@echo ">>> Pytest"
	@$(PY) -m pytest
	@echo ">>> dbt tests"
	@$(DBT_ENV) $(DBT) test

run:
	@echo ">>> Prefect flow"
	@$(PY) -m flows.etl_flow

clean:
	@echo ">>> Cleaning caches"
	@find . -type d -name "__pycache__" -prune -exec rm -rf {} +
	@rm -rf .ruff_cache .pytest_cache

dbt-seed:
	@echo ">>> dbt seed"
	@$(DBT_ENV) $(DBT) seed

dbt-run:
	@echo ">>> dbt run"
	@$(DBT_ENV) $(DBT) run

dbt-test:
	@echo ">>> dbt test"
	@$(DBT_ENV) $(DBT) test

dbt-debug:
	@echo ">>> dbt debug"
	@$(DBT_ENV) $(DBT) debug
