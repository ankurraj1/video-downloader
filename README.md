# Video Downloader

A simple desktop application for downloading videos using yt-dlp.

## Features

- Download videos from various platforms
- Choose video quality (Best, 720p, 480p, or Audio only)
- Select download location
- Progress bar with download speed
- Download history log

## Installation

1. Install Python 3 and required packages:
```bash
sudo apt-get install python3 python3-tk python3-venv python3-pip python3-full
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

1. Activate the virtual environment:
```bash
source venv/bin/activate
```

2. Run the application:
```bash
python3 video_downloader.py
```

3. Using the app:
   - Paste the video URL
   - Select download location (default: ~/Downloads)
   - Choose quality
   - Click Download

## Requirements

- Python 3.6+
- tkinter
- yt-dlp