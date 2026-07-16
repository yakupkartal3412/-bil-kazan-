import json
import random
import os

def generate_more():
    raw_data = [
        # --- Coğrafya & Doğa ---
        ("Mısır'ın başkenti neresidir?", ["Kahire", "İskenderiye", "Luksor", "Şarm El-Şeyh"], 0, 1, "Coğrafya"),
        ("Çin'in başkenti neresidir?", ["Şanghay", "Hong Kong", "Pekin", "Makao"], 2, 2, "Coğrafya"),
        ("Hangi okyanus Amerika ve Avrupa arasındadır?", ["Pasifik", "Atlas Okyanusu", "Hint", "Kuzey Buz"], 1, 1, "Coğrafya"),
        ("Dünyanın en soğuk okyanusu hangisidir?", ["Atlas", "Pasifik", "Arktik Okyanusu", "Hint"], 2, 2, "Coğrafya"),
        ("Alpler dağ sırası hangi kıtadadır?", ["Asya", "Avrupa", "Kuzey Amerika", "Güney Amerika"], 1, 1, "Coğrafya"),
        ("Asya'nın en uzun nehri hangisidir?", ["Ganj", "Mekong", "Sarı Nehir", "Yangtze"], 3, 3, "Coğrafya"),
        ("Kanguruların doğal yaşam alanı neresidir?", ["Güney Afrika", "Brezilya", "Avustralya", "Hindistan"], 2, 1, "Doğa"),
        ("En uzun boylu kara hayvanı hangisidir?", ["Fil", "Zürafa", "Devekuşu", "Gergedan"], 1, 1, "Doğa"),
        ("Hangi doğal afet okyanus tabanındaki depremlerle oluşur?", ["Hortum", "Tsunami", "Muson", "Çığ"], 1, 1, "Doğa"),
        ("Türkiye'nin en yağışlı bölgesi hangisidir?", ["Ege", "Akdeniz", "Karadeniz", "Marmara"], 2, 1, "Türkiye"),
        
        # --- Tarih ---
        ("Magna Carta hangi ülkede imzalanmıştır?", ["Fransa", "İspanya", "İngiltere", "İtalya"], 2, 3, "Tarih"),
        ("Amerika Birleşik Devletleri'nin ilk başkanı kimdir?", ["Abraham Lincoln", "George Washington", "Thomas Jefferson", "John Adams"], 1, 1, "Tarih"),
        ("Mustafa Kemal Atatürk'ün doğum yılı nedir?", ["1880", "1881", "1882", "1883"], 1, 1, "Türk Tarihi"),
        ("Çanakkale Savaşı hangi padişah döneminde olmuştur?", ["V. Mehmed Reşad", "II. Abdülhamid", "Vahdettin", "Abdülaziz"], 0, 3, "Osmanlı"),
        ("Truva Savaşı efsanesinde adı geçen tahta at hangi şehirde yapılmıştır?", ["Atina", "Sparta", "Truva", "Miken"], 2, 2, "Tarih"),
        ("Roma İmparatorluğu ikiye ne zaman ayrılmıştır?", ["MS 395", "MS 476", "MS 1453", "MS 1071"], 0, 3, "Tarih"),
        ("1. Dünya Savaşı'nın çıkmasına sebep olan suikast hangi şehirde gerçekleşmiştir?", ["Berlin", "Viyana", "Saraybosna", "Paris"], 2, 3, "Tarih"),
        ("Küba Füze Krizi hangi iki ülke arasında yaşanmıştır?", ["ABD - Çin", "ABD - SSCB", "İngiltere - Fransa", "Almanya - Rusya"], 1, 2, "Tarih"),
        ("Mimar Sinan'ın 'Ustalık Eserim' dediği cami hangisidir?", ["Süleymaniye", "Selimiye", "Şehzade", "Sultanahmet"], 1, 2, "Osmanlı"),
        ("Fatih Sultan Mehmet'in babası kimdir?", ["I. Murad", "Yıldırım Bayezid", "II. Murad", "Yavuz Sultan Selim"], 2, 2, "Osmanlı"),

        # --- Bilim & Teknoloji ---
        ("Kızıl Gezegen olarak bilinen gezegen hangisidir?", ["Venüs", "Jüpiter", "Satürn", "Mars"], 3, 1, "Bilim"),
        ("Güneş'e en uzak gezegen hangisidir?", ["Uranüs", "Neptün", "Plüton", "Satürn"], 1, 2, "Bilim"),
        ("İnsan vücudunda en çok bulunan mineral hangisidir?", ["Demir", "Çinko", "Kalsiyum", "Magnezyum"], 2, 2, "Bilim"),
        ("Hangi vitamin güneşte kalındığında vücut tarafından üretilir?", ["A Vitamini", "B Vitamini", "C Vitamini", "D Vitamini"], 3, 1, "Bilim"),
        ("Karbondioksitin katı haline ne ad verilir?", ["Kuru Buz", "Sıvı Azot", "Ağır Su", "Kristal Karbon"], 0, 3, "Bilim"),
        ("E=mc^2 formülü kime aittir?", ["Newton", "Bohr", "Einstein", "Heisenberg"], 2, 1, "Bilim"),
        ("Matbaayı Avrupa'da kim yaygınlaştırmıştır?", ["Galileo", "Gutenberg", "Newton", "Tesla"], 1, 1, "Teknoloji"),
        ("İlk başarılı uçağı uçuran kardeşlerin soyadı nedir?", ["Wright", "Montgolfier", "Lumiere", "Grimm"], 0, 1, "Teknoloji"),
        ("Apple şirketinin kurucularından olan 'Steve' isimli iki kişi kimdir?", ["Jobs ve Wozniak", "Jobs ve Gates", "Wozniak ve Allen", "Jobs ve Cook"], 0, 2, "Teknoloji"),
        ("Bir bilgisayarın geçici hafızasına ne ad verilir?", ["ROM", "CPU", "RAM", "HDD"], 2, 1, "Teknoloji"),

        # --- Eğlence & Sanat ---
        ("Geleceğe Dönüş serisindeki profesörün adı nedir?", ["Dr. Who", "Dr. Emmett Brown", "Dr. Frankenstein", "Dr. Octopus"], 1, 2, "Sanat"),
        ("Yüzüklerin Efendisi filminin yönetmeni kimdir?", ["Peter Jackson", "Steven Spielberg", "George Lucas", "James Cameron"], 0, 2, "Sanat"),
        ("Efsanevi rock grubu Queen'in solisti kimdi?", ["Mick Jagger", "John Lennon", "Freddie Mercury", "Kurt Cobain"], 2, 1, "Sanat"),
        ("Ünlü pop şarkıcısı Madonna'nın soyadı nedir?", ["Ciccone", "Smith", "Johnson", "Williams"], 0, 3, "Sanat"),
        ("Breaking Bad dizisinde Walter White'ın kullandığı takma ad nedir?", ["Heisenberg", "Einstein", "Oppenheimer", "Schrödinger"], 0, 2, "Sanat"),
        ("La Casa de Papel dizisinde 'Profesör' karakterini canlandıran oyuncu kimdir?", ["Pedro Alonso", "Alvaro Morte", "Jaime Lorente", "Miguel Herran"], 1, 3, "Sanat"),
        ("'Çığlık' tablosunun ressamı kimdir?", ["Van Gogh", "Edvard Munch", "Claude Monet", "Salvador Dali"], 1, 3, "Sanat"),
        ("Ünlü 'Venüs'ün Doğuşu' tablosunu kim çizmiştir?", ["Botticelli", "Da Vinci", "Michelangelo", "Raphael"], 0, 3, "Sanat"),
        ("'Küçük Prens' kitabının yazarı kimdir?", ["Victor Hugo", "Antoine de Saint-Exupery", "Albert Camus", "Jules Verne"], 1, 2, "Sanat"),
        ("Şirinler çizgi filminin yaratıcısı kimdir?", ["Peyo", "Walt Disney", "Stan Lee", "Hergé"], 0, 3, "Sanat"),

        # --- Spor ---
        ("Türkiye Süper Ligi'nde en çok şampiyon olan takım hangisidir?", ["Beşiktaş", "Fenerbahçe", "Galatasaray", "Trabzonspor"], 2, 1, "Spor"),
        ("Şampiyonlar Ligi'ni en çok kazanan takım hangisidir?", ["Barcelona", "Real Madrid", "Bayern Münih", "Milan"], 1, 1, "Spor"),
        ("Usain Bolt hangi ülkenin vatandaşıdır?", ["ABD", "Nijerya", "Jamaika", "İngiltere"], 2, 1, "Spor"),
        ("Bir futbol takımında sahada en fazla kaç oyuncu olabilir?", ["10", "11", "12", "9"], 1, 1, "Spor"),
        ("Buz hokeyinde kaç periyot oynanır?", ["2", "3", "4", "5"], 1, 2, "Spor"),
        ("Bir Amerikan futbolu takımının sahada kaç oyuncusu bulunur?", ["11", "9", "7", "15"], 0, 3, "Spor"),
        ("Dünya Satranç Şampiyonu unvanını en uzun süre elinde tutan oyuncu kimdir?", ["Kasparov", "Carlsen", "Fischer", "Lasker"], 3, 3, "Spor"),
        ("Türkiye Milli Basketbol Takımı'nın lakabı nedir?", ["12 Cesur Yürek", "12 Dev Adam", "Pota Kaplanları", "Smaç Ustaları"], 1, 1, "Spor"),
        ("Güreşte iki omuzun aynı anda yere değmesiyle oluşan duruma ne ad verilir?", ["Tuş", "Pes", "Nakavt", "Kilit"], 0, 1, "Spor"),
        ("Olimpiyatlarda maraton koşusu sonrasında yakılan ateşin adı nedir?", ["Barış Ateşi", "Olimpiyat Ateşi", "Zafer Meşalesi", "Prometheus Ateşi"], 1, 1, "Spor"),

        # --- Yaşam & Kültür ---
        ("Pizza'nın anavatanı neresidir?", ["Fransa", "İspanya", "İtalya", "Yunanistan"], 2, 1, "Kültür"),
        ("Baklava hangi ülkenin tatlısıdır?", ["Yunanistan", "Türkiye", "Suriye", "İran"], 1, 1, "Kültür"),
        ("Zeus'un Roma mitolojisindeki karşılığı nedir?", ["Apollo", "Jüpiter", "Neptün", "Plüton"], 1, 2, "Kültür"),
        ("Poseidon'un simgesi olan silah nedir?", ["Kalkan", "Üç dişli yaba", "Kılıç", "Ok"], 1, 1, "Kültür"),
        ("Budizm'in kurucusu kimdir?", ["Laozi", "Siddhartha Gautama", "Konfüçyüs", "Dalai Lama"], 1, 2, "Kültür"),
        ("İslam dininde yılın hangi ayında oruç tutulur?", ["Şaban", "Recep", "Ramazan", "Muharrem"], 2, 1, "Kültür"),
        ("Japonya'nın para birimi nedir?", ["Yen", "Won", "Yuan", "Baht"], 0, 2, "Kültür"),
        ("Hindistan'ın para birimi nedir?", ["Rupi", "Dinar", "Dirhem", "Pesos"], 0, 2, "Kültür"),
        ("Venedik kanallarında ulaşım için kullanılan uzun kayıklara ne ad verilir?", ["Kano", "Gondol", "Sandal", "Katamaran"], 1, 1, "Kültür"),
        ("Rusya'da iç içe geçen ünlü ahşap bebeklere ne ad verilir?", ["Matruşka", "Babuşka", "Garmoshka", "Uşanka"], 0, 1, "Kültür")
    ]
    
    questions = []
    # Fetch existing
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
    generate_more()
