import matplotlib.pyplot as plt
from datetime import datetime, timedelta
import matplotlib.dates as mdates

# Sample data
events = [
    ("Modularization", "M19", "M27"),
    ("Scenario/sensitivity/uncertainty analyses", "M35", "M43"),
    ("Soft-coupling with other models (WP4)", "M10", "M43"),
    ("Output Routines/Dashboards", "M28", "M35"),
    ("Validation against AR6", "M27", "M34"),
    ("Policy Scenarios", "M18", "M23"),
    ("Validate Reference Scenario", "M37", "M38"),
    ("Hindcasting", "M37", "M38"),
    ("Calibration", "M13", "M16"),
    ("Extend Time Horizon to 2100", "M6", "M14"),
    ("Input Data Generation", "M5", "M43"),
    ("Model Development", "M4", "M43")
]


# Convert "Mx" format into numeric months
def convert_to_month_num(month_str):
    return int(month_str[1:])  # Extract the numeric part (e.g., "M4" -> 4)

# Define the project start date (1 December 2022)
project_start_date = datetime(2022, 12, 1)

# Convert "M" months to actual dates
def month_to_date(month_num):
    delta_months = month_num - 1  # M1 corresponds to the start date
    new_date = project_start_date + timedelta(days=delta_months * 30)  # Approximate month length
    return new_date

# Prepare data for the plot
start_dates = [month_to_date(convert_to_month_num(start)) for _, start, _ in events]
end_dates = [month_to_date(convert_to_month_num(end)) for _, _, end in events]

# Plot the timeline
fig, ax = plt.subplots(figsize=(18, 8))
y_positions = range(len(events))  # One y-position for each event

# Create horizontal bars
for idx, (event, start, end) in enumerate(zip(events, start_dates, end_dates)):
    ax.barh(idx, (end - start).days, left=start, height=0.6, label=event[0], align='center')

# Add a vertical line for the present time at month 24
present_time = month_to_date(29)
ax.axvline(x=present_time, color='black', linestyle='--', linewidth=1.5, label='Present Time (M24)')

# Customize the appearance
ax.set_yticks(y_positions)
ax.set_yticklabels([event for event, _, _ in events], fontsize=24)  # Larger font size for y-axis labels
ax.set_xlabel('Time (Months)', fontsize=24)
ax.set_ylabel('Tasks', fontsize=24)
ax.set_title('DIAMOND Timeline Chart', fontsize=24)

# Set the x-axis major locator and formatter for real dates
ax.xaxis.set_major_locator(mdates.MonthLocator(interval=2))  # Every month
ax.xaxis.set_major_formatter(mdates.DateFormatter('%m/%y'))  # Format dates as MM/DD/YY
#ax.invert_yaxis()  # Optional: Flip the y-axis to show first event on top

# Set x-axis limits to end at the last event's end date
ax.set_xlim([month_to_date(4), month_to_date(43)])

# Rotate the date labels for better readability
plt.xticks(rotation=45, fontsize=18)

# Adjust layout
plt.tight_layout()

# Show the chart
plt.show()
