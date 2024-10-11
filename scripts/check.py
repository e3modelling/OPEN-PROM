import datacommons_pandas as dcpd

# API Key if required (update as needed)
API_KEY = "your_API_key"

# Define a mapping of common types of queries to the appropriate statistical variables in DataCommons
QUERY_MAP = {
    "population": "Count_Person",
    "emissions": "Amount_Emissions_GreenhouseGas_NonCO2Eq",
    "renewable energy": "Amount_Consumption_Energy_Renewable",
    "gdp": "Amount_GrossDomesticProduction_Nominal",
    "electricity generation": "Amount_Electricity_Generation",
    "primary energy production": "Amount_Production_Energy_Primary",
    "energy": "Amount_Consumption_Energy",
    "unemployment": "Count_Unemployed",
    "income": "Median_Income_Person",
    "household": "Count_Household",
    "education": "Count_EducationalInstitution",
    # Add more query types as necessary
}

# Mapping of common country names to DataCommons country codes
COUNTRY_CODE_MAP = {
    "Germany": "country/DEU",
    "India": "country/IND",
    "USA": "country/USA",
    "Canada": "country/CAN",
    "France": "country/FRA",
    "Japan": "country/JPN",
    # Add more countries as necessary
}

def get_statistical_data(country_code, query):
    # Look up the statistical variable for the given query
    stat_var = QUERY_MAP.get(query.lower())
    if not stat_var:
        return "Sorry, I can't provide information on that topic."

    try:
        # Fetch the data using the DataCommons API
        data = dcpd.build_time_series(country_code, stat_var)
        return data
    except Exception as e:
        return f"Error fetching data: {str(e)}"

def main():
    # Get user input
    country_input = input("Please enter a country (e.g., 'Germany' or 'country/DEU'): ")
    query = input("What information would you like to know (e.g., population, emissions, etc.)? ")
    
    # Map country name to country code if necessary
    country_code = COUNTRY_CODE_MAP.get(country_input, country_input)
    
    # Retrieve the data
    result = get_statistical_data(country_code, query)
    
    # Print the result
    print(result)

if __name__ == "__main__":
    main()
