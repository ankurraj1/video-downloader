@echo off
title Video Downloader Simple Setup
color 0A

:: Request Administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ================================================
    echo   Video Downloader Setup - Admin Required
    echo ================================================
    echo.
    echo This installer requires Administrator privileges.
    echo Please right-click this file and select:
    echo "Run as Administrator"
    echo.
    pause
    exit /b 1
)

echo ================================================
echo      Video Downloader Simple Setup
echo ================================================
echo.
echo This is a simpler installer that directly copies
echo the Python application without building an .exe
echo.

:: Set paths
set INSTALL_DIR=%PROGRAMFILES%\VideoDownloader
set SCRIPT_DIR=%~dp0
set SRC_DIR=%SCRIPT_DIR%..\src

:: Check for Python
echo [1/5] Checking Python installation...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Python is not installed!
    echo.
    echo Please install Python first:
    echo 1. Go to: https://www.python.org/downloads/
    echo 2. Download Python 3.11 or newer
    echo 3. During installation, check "Add Python to PATH"
    echo 4. Run this installer again
    echo.
    pause
    exit /b 1
)
echo ✓ Python found

:: Check source files exist
echo [2/5] Checking source files...
if not exist "%SRC_DIR%\video_downloader.py" (
    echo ERROR: video_downloader.py not found at: %SRC_DIR%
    pause
    exit /b 1
)
if not exist "%SRC_DIR%\requirements.txt" (
    echo ERROR: requirements.txt not found at: %SRC_DIR%
    pause
    exit /b 1
)
echo ✓ Source files found

:: Create installation directory
echo [3/5] Creating installation directory...
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
cd /d "%INSTALL_DIR%"

:: Copy application files
echo Copying application files...
copy "%SRC_DIR%\video_downloader.py" . >nul
copy "%SRC_DIR%\requirements.txt" . >nul

:: Create virtual environment
echo Creating Python environment...
python -m venv venv
if %errorlevel% neq 0 (
    echo ERROR: Failed to create virtual environment
    pause
    exit /b 1
)

:: Install packages
echo Installing packages...
call venv\Scripts\activate.bat
python -m pip install --upgrade pip >nul 2>&1
python -m pip install -r requirements.txt >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Failed to install packages
    pause
    exit /b 1
)
echo ✓ Python environment ready

:: Download FFmpeg
echo [4/5] Installing FFmpeg...
if not exist ffmpeg mkdir ffmpeg
cd ffmpeg

powershell -Command "try { Invoke-WebRequest -Uri 'https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip' -OutFile 'ffmpeg.zip' -UseBasicParsing } catch { exit 1 }" >nul 2>&1
if %errorlevel% neq 0 (
    echo WARNING: Could not download FFmpeg automatically
    echo The app will work but with limited quality options
    cd ..
    goto skip_ffmpeg
)

powershell -Command "try { Expand-Archive -Path 'ffmpeg.zip' -DestinationPath 'extract' -Force } catch { exit 1 }" >nul 2>&1
if %errorlevel% neq 0 (
    echo WARNING: Could not extract FFmpeg
    cd ..
    goto skip_ffmpeg
)

for /d %%i in (extract\ffmpeg-*) do (
    copy "%%i\bin\ffmpeg.exe" . >nul 2>&1
    copy "%%i\bin\ffprobe.exe" . >nul 2>&1
)

rd /s /q extract >nul 2>&1
del ffmpeg.zip >nul 2>&1
echo ✓ FFmpeg installed

:skip_ffmpeg
cd ..

:: Create launcher script
echo [5/5] Creating application launcher...
(
echo @echo off
echo title Video Downloader
echo cd /d "%%~dp0"
echo set PATH=%%cd%%\ffmpeg;%%PATH%%
echo call venv\Scripts\activate.bat
echo python video_downloader.py
echo if errorlevel 1 pause
) > VideoDownloader.bat

:: Create desktop shortcut
echo Creating desktop shortcut...
powershell -Command "try { $WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\Video Downloader.lnk'); $Shortcut.TargetPath = '%INSTALL_DIR%\VideoDownloader.bat'; $Shortcut.WorkingDirectory = '%INSTALL_DIR%'; $Shortcut.Description = 'Video Downloader - Download videos in best quality'; $Shortcut.Save() } catch {}" >nul

:: Create start menu shortcut
echo Creating Start Menu entry...
powershell -Command "try { $StartMenuPath = '%PROGRAMDATA%\Microsoft\Windows\Start Menu\Programs'; if (-not (Test-Path '$StartMenuPath\Video Downloader')) { New-Item -Path '$StartMenuPath\Video Downloader' -ItemType Directory -Force | Out-Null }; $WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('$StartMenuPath\Video Downloader\Video Downloader.lnk'); $Shortcut.TargetPath = '%INSTALL_DIR%\VideoDownloader.bat'; $Shortcut.WorkingDirectory = '%INSTALL_DIR%'; $Shortcut.Description = 'Video Downloader - Download videos in best quality'; $Shortcut.Save() } catch {}" >nul

echo.
echo ================================================
echo          Installation Complete!
echo ================================================
echo.
echo Video Downloader has been installed successfully!
echo.
echo Installation location: %INSTALL_DIR%
echo Application launcher: %INSTALL_DIR%\VideoDownloader.bat
echo.
echo You can now start the application by:
echo • Double-clicking the desktop shortcut "Video Downloader"
echo • Finding it in the Start Menu under "Video Downloader"  
echo • Running: %INSTALL_DIR%\VideoDownloader.bat
echo.
echo Features:
echo ✓ Download videos in best available quality (4K, 8K)
echo ✓ Audio-only downloads as MP3
echo ✓ Progress tracking and download history
if exist "%INSTALL_DIR%\ffmpeg\ffmpeg.exe" echo ✓ FFmpeg integration for quality merging
echo ✓ Clean Windows integration
echo.
echo The application is ready to use!
echo.
echo Press any key to exit...
pause >nul