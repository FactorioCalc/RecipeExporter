#!/usr/bin/python3

import json
import os
import shutil
import subprocess

with open('info.json') as f:
  j = json.load(f)

version = j['version']

targetdir = f'RecipeExporter_{version}';
targetzip = f'{targetdir}.zip'

os.mkdir(targetdir)

for f in ['control.lua', 'info.json', 'json.lua']:
  shutil.copy2(f, targetdir)

try:
  os.remove(targetzip)
except FileNotFoundError:
  pass

subprocess.run(['zip', '-9r', '--to-crlf', targetzip, targetdir],
               check=True)

shutil.rmtree(targetdir)
