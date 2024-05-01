import os
import re
import argparse
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

def list_subfolders():
    """
    Input: None
    Output: A list of tuples containing subfolder names and their corresponding modification times, sorted in reverse chronological order
    based on their modification times.
    """
    runs_dir = "runs"
    subfolders = [(f.name, f.stat().st_mtime) for f in sorted(os.scandir(runs_dir), key=lambda x: x.stat().st_mtime, reverse=False) if f.is_dir()]
    return subfolders

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
            # Initialize country's status dictionary if not already done
            if current_country not in country_year_status:
                country_year_status[current_country] = {}
        if status_match:
            current_status = 1 if status_match else 0

            if current_year and current_country:
                country_year_status[current_country][current_year] = current_status

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

def plot_heatmap(df, plot_title):
    """
    Input: df - Pandas DataFrame representing run success statuses for countries and years.
           plot_title - Title for the plot
    Output: Displays a heatmap visualization using seaborn and matplotlib, where rows represent countries,
            columns represent years, and color indicates run success (green for success, red for failure).
    """
    if df is not None:
        # Define custom color palette (green for 1, red for 0)
        cmap = sns.color_palette(["red", "green"])

        # Create the heatmap without annotations
        plt.figure(figsize=(10, max(6, len(df) * 0.2)))  # Adjust height based on the number of countries
        sns.heatmap(df, cmap=cmap, annot=False, linewidths=.5, linecolor='black', vmin=0, vmax=1, cbar=False)

        plt.title(plot_title)
        plt.xlabel('Year')
        plt.ylabel('Country')

        plt.show()
    else:
        print("DataFrame is empty.")

def main():
    parser = argparse.ArgumentParser(description='Visualize run success statuses for a selected subfolder.')
    parser.add_argument('-q', '--quick', action='store_true', help='automatically plot the newest subfolder')
    args = parser.parse_args()

    if args.quick:
        subfolders = list_subfolders()
        if subfolders:
            print("Automatically visualizing the newest subfolder:", subfolders[-1][0])
            selected_subfolder = subfolders[-1][0]  # Select the last subfolder (newest)
            print(f"Selected subfolder: {selected_subfolder}\n")
            lines = read_main_log(selected_subfolder)
            country_year_status = parse_main_log(lines)
            df = create_dataframe(country_year_status)
            df.pop(df.columns[-1])  # Remove the last column for pending runs
            plot_heatmap(df, plot_title=selected_subfolder)  # Pass the subfolder name as plot title
        else:
            print("No subfolders found in the 'runs' directory.")
            return
    else:
        subfolders = list_subfolders()
        if subfolders:
            print("Choose a subfolder from the following list:")
            for i, (subfolder, _) in enumerate(subfolders):
                print(f"{len(subfolders)-i}. {subfolder}")
            choice = int(input("Enter the number of the subfolder: "))
            selected_subfolder = subfolders[len(subfolders) - choice][0]
            print(f"Selected subfolder: {selected_subfolder}\n")
            lines = read_main_log(selected_subfolder)
            country_year_status = parse_main_log(lines)
            # Check if the run is pending
            df = create_dataframe(country_year_status)
            plot_heatmap(df, plot_title=selected_subfolder)  # Pass the subfolder name as plot title
        else:
            print("No subfolders found in the 'runs' directory.")
            return

if __name__ == "__main__":
    main()
