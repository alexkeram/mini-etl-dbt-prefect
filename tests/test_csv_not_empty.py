# tests/test_csv_not_empty.py
from __future__ import annotations
from pathlib import Path
import pytest

CSV_FILES = [
    "raw_market_file.csv",
    "raw_market_money.csv",
    "raw_market_time.csv",
    "raw_money.csv",
]


@pytest.mark.parametrize("raw_csv", CSV_FILES)
def test_raw_csv_not_empty(project_root: Path, raw_csv: str):
    """
    Sanity: each source CSV must have at least 1 data row (header + >=1 row).
    """
    csv_path = project_root / "seeds" / raw_csv
    assert csv_path.exists(), f"CSV not found: {csv_path}"
    with csv_path.open("r", encoding="utf-8") as f:
        lines = [line for line in f if line.strip()]
    assert len(lines) >= 2, f"{raw_csv}: empty? only {len(lines)} non-empty lines"
