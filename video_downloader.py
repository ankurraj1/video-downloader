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
        
    def setup_ui(self):
        main_frame = ttk.Frame(self.root, padding="10")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        ttk.Label(main_frame, text="Video URL:", font=('Arial', 10)).grid(row=0, column=0, sticky=tk.W, pady=5)
        
        self.url_entry = ttk.Entry(main_frame, width=50)
        self.url_entry.grid(row=1, column=0, columnspan=2, pady=5, sticky=(tk.W, tk.E))
        
        ttk.Label(main_frame, text="Download Path:", font=('Arial', 10)).grid(row=2, column=0, sticky=tk.W, pady=5)
        
        path_frame = ttk.Frame(main_frame)
        path_frame.grid(row=3, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=5)
        
        self.path_label = ttk.Label(path_frame, text=self.download_path, relief="sunken", padding=5)
        self.path_label.pack(side=tk.LEFT, fill=tk.X, expand=True)
        
        ttk.Button(path_frame, text="Browse", command=self.select_folder).pack(side=tk.RIGHT, padx=(5, 0))
        
        ttk.Label(main_frame, text="Quality:", font=('Arial', 10)).grid(row=4, column=0, sticky=tk.W, pady=5)
        
        self.quality_var = tk.StringVar(value="best")
        quality_frame = ttk.Frame(main_frame)
        quality_frame.grid(row=5, column=0, columnspan=2, sticky=tk.W, pady=5)
        
        ttk.Radiobutton(quality_frame, text="Best", variable=self.quality_var, value="best").pack(side=tk.LEFT, padx=5)
        ttk.Radiobutton(quality_frame, text="720p", variable=self.quality_var, value="720").pack(side=tk.LEFT, padx=5)
        ttk.Radiobutton(quality_frame, text="480p", variable=self.quality_var, value="480").pack(side=tk.LEFT, padx=5)
        ttk.Radiobutton(quality_frame, text="Audio Only", variable=self.quality_var, value="audio").pack(side=tk.LEFT, padx=5)
        
        button_frame = ttk.Frame(main_frame)
        button_frame.grid(row=6, column=0, columnspan=2, pady=20)
        
        self.download_btn = ttk.Button(button_frame, text="Download", command=self.start_download)
        self.download_btn.pack(side=tk.LEFT, padx=5)
        
        ttk.Button(button_frame, text="Clear", command=self.clear_fields).pack(side=tk.LEFT, padx=5)
        
        ttk.Label(main_frame, text="Progress:", font=('Arial', 10)).grid(row=7, column=0, sticky=tk.W, pady=5)
        
        self.progress_var = tk.DoubleVar()
        self.progress_bar = ttk.Progressbar(main_frame, variable=self.progress_var, maximum=100)
        self.progress_bar.grid(row=8, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=5)
        
        self.status_label = ttk.Label(main_frame, text="Ready to download", foreground="green")
        self.status_label.grid(row=9, column=0, columnspan=2, pady=5)
        
        self.log_text = tk.Text(main_frame, height=8, width=70)
        self.log_text.grid(row=10, column=0, columnspan=2, pady=10, sticky=(tk.W, tk.E))
        
        scrollbar = ttk.Scrollbar(main_frame, orient="vertical", command=self.log_text.yview)
        scrollbar.grid(row=10, column=2, sticky=(tk.N, tk.S), pady=10)
        self.log_text.configure(yscrollcommand=scrollbar.set)
        
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
            if d.get('total_bytes'):
                percent = d['downloaded_bytes'] * 100.0 / d['total_bytes']
            elif d.get('total_bytes_estimate'):
                percent = d['downloaded_bytes'] * 100.0 / d['total_bytes_estimate']
            else:
                percent = 0
                
            self.progress_var.set(percent)
            
            speed = d.get('speed', 0)
            if speed:
                speed_mb = speed / 1024 / 1024
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
            
            if quality == "audio":
                format_opt = 'bestaudio/best'
                ext = 'mp3'
            elif quality == "best":
                format_opt = 'best'
                ext = 'mp4'
            else:
                format_opt = f'best[height<={quality}]'
                ext = 'mp4'
                
            ydl_opts = {
                'format': format_opt,
                'outtmpl': os.path.join(self.download_path, '%(title)s.%(ext)s'),
                'progress_hooks': [self.progress_hook],
                'quiet': True,
                'no_warnings': True,
                'user_agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
                'referer': 'https://www.youtube.com/',
                'headers': {
                    'Accept-Language': 'en-US,en;q=0.5',
                },
                'extract_flat': False,
                'writethumbnail': False,
                'writeinfojson': False,
            }
            
            if quality == "audio":
                ydl_opts['postprocessors'] = [{
                    'key': 'FFmpegExtractAudio',
                    'preferredcodec': 'mp3',
                    'preferredquality': '192',
                }]
                
            self.log_message(f"Starting download from: {url}")
            self.log_message(f"Quality: {quality}")
            self.log_message(f"Saving to: {self.download_path}")
            
            with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                info = ydl.extract_info(url, download=False)
                title = info.get('title', 'Unknown')
                self.log_message(f"Video title: {title}")
                
                ydl.download([url])
                
            self.log_message("Download completed successfully!")
            messagebox.showinfo("Success", f"Video downloaded successfully!\nSaved to: {self.download_path}")
            
        except Exception as e:
            error_msg = str(e)
            self.status_label.config(text="Download failed!", foreground="red")
            self.log_message(f"Error: {error_msg}")
            messagebox.showerror("Download Error", f"Failed to download video:\n{error_msg}")
            
        finally:
            self.download_btn.config(state='normal')
            
    def start_download(self):
        self.download_btn.config(state='disabled')
        self.progress_var.set(0)
        self.status_label.config(text="Starting download...", foreground="blue")
        
        download_thread = threading.Thread(target=self.download_video, daemon=True)
        download_thread.start()


def main():
    root = tk.Tk()
    app = VideoDownloader(root)
    root.mainloop()


if __name__ == "__main__":
    main()