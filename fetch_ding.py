import urllib.request
import json
import os

opener = urllib.request.build_opener()
opener.addheaders = [('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)')]
urllib.request.install_opener(opener)

def search_and_download(keyword, filename):
    url = f"https://commons.wikimedia.org/w/api.php?action=query&list=search&srsearch={urllib.parse.quote(keyword)}&srnamespace=6&format=json"
    req = urllib.request.Request(url)
    res = urllib.request.urlopen(req).read().decode('utf-8')
    data = json.loads(res)
    
    for item in data['query']['search']:
        title = item['title'].replace(' ', '_')
        if title.lower().endswith(('.wav', '.mp3')):
            file_url_api = f"https://commons.wikimedia.org/w/api.php?action=query&titles={urllib.parse.quote(title)}&prop=imageinfo&iiprop=url&format=json"
            f_res = urllib.request.urlopen(urllib.request.Request(file_url_api)).read().decode('utf-8')
            f_data = json.loads(f_res)
            pages = f_data['query']['pages']
            page_id = list(pages.keys())[0]
            if 'imageinfo' in pages[page_id]:
                file_url = pages[page_id]['imageinfo'][0]['url']
                print(f"Downloading {title} from {file_url} as {filename}")
                urllib.request.urlretrieve(file_url, f"assets/sounds/{filename}")
                return True
    return False

search_and_download('ding sound .wav', 'correct.wav')
