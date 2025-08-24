@echo off
title Video Downloader EXE Installer - DEBUG MODE
color 0A

echo ================================================
echo       Video Downloader EXE Installer DEBUG
echo ================================================
echo.
echo DEBUG MODE: This will show all output and pause at each step
echo to help identify where the installation is failing.
echo.
pause

:: Request Administrator privileges
echo Checking for Administrator privileges...
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ERROR: This installer requires Administrator privileges.
    echo Please right-click this file and select "Run as Administrator"
    echo.
    pause
    exit /b 1
)
echo ✓ Running as Administrator

:: Set paths and show them
echo.
echo Setting up paths...
set INSTALL_DIR=%PROGRAMFILES%\VideoDownloader
set SCRIPT_DIR=%~dp0
echo INSTALL_DIR: %INSTALL_DIR%
echo SCRIPT_DIR: %SCRIPT_DIR%
echo Current Directory: %CD%
pause

:: Check for Python
echo.
echo [1/7] Checking Python installation...
python --version
if %errorlevel% neq 0 (
    echo ERROR: Python is not installed or not in PATH!
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
pause

:: Check source files exist
echo.
echo Checking for source files...
set SRC_DIR=%SCRIPT_DIR%..\src
echo Looking for source files in: %SRC_DIR%
if not exist "%SRC_DIR%\video_downloader.py" (
    echo ERROR: video_downloader.py not found at: %SRC_DIR%\video_downloader.py
    echo.
    echo Directory contents:
    dir "%SRC_DIR%"
    echo.
    pause
    exit /b 1
)
if not exist "%SRC_DIR%\requirements.txt" (
    echo ERROR: requirements.txt not found at: %SRC_DIR%\requirements.txt
    echo.
    echo Directory contents:
    dir "%SRC_DIR%"
    echo.
    pause
    exit /b 1
)
echo ✓ Source files found
pause

:: Create temporary build directory
echo.
echo [2/7] Setting up build environment...
set BUILD_DIR=%TEMP%\VideoDownloaderBuild
echo BUILD_DIR: %BUILD_DIR%
if exist "%BUILD_DIR%" (
    echo Removing existing build directory...
    rd /s /q "%BUILD_DIR%"
)
echo Creating build directory...
mkdir "%BUILD_DIR%"
cd /d "%BUILD_DIR%"
echo Current directory: %CD%
pause

:: Copy source files
echo.
echo [3/7] Copying application files...
echo Copying from: %SRC_DIR%\video_downloader.py
echo Copying from: %SRC_DIR%\requirements.txt
copy "%SRC_DIR%\video_downloader.py" . || (echo ERROR: Failed to copy video_downloader.py & pause & exit /b 1)
copy "%SRC_DIR%\requirements.txt" . || (echo ERROR: Failed to copy requirements.txt & pause & exit /b 1)
echo ✓ Files copied
pause

:: Create virtual environment and install dependencies
echo.
echo [4/7] Installing dependencies...
echo Creating virtual environment...
python -m venv build_env
if %errorlevel% neq 0 (
    echo ERROR: Failed to create virtual environment
    pause
    exit /b 1
)

echo Activating virtual environment...
call build_env\Scripts\activate.bat
if %errorlevel% neq 0 (
    echo ERROR: Failed to activate virtual environment
    pause
    exit /b 1
)

echo Upgrading pip...
python -m pip install --upgrade pip
if %errorlevel% neq 0 (
    echo WARNING: Failed to upgrade pip, continuing...
)

echo Installing requirements...
python -m pip install -r requirements.txt
if %errorlevel% neq 0 (
    echo ERROR: Failed to install requirements
    echo.
    echo Requirements.txt contents:
    type requirements.txt
    echo.
    pause
    exit /b 1
)

echo Installing PyInstaller...
python -m pip install pyinstaller
if %errorlevel% neq 0 (
    echo ERROR: Failed to install PyInstaller
    pause
    exit /b 1
)
echo ✓ Dependencies installed
pause

:: Download FFmpeg
echo.
echo [5/7] Downloading FFmpeg for bundling...
if not exist ffmpeg mkdir ffmpeg
cd ffmpeg

echo Downloading FFmpeg (this may take a moment)...
powershell -Command "try { Write-Host 'Starting download...'; Invoke-WebRequest -Uri 'https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip' -OutFile 'ffmpeg.zip' -UseBasicParsing; Write-Host 'Download complete' } catch { Write-Host 'Download failed:' $_.Exception.Message; exit 1 }"

if %errorlevel% neq 0 (
    echo WARNING: Could not download FFmpeg
    echo The application will work but may have limited quality options
    cd ..
    goto skip_ffmpeg
)

echo Extracting FFmpeg...
powershell -Command "try { Expand-Archive -Path 'ffmpeg.zip' -DestinationPath 'extract' -Force; Write-Host 'Extraction complete' } catch { Write-Host 'Extraction failed:' $_.Exception.Message }"

:: Find and copy FFmpeg binaries
echo Looking for FFmpeg binaries...
for /d %%i in (extract\ffmpeg-*) do (
    echo Found directory: %%i
    if exist "%%i\bin\ffmpeg.exe" (
        echo Copying ffmpeg.exe...
        copy "%%i\bin\ffmpeg.exe" . >nul 2>&1
        echo Copying ffprobe.exe...
        copy "%%i\bin\ffprobe.exe" . >nul 2>&1
        echo ✓ FFmpeg binaries copied
        goto ffmpeg_done
    )
)

:ffmpeg_done
:: Clean up
echo Cleaning up FFmpeg download files...
rd /s /q extract >nul 2>&1
del ffmpeg.zip >nul 2>&1

:skip_ffmpeg
cd ..
echo Current directory: %CD%
pause

:: Build the executable
echo.
echo [6/7] Building Windows executable...
echo This may take a few minutes...

if exist ffmpeg\ffmpeg.exe (
    echo Building with FFmpeg support...
    echo Command: pyinstaller --onefile --windowed --name VideoDownloader --add-data "ffmpeg;ffmpeg" --icon=NONE video_downloader.py
    pyinstaller --onefile --windowed --name VideoDownloader --add-data "ffmpeg;ffmpeg" --icon=NONE video_downloader.py
) else (
    echo Building without FFmpeg (limited functionality)...
    echo Command: pyinstaller --onefile --windowed --name VideoDownloader --icon=NONE video_downloader.py
    pyinstaller --onefile --windowed --name VideoDownloader --icon=NONE video_downloader.py
)

if %errorlevel% neq 0 (
    echo ERROR: Failed to build executable
    echo.
    echo Check build.log for details (if it exists):
    if exist build.log type build.log
    echo.
    echo PyInstaller output directory contents:
    if exist build dir build
    if exist dist dir dist
    echo.
    pause
    exit /b 1
)

if not exist "dist\VideoDownloader.exe" (
    echo ERROR: VideoDownloader.exe was not created
    echo.
    echo Dist directory contents:
    if exist dist dir dist
    echo.
    pause
    exit /b 1
)

echo ✓ Executable created successfully!
pause

:: Install the application
echo.
echo [7/7] Installing application...

:: Create installation directory
echo Creating installation directory: %INSTALL_DIR%
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

:: Copy the executable
echo Copying executable to Program Files...
copy "dist\VideoDownloader.exe" "%INSTALL_DIR%\" 
if %errorlevel% neq 0 (
    echo ERROR: Failed to copy executable to Program Files
    echo This might be a permissions issue.
    pause
    exit /b 1
)
echo ✓ Executable installed

:: Create desktop shortcut
echo Creating desktop shortcut...
powershell -Command "try { $WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\Video Downloader.lnk'); $Shortcut.TargetPath = '%INSTALL_DIR%\VideoDownloader.exe'; $Shortcut.WorkingDirectory = '%INSTALL_DIR%'; $Shortcut.Description = 'Video Downloader - Download videos in best quality'; $Shortcut.Save(); Write-Host 'Desktop shortcut created' } catch { Write-Host 'Failed to create desktop shortcut:' $_.Exception.Message }"

:: Create start menu shortcut
echo Creating Start Menu entry...
powershell -Command "try { $StartMenuPath = '%PROGRAMDATA%\Microsoft\Windows\Start Menu\Programs'; if (-not (Test-Path '$StartMenuPath\Video Downloader')) { New-Item -Path '$StartMenuPath\Video Downloader' -ItemType Directory -Force | Out-Null }; $WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('$StartMenuPath\Video Downloader\Video Downloader.lnk'); $Shortcut.TargetPath = '%INSTALL_DIR%\VideoDownloader.exe'; $Shortcut.WorkingDirectory = '%INSTALL_DIR%'; $Shortcut.Description = 'Video Downloader - Download videos in best quality'; $Shortcut.Save(); Write-Host 'Start Menu entry created' } catch { Write-Host 'Failed to create Start Menu entry:' $_.Exception.Message }"

:: Clean up build directory
echo Cleaning up build files...
cd /d "%TEMP%"
rd /s /q "%BUILD_DIR%" >nul 2>&1

echo.
echo ================================================
echo          Installation Complete!
echo ================================================
echo.
echo Video Downloader has been installed as a Windows executable!
echo.
echo Installation location: %INSTALL_DIR%\VideoDownloader.exe
echo.
echo You can now start the application by:
echo • Double-clicking the desktop shortcut "Video Downloader"
echo • Finding it in the Start Menu under "Video Downloader"
echo • Running: %INSTALL_DIR%\VideoDownloader.exe
echo.
echo Features:
echo ✓ Professional Windows .exe application
echo ✓ Download videos in best available quality (4K, 8K)
echo ✓ Audio-only downloads as MP3
echo ✓ Progress tracking and download history
if exist "%INSTALL_DIR%\ffmpeg" echo ✓ FFmpeg integration for quality merging
echo ✓ No Python installation required for end users
echo.
echo The application is completely standalone and ready to use!
echo.
echo Press any key to exit...
pause >nul