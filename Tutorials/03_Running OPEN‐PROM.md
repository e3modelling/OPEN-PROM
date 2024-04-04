# Running the OPEN-PROM Model
OPEN-PROM starts with  `main.gms`, the main file of the model. This file contains some GAMS internal settings, the basic model and scenario settings, as well as lists the files that GAMS will have to read and execute after `main.gms`. The model will start by typing `gams main.gms` in the console, or using the task runner buttons in VS Code (more details below). If input data loading is activated, an R script will run before OPEN-PROM actually starts (more in Turorial 02). The function of this R script is to perform the input data calculations, using the R package [`mrprom`](https://github.com/e3modelling/mrprom).

# Task Runner Buttons
As mentioned in Tutorial 01, the model can be executed by utilizing the VS Code task runner. Here are the available options in detail:

* `OPEN-PROM DEV NEW DATA`: 
this task will run the model in development mode, i.e. using only the regions of USA, China, India, Egypt, Morocco and Rest of the World. This region subset significantly reduces model execution time, thus allowing quicker testing of new features, as well as debugging. In addition, this task also executes the `mrprom` data loading script.

* `OPEN-PROM DEV`: this task is identical to the previous, except the loading script is not executed. Therefore, it is assumed that all necessary datasets for the development mode are present in the `data` folder.

* `OPEN-PROM RESEARCH NEW DATA`: this task will run the model in research mode, i.e. by including the entire region set, as defined in Tutorial 05. It should also be noted, that this task requires more than one hour to complete on a modern personal computer. In addition, the `mrprom` library will be used to generate new datasets.

* `OPEN-PROM RESEARCH`: this is identical to the previous task, without utilizing `mrprom` to generate new data. Hence, all necessary datasets for research mode should be available in the `data` folder.

## Creating and Uploading Run Folders
Every model run started by the aforementioned tasks, will be saved as a subfolder in the `/runs` folder. In case you want to temporarily disable this feature, you can open the `start.R` script, and set the `withRunFolder` flag equal to `FALSE`. Additionally, if you are part of E3Modelling, every individual model run stored in `/runs` will also be uploaded to the company cloud storage. To enable this feature, you must first execute the following command, in an R language terminal:

`googledrive::drive_auth()`

After running this command, you must authorize the Tidyverse API Packages to access your Google Drive files. Upon completion, a token will be stored on your computer, hence allowing the seamless upload of model runs. In case you want to disable this feature, you can set the `withUpload` flag equal to `FALSE`.

# Testing the Model with Dummy Data
As mentioned in Tutorial 02, OPEN-PROM utilizes some proprietary data sources that can't be publicly shared. Regardless of that, you can still run and experiment with the model, even if you don't have access to the aforementioned data. You simply need to download [OPEN-PROM v1.0.0](https://github.com/e3modelling/OPEN-PROM/releases/tag/v1.0.0), and make sure you have recent versions of GAMS and the R language installed on your computer. Afterwards, you simply need to open a terminal window and execute the following command:  

`gams main.gms --DevMode=2 --GenerateInput=on --fCountries='RWO' -Idir=./data`

This command will execute the OPEN-PROM model for a single region (RWO - Rest of the world), based on dummy datasets that are similar (**but not identical**) to those used internally by the E3-Modelling team. This will help you get a better understanding of the model equations, and experiment with the input/output. For any further questions or suggestions, feel free to contact the developing team at: info@e3modelling.com
