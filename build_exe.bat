@echo off
title Video Downloader - Build Standalone EXE
color 0A

echo ================================================
echo      Building Video Downloader Standalone EXE
echo ================================================
echo.

:: Check for Python
echo [1/4] Checking Python...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Python not found!
    echo Install Python from https://python.org/downloads/
    pause
    exit /b 1
)
python --version
echo ✓ Python found

:: Install required packages
echo.
echo [2/4] Installing packages...
echo Installing yt-dlp...
python -m pip install yt-dlp>=2024.1.0 >nul 2>&1
echo Installing pyinstaller...
python -m pip install pyinstaller >nul 2>&1
echo ✓ Packages installed

:: Install FFmpeg
echo.
echo [3/4] Installing FFmpeg...
echo Checking if FFmpeg is installed...
ffmpeg -version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ FFmpeg already installed
) else (
    echo Installing FFmpeg via winget...
    winget install Gyan.FFmpeg --silent --accept-package-agreements --accept-source-agreements >nul 2>&1
    if %errorlevel% equ 0 (
        echo ✓ FFmpeg installed successfully
        echo Note: You may need to restart your terminal for PATH updates
    ) else (
        echo WARNING: FFmpeg installation failed - app will work with limited quality options
    )
)

:: Build the EXE
echo.
echo [4/4] Building EXE...
echo This may take a few minutes...

:: Clean up old build files to prevent permission errors
echo Cleaning old build files...
taskkill /F /IM VideoDownloader.exe >nul 2>&1
timeout /t 1 /nobreak >nul 2>&1
if exist dist\VideoDownloader.exe del /F /Q dist\VideoDownloader.exe >nul 2>&1
if exist build rmdir /S /Q build >nul 2>&1
if exist VideoDownloader.spec del /F /Q VideoDownloader.spec >nul 2>&1

echo Building EXE...
python -m PyInstaller --onefile --windowed --name VideoDownloader --icon=NONE src\video_downloader.py

if %errorlevel% neq 0 (
    echo ERROR: Build failed
    pause
    exit /b 1
)

:: Check if the EXE was created (wait a moment for file system sync)
timeout /t 2 /nobreak >nul 2>&1
if exist "dist\VideoDownloader.exe" (
    echo.
    echo ================================================
    echo          Build Complete!
    echo ================================================
    echo.
    echo Standalone EXE created: dist\VideoDownloader.exe
    echo File size: 
    dir dist\VideoDownloader.exe | find ".exe"
    echo.
    echo The app is now ready to use:
    echo • Copy VideoDownloader.exe anywhere
    echo • No installation needed
    echo • Run directly from any location
    echo.
    echo Features:
    echo ✓ Download videos in best quality
    echo ✓ Audio-only downloads as MP3
    echo ✓ FFmpeg integration (if installed)
    echo ✓ Completely portable
    echo.
) else (
    echo ERROR: VideoDownloader.exe not found in dist folder
    echo.
    echo Checking current directory contents:
    dir dist 2>nul || echo dist folder not found
    echo.
    echo If PyInstaller completed successfully above, check the dist folder manually.
    pause
    exit /b 1
)

echo Press any key to exit...
pause >nul