"""
Aggregate CO2 Budgets to OPEN-PROM Regions
===========================================
Reads CO2budgets.csv (country-level budgets: PC, ECPC, AP columns)
and the OPEN-PROM region mapping (regionmappingOPDEV5.csv), then
sums budgets for each (Region, Temperature, Risk) combination.

Outputs: CO2budgets_OPENPROM.csv
"""

import pandas as pd
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]

BUDGETS_CSV = REPO_ROOT / "CO2budgets.csv"
MAPPING_CSV = REPO_ROOT / "data" / "regionmappingOPDEV5.csv"
OUTPUT_CSV  = REPO_ROOT / "CO2budgets_OPENPROM.csv"


def load_mapping(path):
    df = pd.read_csv(path, sep=";", usecols=["ISO3.Code", "Region.Code"])
    return df.rename(columns={"ISO3.Code": "iso3", "Region.Code": "region"})


def load_budgets(path):
    df = pd.read_csv(path)
    df.columns = ["iso3", "temperature", "risk", "PC", "ECPC", "AP"]
    # Drop aggregate rows (non-ISO3 codes: multi-word names or known groups)
    # Keep only 3-letter uppercase ISO codes
    iso3_mask = df["iso3"].str.match(r"^[A-Z]{3}$", na=False)
    n_dropped = (~iso3_mask).sum()
    if n_dropped:
        dropped = df.loc[~iso3_mask, "iso3"].unique().tolist()
        print(f"Dropping {n_dropped} rows for non-ISO3 identifiers: {dropped}")
    return df[iso3_mask].copy()


def aggregate(budgets, mapping):
    merged = budgets.merge(mapping, on="iso3", how="left")

    # Report unmapped countries
    unmapped = merged[merged["region"].isna()]["iso3"].unique()
    if len(unmapped):
        print(f"Warning: {len(unmapped)} ISO3 codes not found in mapping (excluded): {sorted(unmapped)}")
    merged = merged.dropna(subset=["region"])

    # Sum numeric columns, skipping NaN (NaN means no budget assigned)
    result = (
        merged
        .groupby(["region", "temperature", "risk"], sort=True)[["PC", "ECPC", "AP"]]
        .sum(min_count=1)   # returns NaN if ALL values are NaN in a group
        .reset_index()
    )
    return result


def main():
    print(f"Loading budgets from: {BUDGETS_CSV}")
    budgets = load_budgets(BUDGETS_CSV)
    print(f"  {len(budgets)} country-level rows loaded.")

    print(f"Loading region mapping from: {MAPPING_CSV}")
    mapping = load_mapping(MAPPING_CSV)
    print(f"  {len(mapping)} mapping entries loaded ({mapping['region'].nunique()} regions).")

    result = aggregate(budgets, mapping)

    result.to_csv(OUTPUT_CSV, index=False, float_format="%.6f")
    print(f"\nAggregated budgets written to: {OUTPUT_CSV}")
    print(f"  {result['region'].nunique()} OPEN-PROM regions x {result[['temperature','risk']].drop_duplicates().shape[0]} scenarios")
    print(f"  Total rows: {len(result)}")

    print("\nPreview (1.6°C, risk=0.5):")
    preview = result[(result["temperature"] == 1.6) & (result["risk"] == 0.5)].copy()
    preview = preview.sort_values("region")
    print(preview.to_string(index=False))


if __name__ == "__main__":
    main()
