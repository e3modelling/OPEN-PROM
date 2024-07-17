import os
import re
import time
import argparse
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from colorama import Fore, Style

def parse_modelstat(lines):
    """
    Parses the modelstat.txt file for country-year success statuses.
    """
    country_year_status = {}
    year_pattern = re.compile(r'an\s*=\s*(\d+)')
    country_pattern = re.compile(r'runCyL\s*=\s*([A-Z]+)')
    solution_pattern = re.compile(r'--- Solution status\s*=\s*(\d+)')

    current_country = None
    current_year = None

    for line in lines:
        year_match = re.search(year_pattern, line)
        country_match = re.search(country_pattern, line)
        solution_match = re.search(solution_pattern, line)

        if year_match:
            current_year = int(year_match.group(1))
        if country_match:
            current_country = country_match.group(1)
            if current_country not in country_year_status:
                country_year_status[current_country] = {}
        if solution_match:
            solution_status = int(solution_match.group(1))
            if current_country and current_year:
                country_year_status[current_country][current_year] = solution_status

    return country_year_status

def check_files_and_list_subfolders(base_path, flag=False):
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
        modelstat_path = os.path.join(folder, "modelstat.txt")  # Added line

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
            if flag and os.path.exists(modelstat_path):
                with open(modelstat_path, "r") as file:
                    lines = file.readlines()
                country_year_status = parse_modelstat(lines)
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

    # Sort the subfolders list based on their creation time
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
    to run success statuses (1 for optimal solution, 2 for feasible solution, 0 for failure).
    """
    year_pattern = re.compile(r'an\s*=\s*(\d+)')
    country_pattern = re.compile(r'runCyL\s*=\s*([A-Z]+)')
    reading_solution_pattern = re.compile(r'--- Reading solution for model openprom')
    optimal_solution_pattern = re.compile(r'\*\* Optimal solution')
    feasible_solution_pattern = re.compile(r'\*\* Feasible solution')

    country_year_status = {}
    current_year = None
    current_country = None

    for line_num, line in enumerate(lines):
        year_match = re.search(year_pattern, line)
        country_match = re.search(country_pattern, line)
        reading_solution_match = re.search(reading_solution_pattern, line)

        if year_match:
            current_year = int(year_match.group(1))
        if country_match:
            current_country = country_match.group(1)
            # Initialize country's status dictionary if not already done
            if current_country not in country_year_status:
                country_year_status[current_country] = {}

        if reading_solution_match:
            # Start processing lines up to 10 lines above the reading solution line
            start_line = max(0, line_num - 5)
            relevant_lines = lines[start_line:line_num]

            success_found = False
            for relevant_line in relevant_lines:
                optimal_solution_match = re.search(optimal_solution_pattern, relevant_line)
                feasible_solution_match = re.search(feasible_solution_pattern, relevant_line)

                if optimal_solution_match:
                    success_found = True
                    country_year_status[current_country][current_year] = 1
                    break
                elif feasible_solution_match:
                    success_found = True
                    if current_country not in country_year_status or current_year not in country_year_status[current_country]:
                        country_year_status[current_country][current_year] = 2
                    break

            if not success_found:
                if current_country not in country_year_status or current_year not in country_year_status[current_country]:
                    country_year_status[current_country][current_year] = 0

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
    parser.add_argument('-f', '--flag', action='store_true', help='use the modelstat.txt file for parsing')
    args = parser.parse_args()

    # The path to the "scripts" directory where the script is located
    script_directory = os.path.dirname(os.path.abspath(__file__))

    # The base path to the "OPEN-PROM" directory
    base_path = os.path.abspath(os.path.join(script_directory, ".."))

    subfolder_status_list = check_files_and_list_subfolders(base_path, flag=args.flag)
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

    for idx, (subfolder_status, selected_subfolder) in enumerate(selected_subfolders, 1):
        folder_name = selected_subfolder.split(os.sep)[-1]  # Extract folder name
        lines = read_main_log(selected_subfolder) if not args.flag else parse_modelstat(os.path.join(selected_subfolder, "modelstat.txt"))
        if not lines:
            print(f"No data found in the log file for subfolder: {selected_subfolder}")
            continue
        country_year_status = parse_main_log(lines) if not args.flag else parse_modelstat(lines)

        # Check if the run is pending
        pending_run = "Status: PENDING" in subfolder_status

        df = create_dataframe(country_year_status, pending_run)
        if df is None or df.empty:
            print(f"No valid data found in the log file for subfolder: {selected_subfolder}")
            continue
       
        plot_heatmap(df, idx, folder_name)

    plt.show()

if __name__ == "__main__":
    main()
