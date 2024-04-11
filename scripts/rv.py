import os
import time
from colorama import Fore, Style

def select_folders(base_path):
    """
    This functions input is the folder path. It finds the desired directory, scans it,
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

    print("Recently started runs might be listed as FAILED, wait 15 seconds before running the script for recently started runs.")
    print("Checking all subfolders...")
    
    return subfolders
    
def check_files(folder):
    """
    This functions input is the selected subfolders in a list of strings.
    This function performs all the necessary checks for the selected subfolders.
    - First check is to verify if there is a main.gms file present.
    - Second check is to verify if there is a main.lst file present.
    - Third check is to verify if there is a main.log file present.
    If all there checks pass, then it opens the main.log file in each subfolder
    and searches the last 5 lines for the key phrase: *** Status: Normal completion.
    Lastly it informs the user about the state of each subfolder, which files are 
    missing and whether the main.log is successful or not.
    """

    main_gms_path = os.path.join(folder, "main.gms")
    main_lst_path = os.path.join(folder, "main.lst")
    main_log_path = os.path.join(folder, "main.log")

    # Split the path and isolate folder name for printing
    folder_name = folder.split('\\')[-1]

    if not os.path.exists(main_gms_path):
        print(Fore.RED  + f"{folder_name: <20} /Missing: main.gms  /status:NOT A RUN" + Style.RESET_ALL)
    elif not os.path.exists(main_lst_path):
        print(Fore.BLUE + f"{folder_name: <20} /Missing: main.lst  /status:PENDING" + Style.RESET_ALL)
    elif not os.path.exists(main_log_path):
        print(Fore.BLUE + f"{folder_name: <20} /Missing: main.log  /status:PENDING" + Style.RESET_ALL)
    else:

        with open(main_gms_path, "r") as gms_file:
            
            # Read main.gms
            gms_content = gms_file.readlines()

            # Find the line containing "$evalGlobal fEndY" 
            end_horizon_line = next((line for line in gms_content if "$evalGlobal fEndY" in line), None)

            # Extract the year from the line
            end_horizon_year = end_horizon_line.split()[-1]

        with open(main_log_path, "r") as file:

            # Read the last 5 lines of main.log
            last_lines = file.readlines()[-65:]

            # Find the year before the optimal solution note
            if any("an =" in line for line in last_lines): 
                for line in last_lines:
                    if "an =" in line:
                        year = line.split("=")[1].strip()
            # Find the year before the optimal solution note
            running_year = None
         
            # Find the year before the optimal solution note
            for line in reversed(last_lines):
                if "an =" in line:
                    running_year = line.split("=")[1].strip()
                    break

            # Get the current time
            current_time = time.time()

            # Get the last modification time of the file
            file_modification_time = os.path.getmtime(main_log_path)

            # Calculate the time difference in seconds
            time_difference = current_time - file_modification_time

            # Specify the threshold for considering the file as recently modified (in seconds)
            modification_threshold = 15
            max_modification_threshold = 120

            if any("*** Status: Normal completion" in line for line in last_lines) and time_difference > max_modification_threshold and time_difference > modification_threshold:
                print(Fore.GREEN + f"{folder_name: <20} /Missing: NONE      /status:COMPLETED",f"/Year:{year}",f"/Horizon:{end_horizon_year}" + Style.RESET_ALL)
            elif any("*** Status: Normal completion" in line for line in last_lines) and time_difference > modification_threshold:
                print(Fore.GREEN + f"{folder_name: <20} /Missing: NONE      /status:COMPLETED",f"/Year:{year}",f"/Horizon:{end_horizon_year}" + Style.RESET_ALL)
            elif  any("*** Status: Normal completion" in line for line in last_lines) and time_difference < modification_threshold:
                print(Fore.GREEN + f"{folder_name: <20} /Missing: NONE /status:COMPLETED",f"/Year:{year}",f"/Horizon:{end_horizon_year}" + Style.RESET_ALL)
            elif time_difference < modification_threshold and not any("*** Status: Normal completion" in line for line in last_lines):
                
                print(Fore.BLUE  + f"{folder_name: <20} /Missing: NONE      /status:PENDING",f"/Running_Year:{running_year}",f"/Horizon:{end_horizon_year}" + Style.RESET_ALL)

            else:
                print(Fore.RED + f"{folder_name: <20} /main.log -> FAILED /status:FAILED" + Style.RESET_ALL)
    
def main():
    """
    This function intializes all the functions of the script and
    loops over the selected subfolders.
    """

    # The path to the "scripts" directory where the script is located
    script_directory = os.path.dirname(os.path.abspath(__file__))
    
    # The base path to the "OPEN-PROM" directory
    base_path = os.path.abspath(os.path.join(script_directory, ".."))
    
    subfolders = select_folders(base_path)

    for folder in subfolders:
        check_files(folder)

if __name__ == "__main__":
    main()