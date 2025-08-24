@echo off
title Building Video Downloader Installer
echo ===============================================
echo     Building Video Downloader Installer
echo ===============================================
echo.

:: Check if NSIS is installed
where makensis >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: NSIS (Nullsoft Scriptable Install System) is not installed!
    echo.
    echo Please download and install NSIS from: https://nsis.sourceforge.io/Download
    echo After installation, add NSIS to your system PATH or run this script from NSIS directory.
    echo.
    pause
    exit /b 1
)

:: Check for required files
if not exist "video_downloader.py" (
    echo ERROR: video_downloader.py not found!
    echo Make sure you're running this from the correct directory.
    pause
    exit /b 1
)

if not exist "requirements.txt" (
    echo ERROR: requirements.txt not found!
    pause
    exit /b 1
)

echo All required files found!
echo.

:: Create LICENSE.txt if it doesn't exist
if not exist "LICENSE.txt" (
    echo Creating LICENSE.txt...
    echo MIT License > LICENSE.txt
    echo. >> LICENSE.txt
    echo Copyright (c) 2024 Video Downloader >> LICENSE.txt
    echo. >> LICENSE.txt
    echo Permission is hereby granted, free of charge, to any person obtaining a copy >> LICENSE.txt
    echo of this software and associated documentation files, to deal in the Software >> LICENSE.txt
    echo without restriction, including without limitation the rights to use, copy, >> LICENSE.txt
    echo modify, merge, publish, distribute, sublicense, and/or sell copies of the >> LICENSE.txt
    echo Software, and to permit persons to whom the Software is furnished to do so. >> LICENSE.txt
    echo. >> LICENSE.txt
    echo THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND. >> LICENSE.txt
)

:: Build the installer
echo Building installer with NSIS...
makensis installer.nsi

if %errorlevel% eq 0 (
    echo.
    echo ===============================================
    echo     Installer Built Successfully!
    echo ===============================================
    echo.
    echo The installer file "VideoDownloaderSetup.exe" has been created.
    echo This installer will:
    echo - Install Python virtual environment
    echo - Install yt-dlp and dependencies
    echo - Download and install ffmpeg
    echo - Create desktop and start menu shortcuts
    echo - Add uninstall option to Programs and Features
    echo.
    echo You can now distribute "VideoDownloaderSetup.exe" to users.
    echo.
) else (
    echo.
    echo ERROR: Failed to build installer!
    echo Please check the error messages above.
    echo.
)

pause