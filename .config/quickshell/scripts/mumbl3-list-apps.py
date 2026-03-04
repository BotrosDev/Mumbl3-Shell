#!/usr/bin/env python3
import os
import glob
import sqlite3

DB_FILE = os.path.expanduser("~/.config/quickshell/launch-counts.db")

dirs = [
    "/usr/share/applications",
    os.path.join(os.environ.get("XDG_DATA_HOME", os.path.expanduser("~/.local/share")), "applications")
]

def load_counts():
    con = sqlite3.connect(DB_FILE)
    con.execute("CREATE TABLE IF NOT EXISTS counts (name TEXT PRIMARY KEY, count INTEGER DEFAULT 0)")
    con.commit()
    rows = con.execute("SELECT name, count FROM counts").fetchall()
    con.close()
    return dict(rows)

def find_icon(name):
    if not name:
        return ""
    IMAGE_EXTS = (".png", ".svg", ".xpm", ".jpg", ".jpeg")
    if os.path.isfile(name) and name.lower().endswith(IMAGE_EXTS):
        return name
    for size in ["256x256", "128x128", "64x64", "48x48", "scalable"]:
        for theme_dir in ["/usr/share/icons/hicolor", "/usr/share/icons/Papirus", "/usr/share/icons"]:
            for ext in ["png", "svg", "xpm"]:
                p = os.path.join(theme_dir, size, "apps", f"{name}.{ext}")
                if os.path.isfile(p):
                    return p
    for ext in ["png", "svg", "xpm"]:
        p = f"/usr/share/pixmaps/{name}.{ext}"
        if os.path.isfile(p):
            return p
    return ""

counts = load_counts()
results = []

for d in dirs:
    if not os.path.isdir(d):
        continue
    for f in glob.glob(os.path.join(d, "*.desktop")):
        name = exec_ = icon_name = ""
        in_desktop_entry = False
        try:
            with open(f, encoding="utf-8", errors="ignore") as fh:
                for line in fh:
                    line = line.strip()
                    if line == "[Desktop Entry]":
                        in_desktop_entry = True
                        continue
                    if line.startswith("[") and line.endswith("]"):
                        in_desktop_entry = False
                        continue
                    if not in_desktop_entry:
                        continue
                    if line.startswith("Name=") and not name:
                        name = line[5:]
                    elif line.startswith("Exec=") and not exec_:
                        exec_ = line[5:]
                        for token in ["%f","%F","%u","%U","%d","%D","%n","%N","%i","%c","%k","%v","%m"]:
                            exec_ = exec_.replace(token, "")
                        exec_ = exec_.strip()
                        if "=" in exec_:
                            exec_ = ""
                    elif line.startswith("Icon=") and not icon_name:
                        icon_name = line[5:]
        except:
            continue
        if name and exec_:
            results.append((name, exec_, find_icon(icon_name), counts.get(name, 0)))

# Sort by count descending, then alphabetically for ties
results.sort(key=lambda x: (-x[3], x[0].lower()))

for name, exec_, icon, count in results:
    print(f"{name}|{exec_}|{icon}|{count}")