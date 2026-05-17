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
        modelstat_path = os.path.join(folder, "modelstat.txt")

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

            with open(modelstat_path, "r") as file:
                all_lines = file.readlines()
                year_matches = [re.search(r"Year:\s*(\d+)", line) for line in all_lines]
                years = [m.group(1) for m in year_matches if m]
                latest_year_int = max((int(y) for y in years), default=None)
                latest_year = str(latest_year_int).rjust(max_year_length) if latest_year_int is not None else "N/A"
                end_horizon_int = int(end_horizon_year) if end_horizon_year.isdigit() else None

                time_difference = current_time - os.path.getmtime(modelstat_path)
                modification_threshold = 15

                # PENDING: not yet at horizon AND file was modified recently (run is active)
                # COMPLETED: reached the end horizon
                # FAILED: stopped short of horizon and is no longer being updated
                if latest_year_int is not None and end_horizon_int is not None and latest_year_int >= end_horizon_int:
                    status = f"Missing: NONE      Status: COMPLETED  Year: {latest_year}  Horizon: {end_horizon_year}".ljust(max_status_length)
                elif latest_year_int is not None and end_horizon_int is not None and latest_year_int < end_horizon_int and time_difference < modification_threshold:
                    status = f"Missing: NONE      Status: PENDING    Running_Year: {latest_year}  Horizon: {end_horizon_year}".ljust(max_status_length)
                    color = Fore.BLUE
                elif years:
                    status = f"Missing: NONE      Status: FAILED     Year: {latest_year}  Horizon: {end_horizon_year}".ljust(max_status_length)
                    color = Fore.RED
                else:
                    status = f"modelstat.txt -> FAILED Status: FAILED  Year: {latest_year}  Horizon: {end_horizon_year}".ljust(max_status_length)
                    color = Fore.RED

        subfolder_status_list.append((f"{color} {folder_name:<{max_folder_name_length}} {status}{Style.RESET_ALL}", folder))

    # Sort the subfolders list based on their creation time
    subfolder_status_list.sort(key=lambda x: os.path.getctime(x[1]), reverse=False)

    return subfolder_status_list

def find_pending_run(subfolder_status_list):
    for status, folder in subfolder_status_list:
        if "Status: PENDING" in status:
            return folder
    return None

def find_latest_run_by_creation_time(subfolder_status_list):
    candidates = [
        (status, folder) for status, folder in subfolder_status_list
        if os.path.exists(os.path.join(folder, "modelstat.txt"))
    ]
    if not candidates:
        return None
    return max(candidates, key=lambda x: os.path.getctime(x[1]))[1]

def read_modelstat(subfolder):
    modelstat_path = os.path.join(subfolder, "modelstat.txt")
    if os.path.exists(modelstat_path):
        with open(modelstat_path, 'r') as file:
            lines = file.readlines()
        return lines
    else:
        print("modelstat.txt file not found in the selected subfolder.")
        return []

def parse_modelstat(lines):
    line_pattern = re.compile(r'Country:\s*([A-Z]+)\s+Model Status:\s*([\d.]+)\s+Year:\s*(\d+)')
    country_year_status = {}
    for line in lines:
        match = re.search(line_pattern, line)
        if not match:
            continue

        country = match.group(1)
        model_status_raw = int(float(match.group(2)))
        year = int(match.group(3))

        # Traffic-light classes for heatmap values:
        # 0 = failed (red), 1 = success (green), 2 = feasible (yellow)
        if model_status_raw == 2:
            model_status = 1
        elif model_status_raw == 5:
            model_status = 2
        else:
            model_status = 0

        if country not in country_year_status:
            country_year_status[country] = {}

        country_year_status[country][year] = model_status
                    
    return country_year_status

def create_dataframe(country_year_status, pending_run=False):
    if country_year_status:
        df = pd.DataFrame(country_year_status).fillna(0)
        df.index.name = 'Country'
        df = df.T
        df = df.astype(int)
        if pending_run == True and df.shape[1] > 1:
            df.pop(df.columns[-1])
        return df
    else:
        print("No data found in the log file.")
        return None

def plot_heatmap(df, plot_title, live_mode=False):
    if df is not None:
        cmap = sns.color_palette(["red", "green", "yellow"])

        # Clear the current figure
        plt.clf()
      
      
        sns.heatmap(df, cmap=cmap, annot=False, linewidths=.5, linecolor='black', vmin=0, vmax=2, cbar=False)

        plt.title(plot_title)
        plt.xlabel('Year')
        plt.ylabel('Country')

        if live_mode:
            # In live mode, refresh the existing figure periodically.
            plt.draw()
            plt.pause(0.1)
    else:
        print("DataFrame is empty.")

def main_loop(base_path, check_interval=1.5, max_no_update_intervals=4):
    subfolder_status_list = check_files_and_list_subfolders(base_path)
    pending_folder = find_pending_run(subfolder_status_list)

    if not pending_folder:

        print("No pending run found. Plotting the most recent completed run.")
        latest_subfolder = find_latest_run_by_creation_time(subfolder_status_list)
        if latest_subfolder:
            folder_name = latest_subfolder.split(os.sep)[-1]
            lines = read_modelstat(latest_subfolder)
            if lines:
                country_year_status = parse_modelstat(lines)
                df = create_dataframe(country_year_status)
                plot_heatmap(df, folder_name, live_mode=False)
                plt.show()
            else:
                print("No data found in modelstat.txt for the latest subfolder.")
        else:
            print("No run folder was found in the runs directory.")
        return

    pending_folder_name = os.path.basename(pending_folder)
    print(f"Monitoring pending run in folder: {pending_folder_name}")

    plt.ion()
    consecutive_no_update_intervals = 0

    while consecutive_no_update_intervals < max_no_update_intervals:
        try:
            lines = read_modelstat(pending_folder)
            if not lines:
                print(f"No data found in modelstat.txt for subfolder: {pending_folder}")
                continue

            country_year_status = parse_modelstat(lines)
            pending_run = True

            df = create_dataframe(country_year_status, pending_run)
            if df is None or df.empty:
                print(f"No valid data found in modelstat.txt for subfolder: {pending_folder}")
                consecutive_no_update_intervals += 1
                continue

            plot_title = pending_folder_name  # Use folder name as plot title
            plot_heatmap(df, plot_title, live_mode=True)
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
