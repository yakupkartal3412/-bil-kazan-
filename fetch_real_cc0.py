import urllib.request
import os

opener = urllib.request.build_opener()
opener.addheaders = [('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)')]
urllib.request.install_opener(opener)

os.makedirs('assets/sounds', exist_ok=True)

try:
    print("Doğru cevabın sesi (Glass Ping) indiriliyor...")
    urllib.request.urlretrieve("https://upload.wikimedia.org/wikipedia/commons/1/17/Glass_Ping.wav", "assets/sounds/correct.wav")
    print("Yanlış cevabın sesi (Buzzer) indiriliyor...")
    urllib.request.urlretrieve("https://upload.wikimedia.org/wikipedia/commons/5/55/Buzzer.wav", "assets/sounds/wrong.wav")
    print("Bütün profesyonel CC0 sesler başarıyla indirildi!")
except Exception as e:
    print("Hata:", e)
