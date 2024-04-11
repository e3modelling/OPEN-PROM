import os
import time
import re
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from colorama import Fore, Style

def select_folders(base_path):
    """
    This function's input is the folder path. It finds the desired directory, scans it,
    presents a subfolder list sorted by modification time (newest to oldest).
    Lastly, it returns a list of strings with all the subfolders.
    """

    runs_path = os.path.join(base_path, "runs")
    subfolders = [f.path for f in os.scandir(runs_path) if f.is_dir()]

    # Create a list of tuples containing subfolder path and its modification time
    subfolder_modification_times = [(folder, os.path.getmtime(folder)) for folder in subfolders]

    # Sort the list of tuples based on modification time (newest to oldest)
    subfolder_modification_times.sort(key=lambda x: x[1], reverse=True)

    # Extract the folder paths from the sorted list
    subfolders = [folder for folder, _ in subfolder_modification_times]

    print(Fore.YELLOW + "Recently started runs might be listed as FAILED, wait 15 seconds before running the script for recently started runs.")
    print("Checking all subfolders..." + Style.RESET_ALL)

    return subfolders

def check_files_and_list_subfolders(base_path):
    """
    This function checks each subfolder for necessary files and generates a list of subfolders with color-coded status.
    """
    runs_path = os.path.join(base_path, "runs")
    subfolders = [f.path for f in os.scandir(runs_path) if f.is_dir()]

    max_folder_name_length = max([len(folder.split(os.sep)[-1]) for folder in subfolders])

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
            status = f"Missing: main.gms  Status: NOT A RUN"
            color = Fore.RED
        elif not os.path.exists(main_lst_path):
            status = f"Missing: main.lst  Status: PENDING"
            color = Fore.BLUE
        elif not os.path.exists(main_log_path):
            status = f"Missing: main.log  Status: PENDING"
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
                            year = line.split("=")[1].strip()

                for line in reversed(last_lines):
                    if "an =" in line:
                        running_year = line.split("=")[1].strip()
                        break

                current_time = time.time()
                file_modification_time = os.path.getmtime(main_log_path)
                time_difference = current_time - file_modification_time

                modification_threshold = 15
                max_modification_threshold = 120

                if any("*** Status: Normal completion" in line for line in last_lines) and time_difference > max_modification_threshold and time_difference > modification_threshold:
                    status = f"Missing: NONE      Status: COMPLETED  Year: {year}  Horizon: {end_horizon_year}"
                elif any("*** Status: Normal completion" in line for line in last_lines) and time_difference > modification_threshold:
                    status = f"Missing: NONE      Status: COMPLETED  Year: {year}  Horizon: {end_horizon_year}"
                elif  any("*** Status: Normal completion" in line for line in last_lines) and time_difference < modification_threshold:
                    status = f"Missing: NONE      Status: COMPLETED  Year: {year}  Horizon: {end_horizon_year}"
                elif time_difference < modification_threshold and not any("*** Status: Normal completion" in line for line in last_lines):
                    status = f"Missing: NONE      Status: PENDING    Running_Year: {running_year}  Horizon: {end_horizon_year}"
                    color = Fore.BLUE
                else:
                    status = "main.log -> FAILED Status: FAILED"
                    color = Fore.RED

        subfolder_status_list.append((f"{color} {folder_name:<{max_folder_name_length}} {status}{Style.RESET_ALL}", folder))

    # Sort the subfolders list based on their modification time
    subfolder_status_list.sort(key=lambda x: os.path.getmtime(x[1]), reverse=True)

    return subfolder_status_list


def list_subfolders(subfolder_status_list):
    """
    Input: subfolder_status_list - List of tuples containing color-coded folder status and folder path
    Output: Displays the list of subfolders with color-coded status
    """
    if subfolder_status_list:
        print("Choose up to two subfolders from the following list (separated by commas):")
        for i, (subfolder_status, _) in enumerate(subfolder_status_list):
            print(f"{i+1}. {subfolder_status}")
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

def plot_heatmap(df, fig_num, plot_title):
    """
    Input: df - Pandas DataFrame representing run success statuses for countries and years.
    fig_num: figure number for matplotlib
    plot_title: Title for the plot
    Output: Displays a heatmap visualization using seaborn and matplotlib, where rows represent countries,
    columns represent years, and color indicates run success (green for success, red for failure).
    """
    if df is not None:
        # Define custom color palette (green for 1, red for 0)
        cmap = sns.color_palette(["red", "green"])

        # Create the heatmap without annotations
        plt.figure(fig_num, figsize=(10, max(6, len(df) * 0.2)))  # Adjust height based on the number of countries
        sns.heatmap(df, cmap=cmap, annot=False, linewidths=.5, linecolor='black', vmin=0, vmax=1, cbar=False)

        plt.title(plot_title)
        plt.xlabel('Year')
        plt.ylabel('Country')

        plt.show(block=False)
    else:
        print("DataFrame is empty.")

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
    selected_subfolders = list_subfolders(subfolder_status_list)
    if selected_subfolders:
        choices = input("Enter the numbers of the subfolders (e.g., '1,2'): ")
        choices = [int(choice.strip()) for choice in choices.split(",")]

        selected_subfolders = [subfolder_status_list[choice - 1] for choice in choices]
        print(f"Selected subfolders: {[subfolder for _, subfolder in selected_subfolders]}\n")

        for idx, (subfolder_status, selected_subfolder) in enumerate(selected_subfolders, 1):
            folder_name = selected_subfolder.split(os.sep)[-1]  # Extract folder name
            lines = read_main_log(selected_subfolder)
            country_year_status = parse_main_log(lines)
            df = create_dataframe(country_year_status)

            plot_heatmap(df, idx, folder_name)

        plt.show()
    else:
        print("No subfolders found in the 'runs' directory.")

if __name__ == "__main__":
    main()
