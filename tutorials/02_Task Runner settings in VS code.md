## Task Runner Settings in VS code

This guide is designed for advanced users, though the model can still be utilized without Git or Visual Studio Code.

**Objective:**

Learn how to install the Task Runner extension in VS Code. This allows you to quickly execute OPEN-PROM tasks by creating and using buttons similar to the ones found in other programs, such as GAMS Studio. These buttons simplify the launch of the predefined workflows, but they do not replace the command line. They are simply a more convenient way to trigger the same commands from inside VS Code.

**Note:**
It is recommended to follow this tutorial after completing Tutorial 01 and having cloned the repository and installed the necessary extensions.

## Step-by-Step Guide

1. **Install Task Runner Extension:**
   - Search for the `Task Runner` extension by [Sana Ajani](https://marketplace.visualstudio.com/items?itemName=sanaajani.taskrunner) in the Visual Studio Code Extensions Marketplace.
   - Click on "Install" to add the extension to your VS Code setup.

2. **Restart Visual Studio Code:**
   - After installing the extension, restart Visual Studio Code for the changes to take effect.

3. **Open Cloned Repository:**
   - Open the cloned `OPEN-PROM` repository folder in Visual Studio Code.

4. **Access Task Runner:**
   - In the left-hand sidebar, click on the "Explorer" tab.
   - At the bottom of the Explorer view, you should see the Task Runner dropdown list.
   - Expand it to reveal the available OPEN-PROM buttons from `.vscode/tasks.json`.

## What the Buttons Actually Do

The Task Runner buttons are shortcuts for commands defined in `.vscode/tasks.json`. In practice, they call commands such as:

- `Rscript start.R task=...`
- or direct GAMS calls

So the Task Runner panel is not a different workflow. It is a launch panel for the same predefined commands that could also be executed in the terminal.

## Development and Research Modes

The OPEN-PROM tasks are divided into several run modes. At a high level, these include:

- development runs,
- development runs with fresh data generation,
- research runs,
- and calibration-related runs.

At this stage, you do not need to memorize every task. The important point is that different buttons trigger different combinations of flags in `start.R`, such as `DevMode`, `GenerateInput`, and reporting options.

If you want to study the exact meaning of each mode, continue to Tutorial 05.

**You are all set up!**

By following these steps, you can integrate the Task Runner extension into your Visual Studio Code workflow and use it as a convenient way to launch OPEN-PROM runs.
