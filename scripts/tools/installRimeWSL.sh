#!/bin/bash
# Install RIME for the OPEN-PROM climate feedback (OPEN-PROM -> MAGICC -> RIME).
# Run in WSL from the OPEN-PROM root:   bash scripts/tools/installRimeWSL.sh
#
# * clones RIME (https://github.com/iiasa/rime) at the pinned commit next to OPEN-PROM (../rime),
#   unchanged: OPEN-PROM's own scripts stay in OPEN-PROM;
# * creates ../rime/.venv (ignored by RIME's .gitignore) with Python 3.10 (RIME requires
#   >=3.10,<3.11), the pinned packages of scripts/tools/rime-requirements.txt and RIME itself
#   (editable install of the clone, as climate-assessment is used for MAGICC);
# * creates ../rime-data (download cache: impact maps, Natural Earth).
# Override the location with: RIME_DIR=/path/to/rime bash scripts/tools/installRimeWSL.sh
set -euo pipefail

OPENPROM_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
RIME_DIR="${RIME_DIR:-$(dirname "$OPENPROM_DIR")/rime}"
RIME_COMMIT=9f52c23b1fd837da6d657a2e49923aa8e0662776   # RIME has no releases: tested commit
PY=python3.10

# Python 3.10 (Ubuntu 24.04 ships 3.12): deadsnakes PPA
if ! command -v $PY >/dev/null; then
  echo "Installing Python 3.10 (deadsnakes PPA)"
  sudo apt-get update
  sudo apt-get install -y software-properties-common
  sudo add-apt-repository -y ppa:deadsnakes/ppa
  sudo apt-get update
  sudo apt-get install -y python3.10 python3.10-venv python3.10-dev
fi

# RIME source at the pinned commit (kept clean: no OPEN-PROM files are added)
if [ ! -d "$RIME_DIR/.git" ]; then
  git clone https://github.com/iiasa/rime.git "$RIME_DIR"
fi
git -C "$RIME_DIR" fetch --quiet origin
git -C "$RIME_DIR" checkout --quiet "$RIME_COMMIT"
echo "RIME at $RIME_DIR, commit $RIME_COMMIT"

# Virtual environment with the pinned packages
$PY -m venv "$RIME_DIR/.venv"
"$RIME_DIR/.venv/bin/pip" install --quiet --upgrade pip
"$RIME_DIR/.venv/bin/pip" install -r "$OPENPROM_DIR/scripts/tools/rime-requirements.txt"
"$RIME_DIR/.venv/bin/pip" install --no-deps --editable "$RIME_DIR"
"$RIME_DIR/.venv/bin/pip" check

mkdir -p "$(dirname "$OPENPROM_DIR")/rime-data"
"$RIME_DIR/.venv/bin/python" -W ignore -c "import rime, pyam, regionmask, geopandas; from rime.core import RasterArray, GMTPathway; print('RIME environment OK')"
