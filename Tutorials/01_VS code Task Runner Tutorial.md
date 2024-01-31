# Task Runner Tutorial

This tutorial provides a step-by-step guide to installing the Task Runner extension in Visual Studio Code and utilizing a custom button for running GAMS code, similar to the Run (F9) button in GAMS Studio.

**Warning:**
It is recommended to follow this tutorial after completing Tutorial 00 and having cloned the repository, and added all necessary extensions.

## Step-by-Step Guide

1. **Install Task Runner Extension:**
   - Search for the `Task Runner` extension by [Sana Ajani](https://marketplace.visualstudio.com/items?itemName=sanaajani.taskrunner) in the Visual Studio Code Extensions Marketplace.
   - Click on "Install" to add the extension to your VS Code setup.

2. **Restart Visual Studio Code:**
   - After installing the extension, restart Visual Studio Code for the changes to take effect.

3. **Open Cloned Repository:**
   - Open the cloned repository folder in Visual Studio Code.

4. **Access Task Runner:**
   - In the left-hand sidebar, click on the "Explorer" tab.
   - At the bottom of the opened tab, you should see the Task Runner dropdown list. Click on it to reveal the available tasks, such as OPEN-PROM tasks.

## Development and Research Modes

The OPEN-PROM tasks are divided into two modes: development and research.

- **Development Mode:**
  - Use development mode when adding new features or modifying the model code.
  - Development mode is less demanding in terms of computational resources.

- **Research Mode:**
  - Prefer research mode when studying various policy scenarios.
  - Research mode requires more computational resources and takes longer to execute.

If you want to study the command-line flags of each mode, refer to the `.vscode/tasks.json` file in your project directory.

**You are all set up!**

By following these steps, you can seamlessly integrate the Task Runner extension into your Visual Studio Code workflow for running GAMS code efficiently.
