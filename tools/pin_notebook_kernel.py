# pins kernelspec for all .ipynb under repo to "mini-etl"
import json
import pathlib

KERNEL = {
    "display_name": "Python (mini-etl)",
    "language": "python",
    "name": "mini-etl",
}


def patch_nb(path: pathlib.Path) -> bool:
    data = json.loads(path.read_text(encoding="utf-8"))
    md = data.setdefault("metadata", {})
    ks = md.setdefault("kernelspec", {})
    changed = ks != KERNEL
    md["kernelspec"] = KERNEL
    li = md.setdefault("language_info", {})
    li.setdefault("name", "python")
    if changed:
        path.write_text(json.dumps(data, ensure_ascii=False, indent=1), encoding="utf-8")
    return changed


def main():
    root = pathlib.Path(".")
    nbs = list(root.rglob("*.ipynb"))
    changed = sum(patch_nb(nb) for nb in nbs)
    print(f"Patched {changed} notebook(s).")


if __name__ == "__main__":
    main()
