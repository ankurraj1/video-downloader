@echo off
title Video Downloader EXE Installer
color 0A

:: Request Administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
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
echo       Video Downloader EXE Installer
echo ================================================
echo.
echo Creating a professional Windows executable...
echo.

:: Set paths
set INSTALL_DIR=%PROGRAMFILES%\VideoDownloader
set SCRIPT_DIR=%~dp0

:: Check for Python
echo [1/7] Checking Python installation...
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

:: Create temporary build directory
echo [2/7] Setting up build environment...
set BUILD_DIR=%TEMP%\VideoDownloaderBuild
if exist "%BUILD_DIR%" rd /s /q "%BUILD_DIR%"
mkdir "%BUILD_DIR%"
cd /d "%BUILD_DIR%"

:: Check source files exist
echo Checking for source files...
set SRC_DIR=%SCRIPT_DIR%..\src
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

:: Copy source files
echo [3/7] Copying application files...
copy "%SRC_DIR%\video_downloader.py" . || (echo ERROR: Failed to copy video_downloader.py & pause & exit /b 1)
copy "%SRC_DIR%\requirements.txt" . || (echo ERROR: Failed to copy requirements.txt & pause & exit /b 1)

:: Create virtual environment and install dependencies
echo [4/7] Installing dependencies...
python -m venv build_env
if %errorlevel% neq 0 (
    echo ERROR: Failed to create virtual environment
    pause
    exit /b 1
)

call build_env\Scripts\activate.bat
if %errorlevel% neq 0 (
    echo ERROR: Failed to activate virtual environment
    pause
    exit /b 1
)

python -m pip install --upgrade pip
python -m pip install -r requirements.txt
if %errorlevel% neq 0 (
    echo ERROR: Failed to install requirements
    pause
    exit /b 1
)

python -m pip install pyinstaller
if %errorlevel% neq 0 (
    echo ERROR: Failed to install PyInstaller
    pause
    exit /b 1
)

:: Download FFmpeg
echo [5/7] Downloading FFmpeg for bundling...
if not exist ffmpeg mkdir ffmpeg
cd ffmpeg

echo Downloading FFmpeg (this may take a moment)...
powershell -Command "try { Invoke-WebRequest -Uri 'https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip' -OutFile 'ffmpeg.zip' -UseBasicParsing; Write-Host 'Download complete' } catch { Write-Host 'Download failed'; exit 1 }"

if %errorlevel% neq 0 (
    echo WARNING: Could not download FFmpeg
    echo The application will work but may have limited quality options
    cd ..
    goto skip_ffmpeg
)

powershell -Command "try { Expand-Archive -Path 'ffmpeg.zip' -DestinationPath 'extract' -Force; Write-Host 'Extraction complete' } catch { Write-Host 'Extraction failed' }"

:: Find and copy FFmpeg binaries
for /d %%i in (extract\ffmpeg-*) do (
    if exist "%%i\bin\ffmpeg.exe" (
        copy "%%i\bin\ffmpeg.exe" . >nul 2>&1
        copy "%%i\bin\ffprobe.exe" . >nul 2>&1
        echo ✓ FFmpeg binaries extracted
        goto ffmpeg_done
    )
)

:ffmpeg_done
:: Clean up
rd /s /q extract >nul 2>&1
del ffmpeg.zip >nul 2>&1

:skip_ffmpeg
cd ..

:: Build the executable
echo [6/7] Building Windows executable...
echo This may take a few minutes...

if exist ffmpeg\ffmpeg.exe (
    echo Building with FFmpeg support...
    pyinstaller --onefile --windowed --name VideoDownloader --add-data "ffmpeg;ffmpeg" --icon=NONE video_downloader.py >build.log 2>&1
) else (
    echo Building without FFmpeg (limited functionality)...
    pyinstaller --onefile --windowed --name VideoDownloader --icon=NONE video_downloader.py >build.log 2>&1
)

if %errorlevel% neq 0 (
    echo ERROR: Failed to build executable
    echo Check build.log for details:
    type build.log
    pause
    exit /b 1
)

if not exist "dist\VideoDownloader.exe" (
    echo ERROR: VideoDownloader.exe was not created
    pause
    exit /b 1
)

echo ✓ Executable created successfully!

:: Install the application
echo [7/7] Installing application...

:: Create installation directory
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

:: Copy the executable
copy "dist\VideoDownloader.exe" "%INSTALL_DIR%\" >nul
if %errorlevel% neq 0 (
    echo ERROR: Failed to copy executable to Program Files
    pause
    exit /b 1
)

:: Create desktop shortcut
echo Creating desktop shortcut...
powershell -Command "try { $WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\Video Downloader.lnk'); $Shortcut.TargetPath = '%INSTALL_DIR%\VideoDownloader.exe'; $Shortcut.WorkingDirectory = '%INSTALL_DIR%'; $Shortcut.Description = 'Video Downloader - Download videos in best quality'; $Shortcut.Save(); Write-Host 'Desktop shortcut created' } catch { Write-Host 'Failed to create desktop shortcut' }"

:: Create start menu shortcut
echo Creating Start Menu entry...
powershell -Command "try { $StartMenuPath = '%PROGRAMDATA%\Microsoft\Windows\Start Menu\Programs'; if (-not (Test-Path '$StartMenuPath\Video Downloader')) { New-Item -Path '$StartMenuPath\Video Downloader' -ItemType Directory -Force | Out-Null }; $WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('$StartMenuPath\Video Downloader\Video Downloader.lnk'); $Shortcut.TargetPath = '%INSTALL_DIR%\VideoDownloader.exe'; $Shortcut.WorkingDirectory = '%INSTALL_DIR%'; $Shortcut.Description = 'Video Downloader - Download videos in best quality'; $Shortcut.Save(); Write-Host 'Start Menu entry created' } catch { Write-Host 'Failed to create Start Menu entry' }"

:: Clean up build directory
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