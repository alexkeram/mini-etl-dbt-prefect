# tools/sitecustomize.py
import warnings

warnings.filterwarnings(
    "ignore",
    message=r"The 'default' attribute with value .* was provided to the `Field\(\)` function.*",
    module=r"pydantic\._internal\._generate_schema",
)
