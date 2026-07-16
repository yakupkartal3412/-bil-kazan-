import json
import random

def generate():
    raw_data = [
        # --- Coğrafya & Doğa (1-10) ---
        # Dünya başkentleri
        ("Fransa'nın başkenti neresidir?", ["Paris", "Lyon", "Marsilya", "Nice"], 0, 1, "Coğrafya"),
        ("Kanada'nın başkenti neresidir?", ["Toronto", "Vancouver", "Ottawa", "Montreal"], 2, 2, "Coğrafya"),
        # Okyanuslar & denizler
        ("Dünyanın en büyük okyanusu hangisidir?", ["Atlas Okyanusu", "Pasifik Okyanusu", "Hint Okyanusu", "Arktik Okyanusu"], 1, 1, "Coğrafya"),
        ("Hangi deniz Avrupa ve Afrika kıtalarını birbirinden ayırır?", ["Kızıldeniz", "Karadeniz", "Akdeniz", "Baltık Denizi"], 2, 1, "Coğrafya"),
        # Dağlar & nehirler
        ("Dünyanın en yüksek dağı hangisidir?", ["K2", "Everest", "Kilimanjaro", "Alpler"], 1, 1, "Coğrafya"),
        ("Dünyanın en uzun nehri hangisidir?", ["Amazon", "Nil", "Mississippi", "Yangtze"], 1, 2, "Coğrafya"),
        # Hayvanlar & doğa
        ("Karada yaşayan en hızlı hayvan hangisidir?", ["Aslan", "Leopar", "Çita", "Kaplan"], 2, 1, "Doğa"),
        ("Hangi memeli uçabilir?", ["Yarasa", "Uçan Sincap", "Penguen", "Lemur"], 0, 2, "Doğa"),
        # İklim & doğal afetler
        ("Richter ölçeği neyi ölçmek için kullanılır?", ["Rüzgar şiddeti", "Deprem büyüklüğü", "Hava sıcaklığı", "Tsunami dalgası"], 1, 1, "Doğa"),
        ("Tornado olarak da bilinen şiddetli rüzgar türü hangisidir?", ["Kasırga", "Hortum", "Tayfun", "Muson"], 1, 2, "Doğa"),
        # Ülkeler & bayraklar
        ("Üzerinde akçaağaç yaprağı bulunan bayrak hangi ülkeye aittir?", ["Kanada", "Japonya", "Brezilya", "İsviçre"], 0, 1, "Coğrafya"),
        ("Hangi ülkenin bayrağı tamamen kare şeklindedir?", ["İsviçre", "ABD", "Fransa", "Türkiye"], 0, 3, "Coğrafya"),
        # Ormanlar & bitkiler
        ("Dünyanın akciğerleri olarak bilinen ormanlar hangileridir?", ["Amazon Ormanları", "Taiga Ormanları", "Kongo Havzası", "Kara Orman"], 0, 1, "Doğa"),
        ("Fotosentez sırasında bitkiler havadan hangi gazı alır?", ["Oksijen", "Karbondioksit", "Azot", "Hidrojen"], 1, 1, "Doğa"),
        # Göller & şelaleler
        ("Dünyanın en derin gölü hangisidir?", ["Viktorya Gölü", "Baykal Gölü", "Hazar Gölü", "Lut Gölü"], 1, 3, "Coğrafya"),
        ("ABD ve Kanada sınırında bulunan ünlü şelalenin adı nedir?", ["Angel Şelalesi", "Niagara Şelalesi", "İguazu Şelalesi", "Victoria Şelalesi"], 1, 2, "Coğrafya"),
        # Adalar & yarımadalar
        ("Dünyanın en büyük adası hangisidir?", ["Grönland", "Madagaskar", "Büyük Britanya", "Yeni Gine"], 0, 2, "Coğrafya"),
        ("İtalya hangi yarımada üzerinde yer alır?", ["İber Yarımadası", "İskandinav Yarımadası", "Apennin Yarımadası", "Balkan Yarımadası"], 2, 3, "Coğrafya"),
        # Türkiye coğrafyası
        ("Türkiye'nin en yüksek dağı hangisidir?", ["Erciyes Dağı", "Ağrı Dağı", "Süphan Dağı", "Nemrut Dağı"], 1, 1, "Türkiye"),
        ("Türkiye'nin en büyük gölü hangisidir?", ["Tuz Gölü", "Eğirdir Gölü", "Van Gölü", "Beyşehir Gölü"], 2, 1, "Türkiye"),

        # --- Tarih (11-20) ---
        # Dünya tarihi
        ("Amerika kıtası hangi yılda keşfedilmiştir?", ["1492", "1453", "1500", "1512"], 0, 2, "Tarih"),
        ("Matbaayı icat eden kişi kimdir?", ["Galileo", "Da Vinci", "Gutenberg", "Newton"], 2, 2, "Tarih"),
        # Türk tarihi
        ("Türkiye Cumhuriyeti hangi yıl ilan edilmiştir?", ["1920", "1923", "1919", "1921"], 1, 1, "Türk Tarihi"),
        ("Malazgirt Meydan Muharebesi hangi yıl yapılmıştır?", ["1071", "1453", "1299", "1526"], 0, 1, "Türk Tarihi"),
        # Antik medeniyetler
        ("Piramitleriyle ünlü antik medeniyet hangisidir?", ["Sümerler", "Mısırlılar", "Romalılar", "İnkalar"], 1, 1, "Tarih"),
        ("Yazıyı icat eden medeniyet hangisidir?", ["Hititler", "Babiller", "Sümerler", "Akadlar"], 2, 2, "Tarih"),
        # Savaşlar & anlaşmalar
        ("1. Dünya Savaşı hangi yıl sona ermiştir?", ["1918", "1914", "1945", "1939"], 0, 2, "Tarih"),
        ("Lozan Barış Antlaşması hangi yıl imzalanmıştır?", ["1920", "1922", "1923", "1924"], 2, 2, "Türk Tarihi"),
        # Ünlü liderler & krallar
        ("Fransız İhtilali sırasında Fransa'nın kraliçesi kimdi?", ["Boleyn Kızı", "Marie Antoinette", "Kraliçe Victoria", "Katerina"], 1, 3, "Tarih"),
        ("Büyük İskender nereliydi?", ["Romalı", "Mısırlı", "Makedonyalı", "Pers"], 2, 2, "Tarih"),
        # Osmanlı İmparatorluğu
        ("Osmanlı Devleti'nin kurucusu kimdir?", ["Orhan Gazi", "Osman Gazi", "Fatih Sultan Mehmet", "Yavuz Sultan Selim"], 1, 1, "Osmanlı"),
        ("İstanbul'u fetheden Osmanlı padişahı kimdir?", ["Kanuni Sultan Süleyman", "II. Mahmud", "Fatih Sultan Mehmet", "Yıldırım Bayezid"], 2, 1, "Osmanlı"),
        # Rönesans & reformlar
        ("Rönesans ilk olarak hangi ülkede başlamıştır?", ["İngiltere", "Fransa", "İspanya", "İtalya"], 3, 2, "Tarih"),
        ("Protestan Reformu'nu başlatan isim kimdir?", ["John Calvin", "Martin Luther", "Henry VIII", "Erasmus"], 1, 3, "Tarih"),
        # Fransız İhtilali
        ("Fransız İhtilali hangi yılda gerçekleşmiştir?", ["1789", "1889", "1689", "1799"], 0, 3, "Tarih"),
        ("Fransız İhtilali'nin ünlü sloganı olan üç kelime nedir?", ["Savaş, Barış, Adalet", "Özgürlük, Eşitlik, Kardeşlik", "Güç, Zafer, Onur", "Hak, Hukuk, Devlet"], 1, 2, "Tarih"),
        # 1 & 2. Dünya Savaşı
        ("İkinci Dünya Savaşı hangi yıl başlamıştır?", ["1939", "1945", "1914", "1938"], 0, 2, "Tarih"),
        ("Normandiya Çıkarması hangi savaşta gerçekleşmiştir?", ["1. Dünya Savaşı", "2. Dünya Savaşı", "Kore Savaşı", "Vietnam Savaşı"], 1, 2, "Tarih"),
        # Soğuk Savaş dönemi
        ("Soğuk Savaş döneminde iki büyük süper güç hangi ülkelerdi?", ["ABD - İngiltere", "ABD - SSCB", "İngiltere - Fransa", "SSCB - Çin"], 1, 1, "Tarih"),
        ("Berlin Duvarı hangi yıl yıkılmıştır?", ["1989", "1991", "1985", "1990"], 0, 3, "Tarih"),

        # --- Bilim & Teknoloji (21-30) ---
        # Uzay & astronomi
        ("Güneş sistemindeki en küçük gezegen hangisidir?", ["Mars", "Venüs", "Merkür", "Dünya"], 2, 2, "Bilim"),
        ("Ay'a ilk ayak basan insan kimdir?", ["Yuri Gagarin", "Neil Armstrong", "Buzz Aldrin", "Michael Collins"], 1, 1, "Bilim"),
        # İnsan vücudu & sağlık
        ("İnsan vücudundaki en büyük organ hangisidir?", ["Kalp", "Karaciğer", "Beyin", "Deri"], 3, 2, "Bilim"),
        ("Kanın kırmızı rengini veren madde nedir?", ["Melanin", "Hemoglobin", "Keratin", "Glikoz"], 1, 2, "Bilim"),
        # Kimya & fizik
        ("Suyun kimyasal formülü nedir?", ["H2O", "CO2", "NaCl", "O2"], 0, 1, "Bilim"),
        ("Yerçekimini keşfeden ünlü bilim insanı kimdir?", ["Albert Einstein", "Isaac Newton", "Galileo Galilei", "Nikola Tesla"], 1, 1, "Bilim"),
        # İcatlar & mucitler
        ("Telefonu kim icat etmiştir?", ["Thomas Edison", "Alexander Graham Bell", "Guglielmo Marconi", "Nikola Tesla"], 1, 1, "Bilim"),
        ("Ampulü kim icat etmiştir?", ["Nikola Tesla", "Thomas Edison", "Alessandro Volta", "James Watt"], 1, 1, "Bilim"),
        # Bilgisayar & internet
        ("World Wide Web'in (WWW) mucidi kimdir?", ["Bill Gates", "Steve Jobs", "Tim Berners-Lee", "Mark Zuckerberg"], 2, 3, "Teknoloji"),
        ("Hangi şirket 'Windows' işletim sistemini geliştirmiştir?", ["Apple", "Google", "Microsoft", "IBM"], 2, 1, "Teknoloji"),
        # Yapay zeka & robotlar
        ("Alan Turing hangi alandaki çalışmalarıyla tanınır?", ["Biyoloji", "Bilgisayar Bilimleri", "Astronomi", "Kimya"], 1, 2, "Teknoloji"),
        ("İnsan gibi davranan ilk yapay zeka testi nedir?", ["Turing Testi", "Asimov Testi", "Einstein Testi", "Robot Testi"], 0, 2, "Teknoloji"),
        # Matematik & sayılar
        ("Pi sayısının ilk üç rakamı nedir?", ["3.12", "3.14", "3.16", "3.18"], 1, 1, "Matematik"),
        ("Sıfır rakamını matematiğe kazandıran medeniyet hangisidir?", ["Hintliler", "Yunanlılar", "Romalılar", "Mısırlılar"], 0, 3, "Matematik"),
        # Biyoloji & genetik
        ("DNA'nın açılımı nedir?", ["Deoksiribo Nükleik Asit", "Dinamik Nükleik Asit", "Deoksi Nötr Asit", "Dizi Nükleik Asit"], 0, 2, "Bilim"),
        ("Penisilini bularak milyonlarca hayat kurtaran kimdir?", ["Louis Pasteur", "Alexander Fleming", "Marie Curie", "Charles Darwin"], 1, 3, "Bilim"),
        # Çevre & enerji
        ("Güneş enerjisini elektriğe çeviren panellere ne ad verilir?", ["Rüzgar Türbini", "Termal Panel", "Solar Panel", "Kinetik Panel"], 2, 1, "Bilim"),
        ("Hangi gaz sera etkisine en çok neden olur?", ["Karbondioksit", "Oksijen", "Azot", "Argon"], 0, 2, "Bilim"),
        # Tıp & hastalıklar
        ("Kuduz aşısını kim bulmuştur?", ["Alexander Fleming", "Louis Pasteur", "Robert Koch", "Edward Jenner"], 1, 3, "Bilim"),
        ("Tansiyonu ölçmeye yarayan aletin adı nedir?", ["Termometre", "Steteskop", "Tansiyon Aleti (Sfigmomanometre)", "Mikroskop"], 2, 1, "Bilim"),

        # --- Eğlence & Sanat (31-40) ---
        # Sinema & filmler
        ("'Titanik' filminin yönetmeni kimdir?", ["Steven Spielberg", "James Cameron", "Christopher Nolan", "Quentin Tarantino"], 1, 2, "Sanat"),
        ("Oscar ödüllerinin diğer adı nedir?", ["Altın Küre", "Akademi Ödülleri", "Emmy Ödülleri", "Grammy Ödülleri"], 1, 2, "Sanat"),
        # Müzik & sanatçılar
        ("'Popun Kralı' olarak bilinen şarkıcı kimdir?", ["Elvis Presley", "Michael Jackson", "Prince", "Freddie Mercury"], 1, 1, "Sanat"),
        ("Beethoven'ın en ünlü eserlerinden olan sağır olduğu dönemde bestelediği senfoni hangisidir?", ["3. Senfoni", "5. Senfoni", "9. Senfoni", "1. Senfoni"], 2, 3, "Sanat"),
        # Televizyon & diziler
        ("Game of Thrones dizisi hangi yazarın kitap serisinden uyarlanmıştır?", ["J.R.R. Tolkien", "George R.R. Martin", "J.K. Rowling", "Stephen King"], 1, 2, "Sanat"),
        ("Türkiye'nin en uzun soluklu dizilerinden olan 'Arka Sokaklar' hangi yıl başlamıştır?", ["2004", "2006", "2008", "2010"], 1, 3, "Sanat"),
        # Resim & heykel
        ("Mona Lisa tablosunu çizen ünlü ressam kimdir?", ["Vincent van Gogh", "Pablo Picasso", "Leonardo da Vinci", "Claude Monet"], 2, 1, "Sanat"),
        ("David heykelini yapan ünlü İtalyan sanatçı kimdir?", ["Donatello", "Michelangelo", "Raphael", "Da Vinci"], 1, 3, "Sanat"),
        # Edebiyat & kitaplar
        ("'Suç ve Ceza' romanının başkarakteri kimdir?", ["Raskolnikov", "Karamazov", "Mişkin", "Svidrigailov"], 0, 3, "Sanat"),
        ("Harry Potter serisini hangi yazar kaleme almıştır?", ["J.R.R. Tolkien", "J.K. Rowling", "Suzanne Collins", "Stephenie Meyer"], 1, 1, "Sanat"),
        # Animasyon & çizgi film
        ("İlk tam uzunluklu bilgisayar animasyonu filmi hangisidir?", ["Oyuncak Hikayesi", "Kayıp Balık Nemo", "Aslan Kral", "Şrek"], 0, 2, "Sanat"),
        ("Mickey Mouse'u yaratan ünlü isim kimdir?", ["Stan Lee", "Walt Disney", "Hayao Miyazaki", "Matt Groening"], 1, 1, "Sanat"),
        # Tiyatro & opera
        ("Romeo ve Juliet'i yazan ünlü İngiliz oyun yazarı kimdir?", ["Christopher Marlowe", "Arthur Miller", "William Shakespeare", "Oscar Wilde"], 2, 1, "Sanat"),
        ("Ünlü 'Kuğu Gölü' balesinin bestecisi kimdir?", ["Mozart", "Beethoven", "Çaykovski", "Vivaldi"], 2, 3, "Sanat"),
        # Fotoğrafçılık
        ("Dünyanın ilk fotoğrafı hangi yüzyılda çekilmiştir?", ["18. Yüzyıl", "19. Yüzyıl", "20. Yüzyıl", "17. Yüzyıl"], 1, 3, "Sanat"),
        ("En yaygın fotoğraf formatı olan JPEG'in açılımı nedir?", ["Joint Photographic Experts Group", "Java Photo Export Group", "Joint Pixel Electronic Group", "Just Photo Editing Group"], 0, 3, "Sanat"),
        # Mimari & yapılar
        ("Eyfel Kulesi hangi şehirdedir?", ["Londra", "Roma", "Paris", "Berlin"], 2, 1, "Sanat"),
        ("Taç Mahal hangi ülkede bulunmaktadır?", ["Hindistan", "Mısır", "Türkiye", "Çin"], 0, 1, "Sanat"),
        # Ödüller & festivaller
        ("Müzik dünyasının en prestijli ödülü hangisidir?", ["Oscar", "Emmy", "Tony", "Grammy"], 3, 2, "Sanat"),
        ("Cannes Film Festivali hangi ülkede düzenlenmektedir?", ["İtalya", "Fransa", "İspanya", "Almanya"], 1, 2, "Sanat"),

        # --- Spor (41-50) ---
        # Futbol
        ("Dünya Kupası'nı en çok kazanan ülke hangisidir?", ["Almanya", "İtalya", "Brezilya", "Arjantin"], 2, 2, "Spor"),
        ("Bir futbol maçı normal sürede kaç dakika sürer?", ["80", "90", "100", "120"], 1, 1, "Spor"),
        # Olimpiyat oyunları
        ("Olimpiyat halkaları kaç renkten oluşur?", ["4", "5", "6", "7"], 1, 2, "Spor"),
        ("İlk modern Olimpiyat oyunları nerede düzenlenmiştir?", ["Roma", "Londra", "Atina", "Paris"], 2, 3, "Spor"),
        # Basketbol
        ("Basketbolda bir takım sahada kaç kişiyle oynar?", ["5", "6", "7", "11"], 0, 1, "Spor"),
        ("NBA logosundaki silüet hangi basketbolcuya aittir?", ["Michael Jordan", "Jerry West", "Larry Bird", "Magic Johnson"], 1, 3, "Spor"),
        # Tenis
        ("Wimbledon tenis turnuvası hangi ülkede düzenlenir?", ["ABD", "Fransa", "İngiltere", "Avustralya"], 2, 2, "Spor"),
        ("Toprak kortun kralı olarak bilinen tenisçi kimdir?", ["Roger Federer", "Novak Djokovic", "Rafael Nadal", "Andy Murray"], 2, 2, "Spor"),
        # Dünya rekorları
        ("Erkekler 100 metre dünya rekorunu elinde bulunduran atlet kimdir?", ["Tyson Gay", "Usain Bolt", "Yohan Blake", "Justin Gatlin"], 1, 1, "Spor"),
        ("Bir maçta en çok gol atma rekoru (100 gol) hangi basketbolcuya aittir?", ["Michael Jordan", "Kobe Bryant", "LeBron James", "Wilt Chamberlain"], 3, 3, "Spor"),
        # Türk sporcular
        ("Olimpiyatlarda Türkiye'ye altın madalya getiren ilk kadın sporcumuz kimdir?", ["Nurcan Taylan", "Naim Süleymanoğlu", "Şahika Ercümen", "Neslihan Demir"], 0, 3, "Spor"),
        ("Hangi haltercimiz 'Cep Herkülü' lakabıyla anılır?", ["Halil Mutlu", "Naim Süleymanoğlu", "Daniyar İsmayilov", "Taner Sağır"], 1, 1, "Spor"),
        # Formül 1
        ("Formula 1'de en çok şampiyonluk kazanan iki pilottan biri kimdir?", ["Sebastian Vettel", "Fernando Alonso", "Michael Schumacher", "Ayrton Senna"], 2, 2, "Spor"),
        ("Formula 1 yarışlarında bayrak sallanan son turun adı nedir?", ["Isınma turu", "Sıralama turu", "Damalı bayrak", "Zafer turu"], 2, 1, "Spor"),
        # Yüzme & atletizm
        ("Olimpiyatlarda en çok altın madalya kazanan yüzücü kimdir?", ["Michael Phelps", "Ian Thorpe", "Mark Spitz", "Ryan Lochte"], 0, 2, "Spor"),
        ("Maraton koşusu yaklaşık kaç kilometredir?", ["21", "30", "42", "50"], 2, 3, "Spor"),
        # Güreş & dövüş sporları
        ("Boks tarihinin efsanesi 'Muhammed Ali'nin asıl adı nedir?", ["Malcolm X", "Cassius Clay", "Joe Frazier", "Mike Tyson"], 1, 3, "Spor"),
        ("Sumo güreşi hangi ülkeye ait geleneksel bir spordur?", ["Çin", "Güney Kore", "Japonya", "Tayland"], 2, 1, "Spor"),
        # Kış sporları
        ("Kış Olimpiyatları kaç yılda bir düzenlenir?", ["2", "3", "4", "5"], 2, 1, "Spor"),
        ("Buz üzerinde süpürgelerle oynanan stratejik kış sporu hangisidir?", ["Buz Hokeyi", "Curling", "Artistik Patinaj", "Bobsled"], 1, 2, "Spor"),

        # --- Yaşam & Kültür (51-60) ---
        # Yemek & mutfak kültürü
        ("Sushi hangi ülkenin mutfağına aittir?", ["Çin", "Japonya", "Tayland", "Vietnam"], 1, 1, "Kültür"),
        ("İtalya'nın meşhur peyniri Mozzarella orijinalinde hangi hayvanın sütünden yapılır?", ["İnek", "Keçi", "Manda", "Koyun"], 2, 3, "Kültür"),
        # Mitoloji & efsaneler
        ("Yunan mitolojisinde tanrıların kralı kimdir?", ["Poseidon", "Hades", "Zeus", "Ares"], 2, 1, "Kültür"),
        ("Roma mitolojisinde aşk tanrıçası kimdir?", ["Hera", "Venüs", "Afrodit", "Athena"], 1, 3, "Kültür"),
        # Dinler & inanışlar
        ("Müslümanların kutsal kitabı hangisidir?", ["Tevrat", "İncil", "Zebur", "Kur'an-ı Kerim"], 3, 1, "Kültür"),
        ("Hinduizm'in en yaygın olduğu ülke hangisidir?", ["Çin", "Hindistan", "Nepal", "Bangladeş"], 1, 1, "Kültür"),
        # Ekonomi & para birimleri
        ("Avrupa Birliği'nin ortak para birimi nedir?", ["Dolar", "Sterlin", "Euro", "Frang"], 2, 1, "Kültür"),
        ("İngiltere'nin para birimi nedir?", ["Euro", "Sterlin", "Dolar", "Ruble"], 1, 1, "Kültür"),
        # Moda & tasarım
        ("Dünyanın moda başkenti olarak bilinen İtalya şehri neresidir?", ["Roma", "Milano", "Venedik", "Floransa"], 1, 2, "Kültür"),
        ("'Chanel' markasının kurucusu ünlü Fransız modacı kimdir?", ["Christian Dior", "Coco Chanel", "Yves Saint Laurent", "Hubert de Givenchy"], 1, 2, "Kültür"),
        # Psikoloji & insan davranışı
        ("Rüyaların yorumlanması üzerine ünlü teorileri olan psikanalist kimdir?", ["Carl Jung", "Sigmund Freud", "Ivan Pavlov", "B.F. Skinner"], 1, 2, "Kültür"),
        ("Köpekler üzerinde yaptığı şartlanma deneyiyle bilinen bilim insanı kimdir?", ["Freud", "Pavlov", "Watson", "Maslow"], 1, 3, "Kültür"),
        # Diller & alfabeler
        ("Dünyada en çok konuşulan ana dil hangisidir?", ["İngilizce", "İspanyolca", "Mandarin (Çince)", "Hintçe"], 2, 2, "Kültür"),
        ("Kaç harften oluşan modern Türk alfabesi kullanılmaktadır?", ["27", "28", "29", "30"], 2, 1, "Kültür"),
        # Gelenekler & festivaller
        ("Ölüler Günü (Día de los Muertos) festivali hangi ülkede kutlanır?", ["İspanya", "Brezilya", "Meksika", "Küba"], 2, 2, "Kültür"),
        ("Domates fırlatarak kutlanan La Tomatina festivali hangi ülkede yapılır?", ["İtalya", "Meksika", "Portekiz", "İspanya"], 3, 3, "Kültür"),
        # Ünlü şehirler & meydanlar
        ("Times Meydanı (Times Square) hangi şehirdedir?", ["Londra", "New York", "Paris", "Tokyo"], 1, 1, "Kültür"),
        ("Kızıl Meydan hangi ülkenin başkentinde bulunur?", ["Çin", "Almanya", "İngiltere", "Rusya"], 3, 2, "Kültür"),
        # Sosyal medya & popüler kültür
        ("280 karakter sınırı ile bilinen (Eski adıyla Twitter) platformun yeni adı nedir?", ["Threads", "X", "Y", "Z"], 1, 1, "Kültür"),
        ("Videolarıyla ünlü 'YouTube' hangi şirkete aittir?", ["Facebook", "Microsoft", "Google", "Apple"], 2, 1, "Kültür")
    ]
    
    questions = []
    for idx, (text, options, ans_idx, diff, cat) in enumerate(raw_data):
        questions.append({
            "id": str(idx + 1),
            "text": text,
            "options": options,
            "correctOptionIndex": ans_idx,
            "difficulty": diff,
            "category": cat
        })

    # Shuffle for good measure
    random.shuffle(questions)
    
    with open('assets/questions.json', 'w', encoding='utf-8') as f:
        json.dump(questions, f, ensure_ascii=False, indent=2)

    print(f"Bütün alt kategorilerden en seçkin {len(questions)} özel soru eklendi!")

if __name__ == "__main__":
    generate()
