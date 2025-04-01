#!/usr/bin/python3

import json
import os
import shutil
import subprocess

with open('info.json') as f:
  j = json.load(f)

version = j['version']

targetdir = f'RecipeExporter_{version}';

os.mkdir(targetdir)

for f in ['control.lua', 'info.json', 'json.lua']:
  shutil.copy2(f, targetdir)

subprocess.run(['zip', '-9r', '--to-crlf', f'{targetdir}.zip',  targetdir],
               check=True)
