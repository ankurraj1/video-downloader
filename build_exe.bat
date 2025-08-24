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

:: Download FFmpeg
echo.
echo [3/4] Getting FFmpeg...
if not exist ffmpeg mkdir ffmpeg
cd ffmpeg

if not exist ffmpeg.exe (
    echo Downloading FFmpeg...
    powershell -Command "[Net.ServicePointManager]::SecurityProtocol = 'Tls12'; try { Invoke-WebRequest 'https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip' -OutFile 'temp.zip' -UseBasicParsing -TimeoutSec 60; Expand-Archive 'temp.zip' 'temp' -Force; Get-ChildItem 'temp\ffmpeg-*\bin\ffmpeg.exe' | Copy-Item -Destination '.'; Get-ChildItem 'temp\ffmpeg-*\bin\ffprobe.exe' | Copy-Item -Destination '.' -ErrorAction SilentlyContinue; Remove-Item 'temp' -Recurse -Force; Remove-Item 'temp.zip' -Force; Write-Host 'FFmpeg ready' } catch { Write-Host 'FFmpeg download failed - continuing without it' }"
) else (
    echo ✓ FFmpeg already exists
)
cd ..

:: Build the EXE
echo.
echo [4/4] Building EXE...
echo This may take a few minutes...

if exist ffmpeg\ffmpeg.exe (
    echo Building with FFmpeg...
    python -m PyInstaller --onefile --windowed --name VideoDownloader --add-data "ffmpeg;ffmpeg" --icon=NONE src\video_downloader.py
) else (
    echo Building without FFmpeg...
    python -m PyInstaller --onefile --windowed --name VideoDownloader --icon=NONE src\video_downloader.py
)

if %errorlevel% neq 0 (
    echo ERROR: Build failed
    pause
    exit /b 1
)

if exist dist\VideoDownloader.exe (
    echo.
    echo ================================================
    echo          Build Complete!
    echo ================================================
    echo.
    echo Standalone EXE created: dist\VideoDownloader.exe
    echo.
    echo The app is now ready to use:
    echo • Copy VideoDownloader.exe anywhere
    echo • No installation needed
    echo • Run directly from any location
    echo.
    echo Features:
    echo ✓ Download videos in best quality
    echo ✓ Audio-only downloads as MP3
    if exist ffmpeg\ffmpeg.exe echo ✓ FFmpeg bundled for quality merging
    echo ✓ Completely portable
    echo.
) else (
    echo ERROR: VideoDownloader.exe not created
    pause
    exit /b 1
)

echo Press any key to exit...
pause >nul