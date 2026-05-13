import os
from rr import check_files_and_list_subfolders, list_subfolders

def call_functions():
    # The path to the "scripts" directory where the script is located
    script_directory = os.path.dirname(os.path.abspath(__file__))

    # The base path to the "OPEN-PROM" directory
    base_path = os.path.abspath(os.path.join(script_directory, ".."))

    subfolder_status_list = check_files_and_list_subfolders(base_path)
    selected_subfolders = list_subfolders(subfolder_status_list)

    if not selected_subfolders:
        print("No subfolders found in the 'runs' directory.")
        return

    choices = input("Enter the numbers of the subfolders (e.g., '1 2'): ")
    choices = [int(choice.strip()) for choice in choices.split()]

    selected_subfolders = [subfolder_status_list[len(subfolder_status_list) - choice] for choice in choices]
    print(f"Selected subfolders: {[subfolder for _, subfolder in selected_subfolders]}\n")

    return selected_subfolders

if __name__ == "__main__":
    path = call_functions()
