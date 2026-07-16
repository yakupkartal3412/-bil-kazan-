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

# Futbol
futbol_qs = [
    ("Hangi futbolcu kariyeri boyunca en çok Ballon d'Or ödülünü kazanmıştır?", "Lionel Messi", ["Cristiano Ronaldo", "Pele", "Diego Maradona"]),
    ("Tarihte 'Sarı Kanaryalar' lakabıyla bilinen Türk futbol kulübü hangisidir?", "Fenerbahçe", ["Galatasaray", "Beşiktaş", "Trabzonspor"]),
    ("İngiltere Premier Lig tarihinde 'The Invincibles' (Yenilmezler) unvanıyla namağlup şampiyon olan tek takım hangisidir?", "Arsenal", ["Manchester United", "Chelsea", "Manchester City"]),
    ("Futbolda kendi kalesine atılan gole ne ad verilir?", "Kendi Kalesine Gol (Own Goal)", ["Ofsayt", "Frikik", "Rövaşata"]),
    ("Türkiye Süper Lig'de 4 yıldız takmaya hak kazanan ilk futbol takımı hangisidir?", "Galatasaray", ["Fenerbahçe", "Beşiktaş", "Trabzonspor"]),
    ("Real Madrid'in efsanevi maçlarını oynadığı dünyaca ünlü stadyumunun adı nedir?", "Santiago Bernabeu", ["Camp Nou", "Allianz Arena", "Old Trafford"]),
    ("Futbol tarihinde 'El Pibe de Oro' (Altın Çocuk) lakabıyla tanınan efsanevi Arjantinli oyuncu kimdir?", "Diego Maradona", ["Lionel Messi", "Gabriel Batistuta", "Alfredo Di Stefano"]),
    ("2002 FIFA Dünya Kupası'nda Türkiye Milli Takımı hangi ülkeyi yenerek dünya üçüncüsü olmuştur?", "Güney Kore", ["Japonya", "Brezilya", "Senegal"]),
    ("Şampiyonlar Ligi'ni (ve eski adıyla Şampiyon Kulüpler Kupası'nı) en çok kazanan Avrupa kulübü hangisidir?", "Real Madrid", ["Milan", "Bayern Münih", "Liverpool"]),
    ("Futbolda rakip takımın savunma arkasına sarkıldığında kural ihlali sayılan pozisyona ne ad verilir?", "Ofsayt", ["Korner", "Taç", "Penaltı"]),
    ("Galatasaray, 2000 yılında UEFA Kupası finalinde hangi takımı penaltılarla geçerek şampiyon olmuştur?", "Arsenal", ["Leeds United", "Real Madrid", "Mallorca"]),
    ("Tarihte 'Siyah İnce İnci' veya sadece 'Kral' lakaplarıyla tanınan, 3 kez Dünya Kupası kazanan tek futbolcu kimdir?", "Pele", ["Maradona", "Ronaldo Nazario", "Ronaldinho"]),
    ("İtalya Serie A'da 'Yaşlı Kadın' (La Vecchia Signora) lakabıyla bilinen takım hangisidir?", "Juventus", ["Milan", "Inter", "Roma"]),
    ("Dünya futbol tarihinde kalecilerin topu elle tutmasının yasak olduğu alanın dışındaki bölgeye ne ad verilir?", "Ceza sahası dışı", ["Altı pas", "Kale arkası", "Yarı alan"]),
    ("Bir futbol maçında aynı oyuncunun 3 gol atması durumuna verilen isim nedir?", "Hat-trick", ["Poker", "Duble", "Clean Sheet"]),
    ("Beşiktaş'ın efsanevi üçlüsü 'Metin - Ali - Feyyaz' döneminde takımın sembolü haline gelen isimlerden Feyyaz'ın soyadı nedir?", "Uçar", ["Tekin", "Güler", "Yılmaz"]),
    ("İngiliz futbolunun kalbi sayılan ve Liverpool'un iç saha maçlarını oynadığı tarihi stadyum neresidir?", "Anfield Road", ["Old Trafford", "Stamford Bridge", "Emirates"]),
    ("Türkiye'de ilk resmi futbol maçı hangi iki takım arasında oynanmıştır?", "Moda FC - HMS Imogene", ["Galatasaray - Fenerbahçe", "Beşiktaş - Galatasaray", "Karşıyaka - Altay"]),
    ("Futbolda hakemin oyunu sarı kartla durdurup, aynı oyuncuya ikinci sarıdan kırmızı kart göstermesi ne anlama gelir?", "Oyundan ihraç", ["Penaltı atışı", "Serbest vuruş", "Uyarı"]),
    ("Dünya Kupası tarihinde en çok gol atan oyuncu olan Miroslav Klose hangi ülkenin vatandaşıdır?", "Almanya", ["Polonya", "Avusturya", "İsviçre"]),
    ("Türkiye Milli Futbol Takımı'nın tarihindeki en çok gol atan oyuncusu (Tüm zamanların en golcüsü) kimdir?", "Hakan Şükür", ["Burak Yılmaz", "Lefter Küçükandonyadis", "Nihat Kahveci"]),
    ("Futbol oyun kurallarına göre bir takım sahada en fazla kaç oyuncu ile mücadele edebilir?", "11", ["10", "12", "9"]),
    ("Brezilyalı efsane Ronaldinho'nun adıyla özdeşleşen ve topu rakibin bacak arasından geçirmeye dayalı çalıma ne denir?", "Bacak arası (Nutmeg)", ["Rövaşata", "Gökkuşağı", "Plase"]),
    ("Şampiyonlar Ligi müziği hangi klasik bestecinin eserinden uyarlanmıştır?", "George Frideric Handel", ["Wolfgang Amadeus Mozart", "Ludwig van Beethoven", "Johann Sebastian Bach"]),
    ("Türkiye'de 'Dört Büyükler' olarak anılan takımların dışında Süper Lig şampiyonluğu yaşayan ilk Anadolu kulübü hangisidir?", "Trabzonspor", ["Bursaspor", "Başakşehir", "Kocaelispor"]),
    ("Futbol maçlarında sürenin bitimiyle birlikte hakemin eklediği kayıp zamana ne ad verilir?", "Uzatma (Duraklama) anları", ["Altın gol", "Gümüş gol", "Penaltılar"]),
    ("Hollanda futbolunun felsefesi olan 'Total Futbol'u dünyaya tanıtan efsanevi futbol adamı kimdir?", "Johan Cruyff", ["Marco van Basten", "Ruud Gullit", "Frank Rijkaard"]),
    ("Avrupa Futbol Şampiyonası (EURO) tarihinde sürpriz bir şekilde 2004 yılında şampiyon olan ülke hangisidir?", "Yunanistan", ["Portekiz", "Danimarka", "Çekya"]),
    ("Bir kalecinin kendi ceza sahası dışında topa eliyle müdahale etmesinin cezası genellikle nedir?", "Kırmızı Kart", ["Sarı Kart", "Uyarı", "Penaltı"]),
    ("Lionel Messi'nin Barcelona'da giydiği efsanevi forma numarası kaçtır?", "10", ["9", "11", "7"]),
    ("Cristiano Ronaldo, profesyonel kariyerine hangi Portekiz kulübünde başlamıştır?", "Sporting Lizbon", ["Porto", "Benfica", "Braga"]),
    ("Türkiye Süper Ligi'nde en çok gol krallığı yaşayan ve 'Taçsız Kral' lakabıyla anılan efsane kimdir?", "Metin Oktay", ["Lefter Küçükandonyadis", "Hakkı Yeten", "Tanju Çolak"])
]

for t, ans, wr in futbol_qs:
    add_q("Futbol", t, ans, wr)

# Basketbol
basketbol_qs = [
    ("Basketbolda kendi çemberine doğru giden topu havada yakalayıp smaçla bitirmeye ne ad verilir?", "Alley-oop", ["Pick and Roll", "Crossover", "Fadeaway"]),
    ("NBA tarihinde 'Ekselansları' (His Airness) lakabıyla bilinen ve Chicago Bulls ile 6 şampiyonluk kazanan efsane kimdir?", "Michael Jordan", ["Kobe Bryant", "LeBron James", "Magic Johnson"]),
    ("Türkiye Erkekler Basketbol tarihinde EuroLeague kupasını kazanan ilk takım hangisidir?", "Fenerbahçe", ["Anadolu Efes", "Galatasaray", "Darüşşafaka"]),
    ("Basketbolda hücum süresi (shot clock) standart olarak kaç saniyedir?", "24 saniye", ["30 saniye", "20 saniye", "15 saniye"]),
    ("NBA logosunda silueti bulunan efsanevi basketbolcu kimdir?", "Jerry West", ["Wilt Chamberlain", "Bill Russell", "Larry Bird"]),
    ("Bir oyuncunun maç boyunca çift haneli istatistiklere 3 farklı kategoride (örneğin: sayı, ribaund, asist) ulaşmasına ne denir?", "Triple-Double", ["Double-Double", "Quadruple-Double", "Buzzer Beater"]),
    ("EuroLeague tarihinde en çok şampiyonluk kazanan başantrenör (Koç) kimdir?", "Zeljko Obradovic", ["Ergin Ataman", "Ettore Messina", "Dusan Ivkovic"]),
    ("Basketbolda serbest atış (free throw) çizgisinden atılan ve giren her bir şut kaç puan değerindedir?", "1", ["2", "3", "0.5"]),
    ("Los Angeles Lakers'ın efsanevi yıldızı Kobe Bryant'ın sahada kullandığı lakap neydi?", "Black Mamba", ["The Answer", "The Truth", "The King"]),
    ("Top sürerken (dribbling) topu sektirmeyi bırakıp iki eliyle tuttuktan sonra tekrar sektirmeye başlamak hangi kural ihlalidir?", "Çift Top (Double Dribble)", ["Hatalı Yürüme", "Taşıma", "Geri Saha İhlali"]),
    ("Dünya Basketbol Şampiyonası'nda (FIBA) en çok madalya kazanan ve basketbolun beşiği sayılan ülke hangisidir?", "ABD", ["Sırbistan", "İspanya", "Arjantin"]),
    ("Efsanevi oyuncu LeBron James, NBA kariyerine hangi takımda başlamıştır?", "Cleveland Cavaliers", ["Miami Heat", "Los Angeles Lakers", "Chicago Bulls"]),
    ("Avrupa basketbolunun kulüpler bazındaki en prestijli turnuvası hangisidir?", "EuroLeague", ["EuroCup", "FIBA Şampiyonlar Ligi", "VTB Ligi"]),
    ("Basketbolda potanın yerden yüksekliği standart olarak tam kaç metredir?", "3.05 metre", ["2.95 metre", "3.15 metre", "3.00 metre"]),
    ("Bir oyuncunun topu çemberin içinden geçirirken elleriyle çembere asılarak attığı çok sert sayı türü nedir?", "Smaç (Dunk)", ["Turnike (Layup)", "Floter", "Kanca (Hook)"]),
    ("2021 ve 2022 yıllarında üst üste iki kez EuroLeague şampiyonu olan Türk basketbol takımı hangisidir?", "Anadolu Efes", ["Fenerbahçe Beko", "Galatasaray", "Beşiktaş"]),
    ("Basketbolda 3 saniye kuralı, sahanın hangi bölgesinde uygulanır?", "Boyalı alan", ["Orta saha", "Üç sayı çizgisi dışı", "Kenar çizgisi"]),
    ("Efsanevi uzun Wilt Chamberlain, NBA tarihinde bir maçta en fazla kaç sayı atarak kırılması imkansız bir rekor kırmıştır?", "100", ["81", "72", "93"]),
    ("Rakip oyuncu şut attıktan sonra topu engellemeye çalışırken top inişe geçmişse ve o topa müdahale edilirse ne kararı verilir?", "İniş halindeki top (Goaltending) - Sayı geçerli sayılır", ["Blok - Oyun devam eder", "Faul - Serbest atış verilir", "Hatalı savunma - Top yandan başlar"]),
    ("Stephen Curry, NBA'de hangi oyun stili ve yeteneğiyle tüm basketbol dünyasında devrim yapmıştır?", "Uzak mesafeli 3 sayılık atışlar", ["Sert savunma", "Pota altı dominasyonu", "Gözü kapalı asistler"]),
    ("Basketbolu 1891 yılında ABD'de bir spor dalı olarak icat eden beden eğitimi öğretmeni kimdir?", "James Naismith", ["William G. Morgan", "Abner Doubleday", "Alexander Cartwright"]),
    ("Boston Celtics ile kazandığı sayısız şampiyonlukla hatırlanan 'Larry Legend' lakaplı yıldız kimdir?", "Larry Bird", ["Paul Pierce", "Kevin McHale", "Bill Russell"]),
    ("Hücumdaki takımın, kendi yarı sahasından topu rakip yarı sahaya geçirmek için kaç saniye süresi vardır?", "8 saniye", ["5 saniye", "10 saniye", "12 saniye"]),
    ("Maçın bitimini belirten siren çaldığı anda havada olan ve basketle sonuçlanan efsanevi şutlara ne isim verilir?", "Buzzer Beater", ["Fadeaway", "Clutch Shot", "Airball"]),
    ("Hidayet Türkoğlu, NBA kariyerinde en büyük başarılarını ve 'En Çok Gelişme Gösteren Oyuncu' (MIP) ödülünü hangi takımla kazanmıştır?", "Orlando Magic", ["Sacramento Kings", "Toronto Raptors", "San Antonio Spurs"]),
    ("Şut atarken savunmacının üzerinden geriye doğru sıçrayarak atılan, savunulması çok zor şut tekniği nedir?", "Fadeaway", ["Hook Shot", "Layup", "Floater"]),
    ("Dallas Mavericks ile özdeşleşen ve tek bacağı üzerinde geriye çekilerek attığı şutlarla efsaneleşen Alman yıldız kimdir?", "Dirk Nowitzki", ["Pau Gasol", "Tony Parker", "Luka Doncic"]),
    ("Türkiye'nin lakabı '12 Dev Adam' olan Erkek Milli Basketbol Takımı, bu lakabı ilk kez hangi turnuvadaki başarısıyla almıştır?", "2001 Avrupa Şampiyonası", ["2010 Dünya Şampiyonası", "1999 Avrupa Şampiyonası", "2014 Dünya Şampiyonası"]),
    ("Savunma yapan oyuncunun ayakları tamamen yerleşikken, hücum oyuncusunun gelip ona şiddetle çarpmasına ne denir?", "Hücum Faul (Charge)", ["Savunma Faulü", "Blok", "Teknik Faul"]),
    ("Giannis Antetokounmpo'nun sahip olduğu ve inanılmaz fiziği ile uyumlu 'Yunan Ucubesi' anlamına gelen İngilizce lakabı nedir?", "Greek Freak", ["The Alphabet", "Spartan", "Olympian"])
]

for t, ans, wr in basketbol_qs:
    add_q("Basketbol", t, ans, wr)

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
