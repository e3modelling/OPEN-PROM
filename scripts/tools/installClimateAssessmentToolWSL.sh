#!/bin/bash
# This install script has a requirement that OPEN-PROM and the other models have the same parent folder.

# Change directory to home in Linux
echo "Change directory to home in Linux"
cd 
# Install prerequisites
sudo apt update
sudo apt install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev \
  libnss3-dev libssl-dev libreadline-dev libffi-dev curl libsqlite3-dev \
  wget libbz2-dev

# Download Python 3.11.9 source code
cd /tmp
curl -O https://www.python.org/ftp/python/3.11.9/Python-3.11.9.tgz

# Extract and build
tar -xf Python-3.11.9.tgz
cd Python-3.11.9
./configure --enable-optimizations
make -j$(nproc)
sudo make altinstall  # Avoids overwriting system python

# Verify it was installed
python3.11 --version

# Set python3.11 as default python3 - (optional)
# sudo update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.11 1
# sudo update-alternatives --config python3
# python3 --version

# Install climate-assesment tool

# Change to installation directory. PLEASE CHANGE THE "User/Models" to your folder "username/ModelFolder"
cd /mnt/c/Users/user/Models
git clone https://github.com/iiasa/climate-assessment.git
cd climate-assessment

# Create and activate a virtual environment in Python
python3.11 -m venv .venv
source .venv/bin/activate
pip install --editable .[docs,tests,deploy,linter,notebooks] # The --editable flag ensures that changes to the source code are picked up every time import climate-assessment is used in Python code.
pip install "xarray<2023.12.0"
pip install -U pytest

# Test installation # Typical and normal result:4 failed, 151 passed, 17250 warnings
pytest tests/integration -m "not nightly and not wg3" 