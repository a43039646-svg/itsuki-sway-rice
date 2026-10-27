#!/usr/bin/env python3
"""Choose a Wi-Fi network with Fuzzel and connect via NetworkManager."""
import subprocess

def split_nmcli(line):
    fields=[]; current=[]; escaped=False
    for char in line:
        if escaped: current.append(char); escaped=False
        elif char == "\\": escaped=True
        elif char == ":": fields.append("".join(current)); current=[]
        else: current.append(char)
    if escaped: current.append("\\")
    fields.append("".join(current)); return fields

def notify(message): subprocess.run(["notify-send","Itsuki Wi-Fi",message],check=False)
try:
    result=subprocess.run(["nmcli","-t","-f","SSID,SIGNAL,SECURITY","device","wifi","list","--rescan","yes"],check=True,capture_output=True,text=True,timeout=20)
except Exception as exc: notify(f"Couldn't scan Wi-Fi networks: {exc}"); raise SystemExit(1)
entries=[]; seen=set()
for line in result.stdout.splitlines():
    fields=split_nmcli(line)
    if len(fields)<3: continue
    ssid,signal,security=(field.strip() for field in fields[:3])
    if not ssid: continue
    label=f"{ssid}  ·  {signal or '?'}%  ·  {security or 'Open'}"
    if label not in seen: entries.append((label,ssid)); seen.add(label)
if not entries: notify("No visible Wi-Fi networks were found."); raise SystemExit(0)
try:
    picked=subprocess.run(["fuzzel","--dmenu","--prompt","Wi-Fi > "],input="\n".join(label for label,_ in entries)+"\n",capture_output=True,text=True,check=False).stdout.strip()
except FileNotFoundError: notify("Fuzzel was not found."); raise SystemExit(1)
if not picked: raise SystemExit(0)
ssid=next((ssid for label,ssid in entries if label==picked),picked.split("  ·  ",1)[0])
command='nmcli --ask device wifi connect "$1"; status=$?; echo; if [ "$status" -eq 0 ]; then echo "Connected."; else echo "Connection failed."; fi; printf "\\nPress Enter to close this window... "; read -r _; exit "$status"'
try: subprocess.Popen(["kitty","--title","Connect to Wi-Fi","sh","-c",command,"wifi-connect",ssid])
except FileNotFoundError: notify("Kitty was not found; cannot prompt for a Wi-Fi password."); raise SystemExit(1)
