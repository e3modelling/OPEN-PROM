# Purpose: learning to Run the OPEN-PROM Model with real data
Before starting this tutorial you need to complete first the tutorial 03_Loading Input Data files in order to set the input data for running the models. This guide is needed to run the model with real data. You can move directly to Tutorial named 04_First OPEN-PROM running if you want to test the model with dummy data and come back later here.

# Warning
The following steps to create the configuration file, adjust the necessary settings, are identical to the ones described in Tutorial 04_First OPEN-PROM running

## Step 1: Creating a Configuration File
Customization and flexibility is a priority during the development of OPEN-PROM, so we have included a configuration file that lets users change model settings. To create your own configuration file, please **make a copy** of the `config.template.json` file and rename it to `config.json`. Afterwards, you will be able to configure various settings, such as the custom GAMS system directory. It is not needed to delete the `config.template.json`because it is not read by the model because it is excluded in a specific file.

## Step 2: Creating and Syncing Run Folders
Every model run started by the aforementioned tasks, will be saved as a subfolder in the `/runs` folder. In case you want to temporarily disable this feature, you can open the `start.R` script, and set the `withRunFolder` flag equal to `FALSE`. Additionally, if you are part of E3Modelling, every individual model run stored in `/runs` will also be synced with the company cloud storage (SharePoint). You can specify the SharePoint path of your preference in the `"model_runs_path"` parameter of the configuration file. Finally, in case you want to disable this feature, you can set the `withSync` flag equal to `FALSE`.

## Step 3: Setting a Custom GAMS Path
In some cases, it is beneficial to install multiple versions of GAMS, for testing and debugging purposes. For example, you can execute the model with both GAMS version 45 and 46, and compare the results. To specify the GAMS version that is used while executing the model, you can add the associated directory path to the `"gams_path"` parameter of the configuration file. To avoid errors, please remember to include a trailing slash, e.g. `C:\GAMS\45\`.

## Step 4: Setting a Custom Scenario Name
Running various different scenarios is a fundamental aspect of integrated assessment modelling, with the purpose of comparing alternative decarbonization pathways and exploring greenhouse gas emissions trajectories. You can easily specify the scenario name of your preference, by setting the `"scenario_name"` parameter in the configuration file. This scenario name will be used in the model run folders that were mentioned previously.

# Step 5: Running the OPEN-PROM Model
OPEN-PROM starts with  `main.gms`, the main file of the model. This file contains some GAMS internal settings, the basic model and scenario settings, as well as lists the files that GAMS will have to read and execute after `main.gms`. The model will start by typing `gams main.gms -Idir=./data` in the console, or using the task runner buttons in VS Code (more details below). If input data loading is activated, an R script will run before OPEN-PROM actually starts (more in Turorial 02). The function of this R script is to perform the input data calculations, using the R package [`mrprom`](https://github.com/e3modelling/mrprom).

# Task Runner Buttons
As mentioned in Tutorial 01, the model can be executed by utilizing the VS Code task runner. Here are the available options in detail:

* `OPEN-PROM DEV NEW DATA`: 
this task will run the model in development mode, i.e. using only the regions of USA, China, India, Egypt, Morocco and Rest of the World. This region subset significantly reduces model execution time, thus allowing quicker testing of new features, as well as debugging. In addition, this task also executes the `mrprom` data loading script.

* `OPEN-PROM DEV`: this task is identical to the previous, except the loading script is not executed. Therefore, it is assumed that all necessary datasets for the development mode are present in the `data` folder.

* `OPEN-PROM RESEARCH NEW DATA`: this task will run the model in research mode, i.e. by including the entire region set, as defined in Tutorial 05. It should also be noted, that this task requires more than one hour to complete on a modern personal computer. In addition, the `mrprom` library will be used to generate new datasets. After the model is executed, this mode also runs the `reportOutput.R` script, that generates a tabular dataset (MIF format) including final energy, primary energy, CO2 emissions etc. 

* `OPEN-PROM RESEARCH`: this is identical to the previous task, without utilizing `mrprom` to generate new data. Hence, all necessary datasets for research mode should be available in the `data` folder. Similarly to the previous task, this will also run the `reportOutput.R` script, after the model is executed.

Other functionalities useful in coadiuvating the running of the model in the Task Runner are:

* `REPORTING`: a tool to report the output of the models
* `SCENTOOL`: a tool to analyse and validate the model. In particular, scentool() is a function that reads the mif file
* `COMPARE SCENARIOS`: a tool to compare multiple scenarios obtained with the model
* `OPEN-PROM LIVE`: a tool to follow live the running of the model

 Please double check to have installed the last version of Python and the following libraries: colorama, contourpy, cycler, fonttools, kiwisolver, matplotlib numpy packaging pandas pillow pyparsing python-dateutil pytz seaborn six tzdata


