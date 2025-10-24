# scripts/quality_report.py
from __future__ import annotations

import json
import sys
from pathlib import Path
from datetime import datetime

TARGET = Path("target")
REPORTS_DIR = Path("reports")
MD_PATH = REPORTS_DIR / "quality_report.md"
JSON_PATH = REPORTS_DIR / "quality_report.json"


def load_json(path: Path) -> dict:
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)


def pick_results_file() -> Path:
    candidates = [TARGET / "test_results.json", TARGET / "run_results.json"]
    for p in candidates:
        if p.exists():
            return p
    raise FileNotFoundError(
        "dbt results not found. Run `dbt test` first. "
        "Expected one of: target/test_results.json or target/run_results.json"
    )


def build_index_from_manifest(manifest: dict) -> dict:
    nodes = manifest.get("nodes", {})
    return nodes


def infer_model_from_test_node(test_unique_id: str, manifest_nodes: dict) -> str | None:
    node = manifest_nodes.get(test_unique_id)
    if not node:
        return None
    depends = node.get("depends_on", {}).get("nodes", [])
    for dep in depends:
        if dep.startswith("model."):
            model_node = manifest_nodes.get(dep)
            if not model_node:
                return dep
            return model_node.get("alias") or model_node.get("name") or dep
    return None


def summarize(results: dict, manifest_nodes: dict | None) -> dict:
    rows = results.get("results", [])
    summary = {"total": 0, "pass": 0, "warn": 0, "fail": 0, "error": 0, "skip": 0}
    failures = []

    for r in rows:
        status = r.get("status", "").lower()
        summary["total"] += 1
        if status in summary:
            summary[status] += 1

        if status in {"fail", "error"}:
            unique_id = r.get("unique_id", "")
            test_name = unique_id.split(".")[-1] if unique_id else "(unknown)"
            fails = r.get("failures")
            msg = r.get("message") or ""
            model = None
            if manifest_nodes is not None and unique_id:
                model = infer_model_from_test_node(unique_id, manifest_nodes)
            failures.append(
                {
                    "test": test_name,
                    "unique_id": unique_id,
                    "model": model,
                    "status": status,
                    "failures": fails,
                    "message": msg.strip()[:500],
                }
            )

    return {"summary": summary, "failures": failures}


def write_markdown(report: dict) -> None:
    REPORTS_DIR.mkdir(parents=True, exist_ok=True)
    s = report["summary"]
    fails = report["failures"]
    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    lines = []
    lines.append("# Data Quality Report (dbt)\n")
    lines.append(f"_Generated: {ts}_\n")
    lines.append("## Summary\n")
    lines.append(f"- **Total tests:** {s['total']}")
    lines.append(f"- ✅ Pass: {s['pass']}")
    lines.append(f"- ⚠️ Warn: {s['warn']}")
    lines.append(f"- ❌ Fail: {s['fail']}")
    lines.append(f"- 🛑 Error: {s['error']}")
    lines.append(f"- ⏭️ Skip: {s['skip']}\n")

    if not fails:
        lines.append("All tests passed. 🎉\n")
    else:
        lines.append("## Failing tests\n")
        lines.append("| Test | Model | Status | Failed rows | Message |\n")
        lines.append("|---|---|---:|---:|---|\n")
        for f in fails:
            test = f.get("test") or ""
            model = f.get("model") or "—"
            status = f.get("status") or ""
            failed_rows = f.get("failures")
            msg = (f.get("message") or "").replace("\n", " ")[:200]
            lines.append(f"| `{test}` | `{model}` | {status} | {failed_rows} | {msg} |")
        lines.append("")

    MD_PATH.write_text("\n".join(lines), encoding="utf-8")


def write_json(report: dict) -> None:
    REPORTS_DIR.mkdir(parents=True, exist_ok=True)
    JSON_PATH.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")


def main():
    results_path = pick_results_file()
    results = load_json(results_path)

    manifest_nodes = None
    manifest_path = TARGET / "manifest.json"
    if manifest_path.exists():
        manifest_nodes = build_index_from_manifest(load_json(manifest_path))

    report = summarize(results, manifest_nodes)
    write_markdown(report)
    write_json(report)

    print(f"OK: wrote {MD_PATH} and {JSON_PATH}")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"[quality_report] ERROR: {e}", file=sys.stderr)
        sys.exit(1)
