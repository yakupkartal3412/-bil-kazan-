import json
import random
import uuid

questions = []

def add_q(cat, text, correct, wrongs):
    q = {
        "id": str(uuid.uuid4()),
        "category": cat,
        "difficulty": random.randint(1, 3),
        "text": text,
        "options": [correct] + wrongs,
        "correctOptionIndex": 0
    }
    random.shuffle(q["options"])
    q["correctOptionIndex"] = q["options"].index(correct)
    questions.append(q)

# Cografya
capitals = {
    "Almanya": "Berlin", "Fransa": "Paris", "İtalya": "Roma", "İspanya": "Madrid", "Türkiye": "Ankara",
    "Japonya": "Tokyo", "Çin": "Pekin", "Rusya": "Moskova", "Brezilya": "Brasilia", "Arjantin": "Buenos Aires",
    "Meksika": "Meksiko", "Kanada": "Ottawa", "Avustralya": "Kanberra", "Güney Kore": "Seul", "Mısır": "Kahire",
    "Hindistan": "Yeni Delhi", "İngiltere": "Londra", "Yunanistan": "Atina", "İsveç": "Stokholm", "Norveç": "Oslo",
    "Finlandiya": "Helsinki", "Portekiz": "Lizbon", "Hollanda": "Amsterdam", "Belçika": "Brüksel", "Polonya": "Varşova",
    "Avusturya": "Viyana", "İsviçre": "Bern", "Macaristan": "Budapeşte", "Çekya": "Prag", "İrlanda": "Dublin",
    "Küba": "Havana", "Peru": "Lima", "Şili": "Santiago", "Kolombiya": "Bogota", "Venezuela": "Karakas",
    "Irak": "Bağdat", "İran": "Tahran", "Suriye": "Şam", "Suudi Arabistan": "Riyad", "Pakistan": "İslamabad",
    "Endonezya": "Cakarta", "Tayland": "Bangkok", "Malezya": "Kuala Lumpur", "Filipinler": "Manila", "Vietnam": "Hanoi"
}
all_cities = list(capitals.values())
cap_templates = [
    "{country} ülkesinin başkenti neresidir?",
    "Aşağıdaki şehirlerden hangisi {country}'nin başkentidir?",
    "{country}'ye seyahat eden biri, ülkenin başkenti olan hangi şehri ziyaret etmiş olur?",
    "Haritada {country} ülkesini inceliyorsanız, başkent olarak hangi şehri görürsünüz?",
    "{country}'nin siyasi merkezi olan başkenti hangisidir?"
]
for country, cap in capitals.items():
    wrongs = random.sample([c for c in all_cities if c != cap], 3)
    t = random.choice(cap_templates).replace("{country}", country)
    add_q("Coğrafya", t, cap, wrongs)

mountains = {"Everest": "Asya", "Kilimanjaro": "Afrika", "Elbrus": "Avrupa", "Aconcagua": "Güney Amerika", "Denali": "Kuzey Amerika"}
mnt_templates = [
    "{m} dağı hangi kıtada yer almaktadır?",
    "Dünyaca ünlü {m} dağına tırmanmak isteyen bir dağcı hangi kıtaya gitmelidir?",
    "Aşağıdaki kıtalardan hangisi {m} dağına ev sahipliği yapmaktadır?"
]
for m, c in mountains.items():
    wrongs = random.sample([x for x in mountains.values() if x != c] + ["Okyanusya", "Antarktika"], 3)
    t = random.choice(mnt_templates).replace("{m}", m)
    add_q("Coğrafya", t, c, wrongs)

# Tarih
sultans = {
    "Fatih Sultan Mehmet": "İstanbul'u fetheden",
    "Yavuz Sultan Selim": "Mısır'ı fethedip Halifeliği Osmanlı'ya getiren",
    "Kanuni Sultan Süleyman": "Osmanlı'nın en uzun süre tahtta kalan",
    "Orhan Gazi": "Bursa'yı fetheden",
    "Osman Gazi": "Osmanlı Devleti'nin kurucusu olan",
    "II. Abdülhamid": "33 yıl tahtta kalan ve Yıldız Sarayı'nı merkez yapan",
    "IV. Murat": "Bağdat Fatihi olarak bilinen",
    "Yıldırım Bayezid": "Niğbolu Savaşı'nı kazanan",
    "I. Süleyman": "Muhteşem unvanıyla bilinen",
    "III. Selim": "Nizam-ı Cedid yeniliklerini yapan",
    "II. Mahmut": "Yeniçeri Ocağı'nı kaldıran",
    "I. Ahmet": "Sultanahmet Camii'ni yaptıran",
    "I. Murat": "Kosova Savaşı'nda şehit düşen",
    "II. Selim": "Sarı lakabıyla bilinen",
    "III. Murat": "Osmanlı'nın en geniş sınırlarına ulaşmasını sağlayan padişahlardan biri olan",
    "Genç Osman (II. Osman)": "Yeniçeriler tarafından öldürülen ilk padişah olan"
}
all_sultans = list(sultans.keys())
sultan_templates = [
    "{desc} Osmanlı padişahı hangisidir?",
    "Osmanlı tarihinde {desc} hükümdar kimdir?",
    "Tarih kitaplarında {desc} kişi olarak bilinen padişah aşağıdakilerden hangisidir?",
    "Aşağıdaki padişahlardan hangisi {desc} özelliğiyle tarihe geçmiştir?"
]
for sultan, desc in sultans.items():
    wrongs = random.sample([s for s in all_sultans if s != sultan], 3)
    t = random.choice(sultan_templates).replace("{desc}", desc)
    add_q("Tarih", t, sultan, wrongs)

years = {
    "1071": "Malazgirt Meydan Muharebesi", "1453": "İstanbul'un Fethi", "1923": "Cumhuriyet'in İlanı", "1920": "TBMM'nin Açılışı",
    "1538": "Preveze Deniz Zaferi", "1526": "Mohaç Meydan Muharebesi", "1915": "Çanakkale Zaferi", "1919": "Mustafa Kemal'in Samsun'a çıkışı",
    "1048": "Pasinler Savaşı", "1176": "Miryokefalon Savaşı", "1299": "Osmanlı'nın Kuruluşu", "1922": "Saltanatın Kaldırılması",
    "1514": "Çaldıran Savaşı", "1522": "Rodos'un Fethi", "1924": "Halifeliğin Kaldırılması", "1877": "93 Harbi", "1914": "Birinci Dünya Savaşı'nın Başlaması"
}
all_years = list(years.keys())
year_templates = [
    "{event} hangi yılda gerçekleşmiştir?",
    "Tarihteki önemli olaylardan olan {event}, aşağıdaki yıllardan hangisinde meydana gelmiştir?",
    "Aşağıdaki tarihlerden hangisi {event} ile ilişkilidir?",
    "Tarih derslerinde sıkça geçen {event}, tam olarak hangi yıl olmuştur?"
]
for year, event in years.items():
    wrongs = [str(int(year) + random.choice([-10, -5, 5, 10, -1, 1, 2, -2])) for _ in range(3)]
    t = random.choice(year_templates).replace("{event}", event)
    add_q("Tarih", t, year, wrongs)

# Spor
world_cups = {
    "2022": "Arjantin", "2018": "Fransa", "2014": "Almanya", "2010": "İspanya",
    "2006": "İtalya", "2002": "Brezilya", "1998": "Fransa", "1994": "Brezilya",
    "1990": "Almanya", "1986": "Arjantin", "1982": "İtalya", "1978": "Arjantin"
}
all_countries = ["Arjantin", "Fransa", "Almanya", "İspanya", "İtalya", "Brezilya", "İngiltere", "Uruguay", "Hollanda", "Hırvatistan"]
for year, winner in world_cups.items():
    wrongs = random.sample([c for c in all_countries if c != winner], 3)
    add_q("Spor", f"{year} FIFA Dünya Kupası'nı hangi ülke kazanmıştır?", winner, wrongs)

sports_terms = {
    "Futbol": ["Korner", "Taç", "Ofsayt", "Penaltı", "Sarı Kart", "Asist", "Hat-trick", "Frikik"],
    "Basketbol": ["Ribaund", "Turnike", "Hatalı Yürüme", "Üçlük", "Blok", "Pota"],
    "Tenis": ["Tie-break", "Ace", "Backhand", "Forehand", "Set Sayısı", "Grand Slam"],
    "Voleybol": ["Manşet", "Smaç", "Servis", "Libero", "File"]
}
all_sports = list(sports_terms.keys())
for sport, terms in sports_terms.items():
    for term in terms:
        wrongs = random.sample([s for s in all_sports if s != sport], 3)
        add_q("Spor", f"'{term}' terimi genellikle hangi sporda kullanılır?", sport, wrongs)

cl_winners = {
    "2023": "Manchester City", "2022": "Real Madrid", "2021": "Chelsea", "2020": "Bayern Münih",
    "2019": "Liverpool", "2018": "Real Madrid", "2017": "Real Madrid", "2016": "Real Madrid",
    "2015": "Barcelona", "2014": "Real Madrid", "2013": "Bayern Münih", "2012": "Chelsea",
    "2010": "Inter", "2009": "Barcelona", "2008": "Manchester United", "2007": "Milan",
    "2005": "Liverpool", "1999": "Manchester United"
}
cl_teams = list(set(cl_winners.values()) | {"Arsenal", "Juventus", "PSG", "Borussia Dortmund", "Atletico Madrid"})
for year, winner in cl_winners.items():
    wrongs = random.sample([t for t in cl_teams if t != winner], 3)
    add_q("Spor", f"{year} yılında UEFA Şampiyonlar Ligi'ni hangi takım kazanmıştır?", winner, wrongs)

tsl_winners = {
    "2023": "Galatasaray", "2022": "Trabzonspor", "2021": "Beşiktaş", "2020": "Başakşehir",
    "2019": "Galatasaray", "2018": "Galatasaray", "2017": "Beşiktaş", "2016": "Beşiktaş",
    "2014": "Fenerbahçe", "2010": "Bursaspor"
}
tsl_teams = ["Galatasaray", "Fenerbahçe", "Beşiktaş", "Trabzonspor", "Bursaspor", "Başakşehir", "Sivasspor"]
for year, winner in tsl_winners.items():
    wrongs = random.sample([t for t in tsl_teams if t != winner], 3)
    add_q("Spor", f"{year} yılında Türkiye Süper Ligi'nde hangi takım şampiyon olmuştur?", winner, wrongs)

f1_champs = {
    "2023": "Max Verstappen", "2022": "Max Verstappen", "2021": "Max Verstappen",
    "2020": "Lewis Hamilton", "2019": "Lewis Hamilton", "2018": "Lewis Hamilton",
    "2016": "Nico Rosberg", "2013": "Sebastian Vettel", "2006": "Fernando Alonso",
    "2004": "Michael Schumacher", "2007": "Kimi Raikkonen"
}
f1_drivers = list(set(f1_champs.values()) | {"Charles Leclerc", "Lando Norris", "Carlos Sainz", "Valtteri Bottas", "Sergio Perez"})
for year, winner in f1_champs.items():
    wrongs = random.sample([d for d in f1_drivers if d != winner], 3)
    add_q("Spor", f"{year} Formula 1 Dünya Şampiyonu kim olmuştur?", winner, wrongs)

nba_champs = {
    "2023": "Denver Nuggets", "2022": "Golden State Warriors", "2021": "Milwaukee Bucks",
    "2020": "Los Angeles Lakers", "2019": "Toronto Raptors", "2016": "Cleveland Cavaliers",
    "2014": "San Antonio Spurs", "2011": "Dallas Mavericks", "2008": "Boston Celtics",
    "1998": "Chicago Bulls", "1996": "Chicago Bulls"
}
nba_teams = list(set(nba_champs.values()) | {"Miami Heat", "Phoenix Suns", "Houston Rockets", "New York Knicks"})
for year, winner in nba_champs.items():
    wrongs = random.sample([t for t in nba_teams if t != winner], 3)
    add_q("Spor", f"{year} NBA Şampiyonu hangi takım olmuştur?", winner, wrongs)

# Sinema & Sanat
directors = {
    "Steven Spielberg": "Jurassic Park", "James Cameron": "Avatar", "Christopher Nolan": "Inception",
    "Quentin Tarantino": "Pulp Fiction", "Peter Jackson": "Yüzüklerin Efendisi", "Francis Ford Coppola": "Baba (The Godfather)",
    "Ridley Scott": "Gladyatör", "George Lucas": "Star Wars", "Martin Scorsese": "Taksi Şoförü",
    "Stanley Kubrick": "Cinnet (The Shining)", "David Fincher": "Dövüş Kulübü", "Alfred Hitchcock": "Sapık (Psycho)"
}
all_dirs = list(directors.keys())
dir_templates = [
    "'{m}' filminin yönetmen koltuğunda kim oturmaktadır?",
    "Sinema tarihinin klasikleri arasına giren '{m}' filmini kim yönetmiştir?",
    "Aşağıdaki yönetmenlerden hangisi '{m}' adlı esere imza atmıştır?",
    "'{m}' filminin dünyaca ünlü yönetmeni kimdir?"
]
for d, m in directors.items():
    wrongs = random.sample([x for x in all_dirs if x != d], 3)
    t = random.choice(dir_templates).replace("{m}", m)
    add_q("Sinema", t, d, wrongs)

actors = {
    "Leonardo DiCaprio": "Titanik", "Keanu Reeves": "Matrix", "Johnny Depp": "Karayip Korsanları",
    "Tom Hanks": "Forrest Gump", "Marlon Brando": "Baba", "Christian Bale": "Kara Şövalye",
    "Brad Pitt": "Dövüş Kulübü", "Elijah Wood": "Yüzüklerin Efendisi", "Daniel Radcliffe": "Harry Potter",
    "Al Pacino": "Yaralı Yüz (Scarface)", "Robert De Niro": "Sıkı Dostlar (Goodfellas)", "Tom Cruise": "Görevimiz Tehlike",
    "Harrison Ford": "Indiana Jones", "Russell Crowe": "Gladyatör", "Joaquin Phoenix": "Joker",
    "Morgan Freeman": "Esaretin Bedeli", "Anthony Hopkins": "Kuzuların Sessizliği", "Sylvester Stallone": "Rocky"
}
all_acts = list(actors.keys())
act_templates = [
    "'{m}' filmindeki efsanevi başrol performansıyla hafızalara kazınan aktör kimdir?",
    "'{m}' filminde başkarakteri canlandırarak büyük beğeni toplayan isim hangisidir?",
    "Aşağıdaki oyunculardan hangisi '{m}' filmindeki rolüyle tanınır?",
    "'{m}' sinema filminde başrolde kim oynamıştır?"
]
for a, m in actors.items():
    wrongs = random.sample([x for x in all_acts if x != a], 3)
    t = random.choice(act_templates).replace("{m}", m)
    add_q("Sinema", t, a, wrongs)

# Bilim
inventors = {
    "Thomas Edison": "Ampulü", "Alexander Graham Bell": "Telefonu", "Guglielmo Marconi": "Radyoyu",
    "Nikola Tesla": "Alternatif akımı", "Wright Kardeşler": "Uçağı", "Johannes Gutenberg": "Matbaayı",
    "Isaac Newton": "Yerçekimi kanununu", "Albert Einstein": "İzafiyet teorisini", "Marie Curie": "Radyoaktiviteyi",
    "Louis Pasteur": "Kuduz aşısını", "Galileo Galilei": "Teleskopu astronomide kullanan", "Charles Darwin": "Evrim teorisini",
    "Alexander Fleming": "Penisilini", "James Watt": "Buhar makinesini geliştiren", "Alessandro Volta": "Pili",
    "Dmitri Mendeleyev": "Periyodik tabloyu", "Stephen Hawking": "Kara delik radyasyonunu", "Nicolaus Copernicus": "Güneş merkezli evren modelini",
    "Rosalind Franklin": "DNA'nın çift sarmal yapısını fotoğraflayan", "Alan Turing": "Modern bilgisayar biliminin kurucusu sayılan"
}
all_invs = list(inventors.keys())
inv_templates = [
    "{inven} bulan veya insanlığa kazandıran ünlü bilim insanı kimdir?",
    "Bilim tarihinde {inven} kişi olarak bilinen dahi hangisidir?",
    "Aşağıdaki bilim insanlarından hangisi {inven} buluşuyla/keşfiyle ünlüdür?",
    "{inven} çalışmalarıyla dünya bilim tarihine geçen isim kimdir?"
]
for inv, inven in inventors.items():
    wrongs = random.sample([x for x in all_invs if x != inv], 3)
    t = random.choice(inv_templates).replace("{inven}", inven)
    add_q("Bilim", t, inv, wrongs)

planets = {
    "Merkür": "Güneş'e en yakın", "Venüs": "Dünya'nın ikizi olarak bilinen", "Mars": "Kızıl Gezegen olarak bilinen",
    "Jüpiter": "Güneş sisteminin en büyük", "Satürn": "Halkalarıyla ünlü olan", "Uranüs": "Güneş etrafında yan yatmış varil gibi dönen",
    "Neptün": "Güneş sisteminin en uzak (cüce gezegenler hariç)"
}
all_planets = list(planets.keys()) + ["Dünya"]
planet_templates = [
    "Güneş sistemimizde {desc} gezegen hangisidir?",
    "Astronomi bilimine göre, {desc} olan gezegenin adı nedir?",
    "Aşağıdaki gezegenlerden hangisi '{desc}' özelliği taşır?"
]
for p, desc in planets.items():
    wrongs = random.sample([x for x in all_planets if x != p], 3)
    t = random.choice(planet_templates).replace("{desc}", desc)
    add_q("Bilim", t, p, wrongs)

# Genel Kültür
gk = [
    ("Türkiye'nin plaka kodu 01 olan şehri hangisidir?", "Adana", ["Ankara", "Adıyaman", "Ağrı"]),
    ("İstiklal Marşı'nın şairi kimdir?", "Mehmet Akif Ersoy", ["Necip Fazıl Kısakürek", "Nazım Hikmet", "Cemal Süreya"]),
    ("Bir gün kaç dakikadır?", "1440", ["1200", "3600", "2400"]),
    ("Hangi hayvanın kalbi kafasındadır?", "Karides", ["Ahtapot", "Yengeç", "Denizanasi"]),
    ("Dünyanın en uzun nehri hangisidir?", "Nil Nehri", ["Amazon Nehri", "Mississippi Nehri", "Yangtze Nehri"]),
    ("Türkiye'nin en yüksek dağı hangisidir?", "Ağrı Dağı", ["Erciyes Dağı", "Süphan Dağı", "Kaçkar Dağı"]),
    ("Satranç tahtasında toplam kaç kare vardır?", "64", ["32", "100", "81"]),
    ("Mona Lisa tablosu hangi müzede sergilenmektedir?", "Louvre Müzesi", ["British Museum", "Prado Müzesi", "Vatikan Müzeleri"]),
    ("Nobel Ödülleri hangi ülkede verilmektedir?", "İsveç", ["İsviçre", "Norveç", "Danimarka"]),
    ("Pi sayısının ilk üç basamağı nedir?", "3.14", ["3.12", "3.15", "3.16"]),
    ("Dünyanın en kalabalık ülkesi hangisidir? (2024 itibarıyla)", "Hindistan", ["Çin", "ABD", "Endonezya"]),
    ("Hangi renklerin karışımı yeşili oluşturur?", "Sarı ve Mavi", ["Sarı ve Kırmızı", "Mavi ve Kırmızı", "Beyaz ve Siyah"]),
    ("Tarihte parayı ilk bulan medeniyet hangisidir?", "Lidyalılar", ["Sümerler", "Hititler", "Frigler"]),
    ("Olimpiyat halkalarında bulunmayan renk hangisidir?", "Kahverengi", ["Mavi", "Sarı", "Siyah"]),
    ("Hangi gezegene Kızıl Gezegen denir?", "Mars", ["Venüs", "Jüpiter", "Merkür"]),
    ("T.C. kimlik numaraları kaç hanelidir?", "11", ["9", "10", "12"]),
    ("Gökyüzü neden mavidir?", "Işığın saçılması", ["Okyanusların yansıması", "Ozon tabakası", "Güneşin sıcaklığı"]),
    ("Hangi müzik aleti yaylı çalgılar ailesindendir?", "Keman", ["Flüt", "Trompet", "Piyano"]),
    ("En sert doğal mineral hangisidir?", "Elmas", ["Altın", "Demir", "Kuvars"]),
    ("Hangi ilimiz Ege Bölgesinde değildir?", "Burdur", ["İzmir", "Aydın", "Muğla"]),
    ("Bir satranç oyununda her oyuncunun başlangıçta kaç taşı vardır?", "16", ["12", "20", "24"]),
    ("Türk lirasının simgesini kim tasarlamıştır?", "Tülay Lale", ["Ali Ercan", "Ayşe Kulin", "Mehmet Akif"]),
    ("İnsan vücudundaki en büyük organ hangisidir?", "Deri", ["Karaciğer", "Akciğer", "Beyin"]),
    ("Pusulada güneyi gösteren harf hangisidir?", "S", ["N", "E", "W"]),
    ("Hangi yazar 'Sefiller' adlı eserin sahibidir?", "Victor Hugo", ["Lev Tolstoy", "Charles Dickens", "Dostoyevski"]),
    ("Periyodik tablodaki ilk element hangisidir?", "Hidrojen", ["Helyum", "Oksijen", "Karbon"]),
    ("Türkiye'nin en kalabalık ilçesi hangisidir?", "Esenyurt", ["Çankaya", "Keçiören", "Şahinbey"]),
    ("Dünyanın en büyük okyanusu hangisidir?", "Pasifik Okyanusu", ["Atlantik Okyanusu", "Hint Okyanusu", "Kuzey Buz Denizi"]),
    ("Güneş sistemindeki en küçük gezegen hangisidir?", "Merkür", ["Mars", "Venüs", "Plüton"]),
    ("Bir yılda kaç hafta vardır?", "52", ["50", "54", "48"]),
    ("Cumhurbaşkanlığı Forsunda kaç yıldız vardır?", "16", ["15", "12", "18"]),
    ("Osmanlı Devleti'nin ilk başkenti neresidir?", "Söğüt", ["Bursa", "Edirne", "İstanbul"])
]
for q, c, w in gk:
    add_q("Genel Kültür", q, c, w)

# Duplicate slightly to ensure at least 35-40 per category
with open('assets/event_questions.json', 'w', encoding='utf-8') as f:
    json.dump(questions, f, ensure_ascii=True, indent=2)

print(f"Generated {len(questions)} event questions successfully.")
