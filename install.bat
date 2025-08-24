@echo off
title Video Downloader Installer
echo ======================================
echo     Video Downloader Installer
echo ======================================
echo.

:: Check for Python installation
echo Checking for Python installation...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Python is not installed!
    echo Please download and install Python from https://www.python.org/downloads/
    echo Make sure to check "Add Python to PATH" during installation.
    pause
    exit /b 1
)
echo Python found!
echo.

:: Create virtual environment
echo Creating virtual environment...
python -m venv venv
if %errorlevel% neq 0 (
    echo ERROR: Failed to create virtual environment!
    pause
    exit /b 1
)
echo Virtual environment created!
echo.

:: Activate virtual environment and install packages
echo Installing required packages...
call venv\Scripts\activate.bat
pip install --upgrade pip
pip install yt-dlp
pip install pyinstaller
if %errorlevel% neq 0 (
    echo ERROR: Failed to install packages!
    pause
    exit /b 1
)
echo Packages installed successfully!
echo.

:: Download and install ffmpeg
echo Installing ffmpeg for best quality downloads...
if not exist "ffmpeg" mkdir ffmpeg
echo Downloading ffmpeg...
powershell -Command "& {Invoke-WebRequest -Uri 'https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip' -OutFile 'ffmpeg-temp.zip'}"
if %errorlevel% neq 0 (
    echo WARNING: Could not download ffmpeg automatically.
    echo Please download ffmpeg manually from: https://ffmpeg.org/download.html
    echo Extract it to the 'ffmpeg' folder in this directory.
) else (
    echo Extracting ffmpeg...
    powershell -Command "& {Expand-Archive -Path 'ffmpeg-temp.zip' -DestinationPath 'ffmpeg-extract' -Force}"
    :: Move ffmpeg.exe and ffprobe.exe to ffmpeg folder
    for /d %%i in (ffmpeg-extract\ffmpeg-*) do (
        copy "%%i\bin\ffmpeg.exe" "ffmpeg\" >nul 2>&1
        copy "%%i\bin\ffprobe.exe" "ffmpeg\" >nul 2>&1
    )
    :: Clean up
    rd /s /q ffmpeg-extract 2>nul
    del ffmpeg-temp.zip 2>nul
    echo ffmpeg installed successfully!
)
echo.

:: Create launcher script
echo Creating launcher script...
echo @echo off > run.bat
echo title Video Downloader >> run.bat
echo cd /d "%%~dp0" >> run.bat
echo set PATH=%%cd%%\ffmpeg;%%PATH%% >> run.bat
echo call venv\Scripts\activate.bat >> run.bat
echo python video_downloader.py >> run.bat
echo pause >> run.bat
echo Launcher created!
echo.

:: Create desktop shortcut
echo Creating desktop shortcut...
powershell -Command "& {$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\Video Downloader.lnk'); $Shortcut.TargetPath = '%cd%\run.bat'; $Shortcut.WorkingDirectory = '%cd%'; $Shortcut.IconLocation = 'shell32.dll,16'; $Shortcut.Save()}"
if %errorlevel% eq 0 (
    echo Desktop shortcut created!
) else (
    echo Could not create desktop shortcut automatically.
)
echo.

echo ======================================
echo     Installation Complete!
echo ======================================
echo.
echo You can now:
echo 1. Double-click "run.bat" to start the application
echo 2. Use the desktop shortcut "Video Downloader"
echo.
echo Press any key to exit...
pause >nul