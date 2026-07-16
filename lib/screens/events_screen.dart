import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../utils/constants.dart';
import 'quiz_screen.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appPurpleBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Özel Etkinlikler',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kategorini Seç, 30 Soruyu Bil, 1000 💎 Kazan!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.amberAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildEventCard(
                      context,
                      title: 'Yeşilçam Efsaneleri',
                      subtitle: 'Şener Şen, Kemal Sunal ve unutulmaz replikler.',
                      icon: Icons.movie,
                      color: Colors.redAccent,
                      keywords: ['Yeşilçam'],
                    ),
                    const SizedBox(height: 12),
                    _buildEventCard(
                      context,
                      title: 'Türk Müziği',
                      subtitle: 'Barış Manço, 90\'lar Pop ve altın şarkılar.',
                      icon: Icons.music_note,
                      color: Colors.purpleAccent,
                      keywords: ['Türk Müziği'],
                    ),
                    const SizedBox(height: 12),
                    _buildEventCard(
                      context,
                      title: 'Anadolu Kültürü',
                      subtitle: 'Efsaneler, yöresel kültür ve deyimler.',
                      icon: Icons.public,
                      color: Colors.amber,
                      keywords: ['Anadolu Kültürü'],
                    ),
                    const SizedBox(height: 12),
                    _buildEventCard(
                      context,
                      title: 'Efsane Diziler',
                      subtitle: 'Unutulmaz Türk dizileri ve efsane karakterleri.',
                      icon: Icons.tv,
                      color: Colors.blueAccent,
                      keywords: ['Türk Dizileri'],
                    ),
                    const SizedBox(height: 12),
                    _buildEventCard(
                      context,
                      title: 'Türk Mutfağı',
                      subtitle: 'Kebaplar, tatlılar ve yöresel yemek sırlarımız.',
                      icon: Icons.restaurant,
                      color: Colors.orangeAccent,
                      keywords: ['Türk Mutfağı'],
                    ),
                    const SizedBox(height: 12),
                    _buildEventCard(
                      context,
                      title: 'Edebiyat ve Şiir',
                      subtitle: 'Roman kahramanları ve unutulmaz dizeler.',
                      icon: Icons.menu_book,
                      color: Colors.tealAccent,
                      keywords: ['Türk Edebiyatı'],
                    ),
                    const SizedBox(height: 12),
                    _buildEventCard(
                      context,
                      title: 'Büyük İcatlar',
                      subtitle: 'Dünyayı değiştiren teknolojik buluşlar.',
                      icon: Icons.lightbulb,
                      color: Colors.cyanAccent,
                      keywords: ['Teknoloji'],
                    ),
                    const SizedBox(height: 12),
                    _buildEventCard(
                      context,
                      title: 'Doğa ve Hayvanlar',
                      subtitle: 'Hayvanlar alemi ve ilginç biyolojik gerçekler.',
                      icon: Icons.pets,
                      color: Colors.greenAccent,
                      keywords: ['Doğa'],
                    ),
                    const SizedBox(height: 12),
                    _buildEventCard(
                      context,
                      title: 'Efsane Futbol',
                      subtitle: 'Yeşil sahaların unutulmaz efsaneleri ve kuralları.',
                      icon: Icons.sports_soccer,
                      color: Colors.green,
                      keywords: ['Futbol'],
                    ),
                    const SizedBox(height: 12),
                    _buildEventCard(
                      context,
                      title: 'Eğlenceli Tarih',
                      subtitle: 'Tarihin arka odasındaki ilginç gerçekler ve krallar.',
                      icon: Icons.account_balance,
                      color: Colors.orangeAccent,
                      keywords: ['Tarih'],
                    ),
                    const SizedBox(height: 12),
                    _buildEventCard(
                      context,
                      title: 'Coğrafya Gezgini',
                      subtitle: 'İlginç ülkeler, kültürel coğrafya ve harikalar.',
                      icon: Icons.public,
                      color: Colors.blue,
                      keywords: ['Coğrafya'],
                    ),
                    const SizedBox(height: 12),
                    _buildEventCard(
                      context,
                      title: 'Basketbol Ateşi',
                      subtitle: 'Parkelerin hakimleri, efsaneler ve ilginç kurallar.',
                      icon: Icons.sports_basketball,
                      color: Colors.orange,
                      keywords: ['Basketbol'],
                    ),
                    const SizedBox(height: 12),
                    _buildEventCard(
                      context,
                      title: 'Genel Kültür',
                      subtitle: 'Psikoloji, sanat, bilim ve hayata dair her şey.',
                      icon: Icons.lightbulb_outline,
                      color: Colors.pinkAccent,
                      keywords: ['Genel Kültür'],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<String> keywords,
  }) {
    return GestureDetector(
      onTap: () {
        // Show start dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: AppColors.menuButtonBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                title,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Bu etkinlikte sadece bu kategoriye ait sorular çıkacak.\n\n30 soruyu doğru bilirsen tam 1000 💎 hediye!',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('İptal', style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // close dialog
                    context.read<QuizProvider>().startEventGame(title, keywords);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const QuizScreen()),
                    );
                  },
                  child: const Text('Başla!', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.menuButtonBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color.withValues(alpha: 0.5), size: 16),
          ],
        ),
      ),
    );
  }
}
