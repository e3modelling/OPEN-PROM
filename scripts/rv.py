import os
import time
import re
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from colorama import Fore, Style

#def select_folders(base_path):
   # """
    #This function's input is the folder path. It finds the desired directory, scans it,
    #presents a subfolder list sorted by modification time (newest to oldest).
    #Lastly, it returns a list of strings with all the subfolders.
    #"""

    #runs_path = os.path.join(base_path, "runs")
    #subfolders = [f.path for f in os.scandir(runs_path) if f.is_dir()]

    # Create a list of tuples containing subfolder path and its modification time
    #subfolder_modification_times = [(folder, os.path.getmtime(folder)) for folder in subfolders]

    # Sort the list of tuples based on modification time (newest to oldest)
    #subfolder_modification_times.sort(key=lambda x: x[1], reverse=True)

    # Extract the folder paths from the sorted list
    #subfolders = [folder for folder, _ in subfolder_modification_times]

    #print(Fore.YELLOW + "Recently started runs might be listed as FAILED, wait 15 seconds before running the script for recently started runs.")
    #print("Checking all subfolders..." + Style.RESET_ALL)

    #return subfolders

def check_files_and_list_subfolders(base_path):
    """
    This function checks each subfolder for necessary files and generates a list of subfolders with color-coded status.
    It also includes information about failed subfolders, their horizon, and the last year they ran.
    """
    runs_path = os.path.join(base_path, "runs")
    subfolders = [f.path for f in os.scandir(runs_path) if f.is_dir()]

    max_folder_name_length = max([len(folder.split(os.sep)[-1]) for folder in subfolders])

    max_status_length = 35  # Maximum length for the status message
    max_year_length = 4  # Maximum length for the year

    current_time = time.time()
    max_modification_threshold = 120  # 120 seconds threshold for max modification time
    max_modification_time = current_time - max_modification_threshold

    subfolder_status_list = []

    for folder in subfolders:
        main_gms_path = os.path.join(folder, "main.gms")
        main_lst_path = os.path.join(folder, "main.lst")
        main_log_path = os.path.join(folder, "main.log")

        # Split the path and isolate folder name for printing
        folder_name = folder.split(os.sep)[-1]

        status = ""
        color = Fore.GREEN

        if not os.path.exists(main_gms_path):
            status = f"Missing: main.gms  Status: NOT A RUN".ljust(max_status_length)
            color = Fore.RED
        elif not os.path.exists(main_lst_path) or not os.path.exists(main_log_path):
            if current_time > max_modification_time:
                status = f"main.lst or main.log missing -> FAILED".ljust(max_status_length)
                color = Fore.RED
            else:
                status = f"Missing: main.lst or main.log  Status: PENDING".ljust(max_status_length)
                color = Fore.BLUE
        else:
            with open(main_gms_path, "r") as gms_file:
                gms_content = gms_file.readlines()
                end_horizon_line = next((line for line in gms_content if "$evalGlobal fEndY" in line), None)
                end_horizon_year = end_horizon_line.split()[-1]

            with open(main_log_path, "r") as file:
                last_lines = file.readlines()[-65:]
                year = None
                running_year = None

                if any("an =" in line for line in last_lines):
                    for line in last_lines:
                        if "an =" in line:
                            year = line.split("=")[1].strip().rjust(max_year_length)

                for line in reversed(last_lines):
                    if "an =" in line:
                        running_year = line.split("=")[1].strip().rjust(max_year_length)
                        break

                time_difference = current_time - os.path.getmtime(main_log_path)

                modification_threshold = 15

                if any("*** Status: Normal completion" in line for line in last_lines) and time_difference > max_modification_threshold and time_difference > modification_threshold:
                    status = f"Missing: NONE      Status: COMPLETED  Year: {year}  Horizon: {end_horizon_year}".ljust(max_status_length)
                elif any("*** Status: Normal completion" in line for line in last_lines) and time_difference > modification_threshold:
                    status = f"Missing: NONE      Status: COMPLETED  Year: {year}  Horizon: {end_horizon_year}".ljust(max_status_length)
                elif  any("*** Status: Normal completion" in line for line in last_lines) and time_difference < modification_threshold:
                    status = f"Missing: NONE      Status: COMPLETED  Year: {year}  Horizon: {end_horizon_year}".ljust(max_status_length)
                elif time_difference < modification_threshold and not any("*** Status: Normal completion" in line for line in last_lines):
                    status = f"Missing: NONE      Status: PENDING    Running_Year: {running_year}  Horizon: {end_horizon_year}".ljust(max_status_length)
                    color = Fore.BLUE
                else:
                    status = f"main.log -> FAILED Status: FAILED     Year: {year}  Horizon: {end_horizon_year}".ljust(max_status_length)
                    color = Fore.RED

        subfolder_status_list.append((f"{color} {folder_name:<{max_folder_name_length}} {status}{Style.RESET_ALL}", folder))

    # Sort the subfolders list based on their modification time
    subfolder_status_list.sort(key=lambda x: os.path.getmtime(x[1]), reverse=False)

    return subfolder_status_list

def list_subfolders(subfolder_status_list):
    """
    Input: subfolder_status_list - List of tuples containing color-coded folder status and folder path
    Output: Displays the list of subfolders with color-coded status, with reversed numbering.
    """
    if subfolder_status_list:
        print(Fore.YELLOW + "Recently started runs might be listed as FAILED, wait 15 seconds before running the script for recently started runs.")
        print("Checking all subfolders..." + Style.RESET_ALL)

    
        for idx, (subfolder_status, _) in enumerate(subfolder_status_list, 1):
            print(f"{len(subfolder_status_list) - idx + 1:2}. {subfolder_status}")  # Adjust the numbering
        return subfolder_status_list
    else:
        print("No subfolders found in the 'runs' directory.")
        return []


def read_main_log(subfolder):
    """
    Input: subfolder - Name of the subfolder within the "runs" directory.
    Output: The content of the main.log file located in the specified subfolder, returned as a list of strings
    representing each line of the file.
    """
    main_log_path = os.path.join("runs", subfolder, "main.log")
    if os.path.exists(main_log_path):
        with open(main_log_path, 'r') as file:
            lines = file.readlines()
        return lines
    else:
        print("main.log file not found in the selected subfolder.")
        return []

def parse_main_log(lines):
    """
    Input: lines - List of strings representing the content of the main.log file.
    Output: A dictionary where keys are country names and values are dictionaries mapping years
    to run success statuses (1 for success, 0 for failure).
    """
    year_pattern = re.compile(r'an\s*=\s*(\d+)')
    country_pattern = re.compile(r'runCyL\s*=\s*([A-Z]+)')
    status_pattern = re.compile(r'\*\* Optimal solution')

    country_year_status = {}
    current_year = None
    current_country = None

    for line in lines:
        year_match = re.search(year_pattern, line)
        country_match = re.search(country_pattern, line)
        status_match = re.search(status_pattern, line)

        if year_match:
            current_year = int(year_match.group(1))
        if country_match:
            current_country = country_match.group(1)
        if status_match:
            current_status = 1 if status_match else 0

            if current_year and current_country:
                country_year_status.setdefault(current_country, {})[current_year] = current_status

    return country_year_status

def create_dataframe(country_year_status):
    """
    Input: country_year_status - Dictionary where keys are country names and values are dictionaries mapping years
    to run success statuses.
    Output: A pandas DataFrame where rows represent countries, columns represent years, and cell values represent
    run success statuses (1 for success, 0 for failure).
    """
    if country_year_status:
        # Create DataFrame directly from country_year_status dictionary
        df = pd.DataFrame(country_year_status).fillna(0)
        # Reindex rows to use country names
        df.index.name = 'Country'
        # Transpose DataFrame to use years as columns
        df = df.T
        df = df.astype(int)
        return df
    else:
        print("No data found in the log file.")
        return None

def main():
    """
    This function initializes all the functions of the script and
    loops over the selected subfolders.
    """

    # The path to the "scripts" directory where the script is located
    script_directory = os.path.dirname(os.path.abspath(__file__))

    # The base path to the "OPEN-PROM" directory
    base_path = os.path.abspath(os.path.join(script_directory, ".."))

    subfolder_status_list = check_files_and_list_subfolders(base_path)
    list_subfolders(subfolder_status_list)
    
if __name__ == "__main__":
    main()
