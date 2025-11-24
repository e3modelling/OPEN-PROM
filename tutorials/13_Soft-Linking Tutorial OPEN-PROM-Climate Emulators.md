# 🌍 Using Climate-Assessment with OPEN-PROM on Windows (via WSL)

## 1. Introduction

The **climate-assessment** tool is designed to process **Integrated Assessment Model (IAM)** outputs and generate climate-relevant indicators by running climate emulators (MAGICC, CICERO-SCM, FAIR), such as **global mean surface temperature (GSAT)** and **warming probabilities**.

It is often used in combination with IAM frameworks such as **OPEN-PROM**, which provides socio-economic and energy system scenarios. By linking the two:

* **OPEN-PROM** → generates emissions pathways (e.g., CO₂, CH₄, N₂O).
* **climate-assessment** → translates those emissions into climate outcomes.

This integration allows researchers to evaluate whether IAM scenarios are **consistent with climate targets** like 1.5°C or 2°C.

## 2. How Climate-Assessment Works?

The climate assessment workflow described on the [Climate Assessment documentation site](https://climate-assessment.readthedocs.io/en/latest/general.html) is designed to ensure that emissions scenarios from different Integrated Assessment Models (IAMs) can be compared consistently and translated into temperature outcomes using standardized climate emulators. Many IAMs generate projections of future greenhouse gas and pollutant emissions but differ in their treatment of the climate system—or may omit it altogether. This workflow provides a common framework to process those emissions through a uniform climate modelling chain, producing comparable estimates of global temperature and related climate indicators.

The process begins with calibration, where the parameters of the chosen climate emulators are tuned to reproduce observed historical temperatures and align with a reference temperature assessment. This step ensures that subsequent projections are based on a consistent historical foundation.

Next, in scenario preparation, IAM teams provide their projected emissions pathways—typically in standardized data files covering a wide range of greenhouse gases and pollutants from the present day through the year 2100. Because each IAM may use slightly different historical baselines, the harmonization step adjusts the starting point of each scenario to match observed historical emissions. This removes artificial discrepancies that could arise purely from differences in input data rather than real differences in future trajectories.

After harmonization, the workflow performs infilling to estimate emissions for species not reported by a particular model (e.g., HFCs). This ensures that every scenario has a complete set of emissions time series for all relevant substances, which is necessary for running climate emulators.

In the climate modelling (or emulation) stage, these harmonized and infilled emissions data are input into simple climate models—such as FaIR, MAGICC, or CICERO-SCM—run in probabilistic mode. These emulators calculate atmospheric concentrations, radiative forcing, and resulting global mean surface temperature changes, among other outputs.

The final products of the workflow include probabilistic time series of climate variables (such as concentrations, forcing, and temperature) and summary metadata for each scenario, including temperature-based classifications. 

## 3. Running on Windows with WSL

Since **climate-assessment** is Linux-oriented, the recommended way to run it on Windows is via **WSL (Windows Subsystem for Linux)**. **Missing Intel Fortran libraries on Windows** is why WSL is recommended; Linux provides required libraries.

### 3.1 Install WSL

Open **PowerShell as Administrator** and run:

```powershell
wsl --install
```

This will:

* Install the latest Ubuntu distribution by default.
* Enable virtualization features in Windows.

After installation, reboot your system. Then, you can open **Ubuntu (WSL)** from the Start Menu.

To confirm WSL works:

```bash
wsl --version
```
You may find more information regarding the WSL (installation, usage, file structure, VS code integration) in this [link](https://learn.microsoft.com/en-us/windows/wsl/setup/environment). 
### 3.2 File System Structure

WSL integrates Linux with Windows. Your Windows files are accessible under:

```
/mnt/c/Users/<username>/
```
You can navigate to your Windows directories from within WSL. You can find also Linux files in Windows Explorer. 

For this setup:

* Place **OPEN-PROM** and **climate-assessment** in the **same parent folder** (important for the script).

Example:

```
/mnt/c/Users/user/Models/
   ├── OPEN-PROM
   ├── climate-assessment
   └── other_models
```

## 4. Installation Script 

Installing climate assessment is done by running the bash script "installClimateAssessmentToolWSL.sh" in the scripts folder. Please make sure that you are in the right folder and you are running it from WSL, not CMD. You can set the permissions by running in the WSL terminal:
```
chmod +x installClimateAssessmentToolWSL.sh
./installClimateAssessmentToolWSL.sh
```
After running the script, you should see a new folder called `.venv` in the `climate-assessment` folder. This is your Python virtual environment.

Below is the installation, explained **step by step**:

### Step 1: Change to Home and Install Dependencies

```bash
cd 
sudo apt update
sudo apt install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev \
  libnss3-dev libssl-dev libreadline-dev libffi-dev curl libsqlite3-dev \
  wget libbz2-dev
```

👉 Moves into your Linux home directory (`/home/<username>`) and then installs packages required to compile Python and run the tool (compilers, compression libraries, security libs, SQLite).

#### Possible problem with installation
If you encounter issues with missing dependencies or installation errors in WSL, e.g., "E: Unmet dependencies. Try 'apt --fix-broken install' with no packages (or specify a solution).", try to run the following commands to fix broken packages and reconfigure dpkg: 

Please run these commands exactly:
```bash
# 1. Force remove the broken post-install script
sudo mv /var/lib/dpkg/info/udev.postinst /var/lib/dpkg/info/udev.postinst.bak

# 2. Force dpkg to mark udev as configured
sudo dpkg --configure -a

# 3. Hold it again to prevent future reconfiguration attempts
sudo apt-mark hold udev

# 4. Clean up and fix dependencies
sudo apt --fix-broken install
sudo apt clean
sudo apt autoremove

#After running those, check:
dpkg -l | grep udev\
# hi  udev   255.4-1ubuntu8.11   amd64   device manager for the Linux kernel
sudo apt update
sudo apt --fix-broken install
#you should finally get:
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.

```
Then try again to install the dependencies with `sudo apt install -y ...` as shown above.

### Step 2: Install Python 3.11.9

```bash
cd /tmp
curl -O https://www.python.org/ftp/python/3.11.9/Python-3.11.9.tgz
tar -xf Python-3.11.9.tgz
cd Python-3.11.9
./configure --enable-optimizations
make -j$(nproc)
sudo make altinstall
```

👉 Downloads, compiles, and installs **Python 3.11.9** from source.
Uses `altinstall` so it doesn’t overwrite system Python. Climate-assessment requires Python 3.11.x, while latest Ubuntu ships with 3.12.x.

Check version:

```bash
python3.11 --version
```

### Step 3: Install Climate-Assessment
👉 Navigate to the folder where you want to store the `climate-assessment` (adjust path to your own).

```bash
cd /mnt/c/Users/user/Models
git clone https://github.com/iiasa/climate-assessment.git
cd climate-assessment
```

#### Create Virtual Environment

```bash
python3.11 -m venv .venv
source .venv/bin/activate
```

👉 Keeps dependencies isolated.

#### Install Dependencies

```bash
pip install --editable .[docs,tests,deploy,linter,notebooks]
pip install "xarray<2023.12.0"
pip install -U pytest
```

* `--editable` → links directly to the source folder (good for development).
* `xarray` pinned to avoid breaking changes.
* `pytest` for testing.

#### Run Tests

```bash
pytest tests/integration -m "not nightly and not wg3"
```

👉 Runs integration tests.
✅ Normal result: `4 failed, 151 passed, 17250 warnings`. (The failures are expected due to data dependencies.)

#### Download MAGICC7 and configure files

Next, download the MAGICC7 binary from this [link](https://magicc.org/download/magicc7) (registration may be required) and copy the files to a dedicated folder, e.g., `/mnt/c/Users/user/Models/climate-assessment/magicc-files/`. Also, download the probabilistic parameters file from [link](https://magicc.org/download/magicc7) and place it in the same folder.

Finally, edit the `.env.sample` file in the `climate-assessment` folder to point to the MAGICC files and rename it to `.env`. Be careful to create the directories for the workers as specified below. Example configuration:

```
MAGICC_EXECUTABLE_7=/mnt/c/Users/User/Models/climate-assessment/magicc-files/bin/magicc

# How many MAGICC workers can run in parallel?
MAGICC_WORKER_NUMBER=8

# Where should the MAGICC workers be located on the filesystem (you need about
# 500Mb space per worker at the moment)
MAGICC_WORKER_ROOT_DIR=/mnt/tmp/workers
```

## 5. Linking OPEN-PROM and Climate-Assessment

1. **OPEN-PROM runs first**

   * Produces scenario outputs with postprom and an emissions CSV file is created in each folder run. Variables include:

     * `Emissions|CO2`
     * `Emissions|BC`
     * `Emissions|CH4`
     * `Emissions|CO`
     * `Emissions|CO2|AFOLU`
     * `Emissions|CO2|Energy and Industrial Processes`
     * `Emissions|HFC|HFC125`
     * `Emissions|HFC|HFC134a`
     * `Emissions|HFC|HFC143a`
     * `Emissions|HFC|HFC23`
     * `Emissions|HFC|HFC32`
     * `Emissions|HFC|HFC43-10`
     * `Emissions|N2O`
     * `Emissions|NH3`
     * `Emissions|NOx`
     * `Emissions|OC`
     * `Emissions|PFC|C2F6`
     * `Emissions|PFC|C6F14`
     * `Emissions|PFC|CF4`
     * `Emissions|SF6`
     * `Emissions|Sulfur`
     * `Emissions|VOC` 

    * The Emissions|CO2|Energy is provided by OPEN-PROM, while the other emissions are taken from the Navigate project and the REMIND-MAGPIE model. The Emissions|CO2|AFOLU may be provided by MAgPIE (if soft-linking is used). The HFCs are provided by AR6. 
    * The required inputs for climate-assessment are: at least CO₂ emissions (both from energy/industry and from AFOLU—agriculture, forestry, and other land use), though negative values are allowed only for CO₂.

2. **Climate-assessment reads IAM output**  
   * Read the emissions CSV from OPEN-PROM.
   * Harmonizes the emissions to a reference dataset so all models are comparable.
   * Infills missing greenhouse gases (e.g., HFCs) with values from AR6.
   * Runs MAGICC (or CICERO) emulators probilistically to generate climate outcomes.

3. **Main Outputs**

   * GSAT (or global mean surface air temperature) trajectories.
   * Peak warming and probability distributions.

## 6. Typical Workflow

1. Place emissions input files under the designated runs/<runFolder>/emissions.csv directory (or specify a custom path).
2. Run the script with model and folder options, e.g.: "Rscript runClimateModels.R --model magicc --runFolder daily_npi"
3. The script will:
   * Call the Python workflow inside the correct virtual environment.
   * Save processed outputs to runs/<runFolder>/EmissionsOutput-<model>/.
   * Compare against reference outputs and generate a global mean temperature plot (Global_Mean_Temperature.png).