# --- dbt profiles ---
export DBT_PROFILES_DIR := $(CURDIR)/profiles

# --- venv executables ---
ifeq ($(OS),Windows_NT)
PY    := .venv/Scripts/python.exe
PIP   := .venv/Scripts/pip.exe
SHELL := bash
else
PY    := .venv/bin/python
PIP   := .venv/bin/pip
endif

# Call dbt
DBT_CMD := $(PY) -m dbt

.PHONY: init venv lint test run clean clean-venv dbt-seed dbt-run dbt-test dbt-debug

# 1) Create venv
venv:
	@if [ ! -d ".venv" ]; then \
	  echo ">>> Creating venv"; \
	  (command -v python >/dev/null 2>&1 && python -m venv .venv) || \
	  (command -v python3 >/dev/null 2>&1 && python3 -m venv .venv) || \
	  { echo "ERROR: Python not found in PATH. Install Python and retry."; exit 1; }; \
	else \
	  echo ">>> venv exists"; \
	fi
	@echo ">>> Upgrading pip"
	@$(PY) -m pip install --upgrade pip wheel

# 2) Dependencies and pre-commit from venv
init: venv
	@echo ">>> Installing requirements"
	@$(PY) -m pip install -r requirements.txt
	@echo ">>> Installing pre-commit hooks"
	@$(PY) -m pre_commit install
	@$(PY) -m pre_commit run --all-files
	@echo ">>> Done. Venv ready, pre-commit installed."

lint:
	@echo ">>> Ruff check"
	@$(PY) -m ruff check .

test:
	@echo ">>> Pytest"
	@$(PY) -m pytest
	@echo ">>> dbt tests"
	@$(DBT_CMD) test --profiles-dir "$(DBT_PROFILES_DIR)"

run:
	@echo ">>> Prefect flow"
	@$(PY) -m flows.etl_flow

clean:
	@echo ">>> Cleaning caches"
	@find . -type d -name "__pycache__" -prune -exec rm -rf {} +
	@rm -rf .ruff_cache .pytest_cache .mypy_cache

clean-venv:
	@echo ">>> Removing .venv"
	@rm -rf .venv

dbt-seed:
	@echo ">>> dbt seed"
	@$(DBT_CMD) seed --profiles-dir "$(DBT_PROFILES_DIR)"

dbt-run:
	@echo ">>> dbt run"
	@$(DBT_CMD) run --profiles-dir "$(DBT_PROFILES_DIR)"

dbt-test:
	@echo ">>> dbt test"
	@$(DBT_CMD) test --profiles-dir "$(DBT_PROFILES_DIR)"

dbt-debug:
	@echo ">>> dbt debug"
	@$(DBT_CMD) debug --profiles-dir "$(DBT_PROFILES_DIR)"
