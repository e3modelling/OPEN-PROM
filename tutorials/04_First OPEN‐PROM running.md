## First OPEN-PROM run with dummy data

**Objective:**
 OPEN-PROM utilizes some proprietary data sources that can't be publicly shared. To run the OPEN-PROM model for the first time, you can use dummy data to test its functionality and ensure everything is set up correctly. This allows you to familiarize yourself with the model’s structure, configuration, and output without needing access to proprietary data. The following section will guide you through the steps to create a configuration file, adjust the necessary settings, and execute the model using dummy data. This will provide you with a clear understanding of how the model operates and allow you to begin experimenting with its features.

## 1nd step: Creating a Configuration File
Customization and flexibility is a priority during the development of OPEN-PROM, so we have included a configuration file that lets users change model settings. To create your own configuration file, please **make a copy** of the `config.template.json` file and rename it to `config.json`. Afterwards, you will be able to configure various settings, such as the custom GAMS system directory. 

## 2nd step: Creating and Syncing Run Folders in the Configuration File
Every model run started by the aforementioned tasks, will be saved as a subfolder in the `/runs` folder. In case you want to temporarily disable this feature, you can open the `start.R` script, and set the `withRunFolder` flag equal to `FALSE`. Additionally, if you are part of E3Modelling, every individual model run stored in `/runs` will also be synced with the company cloud storage (SharePoint). You can specify the SharePoint path of your preference in the `"model_runs_path"` parameter of the configuration file. Finally, in case you want to disable this feature, you can set the `withSync` flag equal to `FALSE`.

## 3rd step: Setting a Custom GAMS Path
In some cases, it is beneficial to install multiple versions of GAMS, for testing and debugging purposes. For example, you can execute the model with both GAMS version 45 and 46, and compare the results. To specify the GAMS version that is used while executing the model, you can add the associated directory path to the `"gams_path"` parameter of the configuration file. To avoid errors, please remember to include a trailing slash, e.g. `C:\GAMS\45\`.

## 4th step: Setting a Custom Scenario Name
Running various different scenarios is a fundamental aspect of integrated assessment modelling, with the purpose of comparing alternative decarbonization pathways and exploring greenhouse gas emissions trajectories. You can easily specify the scenario name of your preference, by setting the `"scenario_name"` parameter in the configuration file. This scenario name will be used in the model run folders that were mentioned previously.

# Final step: Running the Model with Dummy Data
 Afterwards, you simply need to open a terminal window and execute the following command:  

`gams main.gms --DevMode=2 --GenerateInput=on --fCountries='RWO' -Idir=./data`

This command will execute the OPEN-PROM model for a single region (RWO - Rest of the world), based on dummy datasets that are similar (**but not identical**) to those used internally by the E3-Modelling team. This will help you get a better understanding of the model equations, and experiment with the input/output.
 For any further questions or suggestions, feel free to contact the developing team at: info@e3modelling.com
