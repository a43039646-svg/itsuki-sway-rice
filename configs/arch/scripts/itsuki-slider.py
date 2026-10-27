#!/usr/bin/env python3
"""Small dark-pink slider window for brightness or PipeWire volume."""
import re
import subprocess
import sys
import tkinter as tk
from tkinter import messagebox

BG = "#0c1529"
PANEL = "#15233b"
PINK = "#5caeff"
PINK_LIGHT = "#a5d8ff"
TEXT = "#edf5ff"
TRACK = "#233b5b"
mode = sys.argv[1] if len(sys.argv) > 1 else "volume"
if mode not in {"brightness", "volume"}:
    raise SystemExit("Usage: itsuki-slider.py brightness|volume")
def run(args):
    return subprocess.run(args, check=True, capture_output=True, text=True).stdout.strip()
def current_value():
    if mode == "brightness":
        info = run(["brightnessctl", "-m", "-c", "backlight", "info"])
        return max(1, min(100, int(float(info.splitlines()[0].split(",")[-1].strip().rstrip("%")))) )
    info = run(["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"])
    match = re.search(r"Volume:\s*([0-9.]+)", info)
    if not match: raise RuntimeError("Couldn't read audio volume using wpctl.")
    return max(0, min(100, round(float(match.group(1))*100)))
try:
    initial = current_value()
except Exception as exc:
    root = tk.Tk(); root.withdraw(); messagebox.showerror("Itsuki Controls", str(exc)); root.destroy(); raise SystemExit(1)
root = tk.Tk()
title = "Screen brightness" if mode == "brightness" else "Sound volume"
icon = "☼" if mode == "brightness" else "♫"
root.title(f"Itsuki · {title}"); root.configure(bg=BG); root.resizable(False, False); root.attributes("-topmost", True)
frame=tk.Frame(root,bg=BG,padx=18,pady=14); frame.pack(fill="both",expand=True)
header=tk.Frame(frame,bg=BG); header.pack(fill="x")
tk.Label(header,text=f"{icon}  {title.upper()}",bg=BG,fg=PINK_LIGHT,font=("JetBrains Mono",11,"bold")).pack(side="left")
value_label=tk.Label(header,text=f"{initial}%",bg=BG,fg=TEXT,font=("JetBrains Mono",11,"bold")); value_label.pack(side="right")
scale=tk.Scale(frame,from_=1 if mode=="brightness" else 0,to=100,orient="horizontal",resolution=1,showvalue=False,length=350,width=14,sliderlength=20,bg=BG,fg=TEXT,troughcolor=TRACK,activebackground=PINK,highlightthickness=0,bd=0,relief="flat",sliderrelief="flat")
scale.set(initial); scale.pack(fill="x",pady=(10,9)); pending=None
def apply_value(value):
    global pending; pending=None
    try:
        number=max(1,min(100,int(value))) if mode=="brightness" else max(0,min(100,int(value)))
        if mode=="brightness": subprocess.run(["brightnessctl","-c","backlight","set",f"{number}%"],check=True,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
        else: subprocess.run(["wpctl","set-volume","@DEFAULT_AUDIO_SINK@",f"{number/100:.2f}"],check=True,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
    except Exception as exc: value_label.configure(text="Error"); print(f"Itsuki control error: {exc}",file=sys.stderr)
def changed(raw):
    global pending; value=int(float(raw)); value_label.configure(text=f"{value}%")
    if pending is not None: root.after_cancel(pending)
    pending=root.after(100,lambda v=value:apply_value(v))
scale.configure(command=changed)
buttons=tk.Frame(frame,bg=BG); buttons.pack(fill="x",pady=(1,0))
if mode=="volume":
    def toggle_mute(): subprocess.run(["wpctl","set-mute","@DEFAULT_AUDIO_SINK@","toggle"],check=False)
    tk.Button(buttons,text="Mute / unmute",command=toggle_mute,bg=PANEL,fg=PINK_LIGHT,activebackground="#233b5b",activeforeground=TEXT,relief="flat",bd=0,padx=12,pady=5,cursor="hand2",font=("JetBrains Mono",9)).pack(side="left")
tk.Button(buttons,text="Done",command=root.destroy,bg=PINK,fg="#ffffff",activebackground="#80c4ff",activeforeground="#ffffff",relief="flat",bd=0,padx=18,pady=5,cursor="hand2",font=("JetBrains Mono",9,"bold")).pack(side="right")
root.bind("<Escape>",lambda _event:root.destroy()); root.bind("<Return>",lambda _event:root.destroy()); root.update_idletasks()
width,height=410,(155 if mode=="volume" else 125); root.geometry(f"{width}x{height}+{max(0,(root.winfo_screenwidth()-width)//2)}+{max(0,(root.winfo_screenheight()-height)//2)}")
root.mainloop()
