# flows/etl_flow.py
from __future__ import annotations

import os
import sys
import subprocess
from pathlib import Path
from typing import List, Optional
from datetime import timedelta

from prefect import flow, task, get_run_logger
from prefect.tasks import task_input_hash


def _dbt_executable() -> Optional[str]:
    """
    Return absolute path to dbt executable in current venv if present,
    e.g. <repo>/.venv/Scripts/dbt.exe on Windows or <repo>/.venv/bin/dbt on *nix.
    """
    scripts_dir = Path(sys.executable).parent  # .../.venv/Scripts (win) or .../.venv/bin (*nix)
    exe_name = "dbt.exe" if os.name == "nt" else "dbt"
    candidate = scripts_dir / exe_name
    return str(candidate) if candidate.exists() else None


def _dbt_cmd(*args: str) -> List[str]:
    """
    Prefer calling the dbt executable by absolute path (no PATH dependency).
    Fallback to `python -m dbt ...` if the exe is missing.
    """
    exe = _dbt_executable()
    if exe:
        return [exe, *args]
    # fallback: module mode (works if dbt installed in this interpreter)
    return [sys.executable, "-m", "dbt", *args]


def run_cmd(cmd: List[str], cwd: Optional[str] = None, env: Optional[dict] = None):
    """
    Run a command; raise CalledProcessError on non-zero exit.
    We do NOT rely on PATH; cmd[0] is absolute dbt exe (or python.exe).
    """
    logger = get_run_logger()
    merged_env = dict(os.environ)
    if env:
        merged_env.update(env)

    # Ensure absolute CWD (Windows can be picky)
    if cwd:
        cwd = str(Path(cwd).resolve())

    logger.info("Using Python: %s", sys.executable)
    logger.info("DBT exe resolved: %s", _dbt_executable() or "(module mode via python -m dbt)")
    logger.info("DBT_PROFILES_DIR=%s", merged_env.get("DBT_PROFILES_DIR"))
    logger.info("Running: %s", " ".join(cmd))

    completed = subprocess.run(
        cmd,
        cwd=cwd,
        env=merged_env,
        check=True,
        text=True,
    )
    logger.info("Command finished: %s", " ".join(cmd))
    return completed


@task(
    retries=2,
    retry_delay_seconds=10,
    cache_key_fn=task_input_hash,
    cache_expiration=timedelta(minutes=10),
)
def dbt_deps(project_dir: str):
    logger = get_run_logger()
    logger.info("Installing dbt packages (dbt deps)")
    run_cmd(_dbt_cmd("deps"), cwd=project_dir)


@task(retries=2, retry_delay_seconds=10)
def dbt_seed(project_dir: str):
    logger = get_run_logger()
    logger.info("Loading seeds (dbt seed)")
    run_cmd(_dbt_cmd("seed"), cwd=project_dir)


@task(retries=2, retry_delay_seconds=30)
def dbt_run(project_dir: str, target: Optional[str], threads: int, full_refresh: bool):
    logger = get_run_logger()
    cmd = _dbt_cmd("run", "--threads", str(threads))
    if target:
        cmd += ["--target", target]
    if full_refresh:
        cmd += ["--full-refresh"]
    logger.info("Executing models: %s", " ".join(cmd))
    run_cmd(cmd, cwd=project_dir)


@task(retries=2, retry_delay_seconds=10)
def dbt_test(project_dir: str, target: Optional[str], threads: int):
    logger = get_run_logger()
    cmd = _dbt_cmd("test", "--threads", str(threads))
    if target:
        cmd += ["--target", target]
    logger.info("Running tests: %s", " ".join(cmd))
    run_cmd(cmd, cwd=project_dir)


@flow(name="mini-etl dbt flow")
def etl_flow(
    project_dir: str = ".",
    target: Optional[str] = None,
    threads: int = 4,
    full_refresh: bool = False,
):
    """
    Orchestrates: dbt deps -> dbt seed -> dbt run -> dbt test
    """
    logger = get_run_logger()
    logger.info(
        "Starting flow with project_dir=%s target=%s threads=%d full_refresh=%s",
        project_dir,
        target,
        threads,
        full_refresh,
    )

    dbt_deps(project_dir)
    dbt_seed(project_dir)
    dbt_run(project_dir, target, threads, full_refresh)
    dbt_test(project_dir, target, threads)

    logger.info("Flow finished OK")


if __name__ == "__main__":
    etl_flow(project_dir=".", target=None, threads=4, full_refresh=False)
