import pandas as pd
import numpy as np
import re

# ================= CONFIGURATION =================
MIF_FILE = 'C:\\Users\\at39\\2-Models\\OPEN-PROM\\runs\\SoCDR_Ed3_CurrentTargets\\reporting.mif'

# Years to appear in the output
REPORT_YEARS = [2010, 2015, 2020, 2025, 2030, 2035, 2040, 2045, 2050, 2055, 2060, 2065, 2070, 2075, 2080, 2085, 2090, 2095, 2100]

# EU27 Countries (for aggregation)
EU27_COUNTRIES = [
    'AUT', 'BEL', 'BGR', 'HRV', 'CYP', 'CZE', 'DNK', 'EST', 'FIN', 'FRA', 'DEU', 'GRC', 
    'HUN', 'IRL', 'ITA', 'LVA', 'LTU', 'LUX', 'MLT', 'NLD', 'POL', 'PRT', 'ROU', 'SVK', 
    'SVN', 'ESP', 'SWE'
]

# ================= REPORT STRUCTURE DEFINITION =================
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
    ("  Biomass", "Secondary Energy|Electricity|Biomass"),
    ("  Biomass w/ CCS", "Secondary Energy|Electricity|Biomass|w/ CCS"),  
    ("  Biomass w/o CCS", "Secondary Energy|Electricity|Biomass|w/o CCS"),    
    ("  Coal", "Secondary Energy|Electricity|Coal"),
    ("  Coal w/ CCS", "Secondary Energy|Electricity|Coal|w/ CCS"),
    ("  Coal w/o CCS", "Secondary Energy|Electricity|Coal|w/o CCS"), 
    ("  Demand", "Secondary Energy|Electricity|Demand"),      
    ("  Gas", "Secondary Energy|Electricity|Gas"),
    ("  Gas w/ CCS", "Secondary Energy|Electricity|Gas|w/ CCS"),
    ("  Gas w/o CCS", "Secondary Energy|Electricity|Gas|w/o CCS"),
    ("  Geothermal", "Secondary Energy|Electricity|Geothermal"),
    ("  Hydro", "Secondary Energy|Electricity|Hydro"),
    ("  Hydrogen", "Secondary Energy|Electricity|Hydrogen"),
    ("  Nuclear", "Secondary Energy|Electricity|Nuclear"),
    ("  Oil", "Secondary Energy|Electricity|Oil"),    
    ("  Solar", "Secondary Energy|Electricity|Solar"),
    ("  Steam", "Secondary Energy|Electricity|Steam"),     
    ("  Wind", "Secondary Energy|Electricity|Wind"),

    # ================= FINAL ENERGY BY SECTOR =================

    # --- INDUSTRY ---
    ("Industry Total (Mtoe)", "Final Energy|Industry"),
    ("  Ind|All liquids but GDO-RFO-GSL", "Final Energy|Industry|All liquids but GDO - RFO - GSL"),
    ("  Ind|Biodiesel", "Final Energy|Industry|Biodiesel"),
    ("  Ind|Biogasoline", "Final Energy|Industry|Biogasoline"),
    ("  Ind|Biomass and Waste", "Final Energy|Industry|Biomass and Waste"),
    ("  Ind|Crude Oil and Feedstocks", "Final Energy|Industry|Crude Oil and Feedstocks"),
    ("  Ind|Diesel Oil", "Final Energy|Industry|Diesel Oil"),
    ("  Ind|Electricity", "Final Energy|Industry|Electricity"),
    ("  Ind|Gases", "Final Energy|Industry|Gases"),
    ("  Ind|Gasoline", "Final Energy|Industry|Gasoline"),
    ("  Ind|Geothermal/Renewables", "Final Energy|Industry|Geothermal and other renewable sources"),
    ("  Ind|Hard Coal-Coke-Other Solids", "Final Energy|Industry|Hard Coal-Coke-Other Solids"),
    ("  Ind|Heat", "Final Energy|Industry|Heat"),
    ("  Ind|Kerosene", "Final Energy|Industry|Kerosene"),
    ("  Ind|Lignite", "Final Energy|Industry|Lignite"),
    ("  Ind|LPG", "Final Energy|Industry|Liquefied Petroleum Gas"),
    ("  Ind|Liquids", "Final Energy|Industry|Liquids"),
    ("  Ind|Natural Gas", "Final Energy|Industry|Natural Gas"),
    ("  Ind|New energy forms", "Final Energy|Industry|New energy forms"),
    ("  Ind|Other Gases", "Final Energy|Industry|Other Gases"),
    ("  Ind|Other Liquids", "Final Energy|Industry|Other Liquids"),
    ("  Ind|Renewables exc Hydro", "Final Energy|Industry|Renewables except Hydro"),
    ("  Ind|Residual Fuel Oil", "Final Energy|Industry|Residual Fuel Oil"),
    ("  Ind|Solar", "Final Energy|Industry|Solar"),
    ("  Ind|Solids", "Final Energy|Industry|Solids"),
    #("  Ind|Wind", "Final Energy|Industry|Wind"),

    # --- RESIDENTIAL AND COMMERCIAL ---
    ("Res & Comm Total (Mtoe)", "Final Energy|Residential and Commercial"),
    ("  Res|All liquids but GDO-RFO-GSL", "Final Energy|Residential and Commercial|All liquids but GDO - RFO - GSL"),
    ("  Res|Biodiesel", "Final Energy|Residential and Commercial|Biodiesel"),
    ("  Res|Biogasoline", "Final Energy|Residential and Commercial|Biogasoline"),
    ("  Res|Biomass and Waste", "Final Energy|Residential and Commercial|Biomass and Waste"),
    ("  Res|Crude Oil and Feedstocks", "Final Energy|Residential and Commercial|Crude Oil and Feedstocks"),
    ("  Res|Diesel Oil", "Final Energy|Residential and Commercial|Diesel Oil"),
    ("  Res|Electricity", "Final Energy|Residential and Commercial|Electricity"),
    ("  Res|Gases", "Final Energy|Residential and Commercial|Gases"),
    ("  Res|Gasoline", "Final Energy|Residential and Commercial|Gasoline"),
    ("  Res|Geothermal/Renewables", "Final Energy|Residential and Commercial|Geothermal and other renewable sources"),
    ("  Res|Hard Coal-Coke-Other Solids", "Final Energy|Residential and Commercial|Hard Coal-Coke-Other Solids"),
    ("  Res|Heat", "Final Energy|Residential and Commercial|Heat"),
    ("  Res|Kerosene", "Final Energy|Residential and Commercial|Kerosene"),
    ("  Res|Lignite", "Final Energy|Residential and Commercial|Lignite"),
    ("  Res|LPG", "Final Energy|Residential and Commercial|Liquefied Petroleum Gas"),
    ("  Res|Liquids", "Final Energy|Residential and Commercial|Liquids"),
    ("  Res|Natural Gas", "Final Energy|Residential and Commercial|Natural Gas"),
    ("  Res|New energy forms", "Final Energy|Residential and Commercial|New energy forms"),
    ("  Res|Other Gases", "Final Energy|Residential and Commercial|Other Gases"),
    ("  Res|Other Liquids", "Final Energy|Residential and Commercial|Other Liquids"),
    ("  Res|Renewables exc Hydro", "Final Energy|Residential and Commercial|Renewables except Hydro"),
    ("  Res|Residual Fuel Oil", "Final Energy|Residential and Commercial|Residual Fuel Oil"),
    ("  Res|Solar", "Final Energy|Residential and Commercial|Solar"),
    ("  Res|Solids", "Final Energy|Residential and Commercial|Solids"),
    #("  Res|Wind", "Final Energy|Residential and Commercial|Wind"),

    # --- TRANSPORTATION ---
    ("Transportation Total (Mtoe)", "Final Energy|Transportation"),
    ("  Trans|All liquids but GDO-RFO-GSL", "Final Energy|Transportation|All liquids but GDO - RFO - GSL"),
    ("  Trans|Biodiesel", "Final Energy|Transportation|Biodiesel"),
    ("  Trans|Biogasoline", "Final Energy|Transportation|Biogasoline"),
    #("  Trans|Biomass and Waste", "Final Energy|Transportation|Biomass and Waste"),
    #("  Trans|Crude Oil and Feedstocks", "Final Energy|Transportation|Crude Oil and Feedstocks"),
    ("  Trans|Diesel Oil", "Final Energy|Transportation|Diesel Oil"),
    ("  Trans|Electricity", "Final Energy|Transportation|Electricity"),
    ("  Trans|Gases", "Final Energy|Transportation|Gases"),
    ("  Trans|Gasoline", "Final Energy|Transportation|Gasoline"),
    #("  Trans|Geothermal/Renewables", "Final Energy|Transportation|Geothermal and other renewable sources"),
    #("  Trans|Hard Coal-Coke-Other Solids", "Final Energy|Transportation|Hard Coal-Coke-Other Solids"),
    #("  Trans|Heat", "Final Energy|Transportation|Heat"),
    ("  Trans|Kerosene", "Final Energy|Transportation|Kerosene"),
    ("  Trans|Lignite", "Final Energy|Transportation|Lignite"),
    ("  Trans|LPG", "Final Energy|Transportation|Liquefied Petroleum Gas"),
    ("  Trans|Liquids", "Final Energy|Transportation|Liquids"),
    ("  Trans|Natural Gas", "Final Energy|Transportation|Natural Gas"),
    ("  Trans|New energy forms", "Final Energy|Transportation|New energy forms"),
    ("  Trans|Other Gases", "Final Energy|Transportation|Other Gases"),
    ("  Trans|Other Liquids", "Final Energy|Transportation|Other Liquids"),
    ("  Trans|Renewables exc Hydro", "Final Energy|Transportation|Renewables except Hydro"),
    ("  Trans|Residual Fuel Oil", "Final Energy|Transportation|Residual Fuel Oil"),
    # ("  Trans|Solar", "Final Energy|Transportation|Solar"),
    # ("  Trans|Solids", "Final Energy|Transportation|Solids"),
    # ("  Trans|Wind", "Final Energy|Transportation|Wind"),

    # --- BUNKERS ---
    ("Bunkers Total (Mtoe)", "Final Energy|Bunkers"),
    ("  Bunkers|All liquids but GDO-RFO-GSL", "Final Energy|Bunkers|All liquids but GDO - RFO - GSL"),
    ("  Bunkers|Biodiesel", "Final Energy|Bunkers|Biodiesel"),
    # ("  Bunkers|Biogasoline", "Final Energy|Bunkers|Biogasoline"),
    # ("  Bunkers|Biomass and Waste", "Final Energy|Bunkers|Biomass and Waste"),
    # ("  Bunkers|Crude Oil and Feedstocks", "Final Energy|Bunkers|Crude Oil and Feedstocks"),
    ("  Bunkers|Diesel Oil", "Final Energy|Bunkers|Diesel Oil"),
    # ("  Bunkers|Electricity", "Final Energy|Bunkers|Electricity"),
    ("  Bunkers|Gases", "Final Energy|Bunkers|Gases"),
    ("  Bunkers|Gasoline", "Final Energy|Bunkers|Gasoline"),
    # ("  Bunkers|Geothermal/Renewables", "Final Energy|Bunkers|Geothermal and other renewable sources"),
    # ("  Bunkers|Hard Coal-Coke-Other Solids", "Final Energy|Bunkers|Hard Coal-Coke-Other Solids"),
    # ("  Bunkers|Heat", "Final Energy|Bunkers|Heat"),
    ("  Bunkers|Kerosene", "Final Energy|Bunkers|Kerosene"),
    ("  Bunkers|Lignite", "Final Energy|Bunkers|Lignite"),
    ("  Bunkers|LPG", "Final Energy|Bunkers|Liquefied Petroleum Gas"),
    ("  Bunkers|Liquids", "Final Energy|Bunkers|Liquids"),
    ("  Bunkers|Natural Gas", "Final Energy|Bunkers|Natural Gas"),
    ("  Bunkers|New energy forms", "Final Energy|Bunkers|New energy forms"),
    # ("  Bunkers|Other Gases", "Final Energy|Bunkers|Other Gases"),
    # ("  Bunkers|Other Liquids", "Final Energy|Bunkers|Other Liquids"),
    # ("  Bunkers|Renewables exc Hydro", "Final Energy|Bunkers|Renewables except Hydro"),
    ("  Bunkers|Residual Fuel Oil", "Final Energy|Bunkers|Residual Fuel Oil"),
    # ("  Bunkers|Solar", "Final Energy|Bunkers|Solar"),
    # ("  Bunkers|Solids", "Final Energy|Bunkers|Solids"),
    # ("  Bunkers|Wind", "Final Energy|Bunkers|Wind"),

    # --- CO2 Emissions ---
    ("CO2 Emissions", None),
    ("CO2 Emissions (Mt CO2)", "Emissions|CO2"),
    ("GHG emissions (MtCO2equiv/year)", "Emissions|Kyoto Gases"),
    ("Non-CO2 Emissions (Mt CO2eq/yr)", "Emissions|nonCO2"), 
    
    ("  AFOLU", "Emissions|CO2|AFOLU"),
    ("  Energy", "Emissions|CO2|Energy"),
    ("  Energy and Industrial Processes", "Emissions|CO2|Energy and Industrial Processes"),  
    ("Energy Demand", "Emissions|CO2|Energy|Demand"),        
    ("  Bunkers ", "Emissions|CO2|Energy|Demand|Bunkers"),
    ("  Industry", "Emissions|CO2|Energy|Demand|Industry"),
    ("  Buildings", "Emissions|CO2|Energy|Demand|Residential and Commercial"),    
    ("  Agriculture - Fishing - Forestry", "Emissions|CO2|Energy|Demand|Residential and Commercial|Agriculture - Fishing - Forestry"),
    ("  Households", "Emissions|CO2|Energy|Demand|Residential and Commercial|Households"),
    ("  Services and Trade", "Emissions|CO2|Energy|Demand|Residential and Commercial|Services and Trade"),
    ("  Transport", "Emissions|CO2|Energy|Demand|Transportation"),
    ("  Goods Transport - Inland Navigation", "Emissions|CO2|Energy|Demand|Transportation|Goods Transport - Inland Navigation"),
    ("  Goods Transport - Rail", "Emissions|CO2|Energy|Demand|Transportation|Goods Transport - Rail"),
    ("  Goods Transport - Trucks", "Emissions|CO2|Energy|Demand|Transportation|Goods Transport - Trucks"),
    ("  Passenger Transport - Aviation", "Emissions|CO2|Energy|Demand|Transportation|Passenger Transport - Aviation"),
    ("  Passenger Transport - Busses", "Emissions|CO2|Energy|Demand|Transportation|Passenger Transport - Busses"),
    ("  Passenger Transport - Cars", "Emissions|CO2|Energy|Demand|Transportation|Passenger Transport - Cars"),
    ("  Passenger Transport - Inland Navigation", "Emissions|CO2|Energy|Demand|Transportation|Passenger Transport - Inland Navigation"),
    ("  Passenger Transport - Rail", "Emissions|CO2|Energy|Demand|Transportation|Passenger Transport - Rail"),
    ("Energy Supply", "Emissions|CO2|Energy|Supply"),
    ("  Electricity", "Emissions|CO2|Energy|Supply|Electricity"),
    ("  Heat", "Emissions|CO2|Energy|Supply|Heat"),
    ("  Hydrogen", "Emissions|CO2|Energy|Supply|Hydrogen"),
    ("Industrial Processes", "Emissions|CO2|Industrial Processes"),
    # By Fuel Breakdown
    ("By fuel", None),
    ("  Solids", "Emissions|CO2|Energy|Supply|Solids"),
    ("  Gases", "Emissions|CO2|Energy|Supply|Gases"),
    ("  Liquids", "Emissions|CO2|Energy|Supply|Liquids"),
    # --- Carbon Capture ---
    ("Carbon Capture", None),
    ("Carbon Capture (Mt CO2)", "Carbon Capture"),
    ("  Electricity", "Carbon Capture|Electricity"),
    ("  Enhanced Weathering", "Carbon Capture|Enhanced Weathering"),
    ("  Geological Storage", "Carbon Capture|Geological Storage"),
    ("    Biomass", "Carbon Capture|Geological Storage|Biomass"),
    ("    Direct Air Capture", "Carbon Capture|Geological Storage|Direct Air Capture"),
    ("    Other Sources", "Carbon Capture|Geological Storage|Other Sources"),    
    ("  Hydrogen", "Carbon Capture|Hydrogen"),
    ("  Industry", "Carbon Capture|Industry"),
    ("  Land Use", "Carbon Capture|Land Use"),
    ("Carbon Price", None),  
    ("Carbon Price (US$2015/tn CO2)", "Price|Carbon"),
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

def calculate_non_co2(df):
    """
    Calculates Emissions|nonCO2 = Emissions|Kyoto Gases - Emissions|CO2
    and appends the new rows to the dataframe.
    """
    print("   Calculating Emissions|nonCO2...")
    
    # Filter for relevant variables
    df_kyoto = df[df['Variable'] == 'Emissions|Kyoto Gases'].copy()
    df_co2 = df[df['Variable'] == 'Emissions|CO2'].copy()
    
    if df_kyoto.empty or df_co2.empty:
        print("   Warning: 'Emissions|Kyoto Gases' or 'Emissions|CO2' not found. Skipping calculation.")
        return df

    # Prepare for merge on Metadata columns
    join_cols = ['Model', 'Scenario', 'Region']
    
    # Identify Year columns (intersection of DF columns and config REPORT_YEARS)
    year_cols = [str(y) for y in REPORT_YEARS if str(y) in df.columns]
    
    if not year_cols:
        return df

    # Subset DataFrames to avoid column conflicts
    df_kyoto = df_kyoto[join_cols + year_cols]
    df_co2 = df_co2[join_cols + year_cols]
    
    # Merge
    merged = pd.merge(df_kyoto, df_co2, on=join_cols, suffixes=('_ghg', '_co2'))
    
    if merged.empty:
        return df

    # Create new dataframe for the result
    df_new = merged[join_cols].copy()
    df_new['Variable'] = 'Emissions|nonCO2'
    df_new['Unit'] = 'Mt CO2eq/yr' 
    
    # Perform subtraction
    for col in year_cols:
        val_ghg = pd.to_numeric(merged[col + '_ghg'], errors='coerce')
        val_co2 = pd.to_numeric(merged[col + '_co2'], errors='coerce')
        df_new[col] = val_ghg - val_co2
        
    # Append to original DataFrame
    # (We filter out existing Emissions|nonCO2 to avoid duplicates if re-running)
    df_out = df[df['Variable'] != 'Emissions|nonCO2']
    df_final = pd.concat([df_out, df_new], ignore_index=True)
    
    return df_final

def main():
    print("1. Loading MIF file...")
    try:
        # Try semicolon first, then comma
        df_mif = pd.read_csv(MIF_FILE, sep=';')
        if df_mif.shape[1] < 5: df_mif = pd.read_csv(MIF_FILE, sep=',')
    except Exception as e:
        print(f"Error loading MIF file: {e}")
        return

    # --- CALCULATION STEP ADDED HERE ---
    df_mif = calculate_non_co2(df_mif)
    # -----------------------------------

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