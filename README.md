# 🎬 Video Downloader

A professional desktop application for downloading videos in the best quality using yt-dlp with automatic FFmpeg integration.

## ✨ Features

- 🎥 Download videos from various platforms (YouTube, Vimeo, etc.)
- 🏆 **Best quality downloads** - automatic 4K, 8K support when available
- 🎵 Audio extraction as MP3 with high quality
- 📊 Real-time progress tracking with download speed
- 📁 Custom download location selection
- 🖥️ Clean, user-friendly GUI interface
- ⚡ Professional Windows .exe installer

## 📍 Installation Location
After installation:
- **SimpleSetup:** `C:\Program Files\VideoDownloader\VideoDownloader.bat`
- **ExeInstaller:** `C:\Program Files\VideoDownloader\VideoDownloader.exe`

## 🚀 Quick Installation

### Windows - Choose Your Installer:

#### Option 1: SimpleSetup.bat (Recommended for most users)
1. Go to the `installers` folder
2. Right-click **`SimpleSetup.bat`**
3. Select **"Run as Administrator"**
4. Creates: `C:\Program Files\VideoDownloader\VideoDownloader.bat`

#### Option 2: ExeInstaller.bat (Professional .exe)
1. Go to the `installers` folder  
2. Right-click **`ExeInstaller.bat`**
3. Select **"Run as Administrator"**
4. Creates: `C:\Program Files\VideoDownloader\VideoDownloader.exe`

#### Option 3: Debug Mode (If installer fails)
1. Right-click **`ExeInstaller_Debug.bat`**
2. Select **"Run as Administrator"**
3. Shows detailed progress to identify issues

**All options create desktop shortcuts and Start Menu entries!**

### Linux Installation
```bash
# Install system dependencies
sudo apt-get install python3 python3-tk python3-venv python3-pip ffmpeg

# Setup application
python3 -m venv venv
source venv/bin/activate
pip install -r src/requirements.txt

# Run application
python3 src/video_downloader.py
```

## 🎯 How to Use

1. **Launch** "Video Downloader" from desktop shortcut or Start Menu
2. **Paste** video URL (YouTube, etc.)
3. **Select quality:**
   - **Best** - Highest available quality (4K, 8K, HDR)
   - **720p** - HD quality limit
   - **480p** - SD quality limit  
   - **Audio Only** - Extract as MP3
4. **Choose** download location (optional)
5. **Click** "Download" and watch the progress!

## 📂 Project Structure

```
video-downloader/
├── src/
│   ├── video_downloader.py     # Main application
│   └── requirements.txt        # Python dependencies
├── installers/
│   ├── SimpleSetup.bat         # Simple installer (recommended)
│   ├── ExeInstaller.bat        # Professional .exe builder
│   └── ExeInstaller_Debug.bat  # Debug version
└── README.md                   # This documentation
```

## 🔧 System Requirements

### Windows:
- Windows 10 or later
- Python 3.8+ (installer will check)
- Administrator privileges (for installation only)
- Internet connection (for FFmpeg download)

### Linux:
- Python 3.8+
- tkinter (usually included)
- FFmpeg (install via package manager)

## 🛠️ Troubleshooting

### "Python not found" Error
1. Download Python from https://www.python.org/downloads/
2. During installation: **✅ Check "Add Python to PATH"**
3. Re-run the installer

### "Access Denied" Error
- Right-click installer and select "Run as Administrator"
- Ensure antivirus isn't blocking the installation

### Poor Video Quality
- Make sure you selected "Best" quality option
- Verify FFmpeg was installed correctly
- Check if the source video has higher quality available

### Application Won't Launch
- Windows Defender might be blocking `VideoDownloader.exe`
- Add exclusion or run as Administrator once

## 🏗️ Development

### Build from Source
```bash
pip install pyinstaller
pyinstaller --onefile --windowed --name VideoDownloader src/video_downloader.py
```

## 🗑️ Uninstallation

To remove Video Downloader:
1. Delete `C:\Program Files\VideoDownloader\`
2. Delete desktop shortcut
3. Delete Start Menu entry

## 🎉 What Makes This Special

- **True best quality** - Downloads highest resolution available
- **Professional .exe** - No Python required for end users  
- **FFmpeg bundled** - Automatic video+audio merging
- **Clean installation** - Proper Windows integration
- **Optimized code** - Reduced from 367 to 170 lines
- **One-click installer** - Everything automated

Perfect for content creators, researchers, or anyone who wants the absolute best video quality! 🌟