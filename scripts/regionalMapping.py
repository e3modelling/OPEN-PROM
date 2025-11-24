import pandas as pd
import requests
from io import StringIO
import re
import yaml
from datetime import date

# === CONFIGURATION ===
csvUrl = "https://raw.githubusercontent.com/e3modelling/mrprom/main/inst/extdata/regional/regionmappingOPDEV5.csv"
markdownPath = "../tutorials/06_Regionalization in OPEN-PROM.md"
mappingsYamlPath = "mappings.yaml"
nativeRegionsYamlPath = "native_regions.yaml"
sectionTitle = "### OPEN-PROM Regional Mapping Table"
modelName = "OPEN-PROM 2.0"

# Control whether YAML files are written or not
updateYamlFiles = False


# === UTILITIES ===
def inferRegionName(regionCode, countryList):
    """Heuristic naming for regions based on country list."""
    n = len(countryList)
    lower = [c.lower() for c in countryList]
    if n == 1:
        return countryList[0]
    if any("europe" in c or c in ["andorra", "norway", "switzerland", "iceland", "liechtenstein"] for c in lower):
        if any(c in ["belgium", "germany", "france"] for c in lower):
            return "European Union"
        return "Europe (non-EU)"
    if any(c in lower for c in ["nigeria", "ghana", "ethiopia", "kenya", "zambia"]):
        return "Sub-Saharan Africa"
    if any(c in lower for c in ["iran", "egypt", "turkey", "saudi arabia", "morocco"]):
        return "Middle East, North Africa, Central Asia"
    if any(c in lower for c in ["china", "india", "japan", "indonesia", "vietnam", "thailand", "korea"]):
        return "Asia"
    if any(c in lower for c in ["argentina", "brazil", "mexico", "chile", "cuba"]):
        return "Latin America and the Caribbean"
    if any(c in lower for c in ["australia", "canada", "zealand"]):
        return "OECD Pacific and North America"
    if any(c in lower for c in ["russia", "ukraine", "belarus", "azerbaijan"]):
        return "Reforming Economies of Former Soviet Union"
    return f"Region containing {n} countries"


def buildRegionData(csvUrl):
    """Fetch and process CSV into grouped regional data."""
    response = requests.get(csvUrl)
    response.raise_for_status()
    df = pd.read_csv(StringIO(response.text), sep=";")

    grouped = (
        df.groupby("Region.Code")
        .agg({
            "ISO3.Code": lambda x: sorted(x.unique()),
            "Full.Country.Name": lambda x: sorted(x.unique())
        })
        .reset_index()
    )

    grouped["Name"] = [
        inferRegionName(row["Region.Code"], row["Full.Country.Name"])
        for _, row in grouped.iterrows()
    ]

    return df, grouped


# === REGIONAL MAPPING UPDATE ===
def updateMarkdown(markdownPath, sectionTitle, csvUrl, regionGroups):
    """Update tutorial file with table, region count, and mapping URL."""
    with open(markdownPath, "r", encoding="utf-8") as f:
        mdText = f.read()

    numRegions = len(regionGroups)
    header = "| OPEN-PROM Region Code | Name | ISO Codes | Full Name of countries |"
    separator = "|" + "|".join(["---"] * 4) + "|"
    rows = [
        f"| {row['Region.Code']} | {row['Name']} | {', '.join(row['ISO3.Code'])} | {', '.join(row['Full.Country.Name'])} |"
        for _, row in regionGroups.iterrows()
    ]
    markdownTable = "\n".join([header, separator] + rows)

    # Update metadata
    mdText = re.sub(
        r"(classification of World countries into the )(\d+)( OPEN-PROM regions\.)",
        rf"\g<1>{numRegions}\g<3>", mdText)
    mdText = re.sub(
        r"(A machine-readable version of this mapping is available here:\s*)(https://[^\s]+)",
        rf"\1{csvUrl}", mdText)

    # Replace or append section
    pattern = rf"({re.escape(sectionTitle)}[\s\S]*?)(?=\n#+\s|\Z)"
    replacement = f"{sectionTitle}\n\n{markdownTable}\n\n*Latest update on {date.today()}*\n"
    if re.search(pattern, mdText):
        mdText = re.sub(pattern, replacement, mdText)
    else:
        mdText += "\n\n" + replacement

    with open(markdownPath, "w", encoding="utf-8") as f:
        f.write(mdText)
    print(f"Markdown file updated ({numRegions} regions).")


# === MAPPINGS YAML FILE FOR SCENARIO EXPLORER ===
def updateMappingsYaml(mappingsYamlPath, modelName, df, regionGroups):
    """Rebuild mappings.yaml preserving structure."""
    with open(mappingsYamlPath, "r", encoding="utf-8") as f:
        mappings = yaml.safe_load(f)

    commonRegions = mappings.get("common_regions", [])
    mappings["model"] = modelName
    mappings["native_regions"] = [
        {iso: f"{modelName}|{regionGroups.loc[regionGroups['Region.Code']==region,'Name'].values[0]}"}
        for iso, region in zip(df["ISO3.Code"], df["Region.Code"])
    ]
    mappings["common_regions"] = commonRegions

    with open(mappingsYamlPath, "w", encoding="utf-8") as f:
        yaml.dump(mappings, f, sort_keys=False, allow_unicode=True, width=1000)

    print(f"mappings.yaml rebuilt ({len(df)} entries).")


# === NATIVE REGIONS YAML FILE FOR SCENARIO EXPLORER ===
def updateNativeRegionsYaml(nativeRegionsYamlPath, modelName, regionGroups):
    """Rebuild native_regions.yaml with correct flow-style for multi-country lists."""
    class FlowList(list):
        """Custom YAML representer for inline lists."""
        pass

    def flowRepresenter(dumper, data):
        return dumper.represent_sequence("tag:yaml.org,2002:seq", data, flow_style=True)

    yaml.add_representer(FlowList, flowRepresenter)

    regionEntries = []
    for _, row in regionGroups.iterrows():
        regionLabel = f"{modelName}|{row['Name']}"
        countries = row["Full.Country.Name"]
        if len(countries) == 1:
            entry = {regionLabel: {"countries": countries[0]}}
        else:
            entry = {regionLabel: {"countries": FlowList(countries)}}
        regionEntries.append(entry)

    nativeData = [{modelName: regionEntries}]

    with open(nativeRegionsYamlPath, "w", encoding="utf-8") as f:
        yaml.dump(nativeData, f, sort_keys=False, allow_unicode=True, width=1000)

    print(f"native_regions.yaml rebuilt ({len(regionEntries)} regions).")


# === MAIN EXECUTION ===
if __name__ == "__main__":
    df, regionGroups = buildRegionData(csvUrl)

    updateMarkdown(markdownPath, sectionTitle, csvUrl, regionGroups)

    if updateYamlFiles:
        updateMappingsYaml(mappingsYamlPath, modelName, df, regionGroups)
        updateNativeRegionsYaml(nativeRegionsYamlPath, modelName, regionGroups)