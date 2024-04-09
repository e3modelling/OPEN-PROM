import os
import re
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

def list_subfolders():
    runs_dir = "runs"
    subfolders = [f.name for f in sorted(os.scandir(runs_dir), key=lambda x: x.stat().st_mtime, reverse=True) if f.is_dir()]
    return subfolders

def read_main_log(subfolder):
    main_log_path = os.path.join("runs", subfolder, "main.log")
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

def plot_heatmap(df):
    if df is not None:
        # Define colors for the heatmap (green for 1, red for 0)
        cmap = sns.diverging_palette(10, 220, sep=80, n=2)

        # Create the heatmap without annotations
        plt.figure(figsize=(10, max(6, len(df) * 0.2)))  # Adjust height based on the number of countries
        sns.heatmap(df, cmap=cmap, annot=False, fmt='d', linewidths=.5, linecolor='black')

        plt.title('Run Success Heatmap')
        plt.xlabel('Year')
        plt.ylabel('Country')

        plt.show()
    else:
        print("DataFrame is empty.")

def main():
    subfolders = list_subfolders()
    if subfolders:
        print("Choose a subfolder from the following list:")
        for i, subfolder in enumerate(subfolders):
            print(f"{i+1}. {subfolder}")
        choice = int(input("Enter the number of the subfolder: "))
        selected_subfolder = subfolders[choice - 1]
        print(f"Selected subfolder: {selected_subfolder}\n")

        lines = read_main_log(selected_subfolder)
        country_year_status = parse_main_log(lines)
        df = create_dataframe(country_year_status)

        plot_heatmap(df)
    else:
        print("No subfolders found in the 'runs' directory.")

if __name__ == "__main__":
    main()
