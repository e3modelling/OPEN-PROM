import os
import sys
import platform
import logging
import tempfile
import argparse
import pandas as pd
import pandas.testing as pdt
import pyam
import matplotlib.pyplot as plt
import dotenv
import subprocess
from climate_assessment.cli import run_workflow


# Base directory of this script (used for safe path resolution)
SCRIPT_DIR = os.getcwd()

def setup_logging(level=logging.INFO):
    logger = logging.getLogger("pipeline")
    logger.setLevel(level)
    logging.getLogger().setLevel(level)

    log_formatter = logging.Formatter(
        "%(asctime)s %(name)s %(threadName)s - %(levelname)s:  %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )
    stdout_handler = logging.StreamHandler()
    stdout_handler.setFormatter(log_formatter)
    logging.getLogger().addHandler(stdout_handler)


def download_magicc_if_needed(root_dir):
    """Download and extract MAGICC binaries and config on Linux only."""
    if platform.system().lower() != "linux":
        print("⚠️ MAGICC binary download is only supported on Linux. Please install manually.")
        return

    magicc_bin_dir = os.path.join(root_dir, "magicc-v7.5.3")
    magicc_bin_archive = magicc_bin_dir + ".tar.gz"
    magicc_dist_dir = os.path.join(root_dir, "magicc-ar6-0fd0f62-f023edb-drawnset")
    magicc_dist_archive = magicc_dist_dir + ".tar.gz"

    link_bin = os.environ.get("MAGICC_LINK_FROM_MAGICC_DOT_ORG")
    link_dist = os.environ.get("MAGICC_PROB_DISTRIBUTION_LINK_FROM_MAGICC_DOT_ORG")

    if not os.path.exists(magicc_bin_dir):
        print("⬇️ Downloading MAGICC binary...")
        os.makedirs(magicc_bin_dir, exist_ok=True)
        subprocess.run(["wget", "-O", magicc_bin_archive, link_bin], check=True)
        subprocess.run(["tar", "-xf", magicc_bin_archive, "-C", magicc_bin_dir], check=True)
    else:
        print("✅ MAGICC binary already exists.")

    if not os.path.exists(magicc_dist_dir):
        print("⬇️ Downloading MAGICC probabilistic config...")
        os.makedirs(magicc_dist_dir, exist_ok=True)
        subprocess.run(["wget", "-O", magicc_dist_archive, link_dist], check=True)
        subprocess.run(["tar", "-xf", magicc_dist_archive, "-C", magicc_dist_dir], check=True)
    else:
        print("✅ MAGICC probabilistic config already exists.")


def set_environment_variables(model):
    """Set environment variables based on the model."""
    if model == "ciceroscm":
        os.environ["CICEROSCM_WORKER_NUMBER"] = "4"
        os.environ["CICEROSCM_WORKER_ROOT_DIR"] = tempfile.gettempdir()
    elif model == "magicc":
        default_root = os.path.abspath(os.path.join(SCRIPT_DIR, "..","..", "climate-assessment", "magicc-files"))
        root_dir = os.environ.get("MAGICC_ROOT_FILES_DIR", default_root)
        os.environ["MAGICC_ROOT_FILES_DIR"] = root_dir

        # download_magicc_if_needed(root_dir)

        os.environ["MAGICC_EXECUTABLE_7"] = os.path.join(root_dir, "bin", "magicc")
        os.environ["MAGICC_WORKER_NUMBER"] = "4"
        os.environ["MAGICC_WORKER_ROOT_DIR"] = tempfile.gettempdir()

        print("🔧 MAGICC root directory:", os.environ["MAGICC_ROOT_FILES_DIR"])
        print("🔧 MAGICC executable:", os.environ.get("MAGICC_EXECUTABLE_7"))


def get_model_config(model, emissions_file, output_dir):
    """Return configuration parameters for each model."""
    if model == "ciceroscm":
        probabilistic_file = os.path.join(
            SCRIPT_DIR, "..", "..", "climate-assessment", "data", "cicero", "subset_cscm_configfile.json"
        )
        expected_output_file = os.path.join(
            SCRIPT_DIR, "..", "..", "climate-assessment", "tests", "test-data",
            "expected-output-wg3", "two_ips_climate_cicero.xlsx"
        )
    elif model == "magicc":
        root_dir = os.environ["MAGICC_ROOT_FILES_DIR"]
        probabilistic_file = os.path.join(
            root_dir, "magicc-ar6-0fd0f62-f023edb-drawnset",
            "0fd0f62-derived-metrics-id-f023edb-drawnset.json"
        )
        expected_output_file = os.path.join(
            SCRIPT_DIR, "..", "..", "climate-assessment", "tests", "test-data",
            "expected-output-wg3", "two_ips_climate_magicc.xlsx"
        )
    else:
        raise ValueError("Unsupported model: choose 'ciceroscm' or 'magicc'")

    return {
        "model_version": "v2019vCH4" if model == "ciceroscm" else "v7.5.3",
        "probabilistic_file": os.path.abspath(probabilistic_file),
        "expected_output_file": os.path.abspath(expected_output_file),
        "emissions_file": emissions_file,
        "output_dir": output_dir,
    }


def run_assessment(model: str, emissions_file: str, output_dir: str):
    """Run the full climate assessment workflow for a given model."""
    setup_logging()
    set_environment_variables(model)
    config = get_model_config(model, emissions_file, output_dir)

    num_cfgs = 600
    scenario_batch_size = 20

    infilling_db_path = os.path.abspath(os.path.join(
        SCRIPT_DIR, "..", "..", "climate-assessment", "data",
        "1652361598937-ar6_emissions_vetted_infillerdatabase_10.5281-zenodo.6390768.csv"
    ))

    print(f"\n🚀 Running {model.upper()} model assessment...")
    run_workflow(
        emissions_file,
        output_dir,
        model=model,
        model_version=config["model_version"],
        probabilistic_file=config["probabilistic_file"],
        num_cfgs=num_cfgs,
        infilling_database=infilling_db_path,
        scenario_batch_size=scenario_batch_size,
    )

def loadResults(output_dir,emissions_file):
    """Load results from the generated file and the results from the default runs with climate-assessment"""
    input_basename = os.path.splitext(os.path.basename(emissions_file))[0]
    output_file = os.path.join(output_dir, f"{input_basename}_alloutput.xlsx")

    # Check if file exists
    if not os.path.exists(output_file):
        print(f"File not found: {output_file}")
        sys.exit(1)  # Exit with error code 1

    output = pyam.IamDataFrame(output_file)

    expected_output_file = os.path.join(
                    SCRIPT_DIR, "..", "..", "climate-assessment",
                    "tests", "test-data", "expected-output-wg3/two_ips_climate_cicero.xlsx")
    
    expected_db_output = pyam.IamDataFrame(expected_output_file)

    return output, expected_db_output 

def visualize_output(output,defaultOutput):
    """Plot global warming results."""
    print("📈 Plotting median global surface temperature")
    ax = output.filter(variable="*|Surface Temperature (GSAT)|*|50.0th Percentile").plot(
        color="scenario"
    )
    # Plot also the output from the default models if provided
    if defaultOutput is not None:
        defaultOutput = defaultOutput.filter(variable="*|Surface Temperature (GSAT)|*|50.0th Percentile")
        defaultOutput.plot(ax=ax, color="scenario", linestyle="--")

    plt.title("Global warming above the 1850-1900 mean")
    ax.set_xlim([1995, 2100])
    plt.show()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run climate assessment workflow with CICERO or MAGICC.")
    parser.add_argument("--model", required=False, choices=["ciceroscm", "magicc"], help="Climate model to run.")
    parser.add_argument("--emissions", required=False, help="Path to the input emissions CSV file.")
    parser.add_argument("--output", required=False, help="Path to the output directory.")

    if len(sys.argv) > 1:
        args = parser.parse_args()
        model = args.model
        emissions_file = os.path.abspath(os.path.normpath(args.emissions))
        output_dir = os.path.abspath(os.path.normpath(args.output))
    else:
        # Internal defaults for testing and running without CLI args
        print("⚙️ No command-line arguments detected. Using internal test configuration.")
        model = "ciceroscm"  # "magicc" or "ciceroscm"
        runFolder = "daily_npi"
        emissions_file = os.path.abspath(os.path.join(SCRIPT_DIR, "..", "runs", runFolder , "emissions.csv"))
        output_dir = os.path.abspath(os.path.join(SCRIPT_DIR, "..", "runs", runFolder, "EmissionsOutput-"+model))

    run_assessment(model=model, emissions_file=emissions_file, output_dir=output_dir)
