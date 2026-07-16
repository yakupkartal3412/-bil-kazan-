import urllib.request
import json
import os

def download_from_commons(keyword, filename):
    url = f"https://commons.wikimedia.org/w/api.php?action=query&list=search&srsearch={urllib.parse.quote(keyword)}&srnamespace=6&format=json"
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    response = urllib.request.urlopen(req).read().decode('utf-8')
    data = json.loads(response)
    
    for item in data['query']['search']:
        title = item['title'].replace(' ', '_')
        if title.lower().endswith('.wav') or title.lower().endswith('.ogg'):
            file_url_api = f"https://commons.wikimedia.org/w/api.php?action=query&titles={urllib.parse.quote(title)}&prop=imageinfo&iiprop=url&format=json"
            f_req = urllib.request.Request(file_url_api, headers={'User-Agent': 'Mozilla/5.0'})
            f_res = urllib.request.urlopen(f_req).read().decode('utf-8')
            f_data = json.loads(f_res)
            pages = f_data['query']['pages']
            page_id = list(pages.keys())[0]
            if 'imageinfo' in pages[page_id]:
                file_url = pages[page_id]['imageinfo'][0]['url']
                print(f"Downloading {title} from {file_url} as {filename}")
                urllib.request.urlretrieve(file_url, f"assets/sounds/{filename}")
                return True
    return False

os.makedirs('assets/sounds', exist_ok=True)
download_from_commons('ding sound', 'correct.wav')
download_from_commons('buzzer sound', 'wrong.wav')
download_from_commons('harp sound', 'walk_away.wav')
print("Başarıyla CC0 sesleri indirildi!")
