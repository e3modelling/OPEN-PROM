"""Plot GSAT (median and 5-95% range) from a climate-assessment *_alloutput.xlsx.

Usage: python plotGsat.py <alloutput.xlsx> <out.png>
Python counterpart of the plot in runClimateModels.r, so the GitHub Actions
climate workflow does not need R.
"""
import sys

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
import pandas as pd  # noqa: E402

xlsx, png = sys.argv[1], sys.argv[2]
df = pd.read_excel(xlsx)
df = df[(df["region"] == "World") & df["variable"].str.contains(r"Surface Temperature \(GSAT\)", regex=True)]
years = [c for c in df.columns if str(c).isdigit()]


def pct(p):
    row = df[df["variable"].str.contains(f"|{p} Percentile", regex=False)]
    return None if row.empty else row.iloc[0][years].astype(float)


median, low, high = pct("50.0th"), pct("5.0th"), pct("95.0th")
if median is None:
    sys.exit(f"No median GSAT in {xlsx}")

x = [int(y) for y in years]
fig, ax = plt.subplots(figsize=(10, 6))
if low is not None and high is not None:
    ax.fill_between(x, low, high, alpha=0.25, label="5-95%")
ax.plot(x, median, linewidth=2, label=f"Median ({df['scenario'].iloc[0]})")
ax.set(title="Global warming above the 1850-1900 mean", xlabel="Year", ylabel="°C")
ax.grid(alpha=0.3)
ax.legend()
fig.savefig(png, dpi=200, bbox_inches="tight")
print(f"Saved {png} (median {x[-1]}: {median.iloc[-1]:.2f} °C)")
