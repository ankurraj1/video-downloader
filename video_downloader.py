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
                "best": ("best", {}),
                "720": ("best[height<=720]", {}),
                "480": ("best[height<=480]", {})
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