## General Python Instructions

- Make sure that you have Python installed on your machine.
    - Open a terminal and type `Python` or `py`.
    - If Python is installed you will get the following or similar message.
        ```
        Python 3.12.2 (tags/v3.12.2:6abddd9, Feb  6 2024, 21:26:36) [MSC v.1937 64 bit (AMD64)] on win32
        Type "help", "copyright", "credits" or "license" for more information.
        ```
    - If Python is not installed on your system, you can download and install Python from the official Python website (https://www.python.org/). Follow the installation instructions provided on the website for your operating system.

## Instructions on how to run the python script `rv.py`

**Description:**\
This script checks the status of runs in subfolders, highlighting their completion or pending status.\
It scans the specified directory for subfolders containing run information and displays a list of subfolders along with their status.\
The status includes information about missing files, completion status, running year, and horizon.\
Additionally, it offers color-coded indicators for easy interpretation.

**Instructions:**
1. The necessary library must be installed. Type `pip install colorama`.
2. To run the script itself just type `python .\scripts\rv.py `.

***The script runs automatically and no further user inputs are required.***

## Instructions on how to run the python script `rs.py`

**Description:**\
This script visualizes the success statuses of runs within subfolders.\
It provides options to either automatically plot the newest subfolder or manually select a subfolder from a list.\
The visualization includes a heatmap representation of run success statuses, with rows representing countries and\
columns representing years. Success is indicated by green color, while failure is indicated by red color.

**Instructions:**
1. The necessary libraries must be installed.\
    Type:\
          `pip install pandas`,\
          `pip install seaborn`,\
          `pip install matplotlib` .
2. To run the script itself just type `python .\scripts\rs.py `.

***The script requires a user input regarding the selection of the subfolder.***

## Instructions on how to run the python script `rr.py`

**Description:**\
This script checks each subfolder for necessary files and generates a list of subfolders with color-coded status.\
It includes information about failed subfolders, their horizon, and the last year they ran. It provides options\
to automatically visualize the newest subfolder or manually select subfolders from a list. The visualization includes\
heatmap representations of run success statuses, with rows representing countries and columns representing years.\
Green color indicates success, while red color indicates failure.

**Instructions:**
1. The necessary libraries must be installed.\
    Type:\
            `pip install pandas seaborn matplotlib colorama`
2. To run the script itself just type `python .\scripts\rr.py `.

***The script requires a user input regarding the selection of the subfolder.***


## Instructions on how to run the quick versions of python scripts `rr.py` & `rs.py`

1. The necessary libraries must be installed (check above).
2. Type: \
        `python .\scripts\rr.py  -q`\
        `python .\scripts\rs.py  -q`
3. Note: Utilizing the quick execution command, the scripts automaticaly select the most recent subfolders. \
***The scripts run automatically and no further user inputs are required.***

## Instructions on how to run the python script `R-live.py`

**Description:**\
This script provides real-time monitoring of pending runs. \
 Initialize the GAMS run and the run the script via the command prompt\
 or in the explorer tab in the TASK RUNNER section press the OPEN-PROM LIVE button.

 **Instructions:**
1. The necessary libraries must be installed.\
    Type:\
            `pip install pandas seaborn matplotlib colorama`
2. To run the script itself just type `python .\scripts\R-live.py `.

***The script runs automatically and no further user inputs are required.***