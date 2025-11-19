# Modelling Server Use and Setup Guide in Windows
### Multi-user configuration for OPEN-PROM, GAMS, R, Python, VS Code, OneDrive/SharePoint, and Linux tools

This guide describes how to use and configure a Windows 11 Pro machine so that multiple users can:

- Run **OPEN-PROM** as well as mrprom and postprom
- Use **VS Code**, **GAMS**, **R**, and **Python** system-wide
- Share data via the team's **SharePoint**
- Use Linux tools such as via **WSL** (per-user)

---

# Table of Contents
1. [HOW TO CONNECT?](#1-how-to-connect)
    1. [Remote Desktop Protocol (RDP) - built-in Windows feature](#11-remote-desktop-protocol-rdp---built-in-windows-feature)
    2. [If the other user is logged in via Remote Desktop (RDP session)](#12-if-the-other-user-is-logged-in-via-remote-desktop-rdp-session)
    3. [SSH to Windows via OpenSSH server (install via Optional Features)](#13-ssh-to-windows-via-openssh-server-install-via-optional-features)
2. [SYSTEM PREPARATION](#2-system-preparation)
3. [INSTALL CORE SOFTWARE (SYSTEM-WIDE)](#3-install-core-software-system-wide
)
    1. [Install Git](#31-install-git)
    2. [Install R (system-wide)](#32-install-r-system-wide)
    3. [Install VS Code (shared settings for all users)](#33-install-vs-code-shared-settings-for-all-users)
    4. [Install GAMS (system-wide)](#34-install-gams-system-wide)
4. [INSTALL MAGPIE SYSTEM-WIDE (NO RENV)](#4-install-magpie-system-wide-no-renv)
5. [INSTALL PYTHON PACKAGES (SYSTEM-WIDE)](#5-install-python-packages-system-wide)
6. [INSTALL TINYTEX (SYSTEM-WIDE)](#6-install-tinytex-system-wide)
7. [SHARED ONEDRIVE / SHAREPOINT SETUP](#7-shared-onedrive--sharepoint-setup)
8. [LINUX support - WSL (per-user)](#8-linux-support---wsl-per-user)
9. [TEST THE SETUP](#9-test-the-setup) 
---
# 1. HOW TO CONNECT?
## 1.1 Remote Desktop Protocol (RDP) - built-in Windows feature
To connect to the Windows modelling server from your local pc, use the Windows app "Remote Desktop Connection" and put the given IP address. 
Don't connect with the default option but press more options and try "Use a different account". 
You put as username your cascade username (e.g., "xl99") and your password. Please remember to use VPN when your are out of office or connected in the guest WIFI in the office.

## 1.2 If the other user is logged in via Remote Desktop (RDP session)

Each Windows user session is isolated. Your login (via RDP) will interrupt another user’s session but the user needs to terminate their sessions in order for the second user to log in. However, their session is kept active in the background and so Their model runs keeps running.

## 1.2 SSH to Windows via OpenSSH server (install via Optional Features)

Under development 
---
# 2. SYSTEM PREPARATION

- Ensure Windows 11 **Pro** is installed.
- IT must create user accounts (local or domain) in the machine for each modeller.
- Administrator privileges are required for the setup phase. Ask your IT admin for help if needed or to give you temporary admin rights.

---

# 3. INSTALL CORE SOFTWARE (SYSTEM-WIDE)

## 3.1 Install Git
Download from https://git-scm.com/download/win

Install as adminstrator with:
- “Install for all users”
- Preferred path:  C:\Git\
- Add Git to PATH

Verify:
```powershell
git --version
```
It is better to install Git before R and VS Code, so that they can detect Git automatically. Also, it is recommended to NOT set up git credentials per user.

---

## 3.2 Install R (system-wide)
Download from https://cloud.r-project.org

Install using:
- “Install for all users”
- Preferred path:
  C:\R\R-4.4.0\

Install also RStudio for all users. It needs to be installed after R and with admin rights. It is also need to modify .Rprofile. 
.Rprofile is a script that R runs at startup — before any user code.
It can set library paths, default options, load packages, etc.

You can have:
- User-specific .Rprofile → C:\Users\<user>\Documents\.Rprofile
- Global/system-wide .Rprofile → inside R’s installation folder, used by all users

Edit the global .Rprofile (for all users)
Path: C:\R\R-4.4.0\etc\Rprofile.site

with the following content:
```r
options(MADRAT_MAINFOLDER="C:/madratverse")
Sys.setenv(RENV_CONFIG_AUTOINSTALL = FALSE)
Sys.setenv(RENV_CONFIG_PROJECT_AUTO = FALSE)
Sys.setenv(RENV_CONFIG_USER_PROFILE = FALSE)
Sys.setenv(RENV_PATHS_CACHE = "")
```

Open R or VS Code R terminal as another user and run: .libPaths()

You should see: "C:/R/R-4.4.1/library"

---

## 3.3 Install VS Code (shared settings for all users)

Install to:
C:\Microsoft VS Code\

Create shared user data folder and an extensions folder:
C:\VSCodeUserData
C:\VSCodeExtensions

And in the target of the shortcuts of VS Code, add the following arguments in the properties:
```
"C:\Microsoft VS Code\Code.exe" --user-data-dir "C:\VSCodeUserData" --extensions-dir "C:\VSCodeExtensions"
```
Be careful to modify all shortcuts (Desktop, Start Menu, Taskbar) and keep in mind that the original VS Code executable in "C:\Microsoft VS Code\" should not be used directly.
All users now share extensions, settings, and interpreter paths.

---

## 3.4 Install GAMS (system-wide)

Download from https://www.gams.com/download/

Install to:
C:\GAMS\<version>

Add GAMS to the system PATH.

---

# 4. INSTALL MAGPIE SYSTEM-WIDE (NO RENV)
First: Do NOT install MAGPIE using Chocolatey. It is not suitable for multi-user setups. If all other steps have been done:
✔ Clean R installation
✔ Working Git
✔ Shared VS Code
✔ Users have proper PATH and permissions

You can safely clone MAGPIE and then use it system-wide without RENV.

```
install.packages("remotes")
remotes::install_github("pik-piam/magclass")
remotes::install_github("pik-piam/madrat")
remotes::install_github("pik-piam/mrcommons")
remotes::install_github("pik-piam/mrdrivers")
remotes::install_github("pik-piam/mrvalidation")
remotes::install_github("pik-piam/magpie")
```
Other steps include:
1. Remove renv folder from the magpie folder
2. Edit .Rprofile in the magpie folder to disable renv auto-activation by commenting out all the lines except this one
```r
if (!"https://rse.pik-potsdam.de/r/packages" %in% getOption("repos")) {
  options(repos = c(getOption("repos"), pik = "https://rse.pik-potsdam.de/r/packages"))
}
```
3. Install all required packages system-wide: lucode2, gms, etc.

You can run start a MAgPIE run with Rscript start.R located in the magpie folder. Choose "1" for a default run and then select "1" for direct execution.

---

# 5. INSTALL PYTHON PACKAGES (SYSTEM-WIDE)

Install Python for all users to:
C:\Python310\

Install packages as Admin:
```powershell
pip install numpy pandas matplotlib
```

---

# 6. INSTALL TINYTEX (SYSTEM-WIDE)

In R (Admin):
```r
install.packages("tinytex")
tinytex::install_tinytex(force = TRUE, dir = "C:/TinyTeX")
```

Add to Sytem PATH:
C:\TinyTeX\bin\win32

---

# 7. SHARED ONEDRIVE / SHAREPOINT SETUP

By default, when you sync a SharePoint or OneDrive library in Windows 11, it’s tied to a specific user account and stored under that user’s profile (e.g.
C:\Users\user\CompanyName\SharePoint - ProjectData).

If you want all users on the machine to access the same SharePoint-synced folder, you need to set up OneDrive to sync to a shared location. However, OneDrive does not natively support multi-user sync on the same machine. OneDrive syncs only for the account that’s signed in.
When another user logs in, they see the folder, but their OneDrive client won’t know about it. So they can’t sync changes to SharePoint.

The solution is to set up a scheduled task that runs OneDrive.exe at startup for a single user with admin rights, ensuring that the OneDrive client is active and syncing the shared folder. 
### Steps:
1. Log in as the admin user who set up the OneDrive sync folder for SharePoint.
   - Sources folder for madrat
   - Runs folder for models runs
2. Open Task Scheduler and create a new task.
3. Configure the task with the following settings:
   - Name: Start OneDrive Sync
   - Security options:
   - “Run whether user is logged on or not” ✅
   - “Run with highest privileges” ✅
   - User account: select the same account that owns the OneDrive sync (click Change User or Group if needed).
   - Go to Triggers → New
   - Begin the task: “At startup”
   - (Optional) Add a delay: “Delay task for 30 seconds” — gives the network time to initialize
   - Add an Action, Actions → New, Action: Start a program
   - Program/script: " C:\Users\<YourAccount>\AppData\Local\Microsoft\OneDrive\OneDrive.exe"
   - Add arguments (optional): /background
4. Save the task. You may be prompted to enter the password for the selected user account.
5. Test the task by right-clicking it and selecting “Run”. Check that OneDrive starts and begins syncing.

---

# 8. LINUX SUPPORT - WSL (PER-USER)

Each user must install WSL separately:
```powershell
wsl --install -d Ubuntu
```

There is no system-wide WSL installation. Each user can set up their own WSL environment as needed. 

---

# 9. TEST THE SETUP

Verify for another user
1. Log out and log in as another Windows user.
2. Open PowerShell and run:
'''
python --version
git --version
R --version
gams 
'''
If each command returns a version, the PATH works for everyone.
Make also a research new data run with OPEN-PROM via VS Code task.

