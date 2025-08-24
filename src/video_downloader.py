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
        
        # URL input
        ttk.Label(main_frame, text="Video URL:", font=('Arial', 10)).grid(row=0, column=0, sticky=tk.W, pady=5)
        self.url_entry = ttk.Entry(main_frame, width=50)
        self.url_entry.grid(row=1, column=0, columnspan=2, pady=5, sticky=(tk.W, tk.E))
        
        # Download path
        ttk.Label(main_frame, text="Download Path:", font=('Arial', 10)).grid(row=2, column=0, sticky=tk.W, pady=5)
        path_frame = ttk.Frame(main_frame)
        path_frame.grid(row=3, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=5)
        
        self.path_label = ttk.Label(path_frame, text=self.download_path, relief="sunken", padding=5)
        self.path_label.pack(side=tk.LEFT, fill=tk.X, expand=True)
        ttk.Button(path_frame, text="Browse", command=self.select_folder).pack(side=tk.RIGHT, padx=(5, 0))
        
        # Quality selection
        ttk.Label(main_frame, text="Quality:", font=('Arial', 10)).grid(row=4, column=0, sticky=tk.W, pady=5)
        self.quality_var = tk.StringVar(value="best")
        quality_frame = ttk.Frame(main_frame)
        quality_frame.grid(row=5, column=0, columnspan=2, sticky=tk.W, pady=5)
        
        for text, value in [("Best", "best"), ("1080p", "1080"), ("720p", "720"), ("480p", "480"), ("Audio Only", "audio")]:
            ttk.Radiobutton(quality_frame, text=text, variable=self.quality_var, value=value).pack(side=tk.LEFT, padx=5)
        
        # HDR option
        self.avoid_hdr_var = tk.BooleanVar(value=True)
        hdr_checkbox = ttk.Checkbutton(main_frame, text="Avoid HDR (recommended for standard displays)", 
                                       variable=self.avoid_hdr_var)
        hdr_checkbox.grid(row=5, column=1, sticky=tk.W, padx=(20, 0), pady=5)
        
        # Buttons
        button_frame = ttk.Frame(main_frame)
        button_frame.grid(row=6, column=0, columnspan=2, pady=20)
        self.download_btn = ttk.Button(button_frame, text="Download", command=self.start_download)
        self.download_btn.pack(side=tk.LEFT, padx=5)
        ttk.Button(button_frame, text="Clear", command=self.clear_fields).pack(side=tk.LEFT, padx=5)
        
        # Progress
        ttk.Label(main_frame, text="Progress:", font=('Arial', 10)).grid(row=7, column=0, sticky=tk.W, pady=5)
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
        
        # Add right-click context menus
        self.setup_context_menus()
        
        # Configure grid weights
        main_frame.columnconfigure(0, weight=1)
        self.root.columnconfigure(0, weight=1)
        self.root.rowconfigure(0, weight=1)
        
    def setup_context_menus(self):
        """Setup right-click context menus for URL entry and log text"""
        # Context menu for URL entry
        self.url_menu = tk.Menu(self.root, tearoff=0)
        self.url_menu.add_command(label="Cut", command=lambda: self.url_entry.event_generate("<<Cut>>"))
        self.url_menu.add_command(label="Copy", command=lambda: self.url_entry.event_generate("<<Copy>>"))
        self.url_menu.add_command(label="Paste", command=lambda: self.url_entry.event_generate("<<Paste>>"))
        self.url_menu.add_separator()
        self.url_menu.add_command(label="Select All", command=lambda: self.url_entry.select_range(0, tk.END))
        
        # Context menu for log text
        self.log_menu = tk.Menu(self.root, tearoff=0)
        self.log_menu.add_command(label="Copy", command=lambda: self.log_text.event_generate("<<Copy>>"))
        self.log_menu.add_separator()
        self.log_menu.add_command(label="Select All", command=lambda: self.log_text.tag_add(tk.SEL, "1.0", tk.END))
        
        # Bind right-click events
        self.url_entry.bind("<Button-3>", self.show_url_context_menu)
        self.log_text.bind("<Button-3>", self.show_log_context_menu)
        
    def show_url_context_menu(self, event):
        """Show context menu for URL entry"""
        try:
            self.url_menu.tk_popup(event.x_root, event.y_root)
        finally:
            self.url_menu.grab_release()
            
    def show_log_context_menu(self, event):
        """Show context menu for log text"""
        try:
            self.log_menu.tk_popup(event.x_root, event.y_root)
        finally:
            self.log_menu.grab_release()
        
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
        self.log_text.insert(tk.END, f"{message}\n")
        self.log_text.see(tk.END)
        
    def progress_hook(self, d):
        status = d.get('status')
        
        if status == 'downloading':
            total = d.get('total_bytes') or d.get('total_bytes_estimate', 1)
            downloaded = d.get('downloaded_bytes', 0)
            percent = (downloaded * 100.0 / total) if total else 0
            self.progress_var.set(percent)
            
            if speed := d.get('speed'):
                speed_mb = speed / (1024 * 1024)
                self.status_label.config(text=f"Downloading... {percent:.1f}% ({speed_mb:.1f} MB/s)")
                
        elif status == 'finished':
            self.progress_var.set(100)
            self.status_label.config(text="Download completed!", foreground="green")
            self.log_message("Download finished, processing...")
            
    def get_unique_filename(self, base_path, title, quality_suffix, ext):
        """Generate unique filename with numbering if file exists"""
        filename = f"{title}{quality_suffix}.{ext}"
        full_path = os.path.join(base_path, filename)
        
        if not os.path.exists(full_path):
            return filename
            
        # File exists, add numbering
        counter = 1
        while True:
            filename = f"{title}{quality_suffix}({counter}).{ext}"
            full_path = os.path.join(base_path, filename)
            if not os.path.exists(full_path):
                return filename
            counter += 1

    def download_video(self):
        url = self.url_entry.get().strip()
        if not url:
            messagebox.showerror("Error", "Please enter a video URL")
            return
            
        try:
            quality = self.quality_var.get()
            avoid_hdr = self.avoid_hdr_var.get()
            
            # HDR filter - excludes HDR codecs that cause brightness issues
            hdr_filter = "[vcodec!*=av01][vcodec!*=vp9.2]" if avoid_hdr else ""
            
            # Format mapping with HDR consideration
            if avoid_hdr:
                formats = {
                    "audio": ("bestaudio/best", {"postprocessors": [{'key': 'FFmpegExtractAudio', 'preferredcodec': 'mp3'}]}),
                    "best": (f"bestvideo{hdr_filter}+bestaudio/best", {}),
                    "1080": (f"bestvideo[height<=1080]{hdr_filter}+bestaudio/best[height<=1080]", {}),
                    "720": (f"bestvideo[height<=720]{hdr_filter}+bestaudio/best[height<=720]", {}),
                    "480": (f"bestvideo[height<=480]{hdr_filter}+bestaudio/best[height<=480]", {})
                }
            else:
                formats = {
                    "audio": ("bestaudio/best", {"postprocessors": [{'key': 'FFmpegExtractAudio', 'preferredcodec': 'mp3'}]}),
                    "best": ("bestvideo+bestaudio/best", {}),
                    "1080": ("bestvideo[height<=1080]+bestaudio/best[height<=1080]", {}),
                    "720": ("bestvideo[height<=720]+bestaudio/best[height<=720]", {}),
                    "480": ("bestvideo[height<=480]+bestaudio/best[height<=480]", {})
                }
            
            format_opt, extra_opts = formats.get(quality, ("best", {}))
            
            # Create quality suffix for filename
            quality_suffix = {
                "best": "_best",
                "1080": "_1080p",
                "720": "_720p", 
                "480": "_480p",
                "audio": "_audio"
            }.get(quality, f"_{quality}")
            
            hdr_status = "SDR (avoid HDR)" if avoid_hdr else "Best available (may include HDR)"
            self.log_message(f"Starting download: {url} (Quality: {quality}, {hdr_status})")
            
            # Get video info first to determine filename
            with yt_dlp.YoutubeDL({'quiet': True}) as ydl:
                info = ydl.extract_info(url, download=False)
                title = info.get('title', 'Unknown')
                
                # Clean title for filename
                import re
                clean_title = re.sub(r'[<>:"/\\|?*]', '_', title)
                
                # Determine extension based on quality
                if quality == 'audio':
                    ext = 'mp3'
                else:
                    ext = info.get('ext', 'mp4')
                
                # Get unique filename
                unique_filename = self.get_unique_filename(self.download_path, clean_title, quality_suffix, ext)
                
                self.log_message(f"Title: {title}")
                self.log_message(f"Filename: {unique_filename}")
            
            # Update yt-dlp options with unique filename
            ydl_opts = {
                'format': format_opt,
                'outtmpl': os.path.join(self.download_path, unique_filename),
                'progress_hooks': [self.progress_hook],
                'quiet': True,
                'no_warnings': True,
                'nooverwrites': False,  # Allow re-download
                **extra_opts
            }
                
            # Download with unique filename
            with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                ydl.download([url])
                
            self.log_message("Download completed successfully!")
            messagebox.showinfo("Success", f"Video downloaded as: {unique_filename}")
            
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