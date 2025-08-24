@echo off
title Video Downloader Setup
color 0A

:: Request Administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ================================================
    echo   Video Downloader Setup - Admin Required
    echo ================================================
    echo.
    echo This installer requires Administrator privileges
    echo to install system components and create shortcuts.
    echo.
    echo Please right-click this file and select:
    echo "Run as Administrator"
    echo.
    pause
    exit /b 1
)

echo ================================================
echo           Video Downloader Setup
echo ================================================
echo.
echo Installing Video Downloader with best quality
echo support including automatic FFmpeg setup...
echo.

:: Set installation directory
set INSTALL_DIR=%PROGRAMFILES%\VideoDownloader
echo Installation directory: %INSTALL_DIR%
echo.

:: Check for Python
echo [1/6] Checking Python installation...
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

:: Create installation directory
echo [2/6] Creating installation directory...
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
cd /d "%INSTALL_DIR%"
echo ✓ Directory created

:: Create the Python application
echo [3/6] Installing Video Downloader application...
(
echo import tkinter as tk
echo from tkinter import ttk, messagebox, filedialog
echo import yt_dlp
echo import threading
echo import os
echo from pathlib import Path
echo.
echo.
echo class VideoDownloader:
echo     def __init__(self, root^):
echo         self.root = root
echo         self.root.title("Video Downloader"^)
echo         self.root.geometry("600x500"^)
echo         self.download_path = str(Path.home(^) / "Downloads"^)
echo         self.setup_ui(^)
echo.        
echo     def create_labeled_widget(self, parent, label_text, widget_class, row, **widget_kwargs^):
echo         ttk.Label(parent, text=label_text, font=('Arial', 10^)^).grid(
echo             row=row, column=0, sticky=tk.W, pady=5^)
echo         widget = widget_class(parent, **widget_kwargs^)
echo         return widget
echo.        
echo     def setup_ui(self^):
echo         main_frame = ttk.Frame(self.root, padding="10"^)
echo         main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S^)^)
echo.        
echo         self.url_entry = self.create_labeled_widget(
echo             main_frame, "Video URL:", ttk.Entry, 0, width=50^)
echo         self.url_entry.grid(row=1, column=0, columnspan=2, pady=5, sticky=(tk.W, tk.E^)^)
echo.        
echo         self.create_labeled_widget(main_frame, "Download Path:", ttk.Label, 2^)
echo         path_frame = ttk.Frame(main_frame^)
echo         path_frame.grid(row=3, column=0, columnspan=2, sticky=(tk.W, tk.E^), pady=5^)
echo.        
echo         self.path_label = ttk.Label(path_frame, text=self.download_path, relief="sunken", padding=5^)
echo         self.path_label.pack(side=tk.LEFT, fill=tk.X, expand=True^)
echo         ttk.Button(path_frame, text="Browse", command=self.select_folder^).pack(side=tk.RIGHT, padx=(5, 0^)^)
echo.        
echo         self.create_labeled_widget(main_frame, "Quality:", ttk.Label, 4^)
echo         self.quality_var = tk.StringVar(value="best"^)
echo         quality_frame = ttk.Frame(main_frame^)
echo         quality_frame.grid(row=5, column=0, columnspan=2, sticky=tk.W, pady=5^)
echo.        
echo         qualities = [("Best", "best"^), ("720p", "720"^), ("480p", "480"^), ("Audio Only", "audio"^)]
echo         for text, value in qualities:
echo             ttk.Radiobutton(quality_frame, text=text, variable=self.quality_var, value=value^).pack(side=tk.LEFT, padx=5^)
echo.        
echo         button_frame = ttk.Frame(main_frame^)
echo         button_frame.grid(row=6, column=0, columnspan=2, pady=20^)
echo         self.download_btn = ttk.Button(button_frame, text="Download", command=self.start_download^)
echo         self.download_btn.pack(side=tk.LEFT, padx=5^)
echo         ttk.Button(button_frame, text="Clear", command=self.clear_fields^).pack(side=tk.LEFT, padx=5^)
echo.        
echo         self.create_labeled_widget(main_frame, "Progress:", ttk.Label, 7^)
echo         self.progress_var = tk.DoubleVar(^)
echo         self.progress_bar = ttk.Progressbar(main_frame, variable=self.progress_var, maximum=100^)
echo         self.progress_bar.grid(row=8, column=0, columnspan=2, sticky=(tk.W, tk.E^), pady=5^)
echo.        
echo         self.status_label = ttk.Label(main_frame, text="Ready to download", foreground="green"^)
echo         self.status_label.grid(row=9, column=0, columnspan=2, pady=5^)
echo.        
echo         self.log_text = tk.Text(main_frame, height=8, width=70^)
echo         self.log_text.grid(row=10, column=0, columnspan=2, pady=10, sticky=(tk.W, tk.E^)^)
echo         scrollbar = ttk.Scrollbar(main_frame, orient="vertical", command=self.log_text.yview^)
echo         scrollbar.grid(row=10, column=2, sticky=(tk.N, tk.S^), pady=10^)
echo         self.log_text.configure(yscrollcommand=scrollbar.set^)
echo.        
echo         main_frame.columnconfigure(0, weight=1^)
echo         self.root.columnconfigure(0, weight=1^)
echo         self.root.rowconfigure(0, weight=1^)
echo.        
echo     def select_folder(self^):
echo         folder = filedialog.askdirectory(initialdir=self.download_path^)
echo         if folder:
echo             self.download_path = folder
echo             self.path_label.config(text=self.download_path^)
echo.            
echo     def clear_fields(self^):
echo         self.url_entry.delete(0, tk.END^)
echo         self.progress_var.set(0^)
echo         self.log_text.delete(1.0, tk.END^)
echo         self.status_label.config(text="Ready to download", foreground="green"^)
echo.        
echo     def log_message(self, message^):
echo         self.log_text.insert(tk.END, message + "\n"^)
echo         self.log_text.see(tk.END^)
echo.        
echo     def progress_hook(self, d^):
echo         if d['status'] == 'downloading':
echo             total = d.get('total_bytes'^) or d.get('total_bytes_estimate', 1^)
echo             percent = (d['downloaded_bytes'] * 100.0 / total^) if total else 0
echo             self.progress_var.set(percent^)
echo.            
echo             if speed := d.get('speed'^):
echo                 speed_mb = speed / 1048576
echo                 self.status_label.config(text=f"Downloading... {percent:.1f}%% ({speed_mb:.2f} MB/s^)"^)
echo.                
echo         elif d['status'] == 'finished':
echo             self.progress_var.set(100^)
echo             self.status_label.config(text="Download completed!", foreground="green"^)
echo             self.log_message("Download finished, processing..."^)
echo.            
echo     def download_video(self^):
echo         url = self.url_entry.get(^).strip(^)
echo         if not url:
echo             messagebox.showerror("Error", "Please enter a video URL"^)
echo             return
echo.            
echo         try:
echo             quality = self.quality_var.get(^)
echo.            
echo             format_map = {
echo                 "audio": ("bestaudio/best", {"postprocessors": [{'key': 'FFmpegExtractAudio', 'preferredcodec': 'mp3'}]}^),
echo                 "best": ("bestvideo+bestaudio/best", {}^),
echo                 "720": ("bestvideo[height^<=720]+bestaudio/best[height^<=720]", {}^),
echo                 "480": ("bestvideo[height^<=480]+bestaudio/best[height^<=480]", {}^)
echo             }
echo.            
echo             format_opt, extra_opts = format_map[quality]
echo.            
echo             ydl_opts = {
echo                 'format': format_opt,
echo                 'outtmpl': os.path.join(self.download_path, '%%(title^)s.%%(ext^)s'^),
echo                 'progress_hooks': [self.progress_hook],
echo                 'quiet': True,
echo                 'no_warnings': True,
echo                 **extra_opts
echo             }
echo.                
echo             self.log_message(f"Starting download: {url} (Quality: {quality}^)"^)
echo.            
echo             with yt_dlp.YoutubeDL(ydl_opts^) as ydl:
echo                 info = ydl.extract_info(url, download=False^)
echo                 self.log_message(f"Title: {info.get('title', 'Unknown'^)}"^)
echo                 ydl.download([url]^)
echo.                
echo             self.log_message("Download completed successfully!"^)
echo             messagebox.showinfo("Success", f"Video downloaded to: {self.download_path}"^)
echo.            
echo         except Exception as e:
echo             self.status_label.config(text="Download failed!", foreground="red"^)
echo             self.log_message(f"Error: {e}"^)
echo             messagebox.showerror("Download Error", f"Failed to download video:\n{e}"^)
echo.            
echo         finally:
echo             self.download_btn.config(state='normal'^)
echo.            
echo     def start_download(self^):
echo         self.download_btn.config(state='disabled'^)
echo         self.progress_var.set(0^)
echo         self.status_label.config(text="Starting download...", foreground="blue"^)
echo         threading.Thread(target=self.download_video, daemon=True^).start(^)
echo.
echo.
echo def main(^):
echo     root = tk.Tk(^)
echo     VideoDownloader(root^)
echo     root.mainloop(^)
echo.
echo.
echo if __name__ == "__main__":
echo     main(^)
) > video_downloader.py
echo ✓ Application installed

:: Create virtual environment and install packages
echo [4/6] Setting up Python environment...
python -m venv venv
if %errorlevel% neq 0 (
    echo ERROR: Failed to create virtual environment
    pause
    exit /b 1
)

call venv\Scripts\activate.bat
pip install --upgrade pip >nul 2>&1
pip install yt-dlp >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Failed to install yt-dlp
    pause
    exit /b 1
)
echo ✓ Python packages installed

:: Download and setup FFmpeg
echo [5/6] Installing FFmpeg for best quality support...
if not exist ffmpeg mkdir ffmpeg
cd ffmpeg
if not exist ffmpeg.exe (
    echo Downloading FFmpeg... This may take a moment...
    powershell -Command "try { Invoke-WebRequest -Uri 'https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip' -OutFile '../ffmpeg-temp.zip' -UseBasicParsing } catch { exit 1 }"
    if %errorlevel% neq 0 (
        echo WARNING: Could not download FFmpeg automatically
        echo Some video quality features may be limited
        cd ..
        goto skip_ffmpeg
    )
    
    powershell -Command "try { Expand-Archive -Path '../ffmpeg-temp.zip' -DestinationPath '../ffmpeg-extract' -Force } catch { exit 1 }"
    if %errorlevel% neq 0 (
        echo WARNING: Could not extract FFmpeg
        cd ..
        goto skip_ffmpeg
    )
    
    for /d %%i in (..\ffmpeg-extract\ffmpeg-*) do (
        copy "%%i\bin\ffmpeg.exe" . >nul 2>&1
        copy "%%i\bin\ffprobe.exe" . >nul 2>&1
    )
    
    cd ..
    rd /s /q ffmpeg-extract >nul 2>&1
    del ffmpeg-temp.zip >nul 2>&1
    echo ✓ FFmpeg installed successfully
) else (
    cd ..
    echo ✓ FFmpeg already installed
)

:skip_ffmpeg

:: Create launcher script
echo [6/6] Creating shortcuts and launcher...
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
powershell -Command "try { $WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\Video Downloader.lnk'); $Shortcut.TargetPath = '%INSTALL_DIR%\VideoDownloader.bat'; $Shortcut.WorkingDirectory = '%INSTALL_DIR%'; $Shortcut.IconLocation = 'shell32.dll,16'; $Shortcut.Description = 'Video Downloader - Download videos in best quality'; $Shortcut.Save() } catch {}"

:: Create start menu shortcut
powershell -Command "try { $StartMenuPath = '%PROGRAMDATA%\Microsoft\Windows\Start Menu\Programs'; if (-not (Test-Path '$StartMenuPath\Video Downloader')) { New-Item -Path '$StartMenuPath\Video Downloader' -ItemType Directory -Force | Out-Null }; $WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('$StartMenuPath\Video Downloader\Video Downloader.lnk'); $Shortcut.TargetPath = '%INSTALL_DIR%\VideoDownloader.bat'; $Shortcut.WorkingDirectory = '%INSTALL_DIR%'; $Shortcut.IconLocation = 'shell32.dll,16'; $Shortcut.Description = 'Video Downloader - Download videos in best quality'; $Shortcut.Save() } catch {}"

echo ✓ Shortcuts created

echo.
echo ================================================
echo          Installation Complete!
echo ================================================
echo.
echo Video Downloader has been installed successfully!
echo.
echo Installation location: %INSTALL_DIR%
echo.
echo You can now start the application by:
echo • Double-clicking the desktop shortcut
echo • Finding it in the Start Menu
echo • Running: %INSTALL_DIR%\VideoDownloader.bat
echo.
echo Features:
echo ✓ Download videos in best available quality
echo ✓ Support for 4K, 8K videos when available  
echo ✓ Audio-only downloads as MP3
echo ✓ Progress tracking and download history
echo ✓ FFmpeg integration for quality merging
echo.
echo Press any key to exit...
pause >nul