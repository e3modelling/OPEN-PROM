# Running the OPEN-PROM Model
OPEN-PROM starts with the main file of the model, called `main.gms`. This file contains some GAMS internal settings, the basic model and scenario settings, as well as lists the files that GAMS will have to read and execute after `main.gms`. By typing `gams main.gms` in the console, or using the `OPEN-PROM DEV` task runner button in VScode (see Tutorials 00 and 01) the model will start. If input data loading is activated, an R script will run before OPEN-PROM actually starts (more in Turorial 02). The function of this R script is to perform the input data calculations, using the R package [`mrprom`](https://github.com/e3modelling/mrprom).

# Testing the Model with Dummy Data
As mentioned in Tutorial 02, OPEN-PROM utilizes some proprietary data sources that can't be publicly shared. Regardless of that, you can still run and experiment with the model, even if you don't have access to the aforementioned data. You simply need to download [OPEN-PROM v1.0.0](https://github.com/e3modelling/OPEN-PROM/releases/tag/v1.0.0), and make sure you have recent versions of GAMS and the R language installed on your computer. Afterwards, you simply need to open a terminal window and execute the following command:  

`gams main.gms --DevMode=2 --GenerateInput=on --fCountries='RWO' -Idir=./data`

This command will execute the OPEN-PROM model for a single region (RWO - Rest of the world), based on dummy datasets that are similar (**but not identical**) to those used internally by the E3-Modelling team. This will help you get a better understanding of the model equations, and experiment with the input/output. For any further questions or suggestions, feel free to contact the developing team at: giannousakis@e3modelling.com
