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
        with open(main_log_path, "r") as file:
            # Read the last 5 lines of main.log
            last_lines = file.readlines()[-5:]
            # Get the current time
            current_time = time.time()
            # Get the last modification time of the file
            file_modification_time = os.path.getmtime(main_log_path)
            # Calculate the time difference in seconds
            time_difference = current_time - file_modification_time
            # Specify the threshold for considering the file as recently modified (in seconds)
            modification_threshold = 20
            if any("*** Status: Normal completion" in line for line in last_lines) and time_difference < modification_threshold:
                print(Fore.GREEN + f"{folder_name: <20} /Missing: NONE /status:COMPLETED" + Style.RESET_ALL)
            elif any("*** Status: Normal completion" in line for line in last_lines) and time_difference > modification_threshold:
                print(Fore.BLUE  + f"{folder_name: <20} /Missing: NONE      /status:PENDING" + Style.RESET_ALL)
            else:
                print(Fore.RED + f"{folder_name: <20} /main.log -> FAILED /status:FAILED" + Style.RESET_ALL)
    
def main():
    """
    This function intializes all the functions of the script and
    loops over the selected subfolders.
    """
    # The path needs to become dynamic.
    # Test path: "C:/Users/plesias/Desktop/OPEN-PROM"
    #base_path = "C:/Users/plesias/Desktop/OPEN-PROM"
    # The path to the "scripts" directory where the script is located
    script_directory = os.path.dirname(os.path.abspath(__file__))
    
    # The base path to the "OPEN-PROM" directory
    base_path = os.path.abspath(os.path.join(script_directory, ".."))
    
    subfolders = select_folders(base_path)
    for folder in subfolders:
        check_files(folder)

if __name__ == "__main__":
    main()