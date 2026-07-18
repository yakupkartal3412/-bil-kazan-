import 'package:flutter/material.dart';
import '../utils/constants.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appPurpleBg,
      appBar: AppBar(
        backgroundColor: AppColors.appPurpleBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nasıl Oynanır?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: '🎮 OYUN MODLARI (5 FARKLI MOD)',
              content: 'Oyunda yeteneklerini test edebileceğin çeşitli modlar bulunur:\n'
                  '• Klasik Mod: Klasik kurallarla yarışıp en yüksek ödülü hedeflersin.\n'
                  '• Sonsuz Mod: Hiç hata yapmadan, arka arkaya en çok kaç soru bilebileceğini test edersin.\n'
                  '• Küresel Düello: Çevrimiçi rastgele rakiplerle eşleşip zeka savaşı verirsin. Kazanan tüm bahsi (elmasları) alır!\n'
                  '• Çevrimdışı Düello: Aynı cihaz üzerinden ekranı ikiye bölerek arkadaşınla kıyasıya yarışırsın.\n'
                  '• Etkinlik Modu (Kategori): Bilim, Tarih, Spor gibi sadece kendi seçtiğin özel kategorilerde yarışırsın.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: '🏆 LİDERLİK TABLOSU',
              content: 'Oyun içi başarına göre Dünya Sıralamasına girersin.\n'
                  '• Haftalık Sıfırlama: Liderlik tablosu her hafta sonu (Pazar gecesi) sıfırlanır.\n'
                  '• Ödüller: Sıfırlanma anında İlk 10\'a giren oyuncular çok değerli elmas ödülleri kazanır.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: '🧠 UNVAN VE IQ SİSTEMİ',
              content: 'Oyuna 50 IQ ile başlarsın. Soru bildikçe IQ\'n yükselir, bilemedikçe veya süren bittiğinde düşer.\n'
                  '• Unvanlar: Çömez, Çırak, Öğrenci, Bilgin, Profesör, Dahi ve Efsane.\n'
                  '• Her unvanın kendine özel havalı bir etiketi (rozeti) vardır, rakiplerine karşı hava atabilirsin.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: '🃏 JOKERLER (PREMIUM)',
              content: 'Zorlandığın anlarda kullanabileceğin 4 temel joker bulunur:\n'
                  '• ✂️ Yarı Yarıya: Yanlış olan 2 şıkkı anında eler.\n'
                  '• 📞 Telefon: Soruyu sana en uygun uzmana arayıp sorarsın.\n'
                  '• 📊 Seyirciye Sor: Şıkları elediğinde geriye kalanları seyirciye oylatır.\n'
                  '• ⏩ Soruyu Geç: Soruyu doğrudan geçer, elenmekten kurtarır.\n\n'
                  '💡 Önemli: Jokerlerin ilk kullanımı ücretsizdir. Aynı jokeri 2. kez kullanmak istersen Joker hakkından harcarsın ya da 25 💎 (Elmas) ödersin!',
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: '🛍️ MAĞAZA & AVATARLAR',
              content: 'Mağazayı ziyaret ederek hesabını ve profilini güçlendirebilirsin:\n'
                  '• Elmas ve Oda Kartı Paketleri: Oyun içi avantajlar sağlamak için elmas veya arkadaşlarınla yarışmak için oda kartı satın alabilirsin.\n'
                  '• Joker Kasaları: "Mega Joker Kasası" gibi paketlerle joker stokunu fulleyebilirsin.\n'
                  '• Premium Avatarlar: Einstein, Tesla, Newton gibi efsanevi bilim insanlarının hareketli ve şık avatarlarını satın alabilirsin. Satın aldığın avatar anında profiline kuşanılır!',
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: '🤝 DAVET ET & KAZAN',
              content: 'Ana ekrandaki "Davet Et" bölümünden kendi özel Davet Kodunu görebilirsin.\n'
                  '• Arkadaşlarını bu kodla oyuna kaydettirirsen, her bir arkadaşın için tam 10.000 Elmas 💎 kazanırsın!',
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: '🔑 HESAP GÜVENLİĞİ VE OYUNCU ID',
              content: 'Ayarlar (⚙️) menüsüne girerek hesap işlemlerini yapabilirsin.\n'
                  '• Hesabı Kaydet: Eğer Misafir hesapla girmişsen, emeğinin kaybolmaması için E-posta veya Google ile hesabını kalıcı hale getirebilirsin.\n'
                  '• Oyuncu ID: Yine ayarlar menüsünde sana özel "Gizli Numaran (Oyuncu ID)" bulunur.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: '🌟 GÜNLÜK ÖDÜLLER & ÇARKIFELEK',
              content: '• Çarkıfelek: Her 24 saatte bir ücretsiz çevirip elmas ve ekstra jokerler kazanabilirsin.\n'
                  '• Görevler: Ana menüden ulaşabileceğin "Günlük Görevleri" tamamlayarak daha hızlı seviye atlayabilirsin.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.menuButtonBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.menuButtonBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.cyanAccent, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }
}
