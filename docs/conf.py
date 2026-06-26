# Configuration file for the Sphinx documentation builder.
from datetime import datetime

project = "OPEN-PROM"
author = "E3Modelling"
copyright = f"{datetime.now().year}, E3Modelling"
release = "2.2.0"
version = "2.2.0"

extensions = [
    "myst_parser",
    "sphinx.ext.mathjax",
]

templates_path = ["_templates"]
exclude_patterns = [
    "_build",
    "Thumbs.db",
    ".DS_Store",
]

source_suffix = {
    ".md": "markdown",
}

myst_enable_extensions = [
    "colon_fence",
    "deflist",
    "html_image",
    "dollarmath",
    "amsmath",
]

# Number figures/tables so {numref} references resolve as "Fig. N"
numfig = True

# Landing page
master_doc = "index"

# Theme (same family as the eu-clews reference site)
html_theme = "sphinx_rtd_theme"
html_static_path = ["_static"]
html_logo = "logo.png"
html_title = "OPEN-PROM"
html_baseurl = "https://e3modelling.github.io/OPEN-PROM/"

html_theme_options = {
    "collapse_navigation": False,
    "navigation_depth": 3,
    "titles_only": False,
}
