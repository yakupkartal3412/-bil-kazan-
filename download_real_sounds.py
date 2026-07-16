import urllib.request
import os

urls = {
    "correct.mp3": "https://raw.githubusercontent.com/virkt25/Who_Wants_To_Be_A_Millionaire/master/audio/Correct.mp3",
    "wrong.mp3": "https://raw.githubusercontent.com/virkt25/Who_Wants_To_Be_A_Millionaire/master/audio/Wrong.mp3",
    "background_music.mp3": "https://raw.githubusercontent.com/virkt25/Who_Wants_To_Be_A_Millionaire/master/audio/Background.mp3",
    "suspense.mp3": "https://raw.githubusercontent.com/virkt25/Who_Wants_To_Be_A_Millionaire/master/audio/Suspense.mp3",
    "walk_away.mp3": "https://raw.githubusercontent.com/virkt25/Who_Wants_To_Be_A_Millionaire/master/audio/TotalWinning.mp3"
}

os.makedirs('assets/sounds', exist_ok=True)

for filename, url in urls.items():
    try:
        print(f"Downloading {filename}...")
        urllib.request.urlretrieve(url, f"assets/sounds/{filename}")
        print(f"Success: {filename}")
    except Exception as e:
        print(f"Failed to download {filename}: {e}")
        
        # Fallback to another known repo if the first fails
        try:
            fallback_url = f"https://raw.githubusercontent.com/Nenad2626/Who-Wants-to-Be-a-Millionaire/master/sound/{filename.split('.')[0]}.mp3"
            urllib.request.urlretrieve(fallback_url, f"assets/sounds/{filename}")
            print(f"Success via fallback: {filename}")
        except Exception as e2:
            print(f"Fallback failed too: {e2}")
