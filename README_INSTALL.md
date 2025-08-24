# 🎬 Video Downloader - Installation Guide

## 📍 Final Installation Location
After installation, you'll have:
- **Application:** `C:\Program Files\VideoDownloader\VideoDownloader.exe`
- **Desktop Shortcut:** "Video Downloader" on your Desktop  
- **Start Menu:** Available in Start Menu under "Video Downloader"

## 🚀 Quick Installation (Recommended)

### Step 1: Run the Installer
1. Go to the `installers` folder
2. Right-click on **`ExeInstaller.bat`**
3. Select **"Run as Administrator"**

### Step 2: Wait for Installation
The installer will:
- ✅ Check Python installation (prompts if missing)
- ✅ Download FFmpeg for best quality support
- ✅ Build a professional Windows .exe file
- ✅ Install to `C:\Program Files\VideoDownloader\`
- ✅ Create desktop and Start Menu shortcuts

### Step 3: Launch the App
- Double-click the desktop shortcut "Video Downloader"
- Or find it in Start Menu → Video Downloader

## 🎯 What You Get

After installation, you have a **professional Windows executable**:
- `VideoDownloader.exe` - No .bat files, no console windows
- Standalone application (no Python needed for end users)
- FFmpeg bundled for best quality downloads
- Clean Windows integration with proper shortcuts

## 🛠️ Installation Requirements

### Prerequisites:
- **Windows 10 or later**
- **Python 3.8+** (installer will check and prompt if missing)
- **Administrator privileges** (for installation only)
- **Internet connection** (to download FFmpeg)

### Python Installation (if needed):
1. Go to https://www.python.org/downloads/
2. Download Python 3.11 or newer
3. During installation: **✅ CHECK "Add Python to PATH"**
4. Re-run the installer

## 📱 Using the Application

### Features Available:
- **Best Quality:** Downloads highest resolution available (4K, 8K, etc.)
- **720p/480p:** Specific resolution limits
- **Audio Only:** Extracts audio as MP3
- **Progress Tracking:** Real-time download progress and speed
- **Custom Location:** Choose where to save downloads

### How to Use:
1. Launch "Video Downloader" from desktop or Start Menu
2. Paste video URL (YouTube, etc.)
3. Select quality - **"Best" for maximum quality**
4. Choose download folder (optional)
5. Click "Download"

## 🗂️ Project Structure

This repository is organized as:
```
video-downloader/
├── src/                      # Source code
│   ├── video_downloader.py   # Main application
│   └── requirements.txt      # Python dependencies
├── installers/               # Installation files
│   ├── ExeInstaller.bat      # Main installer (USE THIS)
│   ├── SimpleInstaller.bat   # Alternative (has issues)
│   ├── installer.nsi         # NSIS script (advanced)
│   └── build_installer.bat   # NSIS builder
├── README.md                 # Project documentation
└── README_INSTALL.md         # This installation guide
```

## 🔧 Troubleshooting

### Common Issues:

**"Python not found" Error:**
- Install Python from https://www.python.org/downloads/
- Make sure to check "Add Python to PATH" during installation

**"Access Denied" Error:**
- Right-click the installer and select "Run as Administrator"
- Make sure no antivirus is blocking the installation

**FFmpeg Download Failed:**
- Check your internet connection
- The app will still work but with limited quality options
- Try running the installer again

**Application Won't Start:**
- Make sure Windows Defender/antivirus isn't blocking VideoDownloader.exe
- Try running as Administrator once

### Build Issues (for developers):
- Make sure PyInstaller installed: `pip install pyinstaller`
- Check the build.log file created during installation for error details
- Ensure sufficient disk space (~500MB during build)

## 🗑️ Uninstallation

To completely remove Video Downloader:
1. Delete: `C:\Program Files\VideoDownloader\`
2. Delete desktop shortcut: "Video Downloader"
3. Delete Start Menu entry: `Start Menu\Programs\Video Downloader\`

## ✨ Key Benefits

- **Professional .exe application** - No more .bat files or console windows
- **Standalone** - End users don't need Python installed
- **Best quality downloads** - Automatic 4K, 8K support with FFmpeg
- **Clean installation** - Proper Windows integration
- **Easy distribution** - Single installer creates everything

## 📞 Support

If you encounter issues:
1. Make sure you ran `ExeInstaller.bat` as Administrator
2. Check that Python is installed and in PATH
3. Verify internet connection for FFmpeg download
4. Check Windows Defender isn't blocking the executable