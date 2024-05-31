import os
import re
import time
import argparse
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from colorama import Fore, Style

def check_files_and_list_subfolders(base_path):
    runs_path = os.path.join(base_path, "runs")
    subfolders = [f.path for f in os.scandir(runs_path) if f.is_dir()]

    max_folder_name_length = max([len(folder.split(os.sep)[-1]) for folder in subfolders])

    max_status_length = 35
    max_year_length = 4

    current_time = time.time()
    max_modification_threshold = 120
    max_modification_time = current_time - max_modification_threshold

    subfolder_status_list = []

    for folder in subfolders:
        main_gms_path = os.path.join(folder, "main.gms")
        main_lst_path = os.path.join(folder, "main.lst")
        main_log_path = os.path.join(folder, "main.log")

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

    # Sort the subfolders list based on their creation time
    subfolder_status_list.sort(key=lambda x: os.stat(x[1]).st_birthtime, reverse=False)

    return subfolder_status_list

def find_pending_run(subfolder_status_list):
    for status, folder in subfolder_status_list:
        if "Status: PENDING" in status:
            return folder
    return None

def read_main_log(subfolder):
    main_log_path = os.path.join(subfolder, "main.log")
    if os.path.exists(main_log_path):
        with open(main_log_path, 'r') as file:
            lines = file.readlines()
        return lines
    else:
        print("main.log file not found in the selected subfolder.")
        return []

def parse_main_log(lines):
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
            if current_country not in country_year_status:
                country_year_status[current_country] = {}

        if reading_solution_match:
            
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
    if country_year_status:
        df = pd.DataFrame(country_year_status).fillna(0)
        df.index.name = 'Country'
        df = df.T
        df = df.astype(int)
        if pending_run:
            df.pop(df.columns[-1])
        return df
    else:
        print("No data found in the log file.")
        return None

def plot_heatmap(df, plot_title):
    if df is not None:
        cmap = sns.color_palette(["red", "green", "orange"])

        # Clear the current figure
        plt.clf()
      
      
        sns.heatmap(df, cmap=cmap, annot=False, linewidths=.5, linecolor='black', vmin=0, vmax=2, cbar=False)

        plt.title(plot_title)
        plt.xlabel('Year')
        plt.ylabel('Country')

        # Show the updated plot
        plt.draw()
        plt.pause(0.1)
    else:
        print("DataFrame is empty.")

def main_loop(base_path, check_interval=1.5, max_no_update_intervals=4):
    subfolder_status_list = check_files_and_list_subfolders(base_path)
    pending_folder = find_pending_run(subfolder_status_list)

    if not pending_folder:
        print("No pending runs found.")
        return

    pending_folder_name = os.path.basename(pending_folder)
    print(f"Monitoring pending run in folder: {pending_folder_name}")

    consecutive_no_update_intervals = 0

    while consecutive_no_update_intervals < max_no_update_intervals:
        try:
            lines = read_main_log(pending_folder)
            if not lines:
                print(f"No data found in the log file for subfolder: {pending_folder}")
                continue

            country_year_status = parse_main_log(lines)
            pending_run = True

            df = create_dataframe(country_year_status, pending_run)
            if df is None or df.empty:
                print(f"No valid data found in the log file for subfolder: {pending_folder}")
                consecutive_no_update_intervals += 1
                continue

            plot_title = pending_folder_name  # Use folder name as plot title
            plot_heatmap(df, plot_title)
            plt.pause(0.1)
            consecutive_no_update_intervals = 0  # Reset the counter since there's an update
        except Exception as e:
            print(f"Error processing tasks: {e}")

        time.sleep(check_interval)

    plt.show()  # Display the last plot indefinitely until the user closes the window


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Real-time monitoring of pending runs.')
    parser.add_argument('-i', '--interval', type=float, default=1.5, help='Check interval in seconds')
    args = parser.parse_args()

    script_directory = os.path.dirname(os.path.abspath(__file__))
    base_path = os.path.abspath(os.path.join(script_directory, ".."))

    main_loop(base_path, args.interval)
