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
              title: '🎮 OYUN MODLARI',
              content: 'Oyunda yeteneklerini test edebileceğin 4 ana mod bulunur:\n'
                  '• Klasik Mod: Klasik kurallarla yarışıp en yüksek ödülü hedeflersin.\n'
                  '• Sonsuz Mod: Hiç hata yapmadan, arka arkaya en çok kaç soru bilebileceğini test edersin.\n'
                  '• Global Düello: Çevrimiçi rastgele rakiplerle eşleşip zeka savaşı verirsin. Kazanan tüm bahsi alır!\n'
                  '• Arkadaşınla Oyna: Aynı cihaz üzerinden ekranı ikiye bölerek arkadaşınla kıyasıya bir bilgi yarışması yapabilirsin.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: '🏆 LİDERLİK TABLOSU',
              content: 'Oyun içi başarına göre Dünya Sıralamasına girersin.\n'
                  '• Haftalık Sıfırlama: Liderlik tablosu her hafta sonu sıfırlanır.\n'
                  '• Ödüller: Sıfırlanma anında İlk 10\'a giren oyuncular çok değerli elmas ödülleri kazanır.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: '🧠 UNVAN VE IQ SİSTEMİ',
              content: 'Oyuna 50 IQ ile başlarsın. Soru bildikçe IQ\'n yükselir, bilemedikçe düşer.\n'
                  '• Unvanlar: Çömez, Çırak, Öğrenci, Bilgin, Profesör, Dahi ve Efsane.\n'
                  '• IQ seviyene göre havalı bir unvan etiketi (rozet) kazanıp liderlik tablosunda hava atabilirsin.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: '🃏 JOKERLER (PREMIUM)',
              content: 'Zorlandığın anlarda kullanabileceğin jokerler:\n'
                  '• ✂️ Yarı Yarıya: Yanlış olan 2 şıkkı anında eler.\n'
                  '• 📞 Telefon: Soruyu bir uzmana arayıp sorarsın.\n'
                  '• 📊 Seyirciye Sor: Şıkları elediğinde geriye kalanları seyirciye oylatır.\n'
                  '• ⏩ Soruyu Geç: Soruyu doğrudan geçer, elenmekten kurtarır.\n\n'
                  '💡 Önemli: Jokerlerin ilk kullanımı ücretsizdir. Aynı jokeri 2. kez kullanmak istersen 25 💎 (Elmas) ödemen gerekir!',
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: '🛍️ MAĞAZA & AVATARLAR',
              content: 'Oyun oynadıkça kazandığın elmaslarla Mağaza\'dan avatar satın alabilirsin.\n'
                  '• Seçilebilen Avatarlar: Tesla, Da Vinci, Newton gibi efsane bilim insanlarının avatarlarını alıp profilinde kullanabilirsin.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: '🌟 BAŞARIMLAR & GÜNLÜK ÖDÜLLER',
              content: '• Çarkıfelek: Her 24 saatte bir ücretsiz çevirip elmas ve ödüller kazanabilirsin.\n'
                  '• Görevler: Günlük görevleri tamamlayarak ekstra ödüller elde edebilirsin.\n'
                  '• Başarımlar: Oyunda gösterdiğin üstün performanslar (örneğin art arda soru bilme, unvan atlama) sayesinde eşsiz elmas ödülleri toplayabilirsin.',
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
