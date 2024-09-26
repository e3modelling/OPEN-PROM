import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

# Function to detect fluctuations
def detect_fluctuations(df, threshold=0.2):
    # Calculate year-over-year percentage change starting from the third column
    pct_change = df.iloc[:, 2:].pct_change(axis=1)  # Skip the first two columns (index starts at 0)
    large_fluctuations = (pct_change.abs() > threshold)  # Detect where changes exceed the threshold
    
    return pct_change, large_fluctuations

# Function to visualize only the years with fluctuations using a heatmap
def plot_fluctuations(df, large_fluctuations):
    # Filter columns where fluctuations are found
    cols_with_fluctuations = large_fluctuations.any(axis=0)  # Identify columns with any fluctuation
    filtered_fluctuations = large_fluctuations.loc[:, cols_with_fluctuations]  # Filter the fluctuations data

    # Check for duplicate indices
    if filtered_fluctuations.index.duplicated().any():
        print("Duplicate indices found in filtered_fluctuations. Handling duplicates by taking the max value.")
        filtered_fluctuations = filtered_fluctuations.groupby(filtered_fluctuations.index).max()  # Aggregate duplicates

    # Reindex the dataframe
    grouped_fluctuations = pd.DataFrame(filtered_fluctuations)

    # Transpose the DataFrame to have unique countries as rows
    transposed_fluctuations = grouped_fluctuations.transpose()

    # Create a new DataFrame to aggregate unique countries
    unique_countries = transposed_fluctuations.index.unique()
    aggregated_fluctuations = transposed_fluctuations.loc[unique_countries]

    print(aggregated_fluctuations.to_string())

    # Create the heatmap without annotations
    plt.figure(figsize=(10, max(6, len(aggregated_fluctuations) * 0.2)))  # Adjust height based on the number of unique countries/energy forms

    sns.heatmap(
        aggregated_fluctuations,   # Data for the heatmap
        cmap='Reds',               # Color palette for heatmap
        annot=False,               # Disable annotations
        linewidths=.5,            # Width of the lines separating cells
        linecolor='black',         # Color of the lines for grid effect
        vmin=0,                    # Minimum value for color mapping
        vmax=1,                    # Maximum value for color mapping
        cbar=False                 # Disable color bar
    )

    plt.title("Heatmap of Energy Fluctuations")  # Adding a title
    plt.xlabel("Countries")  # Label for x-axis
    plt.ylabel("Years")  # Label for y-axis
    plt.show()

# Function to create a fluctuation map
def create_fluctuation_map(df, large_fluctuations):
    # Create a list to store fluctuation data
    fluctuation_data = []

    for i, country in enumerate(df.iloc[:, 0]):
        for j, year in enumerate(df.columns[2:]):
            if large_fluctuations.iloc[i, j]:  # If there's a fluctuation
                fluctuation_data.append({
                    'Country/Energy Type': country,
                    'Year': year,
                    'Fluctuation': 'Fluctuated'
                })
    
    # Create a DataFrame from the list
    fluctuation_map = pd.DataFrame(fluctuation_data)

    # Save fluctuation map to Excel on the Desktop
    excel_path = "C:/Users/Plessias/Desktop/fluctuation_map.xlsx"
    fluctuation_map.to_excel(excel_path, index=False)
    print(f"Fluctuation map saved to {excel_path}")

# Function to process the data and highlight fluctuations
def process_energy_data(file_path, threshold=0.2, visualize=False):
    # Read the CSV file
    df = pd.read_csv(file_path, index_col=0)  # Assuming first column has countries/energy types
    
    # Detect fluctuations
    pct_change, large_fluctuations = detect_fluctuations(df, threshold)
    
    # Cast the third column onwards to strings where large fluctuations occur
    flagged_data = df.copy()
    flagged_data.iloc[:, 2:] = flagged_data.iloc[:, 2:].astype(str)  # Convert to string to store 'Fluctuated'
    flagged_data.iloc[:, 2:][large_fluctuations] = 'Fluctuated'  # Mark cells with large fluctuations
    
    # Save the flagged data and percentage changes to new CSV files
    output_flagged = file_path.replace(".csv", "_flagged.csv")
    output_pct_change = file_path.replace(".csv", "_pct_change.csv")
    
    flagged_data.to_csv(output_flagged)  # Save flagged data
    pct_change.to_csv(output_pct_change)  # Save percentage changes
    
    print(f"Analysis complete. Results saved to {output_flagged} and {output_pct_change}")
    
    # Create fluctuation map and save to Excel
    create_fluctuation_map(df, large_fluctuations)
    
    # Optional: Visualize the large fluctuations only for years with fluctuations
    if visualize:
        plot_fluctuations(df, large_fluctuations)

# Example of how to run the function
file_path = "C:/Users/Plessias/OPEN-PROM/runs/Calib2_IND_remove_VCapElecTot_VCapElec_completely_2024-09-25_13-43-54/data/iMaxResPot.csv"  # Update with your actual file path
process_energy_data(file_path, threshold=0.2, visualize=True)  # Adjust threshold if needed
