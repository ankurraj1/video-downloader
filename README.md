# Video Downloader

A simple desktop application for downloading videos in the best quality using yt-dlp with ffmpeg support.

## Features

- Download videos from various platforms (YouTube, etc.)
- Best quality downloads with automatic video+audio merging
- Choose video quality (Best, 720p, 480p, or Audio only)
- Select download location
- Progress bar with download speed
- Download history log
- Professional Windows installer with all dependencies

## Windows Installation (Recommended)

### Option 1: Professional Installer (NSIS)
1. Download and install NSIS from https://nsis.sourceforge.io/Download/
2. Run `build_installer.bat` to create `VideoDownloaderSetup.exe`
3. Distribute and run `VideoDownloaderSetup.exe` on target machines
4. The installer automatically handles:
   - Python virtual environment
   - yt-dlp installation
   - FFmpeg download and setup
   - Desktop shortcuts
   - Start menu entries
   - Uninstaller

### Option 2: Simple Batch Installer
1. Ensure Python is installed from https://www.python.org/downloads/
   - **Important**: Check "Add Python to PATH" during installation
2. Run `install.bat` as administrator
3. The script will automatically:
   - Create virtual environment
   - Install required packages
   - Download and setup FFmpeg
   - Create shortcuts

## Linux Installation

1. Install Python 3 and required packages:
```bash
sudo apt-get install python3 python3-tk python3-venv python3-pip python3-full ffmpeg
```

2. Create and activate virtual environment:
```bash
python3 -m venv venv
source venv/bin/activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

## Usage

### Windows
- Double-click the desktop shortcut "Video Downloader"
- Or run `run.bat` from the installation directory

### Linux
1. Activate the virtual environment:
```bash
source venv/bin/activate
```

2. Run the application:
```bash
python3 video_downloader.py
```

### Using the app:
1. Paste the video URL
2. Select download location (default: Downloads folder)
3. Choose quality:
   - **Best**: Highest quality available (includes 4K, 8K if available)
   - **720p**: 720p maximum resolution
   - **480p**: 480p maximum resolution  
   - **Audio Only**: Extract audio as MP3
4. Click Download

## Requirements

- Python 3.6+
- tkinter (included with Python)
- yt-dlp (auto-installed)
- ffmpeg (auto-installed by Windows installer)

## Building from Source

### Create Windows Executable
```bash
pip install pyinstaller
pyinstaller --onefile --windowed video_downloader.py
```

### Create Professional Windows Installer
1. Install NSIS from https://nsis.sourceforge.io/Download/
2. Run `build_installer.bat`
3. Distribute the generated `VideoDownloaderSetup.exe`

## Troubleshooting

### "ffmpeg not found" error
- Windows: Re-run the installer as administrator
- Linux: Install ffmpeg with `sudo apt install ffmpeg`

### Poor video quality
- Make sure FFmpeg is properly installed
- Use "Best" quality option for maximum quality
- Check if the source video has higher quality available