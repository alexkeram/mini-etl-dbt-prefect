from __future__ import annotations

import os
import subprocess
from typing import List, Optional

from prefect import flow, task, get_run_logger
from prefect.tasks import task_input_hash
from datetime import timedelta


def run_cmd(cmd: List[str], cwd: Optional[str] = None, env: Optional[dict] = None):
    """
    Run a shell command with live stdout/stderr forwarding.
    Raises CalledProcessError on non-zero exit.
    """
    logger = get_run_logger()
    logger.info("Running: %s", " ".join(cmd))
    completed = subprocess.run(
        cmd,
        cwd=cwd,
        env={**os.environ, **(env or {})},
        check=True,
        text=True,
    )
    logger.info("Command finished: %s", " ".join(cmd))
    return completed


@task(
    retries=2,
    retry_delay_seconds=30,
    cache_key_fn=task_input_hash,
    cache_expiration=timedelta(minutes=30),
)
def dbt_deps(project_dir: str):
    logger = get_run_logger()
    logger.info("Installing dbt packages (dbt deps)")
    run_cmd(["dbt", "deps"], cwd=project_dir)


@task(
    retries=2,
    retry_delay_seconds=30,
)
def dbt_run(project_dir: str, target: Optional[str], threads: int, full_refresh: bool):
    logger = get_run_logger()
    cmd = ["dbt", "run", "--threads", str(threads)]
    if target:
        cmd += ["--target", target]
    if full_refresh:
        cmd += ["--full-refresh"]
    logger.info("Executing models: %s", " ".join(cmd))
    run_cmd(cmd, cwd=project_dir)


@task(
    retries=2,
    retry_delay_seconds=30,
)
def dbt_test(project_dir: str, target: Optional[str], threads: int):
    logger = get_run_logger()
    cmd = ["dbt", "test", "--threads", str(threads)]
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
    Orchestrates: dbt deps -> dbt run -> dbt test
    Parameters:
      project_dir: path to dbt project root (where dbt_project.yml lives)
      target: optional dbt target from profiles.yml
      threads: dbt threads
      full_refresh: force full materialization for non-incremental dev runs
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
    dbt_run(project_dir, target, threads, full_refresh)
    dbt_test(project_dir, target, threads)

    logger.info("Flow finished OK")


if __name__ == "__main__":
    # sensible defaults for local development
    etl_flow(project_dir=".", target=None, threads=4, full_refresh=False)
