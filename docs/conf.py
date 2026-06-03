# Configuration file for the Sphinx documentation builder.
import os
from datetime import datetime

project = "OPEN-PROM"
author = "OPEN-PROM contributors"
copyright = f"{datetime.now().year}, {author}"
release = "0.0.1"

extensions = [
    "myst_parser",
]

templates_path = ["_templates"]
exclude_patterns = ["_build", "Thumbs.db", ".DS_Store"]

source_suffix = {
    ".md": "markdown",
}

myst_enable_extensions = [
    "colon_fence",
    "deflist",
    "html_image",
]

html_theme = "sphinx_rtd_theme"
html_static_path = ["_static"]
html_logo = "logo.png"
html_title = "OPEN-PROM"
