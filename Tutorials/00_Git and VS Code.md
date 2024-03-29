## Setting Up Git and VS Code for GitHub: A Step-by-Step Guide

**Objective:**

By the end of this tutorial, you will be proficient in setting up Git and Visual Studio Code (VS Code) for GitHub collaboration. Through this step-by-step guide, you will learn key terminology, check for and install Git, configure settings, install VS Code, clone a repository, and explore the Task Runner extensions. You will understand how to execute tasks in development and research modes, and utilize VS Code functionalities. 

- Git is a widely used Version Control software
- VS Code (Visual Studio Code) is a widely used and versatile text editor for modelers and developers 

***Clarifying Terminology:***

Before diving into the setup process, let's clarify some key terms you'll encounter:

- **Git:**
Git is a distributed version control system that allows multiple developers to collaborate on projects efficiently. It tracks changes to files, maintains a history of revisions, and facilitates collaboration through features like branching and merging.

- **GitHub:**
GitHub is a web-based platform built on top of Git, providing hosting for software development projects. It offers features such as repository hosting, code review, issue tracking, and project management. GitHub is widely used by developers and organizations for open-source and private projects alike.

- **Visual Studio Code (VS Code):**
Visual Studio Code is a lightweight, open-source code editor developed by Microsoft. It offers built-in support for various programming languages, debugging tools, and extensions to enhance functionality. VS Code is highly customizable and popular among developers for its versatility and ease of use.

- **Repository:**
A repository, or repo for short, is a central location where files and directories related to a project are stored and managed. In the context of Git and GitHub, a repository typically contains the source code for a software project along with version history and other project-related files.

- **Cloning:**
Cloning refers to the process of creating a local copy of a repository from a remote source, such as GitHub. When you clone a repository, you replicate its entire history and contents onto your local machine, allowing you to work on the project offline and collaborate with others.

- **Commit:**
A commit is a snapshot of changes made to files in a repository at a specific point in time. When you commit changes in Git, you create a new revision in the project's history, along with a descriptive message that explains the changes made. Commits are essential for tracking progress and collaborating on projects.

- **Push:**
Pushing refers to the act of uploading local changes to a remote repository, such as GitHub. When you push commits to a remote repository, you synchronize your local changes with the central repository, making them accessible to other collaborators.

- **Pull:**
Pulling, or fetching, involves retrieving changes from a remote repository and incorporating them into your local repository. When you pull changes, you update your local copy of the repository to reflect any new commits made by other collaborators.

Understanding these terms will help you navigate the setup process and work effectively with Git, GitHub, and Visual Studio Code.


***Check for Existing Git Installation:***

- Open your command-line interface (Windows Command Prompt).

    Type `git --version` and press Enter.

    If Git is already installed, you'll see its version number.\
    If not, you'll receive the following message.
    ![alt text](<Screenshot (2).png>)


- Install Git:

    *If Git is not installed, follow these steps:*

    1.	Download the Git installer for your operating system from the official Git website: https://git-scm.com/downloads
    2.	Run the installer and follow the on-screen instructions. Please note that you need to select the option of windows default console window, as shown below.
    ![alt text](<Screenshot (1).png>)
    3. Once installed, repeat the `git --version` command to verify the installation.
    4. Re-open your terminal.

***Setting Up GitHub Account:***

If you don't have a GitHub account, sign up at https://github.com.
Verify your email address by following the link sent to your email.

- Configuring Git:

    1. Open your command-line interface.
    2. Configure your name and email for Git using these commands:

        `git config --global user.name "Your Name"`\
        `git config --global user.email "youremail@example.com"`

    Please note that `"Your Name"` & `"youremail@example.com"` must be the ones that are used in GitHub.

***Setting Up VS Code:***

1. Download and install VS Code (Visual Studio Code) from the official website: https://code.visualstudio.com/download
2. Follow the install instructions.
3. Launch VS Code after installation.

- Connecting to Company GitHub and Cloning a Repository:

    1. Open your browser and navigate to your company's GitHub repository.
    2. Click on the "Code" button and copy the repository's URL.

- Cloning the Repository Using VS Code:

    1.	Open VS Code.
    2.	Open your Terminal.\
        Navigate to the directory where you want to clone the repository using\
        the cd command (e.g., `cd Documents`).
    3.	Copy the repository's URL from GitHub.

- Clone the Repository:

    In the command prompt, use the `git clone` command followed by the repository URL and the desired folder name:

    `git clone <repository-url> <folder-name>`

    Replace <repository-url> with the copied URL and <folder-name> with the name you want for the local repository directory.\
    Close and re-open the command prompt after the installation.

- Open VS Code from Command Prompt:

    With the cloned repository folder as your current working directory, open VS Code (Visual Studio Code) from the command prompt using:

    `code .`

    This command opens VS Code with the current directory as the workspace.


**Now you've successfully cloned the repository using the command prompt and opened it in VS Code for further work.**


***Making Changes and Pushing to GitHub:***

1.	Make changes to files in your local repository.
2.	Save the changes in VS Code.
3.	Go to the Source Control panel (branch icon) in VS Code.
4.	Review the changes, add a commit message, and click the checkmark icon to commit the changes.
5.	Click on the "..." (three dots) menu and select "Push" to push the changes to the GitHub repository.

**If everything goes according to plan you should now have a fully functioning, cloned workspace repository in Vs code.**


Basic VS code guide
===================

## Main Bar:
The main bar in VS Code (Visual Studio Code) is the horizontal strip at the top of the application window.It provides quick access to various important features and actions within the editor.\
Here's what you'll find in the main bar:



![image-3](https://github.com/e3modelling/OPEN-PROM/assets/109683718/4593f19e-7659-4242-84fe-1c0790855701)


**1. File Operations:**

- New File: Create a new, blank file.
- Open File: Open an existing file from your file system.
- Save: Save the currently open file.
- Save All: Save all open files.
- Close: Close the currently active file tab.
- Close All: Close all open file tabs.

**2. Edit and Undo:**

- Undo: Revert the last action.
- Redo: Reapply a previously undone action.
- Cut, Copy, Paste: Standard clipboard operations.
- Find and Replace: Search for text and replace occurrences.

**3. Selection:**

- Extend or shrink the current selection based on specific criteria.
- Select entire lines or words within the text.
- Multiple cursor support for editing multiple sections simultaneously.
- Select specific code blocks or elements based on syntax.
- Select all occurrences of a particular word or symbol in the document.

**4. View:**

- Toggle visibility of various panels such as the sidebar, status bar, and activity bar.
- Customize editor layout and arrangement of panes.
- Access different view modes like Zen mode for distraction-free writing.
- Adjust font size and zoom level for better readability.
- Enable or disable specific editor features like word wrap or minimap.

**5. Go:**

- Navigate to symbols within the current file.
- Jump to specific files or folders within the project.
- Navigate to specific lines or columns in the current file.
- Move between recent locations in the editor.
- Access shortcuts for navigating forward or backward through your navigation history.

**6. Run:**

- Start debugging sessions for your code.
- Run or debug specific code files or snippets.
- Manage breakpoints and step through code during debugging.
- Run tasks defined in the project's task configuration.
- Access output and debug consoles for monitoring program execution.

**8. Terminal:**

- Open an integrated terminal within VS Code for executing command-line tasks.
- Run commands directly within the terminal without leaving the editor.
- Customize terminal settings such as shell type and terminal colors.
- Access terminal shortcuts and commands for efficient workflow.
- Utilize terminal multiplexing for running multiple commands simultaneously.

**9. Help:**

- Access documentation and guides for Visual Studio Code and its extensions.
- Browse community forums or stack overflow for troubleshooting and support.
- Report issues or provide feedback directly to the VS Code development team.
- Explore keyboard shortcuts and productivity tips for using VS Code efficiently.
- Check for updates and release notes to stay informed about new features and improvements.

## Sidebar:

The sidebar in VS Code (Visual Studio Code) is the vertical strip located on the left side of the application window.\
It hosts several important navigation and information panels.\
Here's what you'll find in the sidebar:

![image-2](https://github.com/e3modelling/OPEN-PROM/assets/109683718/8a9644e5-37d6-4bd4-b95f-fe6e38ee6c9e)

**1. Explorer:**

Displays the file and folder structure of your project.\
Allows you to easily navigate and open files.

**2. Search:**

Enables you to search for text within your project.\
Provides search results and supports regex search.

**3. Source Control:**

Shows the changes made to your files in the version control system (e.g., Git).\
Allows you to stage, commit, and push changes.

**4. Run & Debug:**

Lists running and completed debugging sessions.\
Provides access to debugging configuration.

**5. Extensions:**

Lists the installed extensions and their icons.\
Provides quick access to extension settings.

**6. Project Manager:(Optional - Extension)**

Allows you to manage and organize different projects within VS Code (Visual Studio Code).\
Provides quick access to your frequently used projects and workspaces.\
Allows you to save and open groups of files, folders, and settings as a project.

**7. GitLens:(Extension - See below for installation instructions)**

GitLens enhances your coding experience by providing detailed insights and information about your code's history.\
Some of the features offered by GitLens include:

- Blame Annotations: Hover over lines of code to see who last modified them and when.

- Code Lens: Display commit and blame information directly in your code file.

- Current Line Blame: View commit details for the current line in the status bar.

- Gutter Indicators: See Git blame information in the gutter of your code file.

- Commit Annotations: See inline annotations for commits related to specific lines.

- Code History and Annotations: Access a more detailed history of code changes and annotations.

- Compare Changes: Compare changes between different commits and branches.

- Interactive Rebase Workflow: Manage interactive rebase operations directly within VS Code.


Adding the Git History Extension to VS Code (Visual Studio Code):
=============================================================

**1. Open VS Code (Visual Studio Code):**

Launch VS Code (Visual Studio Code) on your computer.

**2. Access the Extension Marketplace:**

Click on the "Extensions" icon in the sidebar (square icon) or press Ctrl+Shift+X to open the Extension Marketplace.

**3. Search for Git History :**

In the Extensions Marketplace, search for "Git History " in the search bar at the top,\
publisher:"Don Jayamanne" .

**4. Install Git History :**

You should see the "Git History " extension in the search results.\
Click on the "Install" button next to the Git History  extension.

**5. Wait for Installation:**

VS Code (Visual Studio Code) will download and install the Git History  extension.\
You'll see a progress bar indicating the installation process.

**6. Restart VS Code (if Required):**

After the installation is complete, you might be prompted to restart VS Code (Visual Studio Code).\
If prompted, click on the "Restart" button.

(OPTIONAL) Adding the GitLens Extension to VS Code (Visual Studio Code):
=============================================================

**1. Open VS Code (Visual Studio Code):**

Launch VS Code (Visual Studio Code) on your computer.

**2. Access the Extension Marketplace:**

Click on the "Extensions" icon in the sidebar (square icon) or press Ctrl+Shift+X to open the Extension Marketplace.

**3. Search for GitLens :**

In the Extensions Marketplace, search for "GitLens" in the search bar at the top.

**4. Install GitLens :**

You should see the "GitLens " extension in the search results.\
Click on the "Install" button next to the GitLens  extension.

**5. Wait for Installation:**

VS Code (Visual Studio Code) will download and install the GitLens  extension.\
You'll see a progress bar indicating the installation process.

**6. Restart VS Code (if Required):**

After the installation is complete, you might be prompted to restart VS Code (Visual Studio Code).\
If prompted, click on the "Restart" button.\
**You are all set up !!!**
