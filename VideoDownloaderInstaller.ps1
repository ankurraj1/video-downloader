# Video Downloader PowerShell Installer
# This script creates a complete installation without requiring external tools

param(
    [string]$InstallPath = "$env:PROGRAMFILES\VideoDownloader"
)

# Set execution policy for current process
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

Write-Host "======================================" -ForegroundColor Green
Write-Host "   Video Downloader Installer" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host

# Function to check if running as administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Check for admin rights
if (-not (Test-Administrator)) {
    Write-Host "ERROR: This installer must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click and select 'Run as Administrator'" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Check for Python installation
Write-Host "Checking for Python installation..." -ForegroundColor Yellow
try {
    $pythonVersion = python --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Python found: $pythonVersion" -ForegroundColor Green
    } else {
        throw "Python not found"
    }
} catch {
    Write-Host "✗ Python not found. Installing Python..." -ForegroundColor Red
    
    # Download and install Python
    $pythonUrl = "https://www.python.org/ftp/python/3.11.6/python-3.11.6-amd64.exe"
    $pythonInstaller = "$env:TEMP\python-installer.exe"
    
    Write-Host "Downloading Python from $pythonUrl..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $pythonUrl -OutFile $pythonInstaller -UseBasicParsing
        Write-Host "Installing Python (this may take a few minutes)..." -ForegroundColor Yellow
        Start-Process -FilePath $pythonInstaller -ArgumentList "/quiet", "InstallAllUsers=1", "PrependPath=1" -Wait
        Remove-Item $pythonInstaller -Force
        
        # Refresh environment variables
        $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
        
        Write-Host "✓ Python installed successfully!" -ForegroundColor Green
    } catch {
        Write-Host "✗ Failed to install Python. Please install manually from https://python.org" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
}

# Create installation directory
Write-Host "Creating installation directory: $InstallPath" -ForegroundColor Yellow
if (-not (Test-Path $InstallPath)) {
    New-Item -Path $InstallPath -ItemType Directory -Force | Out-Null
}

# Create video_downloader.py in installation directory
Write-Host "Installing Video Downloader application..." -ForegroundColor Yellow
$videoDownloaderCode = @'
import tkinter as tk
from tkinter import ttk, messagebox, filedialog
import yt_dlp
import threading
import os
from pathlib import Path


class VideoDownloader:
    def __init__(self, root):
        self.root = root
        self.root.title("Video Downloader")
        self.root.geometry("600x500")
        self.download_path = str(Path.home() / "Downloads")
        self.setup_ui()
        
    def create_labeled_widget(self, parent, label_text, widget_class, row, **widget_kwargs):
        """Helper to create label-widget pairs"""
        ttk.Label(parent, text=label_text, font=('Arial', 10)).grid(
            row=row, column=0, sticky=tk.W, pady=5)
        widget = widget_class(parent, **widget_kwargs)
        return widget
        
    def setup_ui(self):
        main_frame = ttk.Frame(self.root, padding="10")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # URL input
        self.url_entry = self.create_labeled_widget(
            main_frame, "Video URL:", ttk.Entry, 0, width=50)
        self.url_entry.grid(row=1, column=0, columnspan=2, pady=5, sticky=(tk.W, tk.E))
        
        # Download path
        self.create_labeled_widget(main_frame, "Download Path:", ttk.Label, 2)
        path_frame = ttk.Frame(main_frame)
        path_frame.grid(row=3, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=5)
        
        self.path_label = ttk.Label(path_frame, text=self.download_path, relief="sunken", padding=5)
        self.path_label.pack(side=tk.LEFT, fill=tk.X, expand=True)
        ttk.Button(path_frame, text="Browse", command=self.select_folder).pack(side=tk.RIGHT, padx=(5, 0))
        
        # Quality selection
        self.create_labeled_widget(main_frame, "Quality:", ttk.Label, 4)
        self.quality_var = tk.StringVar(value="best")
        quality_frame = ttk.Frame(main_frame)
        quality_frame.grid(row=5, column=0, columnspan=2, sticky=tk.W, pady=5)
        
        qualities = [("Best", "best"), ("720p", "720"), ("480p", "480"), ("Audio Only", "audio")]
        for text, value in qualities:
            ttk.Radiobutton(quality_frame, text=text, variable=self.quality_var, value=value).pack(side=tk.LEFT, padx=5)
        
        # Buttons
        button_frame = ttk.Frame(main_frame)
        button_frame.grid(row=6, column=0, columnspan=2, pady=20)
        self.download_btn = ttk.Button(button_frame, text="Download", command=self.start_download)
        self.download_btn.pack(side=tk.LEFT, padx=5)
        ttk.Button(button_frame, text="Clear", command=self.clear_fields).pack(side=tk.LEFT, padx=5)
        
        # Progress
        self.create_labeled_widget(main_frame, "Progress:", ttk.Label, 7)
        self.progress_var = tk.DoubleVar()
        self.progress_bar = ttk.Progressbar(main_frame, variable=self.progress_var, maximum=100)
        self.progress_bar.grid(row=8, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=5)
        
        self.status_label = ttk.Label(main_frame, text="Ready to download", foreground="green")
        self.status_label.grid(row=9, column=0, columnspan=2, pady=5)
        
        # Log area
        self.log_text = tk.Text(main_frame, height=8, width=70)
        self.log_text.grid(row=10, column=0, columnspan=2, pady=10, sticky=(tk.W, tk.E))
        scrollbar = ttk.Scrollbar(main_frame, orient="vertical", command=self.log_text.yview)
        scrollbar.grid(row=10, column=2, sticky=(tk.N, tk.S), pady=10)
        self.log_text.configure(yscrollcommand=scrollbar.set)
        
        # Configure grid weights
        main_frame.columnconfigure(0, weight=1)
        self.root.columnconfigure(0, weight=1)
        self.root.rowconfigure(0, weight=1)
        
    def select_folder(self):
        folder = filedialog.askdirectory(initialdir=self.download_path)
        if folder:
            self.download_path = folder
            self.path_label.config(text=self.download_path)
            
    def clear_fields(self):
        self.url_entry.delete(0, tk.END)
        self.progress_var.set(0)
        self.log_text.delete(1.0, tk.END)
        self.status_label.config(text="Ready to download", foreground="green")
        
    def log_message(self, message):
        self.log_text.insert(tk.END, message + "\n")
        self.log_text.see(tk.END)
        
    def progress_hook(self, d):
        if d['status'] == 'downloading':
            total = d.get('total_bytes') or d.get('total_bytes_estimate', 1)
            percent = (d['downloaded_bytes'] * 100.0 / total) if total else 0
            self.progress_var.set(percent)
            
            if speed := d.get('speed'):
                speed_mb = speed / 1048576  # Bytes to MB
                self.status_label.config(text=f"Downloading... {percent:.1f}% ({speed_mb:.2f} MB/s)")
                
        elif d['status'] == 'finished':
            self.progress_var.set(100)
            self.status_label.config(text="Download completed!", foreground="green")
            self.log_message("Download finished, processing...")
            
    def download_video(self):
        url = self.url_entry.get().strip()
        if not url:
            messagebox.showerror("Error", "Please enter a video URL")
            return
            
        try:
            quality = self.quality_var.get()
            
            # Quality to format mapping
            format_map = {
                "audio": ("bestaudio/best", {"postprocessors": [{'key': 'FFmpegExtractAudio', 'preferredcodec': 'mp3'}]}),
                "best": ("bestvideo+bestaudio/best", {}),
                "720": ("bestvideo[height<=720]+bestaudio/best[height<=720]", {}),
                "480": ("bestvideo[height<=480]+bestaudio/best[height<=480]", {})
            }
            
            format_opt, extra_opts = format_map[quality]
            
            ydl_opts = {
                'format': format_opt,
                'outtmpl': os.path.join(self.download_path, '%(title)s.%(ext)s'),
                'progress_hooks': [self.progress_hook],
                'quiet': True,
                'no_warnings': True,
                **extra_opts
            }
                
            self.log_message(f"Starting download: {url} (Quality: {quality})")
            
            with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                info = ydl.extract_info(url, download=False)
                self.log_message(f"Title: {info.get('title', 'Unknown')}")
                ydl.download([url])
                
            self.log_message("Download completed successfully!")
            messagebox.showinfo("Success", f"Video downloaded to: {self.download_path}")
            
        except Exception as e:
            self.status_label.config(text="Download failed!", foreground="red")
            self.log_message(f"Error: {e}")
            messagebox.showerror("Download Error", f"Failed to download video:\n{e}")
            
        finally:
            self.download_btn.config(state='normal')
            
    def start_download(self):
        self.download_btn.config(state='disabled')
        self.progress_var.set(0)
        self.status_label.config(text="Starting download...", foreground="blue")
        threading.Thread(target=self.download_video, daemon=True).start()


def main():
    root = tk.Tk()
    VideoDownloader(root)
    root.mainloop()


if __name__ == "__main__":
    main()
'@

Set-Content -Path "$InstallPath\video_downloader.py" -Value $videoDownloaderCode -Encoding UTF8

# Create virtual environment
Write-Host "Creating Python virtual environment..." -ForegroundColor Yellow
Set-Location $InstallPath
python -m venv venv
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Failed to create virtual environment!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Install packages
Write-Host "Installing required packages..." -ForegroundColor Yellow
& ".\venv\Scripts\pip.exe" install --upgrade pip
& ".\venv\Scripts\pip.exe" install yt-dlp
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Failed to install packages!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Download and install FFmpeg
Write-Host "Installing FFmpeg for best quality downloads..." -ForegroundColor Yellow
$ffmpegDir = "$InstallPath\ffmpeg"
if (-not (Test-Path $ffmpegDir)) {
    New-Item -Path $ffmpegDir -ItemType Directory | Out-Null
}

if (-not (Test-Path "$ffmpegDir\ffmpeg.exe")) {
    try {
        $ffmpegUrl = "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"
        $ffmpegZip = "$env:TEMP\ffmpeg.zip"
        
        Write-Host "Downloading FFmpeg..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $ffmpegUrl -OutFile $ffmpegZip -UseBasicParsing
        
        Write-Host "Extracting FFmpeg..." -ForegroundColor Yellow
        Expand-Archive -Path $ffmpegZip -DestinationPath "$env:TEMP\ffmpeg-extract" -Force
        
        # Find ffmpeg folder and copy binaries
        $ffmpegFolder = Get-ChildItem "$env:TEMP\ffmpeg-extract" -Directory | Where-Object { $_.Name -like "ffmpeg-*" } | Select-Object -First 1
        if ($ffmpegFolder) {
            Copy-Item "$($ffmpegFolder.FullName)\bin\ffmpeg.exe" $ffmpegDir
            Copy-Item "$($ffmpegFolder.FullName)\bin\ffprobe.exe" $ffmpegDir
        }
        
        # Clean up
        Remove-Item $ffmpegZip -Force -ErrorAction SilentlyContinue
        Remove-Item "$env:TEMP\ffmpeg-extract" -Recurse -Force -ErrorAction SilentlyContinue
        
        Write-Host "✓ FFmpeg installed successfully!" -ForegroundColor Green
    } catch {
        Write-Host "⚠ Could not install FFmpeg automatically. Some features may be limited." -ForegroundColor Yellow
    }
}

# Create launcher script
Write-Host "Creating application launcher..." -ForegroundColor Yellow
$launcherContent = @"
@echo off
title Video Downloader
cd /d "%~dp0"
set PATH=%cd%\ffmpeg;%PATH%
call venv\Scripts\activate.bat
python video_downloader.py
pause
"@

Set-Content -Path "$InstallPath\VideoDownloader.bat" -Value $launcherContent

# Create desktop shortcut
Write-Host "Creating desktop shortcut..." -ForegroundColor Yellow
try {
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\Video Downloader.lnk")
    $Shortcut.TargetPath = "$InstallPath\VideoDownloader.bat"
    $Shortcut.WorkingDirectory = $InstallPath
    $Shortcut.IconLocation = "shell32.dll,16"
    $Shortcut.Description = "Video Downloader - Download videos in best quality"
    $Shortcut.Save()
    Write-Host "✓ Desktop shortcut created!" -ForegroundColor Green
} catch {
    Write-Host "⚠ Could not create desktop shortcut" -ForegroundColor Yellow
}

# Create start menu shortcut
Write-Host "Creating start menu entry..." -ForegroundColor Yellow
try {
    $StartMenuPath = "$env:PROGRAMDATA\Microsoft\Windows\Start Menu\Programs"
    if (-not (Test-Path "$StartMenuPath\Video Downloader")) {
        New-Item -Path "$StartMenuPath\Video Downloader" -ItemType Directory -Force | Out-Null
    }
    
    $Shortcut = $WshShell.CreateShortcut("$StartMenuPath\Video Downloader\Video Downloader.lnk")
    $Shortcut.TargetPath = "$InstallPath\VideoDownloader.bat"
    $Shortcut.WorkingDirectory = $InstallPath
    $Shortcut.IconLocation = "shell32.dll,16"
    $Shortcut.Description = "Video Downloader - Download videos in best quality"
    $Shortcut.Save()
    Write-Host "✓ Start menu entry created!" -ForegroundColor Green
} catch {
    Write-Host "⚠ Could not create start menu entry" -ForegroundColor Yellow
}

Write-Host
Write-Host "======================================" -ForegroundColor Green
Write-Host "     Installation Complete!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host
Write-Host "Video Downloader has been installed to:" -ForegroundColor White
Write-Host $InstallPath -ForegroundColor Cyan
Write-Host
Write-Host "You can now:" -ForegroundColor White
Write-Host "• Double-click the desktop shortcut 'Video Downloader'" -ForegroundColor Yellow
Write-Host "• Find it in the Start Menu under 'Video Downloader'" -ForegroundColor Yellow
Write-Host "• Run $InstallPath\VideoDownloader.bat directly" -ForegroundColor Yellow
Write-Host
Write-Host "Features:" -ForegroundColor White
Write-Host "• Download videos in best quality (4K, 8K if available)" -ForegroundColor Green
Write-Host "• Extract audio only as MP3" -ForegroundColor Green
Write-Host "• Choose specific resolutions (720p, 480p)" -ForegroundColor Green
Write-Host "• Progress tracking and download history" -ForegroundColor Green
Write-Host
Read-Host "Press Enter to exit installer"