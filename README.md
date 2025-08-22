# Video Downloader

A simple desktop application for downloading videos using yt-dlp.

## Features

- Download videos from various platforms
- Choose video quality (Best, 720p, 480p, or Audio only)
- Select download location
- Progress bar with download speed
- Download history log

## Installation

1. Install Python 3 and tkinter:
```bash
sudo apt-get install python3 python3-tk
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

## Usage

Run the application:
```bash
python3 video_downloader.py
```

1. Paste the video URL
2. Select download location (default: ~/Downloads)
3. Choose quality
4. Click Download

## Requirements

- Python 3.6+
- tkinter
- yt-dlp