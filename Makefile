# Cross-platform venv executables
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

.PHONY: init lint test run clean

init:
	@echo ">>> Creating/Updating venv & installing hooks"
	@$(PIP) install -r requirements.txt
	@pre-commit install
	@pre-commit run --all-files || true
	@echo ">>> Done. Venv ready, pre-commit installed."

lint:
	@echo ">>> Ruff check"
	@$(PY) -m ruff check .

test:
	@echo ">>> Pytest (quiet)"
	@$(PY) -m pytest -q

# Placeholder for now; will run Prefect flow
run:
	@echo ">>> TODO: Hook up Prefect flow under construction"
	@$(PY) -c "print('Flow placeholder — will be implemented later')"

clean:
	@echo ">>> Cleaning caches"
	@find . -type d -name "__pycache__" -prune -exec rm -rf {} +
	@rm -rf .ruff_cache .pytest_cache
