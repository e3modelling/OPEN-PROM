import os
import re
import time
import argparse
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from colorama import Fore, Style

def check_files_and_list_subfolders(base_path):
    """
    This function checks each subfolder for necessary files and generates a list of subfolders with color-coded status.
    It also includes information about failed subfolders, their horizon, and the last year they ran.
    """
    runs_path = os.path.join(base_path, "runs")
    subfolders = [f.path for f in os.scandir(runs_path) if f.is_dir()]

    max_folder_name_length = max([len(folder.split(os.sep)[-1]) for folder in subfolders])

    max_status_length = 60  # Maximum length for the status message
    current_time = time.time()
    max_modification_threshold = 120  # 120 seconds threshold for max modification time
    max_modification_time = current_time - max_modification_threshold

    subfolder_status_list = []

    for folder in subfolders:
        main_gms_path = os.path.join(folder, "main.gms")
        main_lst_path = os.path.join(folder, "main.lst")
        modelstat_path = os.path.join(folder, "modelstat.txt")

        # Split the path and isolate folder name for printing
        folder_name = folder.split(os.sep)[-1]

        status = ""
        color = Fore.GREEN

        if not os.path.exists(main_gms_path):
            status = f"Missing: main.gms  Status: NOT A RUN".ljust(max_status_length)
            color = Fore.RED
        elif not os.path.exists(main_lst_path) or not os.path.exists(modelstat_path):
            if current_time > max_modification_time:
                status = f"main.lst or modelstat.txt missing -> FAILED".ljust(max_status_length)
                color = Fore.RED
            else:
                status = f"Missing: main.lst or modelstat.txt  Status: PENDING".ljust(max_status_length)
                color = Fore.BLUE
        else:
            with open(main_gms_path, "r") as gms_file:
                gms_content = gms_file.readlines()
                end_horizon_line = next((line for line in gms_content if "$evalGlobal fEndY" in line), None)
                end_horizon_year = end_horizon_line.split()[-1]

            country_year_status = parse_modelstat(modelstat_path)

            if country_year_status:
                max_year = max(max(years.keys()) for years in country_year_status.values() if years)
                status = f"Status: COMPLETED  Year: {max_year if max_year else ''}".ljust(max_status_length)
            else:
                status = f"modelstat.txt -> FAILED Status: FAILED     Year: {end_horizon_year if end_horizon_year else ''}".ljust(max_status_length)
                color = Fore.RED

        subfolder_status_list.append((f"{color} {folder_name:<{max_folder_name_length}} {status}{Style.RESET_ALL}", folder))

    # Sort the subfolders list based on their creation time in ascending order
    subfolder_status_list.sort(key=lambda x: os.path.getctime(x[1]), reverse=False)

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

def parse_modelstat(modelstat_path):
    """
    Input: modelstat_path - Path to the modelstat.txt file
    Output: A dictionary where keys are country names and values are dictionaries mapping years
    to run success statuses (1 for optimal solution, 2 for feasible solution, 0 for failure).
    Returns None if the file does not exist or cannot be read.
    """
    country_year_status = {}

    if not os.path.exists(modelstat_path):
        print(f"Error: {modelstat_path} not found.")
        return None

    try:
        with open(modelstat_path, "r") as file:
            lines = file.readlines()

            optimal_pattern = re.compile(r'Country:(\w+)\s+Model Status:2\.00\s+Year:(\d{4})')
            feasible_pattern = re.compile(r'Country:(\w+)\s+Model Status:6\.00\s+Year:(\d{4})')

            for line in lines:
                optimal_match = re.search(optimal_pattern, line)
                feasible_match = re.search(feasible_pattern, line)

                if optimal_match:
                    country = optimal_match.group(1)
                    year = int(optimal_match.group(2))
                    if country not in country_year_status:
                        country_year_status[country] = {}
                    country_year_status[country][year] = 1  # Optimal solution
                elif feasible_match:
                    country = feasible_match.group(1)
                    year = int(feasible_match.group(2))
                    if country not in country_year_status:
                        country_year_status[country] = {}
                    country_year_status[country][year] = 2  # Feasible solution
                else:
                    match = re.search(r'Country:(\w+)\s+Model Status:(\d+\.\d+)\s+Year:(\d{4})', line)
                    if match:
                        country = match.group(1)
                        year = int(match.group(3))
                        if country not in country_year_status:
                            country_year_status[country] = {}
                        country_year_status[country][year] = 0  # Failure or infeasible solution
    except Exception as e:
        print(f"Error parsing {modelstat_path}: {str(e)}")
        return None

    return country_year_status

def create_dataframe(country_year_status, pending_run=False):
    """
    Input: country_year_status - Dictionary where keys are country names and values are dictionaries mapping years
    to run success statuses (1 for optimal solution, 2 for feasible solution, 0 for failure).
    pending_run: Flag indicating whether the run is pending
    Output: A pandas DataFrame where rows represent countries, columns represent years, and cell values represent
    run success statuses.
    """
    if country_year_status:
        # Create DataFrame directly from country_year_status dictionary
        df = pd.DataFrame(country_year_status).fillna(0)
        # Reindex rows to use country names
        df.index.name = 'Country'
        # Transpose DataFrame to use years as columns
        df = df.T
        df = df.astype(int)
        # Exclude the last year if the run is pending
        if pending_run == True:
            df.pop(df.columns[-1])
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
    columns represent years, and color indicates run success (green for optimal solution, orange for feasible solution, red for failure).
    """
    if df is not None:
        # Define custom color palette (red for failure/infeasible, green for optimal, orange for feasible)
        cmap = sns.color_palette(["red", "green", "orange"])

        # Create the heatmap without annotations
        plt.figure(fig_num, figsize=(10, max(6, len(df) * 0.2)))  # Adjust height based on the number of countries
        sns.heatmap(df, cmap=cmap, annot=False, linewidths=.5, linecolor='black', vmin=0, vmax=2, cbar=False)

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
    parser = argparse.ArgumentParser(description='Visualize run success statuses for selected subfolders.')
    parser.add_argument('-q', '--subfolders', action='store_true', help='manually select subfolders for visualization')
    args = parser.parse_args()

    # The path to the "scripts" directory where the script is located
    script_directory = os.path.dirname(os.path.abspath(__file__))

    # The base path to the "OPEN-PROM" directory
    base_path = os.path.abspath(os.path.join(script_directory, ".."))

    subfolder_status_list = check_files_and_list_subfolders(base_path)
    selected_subfolders = []

    if args.subfolders:
        newest_subfolder = subfolder_status_list[-1][1]
        print(f"Automatically visualizing the newest subfolder: {newest_subfolder}\n")
        selected_subfolders.append((subfolder_status_list[-1][1], newest_subfolder))
    else:
        selected_subfolders = list_subfolders(subfolder_status_list)
        if not selected_subfolders:
            print("No subfolders found in the 'runs' directory.")
            return

        choices = input("Enter the numbers of the subfolders (e.g., '1 2'): ")
        choices = [int(choice.strip()) for choice in choices.split()]

        selected_subfolders = [subfolder_status_list[len(subfolder_status_list) - choice] for choice in choices]
        print(f"Selected subfolders: {[subfolder for _, subfolder in selected_subfolders]}\n")

    for idx, (subfolder_status, folder_path) in enumerate(selected_subfolders, 1):
        folder_name = folder_path.split(os.sep)[-1]
        plot_title = f"{folder_name}"
        print(f"\nPlotting visualization for subfolder {idx}/{len(selected_subfolders)}: {folder_name}")

        country_year_status = parse_modelstat(os.path.join(folder_path, "modelstat.txt"))
        pending_run = not os.path.exists(os.path.join(folder_path, "main.lst"))

        df = create_dataframe(country_year_status, pending_run=pending_run)
        plot_heatmap(df, fig_num=idx, plot_title=plot_title)

    plt.show()

if __name__ == "__main__":
    main()
