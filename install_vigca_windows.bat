@echo off
:: ViGCA Windows 11 Installer Script
:: This batch file automates the installation of ViGCA on Windows 11 64-bit

setlocal enabledelayedexpansion

:: Set title and colors
title ViGCA Installer for Windows 11
color 0B

:: Check if running as administrator
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo **************************************************************
    echo * WARNING: This installer is not running as administrator.   *
    echo * Some features may not work correctly.                      *
    echo * Please right-click on this file and select                 *
    echo * "Run as administrator" for best results.                   *
    echo **************************************************************
    echo.
    echo Press any key to continue anyway, or CTRL+C to exit...
    pause >nul
)

:: Welcome message
cls
echo **************************************************************
echo *                                                            *
echo *   ViGCA - Vision-Guided Cursor Automation                  *
echo *   Windows 11 64-bit Installer                              *
echo *                                                            *
echo *   Version: 0.1.0                                           *
echo *                                                            *
echo **************************************************************
echo.
echo This installer will set up ViGCA on your system.
echo.
echo The following steps will be performed:
echo  1. Check system requirements
echo  2. Install required Python packages
echo  3. Set up application files
echo  4. Create shortcuts
echo  5. Register application
echo.
echo Press any key to start the installation...
pause >nul

:: Check Python installation
cls
echo [1/5] Checking system requirements...
echo.

:: Try multiple potential Python command names and paths
set "PYTHON_CMD="

:: Try standard "python" command
where python >nul 2>&1
if %errorLevel% EQU 0 (
    set "PYTHON_CMD=python"
    goto :python_found
)

:: Try "python3" command
where python3 >nul 2>&1 
if %errorLevel% EQU 0 (
    set "PYTHON_CMD=python3"
    goto :python_found
)

:: Try "py" command
where py >nul 2>&1
if %errorLevel% EQU 0 (
    set "PYTHON_CMD=py"
    goto :python_found
)

:: Try common installation paths
set "PYTHON_PATHS=^
C:\Python39\python.exe^
C:\Python38\python.exe^
C:\Python310\python.exe^
C:\Python311\python.exe^
C:\Program Files\Python39\python.exe^
C:\Program Files\Python38\python.exe^
C:\Program Files\Python310\python.exe^
C:\Program Files\Python311\python.exe^
C:\Program Files (x86)\Python39\python.exe^
C:\Program Files (x86)\Python38\python.exe^
C:\Program Files (x86)\Python310\python.exe^
C:\Program Files (x86)\Python311\python.exe"

for %%p in (%PYTHON_PATHS%) do (
    if exist "%%p" (
        set "PYTHON_CMD=%%p"
        goto :python_found
    )
)

:: Python not found
echo ERROR: Python not found.
echo.
echo ViGCA requires Python 3.8 or newer. Please install Python from:
echo https://www.python.org/downloads/
echo.
echo Make sure to check "Add Python to PATH" during installation.
echo After installing Python, run this installer again.
echo.
echo Press any key to exit...
pause >nul
exit /b 1

:python_found
echo Found Python: %PYTHON_CMD%

:: Check Python version
%PYTHON_CMD% -c "import sys; sys.exit(0) if sys.version_info >= (3, 8) else sys.exit(1)" >nul 2>&1
if %errorLevel% NEQ 0 (
    echo ERROR: Python version is too old.
    echo.
    echo ViGCA requires Python 3.8 or newer. Your current Python version is:
    %PYTHON_CMD% --version
    echo.
    echo Please update Python from: https://www.python.org/downloads/
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
)

echo - Python version check: OK
%PYTHON_CMD% --version

:: Create application directories
if not exist "logs" mkdir logs
if not exist "resources" mkdir resources
echo - Application directories: OK

:: Set up environment variables
set "INSTALL_DIR=%CD%"
echo - Installation directory: %INSTALL_DIR%
echo.
echo System requirements check completed successfully!
echo.
echo Press any key to continue...
pause >nul

:: Install required packages
cls
echo [2/5] Installing required Python packages...
echo.
echo This may take a few minutes depending on your internet connection.
echo.

:: Upgrade pip
%PYTHON_CMD% -m pip install --upgrade pip
if %errorLevel% NEQ 0 (
    echo ERROR: Failed to upgrade pip.
    echo.
    echo Please check your internet connection and try again.
    echo If you are behind a corporate firewall, you may need to configure proxy settings.
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
)

:: Install required packages
:: First check if the requirements file exists
if not exist "requirements-windows.txt" (
    echo WARNING: requirements-windows.txt not found. Creating a basic one...
    echo opencv-python>=4.5.0 > requirements-windows.txt
    echo numpy>=1.20.0 >> requirements-windows.txt
    echo mss>=6.1.0 >> requirements-windows.txt
    echo pyautogui>=0.9.50 >> requirements-windows.txt
    echo pillow>=8.0.0 >> requirements-windows.txt
    echo customtkinter>=4.5.0 >> requirements-windows.txt
)

%PYTHON_CMD% -m pip install -r requirements-windows.txt
if %errorLevel% NEQ 0 (
    echo ERROR: Failed to install required packages.
    echo.
    echo Please check your internet connection and try again.
    echo If the issue persists, try installing each package individually:
    echo %PYTHON_CMD% -m pip install opencv-python numpy mss pyautogui pillow customtkinter
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
)

echo.
echo Python packages installed successfully!
echo.
echo Press any key to continue...
pause >nul

:: Install the application in development mode
cls
echo [3/5] Setting up application files...
echo.

:: Check if setup.py exists
if not exist "setup.py" (
    echo WARNING: setup.py not found. Creating a basic one...
    echo from setuptools import setup, find_packages > setup.py
    echo. >> setup.py
    echo setup( >> setup.py
    echo     name="vigca", >> setup.py
    echo     version="0.1.0", >> setup.py
    echo     packages=find_packages(), >> setup.py
    echo     install_requires=[ >> setup.py
    echo         "opencv-python>=4.5.0", >> setup.py
    echo         "numpy>=1.20.0", >> setup.py
    echo         "mss>=6.1.0", >> setup.py
    echo         "pyautogui>=0.9.50", >> setup.py
    echo         "pillow>=8.0.0", >> setup.py
    echo         "customtkinter>=4.5.0" >> setup.py
    echo     ] >> setup.py
    echo ) >> setup.py
)

%PYTHON_CMD% -m pip install -e .
if %errorLevel% NEQ 0 (
    echo ERROR: Failed to install ViGCA package.
    echo.
    echo Please check if the files are correctly set up and try again.
    echo You can try installing the package manually with:
    echo %PYTHON_CMD% -m pip install -e .
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
)

echo.
echo Application files set up successfully!
echo.
echo Press any key to continue...
pause >nul

:: Create shortcuts
cls
echo [4/5] Creating shortcuts...
echo.

:: Create desktop shortcut
echo Creating desktop shortcut...
set "SHORTCUT_FILE=%USERPROFILE%\Desktop\ViGCA.lnk"
set "TARGET_FILE=%INSTALL_DIR%\run_vigca_windows.py"
set "ICON_FILE=%INSTALL_DIR%\resources\vigca_icon.ico"

:: Check if the icon file exists, if not, make a dummy one
if not exist "%ICON_FILE%" (
    echo Creating default icon...
    copy nul "%ICON_FILE%" >nul
)

:: Create a temporary VBScript to create the shortcut
echo Set oWS = WScript.CreateObject("WScript.Shell") > "%TEMP%\CreateShortcut.vbs"
echo sLinkFile = "%SHORTCUT_FILE%" >> "%TEMP%\CreateShortcut.vbs"
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> "%TEMP%\CreateShortcut.vbs"
echo oLink.TargetPath = "pythonw" >> "%TEMP%\CreateShortcut.vbs"
echo oLink.Arguments = "%TARGET_FILE%" >> "%TEMP%\CreateShortcut.vbs"
echo oLink.WorkingDirectory = "%INSTALL_DIR%" >> "%TEMP%\CreateShortcut.vbs"
echo oLink.Description = "Vision-Guided Cursor Automation" >> "%TEMP%\CreateShortcut.vbs"
echo oLink.IconLocation = "%ICON_FILE%" >> "%TEMP%\CreateShortcut.vbs"
echo oLink.Save >> "%TEMP%\CreateShortcut.vbs"
cscript //nologo "%TEMP%\CreateShortcut.vbs"
del "%TEMP%\CreateShortcut.vbs"

echo - Desktop shortcut: OK

:: Create Start Menu shortcut
echo Creating Start Menu shortcut...
set "START_MENU_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\ViGCA"
if not exist "%START_MENU_DIR%" mkdir "%START_MENU_DIR%"
set "SHORTCUT_FILE=%START_MENU_DIR%\ViGCA.lnk"

:: Create a temporary VBScript to create the shortcut
echo Set oWS = WScript.CreateObject("WScript.Shell") > "%TEMP%\CreateShortcut.vbs"
echo sLinkFile = "%SHORTCUT_FILE%" >> "%TEMP%\CreateShortcut.vbs"
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> "%TEMP%\CreateShortcut.vbs"
echo oLink.TargetPath = "pythonw" >> "%TEMP%\CreateShortcut.vbs"
echo oLink.Arguments = "%TARGET_FILE%" >> "%TEMP%\CreateShortcut.vbs"
echo oLink.WorkingDirectory = "%INSTALL_DIR%" >> "%TEMP%\CreateShortcut.vbs"
echo oLink.Description = "Vision-Guided Cursor Automation" >> "%TEMP%\CreateShortcut.vbs"
echo oLink.IconLocation = "%ICON_FILE%" >> "%TEMP%\CreateShortcut.vbs"
echo oLink.Save >> "%TEMP%\CreateShortcut.vbs"
cscript //nologo "%TEMP%\CreateShortcut.vbs"
del "%TEMP%\CreateShortcut.vbs"

echo - Start Menu shortcut: OK
echo.
echo Shortcuts created successfully!
echo.
echo Press any key to continue...
pause >nul

:: Register application
cls
echo [5/5] Registering application...
echo.

:: Create a temporary REG file to register the application
echo Windows Registry Editor Version 5.00 > "%TEMP%\ViGCA_Registry.reg"
echo. >> "%TEMP%\ViGCA_Registry.reg"
echo [HKEY_CURRENT_USER\Software\ViGCA] >> "%TEMP%\ViGCA_Registry.reg"
echo "Version"="0.1.0" >> "%TEMP%\ViGCA_Registry.reg"
echo "Path"="%INSTALL_DIR:\=\\%" >> "%TEMP%\ViGCA_Registry.reg"
echo "PythonPath"="%SystemDrive%\\Python3" >> "%TEMP%\ViGCA_Registry.reg"

:: Import the registry file
reg import "%TEMP%\ViGCA_Registry.reg" >nul 2>&1
del "%TEMP%\ViGCA_Registry.reg"

echo Application registration complete!
echo.
echo Press any key to continue...
pause >nul

:: Create an uninstaller
echo @echo off > uninstall_vigca.bat
echo title ViGCA Uninstaller >> uninstall_vigca.bat
echo color 0C >> uninstall_vigca.bat
echo echo Uninstalling ViGCA... >> uninstall_vigca.bat
echo echo. >> uninstall_vigca.bat
echo echo Removing shortcuts... >> uninstall_vigca.bat
echo if exist "%USERPROFILE%\Desktop\ViGCA.lnk" del "%USERPROFILE%\Desktop\ViGCA.lnk" >> uninstall_vigca.bat
echo if exist "%APPDATA%\Microsoft\Windows\Start Menu\Programs\ViGCA\ViGCA.lnk" del "%APPDATA%\Microsoft\Windows\Start Menu\Programs\ViGCA\ViGCA.lnk" >> uninstall_vigca.bat
echo if exist "%APPDATA%\Microsoft\Windows\Start Menu\Programs\ViGCA" rmdir "%APPDATA%\Microsoft\Windows\Start Menu\Programs\ViGCA" >> uninstall_vigca.bat
echo echo Removing registry entries... >> uninstall_vigca.bat
echo reg delete "HKEY_CURRENT_USER\Software\ViGCA" /f ^>nul 2^>^&1 >> uninstall_vigca.bat
echo echo Uninstalling Python package... >> uninstall_vigca.bat
echo %PYTHON_CMD% -m pip uninstall -y vigca ^>nul 2^>^&1 >> uninstall_vigca.bat
echo echo. >> uninstall_vigca.bat
echo echo ViGCA has been uninstalled. >> uninstall_vigca.bat
echo echo You may delete the installation directory manually. >> uninstall_vigca.bat
echo echo. >> uninstall_vigca.bat
echo echo Press any key to exit... >> uninstall_vigca.bat
echo pause ^>nul >> uninstall_vigca.bat
echo exit /b 0 >> uninstall_vigca.bat

:: Create a runner batch file
echo @echo off > run_vigca.bat
echo title ViGCA Runner >> run_vigca.bat
echo cd /d "%INSTALL_DIR%" >> run_vigca.bat
echo echo Starting ViGCA... >> run_vigca.bat
echo set "PYTHONW_PATH=pythonw" >> run_vigca.bat
echo if exist "%PYTHON_CMD:\python.exe=\pythonw.exe%" set "PYTHONW_PATH=%PYTHON_CMD:\python.exe=\pythonw.exe%" >> run_vigca.bat
echo "%%PYTHONW_PATH%%" run_vigca_windows.py >> run_vigca.bat
echo exit /b 0 >> run_vigca.bat

:: Installation complete
cls
echo **************************************************************
echo *                                                            *
echo *   ViGCA - Vision-Guided Cursor Automation                  *
echo *   Installation Complete!                                   *
echo *                                                            *
echo **************************************************************
echo.
echo ViGCA has been successfully installed on your system!
echo.
echo You can now start the application using:
echo  - The desktop shortcut
echo  - The Start Menu shortcut
echo  - The run_vigca.bat file in the installation directory
echo.
echo To uninstall, run the uninstall_vigca.bat file in the 
echo installation directory.
echo.

:: Ask to launch the application
set /p LAUNCH_NOW="Would you like to launch ViGCA now? (Y/N): "
if /i "%LAUNCH_NOW%"=="Y" (
    echo Starting ViGCA...
    set "PYTHONW_PATH=pythonw"
    if exist "%PYTHON_CMD:\python.exe=\pythonw.exe%" set "PYTHONW_PATH=%PYTHON_CMD:\python.exe=\pythonw.exe%"
    start "" "%PYTHONW_PATH%" run_vigca_windows.py
)

echo.
echo Thank you for installing ViGCA!
echo.
echo Press any key to exit the installer...
pause >nul
exit /b 0