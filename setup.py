"""
Setup script for creating Windows executable of Video Downloader
This will create a standalone .exe file that includes all dependencies
"""

from setuptools import setup
import py2exe
import sys
import os

# Add current directory to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# Data files to include (like ffmpeg if available)
data_files = []

# Check if ffmpeg folder exists and include it
if os.path.exists('ffmpeg'):
    ffmpeg_files = []
    for root, dirs, files in os.walk('ffmpeg'):
        for file in files:
            if file.endswith(('.exe', '.dll')):
                ffmpeg_files.append(os.path.join(root, file))
    if ffmpeg_files:
        data_files.append(('ffmpeg', ffmpeg_files))

# PyInstaller setup (alternative to py2exe)
setup_pyinstaller = {
    'name': 'Video Downloader',
    'version': '1.0.0',
    'description': 'Download videos in best quality with yt-dlp',
    'author': 'Your Name',
    'author_email': 'your.email@example.com',
    'py_modules': ['video_downloader'],
    'install_requires': [
        'yt-dlp>=2024.1.0',
    ],
    'data_files': data_files,
}

# py2exe specific setup
setup_py2exe = {
    'console': ['video_downloader.py'],
    'options': {
        'py2exe': {
            'includes': ['tkinter', 'tkinter.ttk', 'tkinter.filedialog', 'tkinter.messagebox'],
            'packages': ['yt_dlp'],
            'bundle_files': 1,
            'compressed': True,
            'optimize': 2,
        }
    },
    'zipfile': None,
    'data_files': data_files,
}

if __name__ == '__main__':
    # Use py2exe if available, otherwise use standard setup
    try:
        import py2exe
        setup(**{**setup_pyinstaller, **setup_py2exe})
        print("\nExecutable created using py2exe!")
        print("You can find the .exe file in the 'dist' folder.")
    except ImportError:
        setup(**setup_pyinstaller)
        print("\nSetup completed!")
        print("To create executable, install PyInstaller and run:")
        print("pip install pyinstaller")
        print("pyinstaller --onefile --windowed --add-data 'ffmpeg;ffmpeg' video_downloader.py")