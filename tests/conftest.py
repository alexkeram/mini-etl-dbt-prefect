# tests/conftest.py
from __future__ import annotations
from pathlib import Path
import pytest

try:
    import duckdb
except ImportError:
    duckdb = None

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DUCKDB_PATH = PROJECT_ROOT / "warehouse.duckdb"


@pytest.fixture(scope="session")
def project_root() -> Path:
    return PROJECT_ROOT


@pytest.fixture(scope="session")
def duckdb_conn():
    """
    Session-wide DuckDB connection to warehouse.duckdb.
    If the DB file is missing, skip DB-dependent tests with a clear message.
    """
    if duckdb is None:
        pytest.skip("duckdb package not installed")
    if not DUCKDB_PATH.exists():
        pytest.skip(
            f"DuckDB file not found at {DUCKDB_PATH}. "
            "Run `dbt seed && dbt run` (or `python -m flows.etl_flow`) first."
        )
    con = duckdb.connect(str(DUCKDB_PATH))
    try:
        yield con
    finally:
        con.close()
