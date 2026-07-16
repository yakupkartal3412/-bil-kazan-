import json
import random
import os

def add_more():
    raw_data = [
        # --- Coğrafya & Doğa ---
        ("Brezilya'nın başkenti neresidir?", ["Sao Paulo", "Rio de Janeiro", "Brasilia", "Salvador"], 2, 2, "Coğrafya"),
        ("İngiltere'nin başkenti neresidir?", ["Manchester", "Londra", "Liverpool", "Birmingham"], 1, 1, "Coğrafya"),
        ("Asya ve Avrupa kıtalarını birbirinden ayıran boğazın adı nedir?", ["Cebelitarık", "İstanbul Boğazı", "Macellan", "Hürmüz"], 1, 1, "Coğrafya"),
        ("En kalabalık nüfusa sahip ülke hangisidir?", ["ABD", "Hindistan", "Çin", "Endonezya"], 1, 1, "Coğrafya"),
        ("Dünyanın en küçük kıtası hangisidir?", ["Avrupa", "Antarktika", "Avustralya", "Güney Amerika"], 2, 2, "Coğrafya"),
        ("Afrika kıtasının en yüksek dağı hangisidir?", ["Elbruz", "Kilimanjaro", "Everest", "Aconcagua"], 1, 3, "Coğrafya"),
        ("Hangi hayvanın siyah beyaz çizgileri vardır?", ["Kaplan", "Zebra", "Çita", "Zürafa"], 1, 1, "Doğa"),
        ("Kutuplarda yaşayan ve siyah-beyaz renklere sahip uçamayan kuş hangisidir?", ["Penguen", "Kivi", "Devekuşu", "Martı"], 0, 1, "Doğa"),
        ("Panda hangi ülkenin sembolik hayvanıdır?", ["Japonya", "Çin", "Hindistan", "Avustralya"], 1, 1, "Doğa"),
        ("Güneş sistemindeki en parlak yıldız hangisidir?", ["Kutup Yıldızı", "Sirius", "Güneş", "Vega"], 1, 3, "Doğa"),
        
        # --- Tarih ---
        ("İlk Türkçe sözlük olan Divan-u Lügati't-Türk'ün yazarı kimdir?", ["Kaşgarlı Mahmud", "Yusuf Has Hacib", "Edip Ahmet", "Hoca Ahmet Yesevi"], 0, 3, "Tarih"),
        ("Roma şehrini efsaneye göre kimler kurmuştur?", ["Romulus ve Remus", "Sezar ve Brütüs", "Spartaküs ve Crixus", "Augustus ve Tiberius"], 0, 3, "Tarih"),
        ("Mısır piramitleri hangi amaçla inşa edilmiştir?", ["Tapınak", "Kral Mezarı", "Saray", "Gözlemevi"], 1, 1, "Tarih"),
        ("1071 Malazgirt Savaşı'nda Selçuklu ordusunu yöneten sultan kimdir?", ["Tuğrul Bey", "Melikşah", "Alparslan", "Sencer"], 2, 1, "Tarih"),
        ("Türkiye Büyük Millet Meclisi'nin ilk başkanı kimdir?", ["İsmet İnönü", "Fevzi Çakmak", "Kazım Karabekir", "Mustafa Kemal Atatürk"], 3, 1, "Tarih"),
        ("1912'de batan ünlü yolcu gemisinin adı nedir?", ["Lusitania", "Britannic", "Titanic", "Queen Mary"], 2, 1, "Tarih"),
        ("Sovyet Sosyalist Cumhuriyetler Birliği (SSCB) hangi yıl dağılmıştır?", ["1989", "1991", "1993", "1995"], 1, 3, "Tarih"),
        ("Kıbrıs Barış Harekatı sırasında Türkiye'nin başbakanı kimdi?", ["Süleyman Demirel", "Bülent Ecevit", "Turgut Özal", "Adnan Menderes"], 1, 2, "Tarih"),
        ("İstanbul'un fethinden sonra Bizans İmparatorluğu'na ne oldu?", ["Sürgüne Gitti", "Yıkıldı", "Vergiye Bağlandı", "Başkenti Taşındı"], 1, 1, "Tarih"),
        ("İlk Çağ'da Anadolu'da kurulan ve başkenti Hattuşaş olan medeniyet hangisidir?", ["Urartular", "Lidyalılar", "Hititler", "Frigler"], 2, 2, "Tarih"),

        # --- Bilim & Teknoloji ---
        ("Bir gün kaç saniyedir?", ["3600", "86400", "1440", "43200"], 1, 3, "Bilim"),
        ("Mikroskobu icat eden bilim insanı kimdir?", ["Galileo", "Antonie van Leeuwenhoek", "Louis Pasteur", "Robert Hooke"], 1, 3, "Bilim"),
        ("Sesin uzayda yayılmamasının sebebi nedir?", ["Çok soğuk olması", "Çok sıcak olması", "Havasız (Vakum) ortam olması", "Yerçekimsiz olması"], 2, 2, "Bilim"),
        ("Periyodik tabloda sembolü 'Au' olan element hangisidir?", ["Gümüş", "Altın", "Alüminyum", "Bakır"], 1, 2, "Bilim"),
        ("Suyun kaynama noktası deniz seviyesinde kaç derecedir?", ["50", "90", "100", "120"], 2, 1, "Bilim"),
        ("Kulağımızdaki en küçük kemiğin adı nedir?", ["Örs", "Çekiç", "Üzengi", "Kaval"], 2, 3, "Bilim"),
        ("Hangi kan grubu 'Genel Verici' olarak bilinir?", ["A", "B", "AB", "0 (Sıfır)"], 3, 2, "Bilim"),
        ("Güneş'ten gelen zararlı ultraviyole ışınlarını hangi tabaka süzer?", ["Troposfer", "İyonosfer", "Ozon Tabakası", "Stratosfer"], 2, 1, "Bilim"),
        ("İnternetin atası sayılan ve ABD savunma bakanlığı tarafından geliştirilen ağın adı nedir?", ["ARPANET", "ETHERNET", "INTRANET", "WWW"], 0, 3, "Teknoloji"),
        ("Tarihteki ilk programcı olarak kabul edilen kadın kimdir?", ["Marie Curie", "Ada Lovelace", "Grace Hopper", "Hedy Lamarr"], 1, 3, "Teknoloji"),

        # --- Eğlence & Sanat ---
        ("Matrix filminde Neo karakterini kim canlandırmaktadır?", ["Tom Cruise", "Keanu Reeves", "Brad Pitt", "Johnny Depp"], 1, 1, "Sanat"),
        ("Gladyatör filminin başrol oyuncusu kimdir?", ["Russell Crowe", "Mel Gibson", "Gerard Butler", "Tom Hanks"], 0, 2, "Sanat"),
        ("Yıldızlı Gece tablosunun ünlü ressamı kimdir?", ["Salvador Dali", "Pablo Picasso", "Vincent van Gogh", "Claude Monet"], 2, 2, "Sanat"),
        ("Heykeltıraşlık sanatında en çok kullanılan taş türü hangisidir?", ["Granit", "Kireçtaşı", "Mermer", "Bazalt"], 2, 1, "Sanat"),
        ("'Olmak ya da olmamak, işte bütün mesele bu' sözü hangi Shakespeare karakterine aittir?", ["Othello", "Macbeth", "Kral Lear", "Hamlet"], 3, 2, "Sanat"),
        ("Hababam Sınıfı'nın yazarı kimdir?", ["Aziz Nesin", "Rıfat Ilgaz", "Orhan Veli", "Sabahattin Ali"], 1, 2, "Sanat"),
        ("Dünyanın en ünlü ödül töreni olan Oscarlar hangi şehirde dağıtılır?", ["Los Angeles", "New York", "Cannes", "Venedik"], 0, 2, "Sanat"),
        ("Harry Potter'ın gittiği büyücülük okulunun adı nedir?", ["Narnia", "Hogwarts", "Gryffindor", "Azkaban"], 1, 1, "Sanat"),
        ("SüngerBob KareŞort nerede yaşar?", ["Mercan Şehri", "Denizaltı Kasabası", "Bikini Kasabası", "Kayıp Şehir"], 2, 1, "Sanat"),
        ("Müzikte notaları gösteren 5 paralel çizgiye ne ad verilir?", ["Porte (Dizek)", "Anahtar", "Ölçü", "Akor"], 0, 2, "Sanat"),

        # --- Spor ---
        ("FIFA Dünya Kupası kaç yılda bir düzenlenir?", ["2", "3", "4", "5"], 2, 1, "Spor"),
        ("Voleybolda bir takım sahada kaç oyuncu ile yer alır?", ["5", "6", "7", "11"], 1, 1, "Spor"),
        ("Karatede en yüksek seviyeyi temsil eden kuşak rengi hangisidir?", ["Siyah", "Kırmızı", "Beyaz", "Kahverengi"], 0, 1, "Spor"),
        ("Tour de France (Fransa Turu) hangi spor dalında yapılan bir yarıştır?", ["Yüzme", "Bisiklet", "Maraton", "Otomobil"], 1, 2, "Spor"),
        ("Ringe havlu atmak boks sporunda ne anlama gelir?", ["Zafer", "Mola", "Pes Etmek", "Kavga"], 2, 1, "Spor"),
        ("Dünyaca ünlü Arjantinli futbol efsanesi Diego Maradona'nın lakabı neydi?", ["Siyah İnci", "Altın Çocuk", "Uzaylı", "El Pibe"], 1, 3, "Spor"),
        ("Galatasaray'ın 2000 yılında kazandığı Avrupa kupasının adı nedir?", ["Şampiyonlar Ligi", "UEFA Kupası", "Süper Kupa", "Kupa Galipleri"], 1, 1, "Spor"),
        ("Teniste her yıl düzenlenen ve en eski turnuva olan organizasyon hangisidir?", ["Roland Garros", "US Open", "Wimbledon", "Avustralya Açık"], 2, 3, "Spor"),
        ("Yüzme sporunda kurbağalama dışında hangi stiller vardır?", ["Kelebek, Serbest, Sırtüstü", "Kelebek, Yan, Serbest", "Sırtüstü, Atlama, Serbest", "Kelebek, Dalış, Sırtüstü"], 0, 2, "Spor"),
        ("NBA'in tüm zamanların en çok sayı atan oyuncusu unvanını Kareem Abdul-Jabbar'dan devralan kimdir?", ["Michael Jordan", "Kobe Bryant", "LeBron James", "Stephen Curry"], 2, 3, "Spor"),

        # --- Yaşam & Kültür ---
        ("Ünlü Meksika yemeği 'Taco' genellikle hangi ekmek türüyle yapılır?", ["Lavaş", "Tortilla", "Pide", "Baget"], 1, 1, "Kültür"),
        ("Japon kültüründe kadın eğlendiricilere ve sanatçılara ne ad verilir?", ["Samuray", "Ninja", "Geyşa", "Şogun"], 2, 2, "Kültür"),
        ("Yunan mitolojisinde denizler tanrısı kimdir?", ["Zeus", "Hades", "Ares", "Poseidon"], 3, 2, "Kültür"),
        ("Hristiyanların ruhani lideri Papa nerede yaşar?", ["İtalya", "Fransa", "Vatikan", "İspanya"], 2, 1, "Kültür"),
        ("Amerika Birleşik Devletleri'nin para birimi nedir?", ["Euro", "Dolar", "Sterlin", "Yen"], 1, 1, "Kültür"),
        ("Bir ürünün veya hizmetin logoyla temsil edildiği tescilli ad ismine ne denir?", ["Marka", "Patent", "Slogan", "Tasarım"], 0, 1, "Kültür"),
        ("Klostrofobi ne korkusudur?", ["Karanlık", "Yükseklik", "Örümcek", "Kapalı Alan"], 3, 1, "Kültür"),
        ("Rus alfabesi olarak da bilinen alfabe hangisidir?", ["Latin", "Kiril", "Arap", "Yunan"], 1, 2, "Kültür"),
        ("Cadılar Bayramı (Halloween) genellikle hangi ayın sonunda kutlanır?", ["Eylül", "Ekim", "Kasım", "Aralık"], 1, 1, "Kültür"),
        ("Fransa'nın sembolik kulesi Eyfel hangi materyalden yapılmıştır?", ["Demir", "Çelik", "Alüminyum", "Bronz"], 0, 2, "Kültür"),
        ("İngiliz kültürünün vazgeçilmezi olan 'Beş Çayı' geleneğini kim başlatmıştır?", ["Kraliçe Elizabeth", "Kraliçe Victoria", "Düşes Anna", "Lord Byron"], 2, 3, "Kültür"),
        ("Kuzey ışıkları (Aurora Borealis) en iyi hangi ülkelerden izlenir?", ["Mısır ve Fas", "İtalya ve İspanya", "Norveç ve İzlanda", "Brezilya ve Arjantin"], 2, 1, "Kültür"),
        ("Güney Kore'nin geleneksel milli yemeği olan fermente lahana turşusuna ne denir?", ["Sushi", "Kimchi", "Ramen", "Tofu"], 1, 3, "Kültür"),
        ("Geleneksel Türk tiyatrosunda gölge oyununun en ünlü iki karakteri kimdir?", ["Kavuklu ile Pişekar", "Karagöz ile Hacivat", "Keloğlan ile Nasreddin Hoca", "Aşuk ile Maşuk"], 1, 1, "Kültür"),
        ("Dünyanın en çok ziyaret edilen müzesi olan Louvre Müzesi nerededir?", ["Londra", "Paris", "Roma", "Madrid"], 1, 1, "Kültür"),
        ("Satranç oyununda hangi taş sadece 'L' şeklinde hareket edebilir?", ["Kale", "Fil", "At", "Vezir"], 2, 1, "Kültür"),
        ("Dünyanın yedi harikasından biri olan Tac Mahal'i kim yaptırmıştır?", ["Fatih Sultan Mehmet", "Şah Cihan", "Babür Şah", "Cengiz Han"], 1, 3, "Kültür"),
        ("Meksika şapkasına ne isim verilir?", ["Sombrero", "Fötr", "Kasket", "Bere"], 0, 2, "Kültür"),
        ("Kızılderililerin geleneksel olarak barındıkları koni şeklindeki çadırlara ne ad verilir?", ["İglo", "Tipi", "Otağ", "Yurt"], 1, 3, "Kültür"),
        ("Hangi İtalyan şehri kanalları ve gondollarıyla ünlüdür?", ["Roma", "Milano", "Napoli", "Venedik"], 3, 1, "Kültür")
    ]
    
    questions = []
    if os.path.exists('assets/questions.json'):
        with open('assets/questions.json', 'r', encoding='utf-8') as f:
            questions = json.load(f)
            
    start_id = len(questions) + 1
    
    for idx, (text, options, ans_idx, diff, cat) in enumerate(raw_data):
        questions.append({
            "id": str(start_id + idx),
            "text": text,
            "options": options,
            "correctOptionIndex": ans_idx,
            "difficulty": diff,
            "category": cat
        })

    # Shuffle everything completely
    random.shuffle(questions)
    
    # Re-assign sequential IDs cleanly
    for i, q in enumerate(questions):
        q['id'] = str(i + 1)
    
    with open('assets/questions.json', 'w', encoding='utf-8') as f:
        json.dump(questions, f, ensure_ascii=False, indent=2)

    print(f"Başarıyla eklendi! Toplam soru sayısı: {len(questions)}")

if __name__ == "__main__":
    add_more()
