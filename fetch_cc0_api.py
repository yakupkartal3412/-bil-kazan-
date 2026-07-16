import urllib.request
import json
import os

opener = urllib.request.build_opener()
opener.addheaders = [('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)')]
urllib.request.install_opener(opener)

def download_file(title, out_name):
    file_url_api = f"https://commons.wikimedia.org/w/api.php?action=query&titles={urllib.parse.quote('File:' + title)}&prop=imageinfo&iiprop=url&format=json"
    req = urllib.request.Request(file_url_api, headers={'User-Agent': 'Mozilla/5.0'})
    res = urllib.request.urlopen(req).read().decode('utf-8')
    data = json.loads(res)
    pages = data['query']['pages']
    page_id = list(pages.keys())[0]
    if 'imageinfo' in pages[page_id]:
        url = pages[page_id]['imageinfo'][0]['url']
        print(f"Downloading {title}...")
        urllib.request.urlretrieve(url, f"assets/sounds/{out_name}")
        print("Success!")
    else:
        print(f"Could not find {title}")

os.makedirs('assets/sounds', exist_ok=True)
download_file('Glass_Ping.wav', 'correct.wav')
download_file('Buzzer.wav', 'wrong.wav')
