import urllib.request
import os

urls = {
    "correct.wav": "https://raw.githubusercontent.com/Calinou/godot-kenney-ui-audio/master/confirmation_001.wav",
    "wrong.wav": "https://raw.githubusercontent.com/Calinou/godot-kenney-ui-audio/master/error_001.wav",
    "walk_away.wav": "https://raw.githubusercontent.com/Calinou/godot-kenney-ui-audio/master/maximize_001.wav"
}

os.makedirs('assets/sounds', exist_ok=True)

for filename, url in urls.items():
    print(f"Downloading {filename}...")
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response, open(f"assets/sounds/{filename}", 'wb') as out_file:
            data = response.read()
            out_file.write(data)
        print(f"Success: {filename}")
    except Exception as e:
        print(f"Failed: {filename} -> {e}")
