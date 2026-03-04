#!/usr/bin/env python3
import sys
import os
import sqlite3

DB_FILE = os.path.expanduser("~/.config/quickshell/launch-counts.db")

if len(sys.argv) < 2:
    sys.exit(1)

name = sys.argv[1]

con = sqlite3.connect(DB_FILE)
con.execute("CREATE TABLE IF NOT EXISTS counts (name TEXT PRIMARY KEY, count INTEGER DEFAULT 0)")
con.execute(
    "INSERT INTO counts (name, count) VALUES (?, 1) ON CONFLICT(name) DO UPDATE SET count = count + 1",
    (name,)
)
con.commit()
con.close()