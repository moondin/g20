@echo off
:: ViGCA Installer Package Creator for Windows 11
:: This script creates a self-contained installer package

setlocal enabledelayedexpansion

:: Set title and colors
title ViGCA Installer Package Creator
color 0A

echo **************************************************************
echo *                                                            *
echo *   ViGCA - Vision-Guided Cursor Automation                  *
echo *   Installer Package Creator                                *
echo *                                                            *
echo **************************************************************
echo.
echo This script will create a standalone installer package for ViGCA.
echo.

::Check if 7-Zip is installed - try multiple potential locations
set "SEVEN_ZIP_FOUND=0"
set "SEVEN_ZIP_CMD=7z"

:: First check if it's in PATH
where 7z >nul 2>&1
if %errorLevel% EQU 0 (
    set "SEVEN_ZIP_FOUND=1"
    set "SEVEN_ZIP_CMD=7z"
    echo Found 7-Zip in PATH
) else (
    :: Check common installation directories
    if exist "C:\Program Files\7-Zip\7z.exe" (
        set "SEVEN_ZIP_FOUND=1"
        set "SEVEN_ZIP_CMD=C:\Program Files\7-Zip\7z.exe"
        echo Found 7-Zip at: C:\Program Files\7-Zip\7z.exe
    ) else if exist "C:\Program Files (x86)\7-Zip\7z.exe" (
        set "SEVEN_ZIP_FOUND=1"
        set "SEVEN_ZIP_CMD=C:\Program Files (x86)\7-Zip\7z.exe"
        echo Found 7-Zip at: C:\Program Files (x86)\7-Zip\7z.exe
    )
)

:: If 7-Zip is still not found, try to use PowerShell instead
if %SEVEN_ZIP_FOUND% EQU 0 (
    echo 7-Zip not found. Attempting to use PowerShell for ZIP creation instead...
    
    :: Check if PowerShell is available
    where powershell >nul 2>&1
    if %errorLevel% NEQ 0 (
        echo ERROR: Neither 7-Zip nor PowerShell was found.
        echo.
        echo This script requires either 7-Zip or PowerShell to create the installer package.
        echo Please install 7-Zip from: https://7-zip.org/
        echo.
        echo Press any key to exit...
        pause >nul
        exit /b 1
    )
    
    echo PowerShell will be used for ZIP creation.
)

echo Creating temporary directory...
if exist "temp_installer" rmdir /s /q "temp_installer"
mkdir "temp_installer"
mkdir "temp_installer\vigca"
mkdir "temp_installer\examples"
mkdir "temp_installer\resources"

:: Check if setup.py exists, if not create a basic one
if not exist "setup.py" (
    echo Creating basic setup.py file...
    echo from setuptools import setup, find_packages > "temp_installer\setup.py" 
    echo. >> "temp_installer\setup.py"
    echo setup( >> "temp_installer\setup.py"
    echo     name="vigca", >> "temp_installer\setup.py"
    echo     version="0.1.0", >> "temp_installer\setup.py"
    echo     packages=find_packages(), >> "temp_installer\setup.py"
    echo     install_requires=[ >> "temp_installer\setup.py"
    echo         "opencv-python>=4.5.0", >> "temp_installer\setup.py"
    echo         "numpy>=1.20.0", >> "temp_installer\setup.py"
    echo         "mss>=6.1.0", >> "temp_installer\setup.py"
    echo         "pyautogui>=0.9.50", >> "temp_installer\setup.py"
    echo         "pillow>=8.0.0", >> "temp_installer\setup.py"
    echo         "customtkinter>=4.5.0" >> "temp_installer\setup.py"
    echo     ] >> "temp_installer\setup.py"
    echo ) >> "temp_installer\setup.py"
    copy "temp_installer\setup.py" "setup.py" >nul
) else (
    copy "setup.py" "temp_installer\" >nul
)

echo Copying files...
xcopy /y "vigca\*.py" "temp_installer\vigca\" >nul 2>&1
if %errorLevel% NEQ 0 echo Warning: Could not copy vigca module files - directory may not exist

xcopy /y "examples\*.py" "temp_installer\examples\" >nul 2>&1
if %errorLevel% NEQ 0 echo Warning: Could not copy example files - directory may not exist

if exist "resources\*.*" xcopy /y "resources\*.*" "temp_installer\resources\" >nul
copy /y "*.py" "temp_installer\" >nul 2>&1
copy /y "*.md" "temp_installer\" >nul 2>&1
copy /y "LICENSE" "temp_installer\" >nul 2>&1
copy /y "*.txt" "temp_installer\" >nul 2>&1
copy /y "install_vigca_windows.bat" "temp_installer\" >nul 2>&1

echo Creating README.txt file with instructions...
echo ViGCA - Vision-Guided Cursor Automation > "temp_installer\README.txt"
echo Windows 11 64-bit Installation Instructions >> "temp_installer\README.txt"
echo. >> "temp_installer\README.txt"
echo 1. Extract all files to a folder of your choice >> "temp_installer\README.txt"
echo 2. Right-click on install_vigca_windows.bat and select "Run as administrator" >> "temp_installer\README.txt"
echo 3. Follow the on-screen instructions to complete installation >> "temp_installer\README.txt"
echo. >> "temp_installer\README.txt"
echo Requirements: >> "temp_installer\README.txt"
echo - Windows 10/11 (64-bit) >> "temp_installer\README.txt"
echo - Python 3.8 or higher >> "temp_installer\README.txt"
echo. >> "temp_installer\README.txt"
echo For more information, see the included README.md file. >> "temp_installer\README.txt"

echo Creating installer package...

:: Create ZIP using either 7-Zip or PowerShell
if %SEVEN_ZIP_FOUND% EQU 1 (
    echo Using 7-Zip to create package...
    "%SEVEN_ZIP_CMD%" a -tzip "ViGCA_Windows_Installer.zip" ".\temp_installer\*" -r >nul
    if %errorLevel% NEQ 0 (
        echo ERROR: Failed to create ZIP file with 7-Zip.
        goto :cleanup_and_exit
    )
) else (
    echo Using PowerShell to create package...
    powershell -command "Compress-Archive -Path '.\temp_installer\*' -DestinationPath 'ViGCA_Windows_Installer.zip' -Force"
    if %errorLevel% NEQ 0 (
        echo ERROR: Failed to create ZIP file with PowerShell.
        goto :cleanup_and_exit
    )
)

:cleanup
echo Cleaning up temporary files...
rmdir /s /q "temp_installer"

if exist "ViGCA_Windows_Installer.zip" (
    echo.
    echo **************************************************************
    echo * Installation package created successfully!                 *
    echo * File: ViGCA_Windows_Installer.zip                          *
    echo **************************************************************
    echo.
    echo You can distribute this ZIP file to users. When they extract
    echo and run the install_vigca_windows.bat file, ViGCA will be 
    echo installed on their system.
) else (
    echo.
    echo ERROR: Failed to create installer package.
)

:exit
echo.
echo Press any key to exit...
pause >nul
exit /b 0

:cleanup_and_exit
rmdir /s /q "temp_installer"
echo.
echo Press any key to exit...
pause >nul
exit /b 1