import site
import shutil
import pathlib
import sys

src = pathlib.Path("tools") / "sitecustomize.py"
if not src.exists():
    print("tools/sitecustomize.py not found; skipping")
    sys.exit(0)

dst = pathlib.Path(site.getsitepackages()[0]) / "sitecustomize.py"
dst.parent.mkdir(parents=True, exist_ok=True)
shutil.copy2(src, dst)
print(f"Installed {src} -> {dst}")
