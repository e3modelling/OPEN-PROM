import pandas as pd
import numpy as np
import re

# ================= CONFIGURATION =================
MIF_FILE = 'reporting.mif'

# Years to appear in the output
REPORT_YEARS = [2005, 2010, 2015, 2020, 2025, 2030, 2035, 2040, 2045, 2050]

# EU27 Countries (for aggregation)
EU27_COUNTRIES = [
    'AUT', 'BEL', 'BGR', 'HRV', 'CYP', 'CZE', 'DNK', 'EST', 'FIN', 'FRA', 'DEU', 'GRC', 
    'HUN', 'IRL', 'ITA', 'LVA', 'LTU', 'LUX', 'MLT', 'NLD', 'POL', 'PRT', 'ROU', 'SVK', 
    'SVN', 'ESP', 'SWE'
]

# ================= REPORT STRUCTURE DEFINITION =================
# This list defines the exact rows that will be created in the Excel file.
# Format: ('Display Name', 'MIF Variable')
# Use 'None' for the MIF Variable to create a Section Header.

REPORT_STRUCTURE = [
    # --- General Indicators ---
    ("Population / Economic growth", None),
    ("Population (Billions)", "Population"),
    ("GDP in billion (US$2015/yr PPP)", "GDP|PPP"),

    # --- Primary Energy ---
    ("Primary Energy", None),
    ("Primary Energy (in Mtoe)", "Primary Energy"),
    ("Coal", "Primary Energy|Coal"),
    ("Oil", "Primary Energy|Oil"),
    ("Gas", "Primary Energy|Gases"),
    ("Nuclear", "Primary Energy|Nuclear"),
    ("Hydro", "Primary Energy|Hydro"),
    ("Biomass and waste", "Primary Energy|Biomass"),
    ("Wind", "Primary Energy|Wind"),
    ("Solar", "Primary Energy|Solar"),
    ("Geothermal", "Primary Energy|Geothermal"),

    # --- Electricity Generation ---
    ("Electricity generation", None),
    ("Electricity generation (in TWh)", "Secondary Energy|Electricity"),
    ("Coal and lignite", "Secondary Energy|Electricity|Coal"),
    ("Gas", "Secondary Energy|Electricity|Gas"),
    ("Nuclear", "Secondary Energy|Electricity|Nuclear"),
    ("Hydro", "Secondary Energy|Electricity|Hydro"),
    ("Wind", "Secondary Energy|Electricity|Wind"),
    ("Solar", "Secondary Energy|Electricity|Solar"),
    ("Biomass and waste", "Secondary Energy|Electricity|Biomass"),
    ("Geothermal", "Secondary Energy|Electricity|Geothermal"),

    # --- Final Energy Demand ---
    ("Final energy demand", None),
    ("Final energy demand ( in Mtoe)", "Final Energy"),
    ("Industry", "Final Energy|Industry"),
    ("Transport", "Final Energy|Transportation"),
    ("Domestic, Services, Agriculture", "Final Energy|Residential and Commercial"),

    # --- CO2 Emissions ---
    ("CO2 Emissions", None),
    ("CO2 Emissions (Mt CO2)", "Emissions|CO2"),
    ("Industry", "Emissions|CO2|Energy|Demand|Industry"),
    ("Transport", "Emissions|CO2|Energy|Demand|Transportation"),
    ("Buildings", "Emissions|CO2|Energy|Demand|Residential and Commercial"),
    ("Electricity production", "Emissions|CO2|Energy|Supply|Electricity"),
    ("Hydrogen production", "Emissions|CO2|Energy|Supply|Hydrogen"),
    ("Bunkers ", "Emissions|CO2|Energy|Demand|Bunkers"),
    
    # By Fuel Breakdown
    ("By fuel", None),
    ("Solids", "Emissions|CO2|Energy|Supply|Solids"),
    ("Gases", "Emissions|CO2|Energy|Supply|Gases"),
    ("Liquids", "Emissions|CO2|Energy|Supply|Liquids"),
    ("Biomass (sequestration)", None), # Placeholder as per request

    ("GHG emissions (MtCO2equiv/year)", "Emissions|Kyoto Gases"),
]

def get_mif_data(df, region, variable, year):
    """Retrieves value. Sums EU27 members if 'EU27' region is missing."""
    if variable is None: return None # Header row
    
    df_var = df[df['Variable'] == variable]
    if df_var.empty: return None

    # 1. Direct Match
    row = df_var[df_var['Region'] == region]
    
    # 2. Aggregate EU27 if missing
    if row.empty and region == 'EU27':
        subset = df_var[df_var['Region'].isin(EU27_COUNTRIES)]
        if not subset.empty and str(year) in subset.columns:
            try:
                return pd.to_numeric(subset[str(year)], errors='coerce').sum()
            except:
                return None
    
    # 3. Return Value
    if not row.empty and str(year) in row.columns:
        return row.iloc[0][str(year)]
    return None

def extract_scenario_name(df_mif):
    """Finds scenario name from columns like 'Scenario', 'ScenarioName', etc."""
    scenario_col = None
    for c in df_mif.columns:
        c_norm = str(c).strip().lower().replace(" ", "").replace("_", "")
        if c_norm in {"scenario", "scenarioname", "name", "scen"} or "scenario" in c_norm:
            scenario_col = c
            break

    if scenario_col is None: return "UnknownScenario"
        
    vals = df_mif[scenario_col].dropna().astype(str).str.strip()
    vals = vals[vals != ""]
    
    if vals.empty: return "UnknownScenario"
    return vals.unique()[0]

def main():
    print("1. Loading MIF file...")
    try:
        # Try semicolon first, then comma
        df_mif = pd.read_csv(MIF_FILE, sep=';')
        if df_mif.shape[1] < 5: df_mif = pd.read_csv(MIF_FILE, sep=',')
    except Exception as e:
        print(f"Error loading MIF file: {e}")
        return

    # Determine Scenario Name
    scenario_name = extract_scenario_name(df_mif)
    safe_scenario_name = re.sub(r'[<>:"/\\|?*]', '_', scenario_name)
    OUTPUT_FILE = f"Results_{safe_scenario_name}.xlsx"
    
    print(f"   Scenario: {scenario_name}")
    print(f"   Output File: {OUTPUT_FILE}")

    # Determine Regions
    all_mif_regions = sorted(df_mif['Region'].unique().astype(str))
    regions_to_process = ['EU27']
    other_regions = [r for r in all_mif_regions if r not in EU27_COUNTRIES and r != 'EU27']
    regions_to_process.extend(other_regions)
    
    print(f"2. Generating report for {len(regions_to_process)} regions...")
    
    with pd.ExcelWriter(OUTPUT_FILE, engine='openpyxl') as writer:
        for region in regions_to_process:
            print(f"   Generating sheet: {region}...")
            
            # Prepare Data Dictionary
            # Column 1: Variable Names
            data = {'Variable': [item[0] for item in REPORT_STRUCTURE]}
            
            # Columns 2+: Years
            for year in REPORT_YEARS:
                col_values = []
                for item in REPORT_STRUCTURE:
                    mif_var = item[1]
                    val = get_mif_data(df_mif, region, mif_var, year)
                    col_values.append(val)
                data[year] = col_values
            
            # Create DataFrame
            df_sheet = pd.DataFrame(data)
            
            # Cosmetic: Rename 'Variable' column to Region Name
            df_sheet.rename(columns={'Variable': region}, inplace=True)
            
            # Insert Scenario Name at the very top
            # Create a header row dataframe
            header_row = {col: np.nan for col in df_sheet.columns}
            header_row[region] = f"Scenario: {scenario_name}"
            
            # Concatenate Header + Data
            df_final = pd.concat([pd.DataFrame([header_row]), df_sheet], ignore_index=True)
            
            # Save to Excel
            safe_sheet_name = str(region)[:31]
            df_final.to_excel(writer, sheet_name=safe_sheet_name, index=False)

    print(f"\nSuccess! Saved to: {OUTPUT_FILE}")

if __name__ == "__main__":
    main()