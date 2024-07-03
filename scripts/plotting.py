import pandas as pd
import matplotlib.pyplot as plt

def load_excel_file(file_path):
    """Load the Excel file and return data from both sheets."""
    df_vcap_elec = pd.read_excel(file_path, sheet_name='VCapElec')
    df_vcap_elec2 = pd.read_excel(file_path, sheet_name='VCapElec2')
    return df_vcap_elec, df_vcap_elec2

def merge_and_compare(df1, df2):
    """Merge two DataFrames on common columns and calculate the difference in 'Level' values."""
    merged_df = pd.merge(df1, df2, on=['allCy', 'PGALL', 'ytime'], suffixes=('_VCapElec', '_VCapElec2'))
    merged_df['Difference'] = merged_df['Level_VCapElec'] - merged_df['Level_VCapElec2']
    return merged_df

def plot_comparison(merged_df, country, sector):
    """Plot the differences in 'Level' values for a specified country and sector across all years."""
    subset = merged_df[(merged_df['allCy'] == country) & (merged_df['PGALL'] == sector)]
    
    if subset.empty:
        print("No data available for the selected parameters.")
        return
    
    plt.figure(figsize=(14, 6))
    
    # Plotting the differences in Level values
    plt.subplot(1, 2, 1)
    plt.plot(subset['ytime'], subset['Difference'], marker='o', linestyle='-', color='blue')
    plt.xlabel('Year')
    plt.ylabel('Difference in values')
    plt.title(f'Difference in values for {country} - {sector} Across All Years')
    plt.grid(True)
    
    # Plotting the levels of the two variables
    plt.subplot(1, 2, 2)
    plt.plot(subset['ytime'], subset['Level_VCapElec'], marker='o', linestyle='-', color='green', label='VCapElec')
    plt.plot(subset['ytime'], subset['Level_VCapElec2'], marker='o', linestyle='-', color='orange', label='VCapElec2')
    plt.xlabel('Year')
    plt.ylabel('Level')
    plt.title(f'Values of VCapElec and VCapElec2 for {country} - {sector} Across All Years')
    plt.legend()
    plt.grid(True)
    
    plt.tight_layout()
    plt.show()

def main():
    # Load the Excel file
    excel_file_path = r"C:\Users\plesias\Desktop\VCapElec-VCapElec2.xlsx"
    df_vcap_elec, df_vcap_elec2 = load_excel_file(excel_file_path)
    
    # Ensure the 'Level' column is present in the DataFrames
    if 'Level' not in df_vcap_elec.columns or 'Level' not in df_vcap_elec2.columns:
        raise ValueError("Both sheets must contain a 'Level' column.")
    
    # Merge and compare the variables
    merged_df = merge_and_compare(df_vcap_elec, df_vcap_elec2)
    
    # Save the comparison to a CSV file
    merged_df.to_csv('comparison_v_cap_elec.csv', index=False)
    
    # Prompt the user for inputs and plot the comparison
    country = input("Enter the country: ")
    sector = input("Enter the sector: ")
    plot_comparison(merged_df, country, sector)

# Run the main function
if __name__ == "__main__":
    main()
