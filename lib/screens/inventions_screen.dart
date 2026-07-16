import 'package:flutter/material.dart';
import '../utils/constants.dart';

class GeniusInvention {
  final String name;
  final String imagePath;
  final List<String> inventions;

  GeniusInvention(this.name, this.imagePath, this.inventions);
}

class InventionsScreen extends StatelessWidget {
  InventionsScreen({super.key});

  final List<GeniusInvention> _geniuses = [
    GeniusInvention('Albert Einstein', 'assets/images/einstein_avatar.png', [
      'İzafiyet Teorisi (E=mc²)',
      'Fotoelektrik Etki',
      'Kuantum Mekaniğine Katkıları'
    ]),
    GeniusInvention('Isaac Newton', 'assets/images/newton_avatar.png', [
      'Yerçekimi Kanunu',
      'Diferansiyel ve İntegral Hesap (Kalkülüs)',
      'Yansıtmalı Teleskop'
    ]),
    GeniusInvention('Nikola Tesla', 'assets/images/tesla_avatar.png', [
      'Alternatif Akım (AC) Sistemi',
      'Tesla Bobini',
      'Radyonun Temelleri',
      'Kablosuz Enerji Transferi'
    ]),
    GeniusInvention('Marie Curie', 'assets/images/curie_avatar.png', [
      'Radyum ve Polonyum Keşfi',
      'Taşınabilir X-Ray Cihazları',
      'Radyoaktivite Teorisi'
    ]),
    GeniusInvention('Galileo Galilei', 'assets/images/galileo_avatar.png', [
      'Jüpiter\'in 4 Uydusu (Galileo Uyduları)',
      'Geliştirilmiş Astronomik Teleskop',
      'Sarkaçlı Saat Tasarımı'
    ]),
    GeniusInvention('Stephen Hawking', 'assets/images/hawking_avatar.png', [
      'Hawking Işıması',
      'Kara Deliklerin Termodinamiği',
      'Evrenin Genişleme Modeli'
    ]),
    GeniusInvention('Charles Darwin', 'assets/images/darwin_avatar.png', [
      'Evrim Teorisi',
      'Doğal Seçilim Mekanizması',
      '"Türlerin Kökeni" Eseri'
    ]),
    GeniusInvention('Thomas Edison', 'assets/images/edison_avatar.png', [
      'Pratik Karbon Flamanlı Ampul',
      'Fonograf (Ses Kayıt Cihazı)',
      'Sinema Kamerası (Kinetoskop)'
    ]),
    GeniusInvention('Alexander G. Bell', 'assets/images/bell_avatar.png', [
      'Telefonun İcadı',
      'Fotofon (Işıkla Ses İletimi)',
      'Metal Dedektörü'
    ]),
    GeniusInvention('Alan Turing', 'assets/images/turing_avatar.png', [
      'Enigma Şifre Kırma Makinesi',
      'Turing Testi (Yapay Zeka)',
      'Modern Bilgisayarların Teorik Temeli'
    ]),
    GeniusInvention('Pisagor', 'assets/images/pythagoras_avatar.png', [
      'Pisagor Teoremi (a²+b²=c²)',
      'Müzikal Aralıkların Oranları',
      'İrrasyonel Sayıların Temelleri'
    ]),
    GeniusInvention('Leonardo da Vinci', 'assets/images/davinci_avatar.png', [
      'Paraşüt ve Helikopter Tasarımları',
      'Zırhlı Tank Eskizleri',
      'Detaylı İnsan Anatomisi Çizimleri'
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appPurpleBg,
      appBar: AppBar(
        backgroundColor: AppColors.appPurpleBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Dehalar ve İcatları',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        physics: const BouncingScrollPhysics(),
        itemCount: _geniuses.length,
        itemBuilder: (context, index) {
          final genius = _geniuses[index];
          return _buildGeniusCard(genius);
        },
      ),
    );
  }

  Widget _buildGeniusCard(GeniusInvention genius) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.menuButtonBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.menuButtonBorder, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white12,
              backgroundImage: AssetImage(genius.imagePath),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    genius.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'En Bilinen İcatları:',
                    style: TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...genius.inventions.map((invention) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(color: Colors.cyanAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(
                              invention,
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
