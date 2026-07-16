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
                      title: 'Tarih Ustası',
                      subtitle: 'Geçmişin derinliklerine yolculuk...',
                      icon: Icons.account_balance,
                      color: Colors.orangeAccent,
                      keywords: ['Tarih', 'Osmanlı', 'Türk Tarihi'],
                    ),
                    const SizedBox(height: 12),
                    _buildEventCard(
                      context,
                      title: 'Coğrafya Gezgini',
                      subtitle: 'Dünyayı ne kadar tanıyorsun?',
                      icon: Icons.public,
                      color: Colors.greenAccent,
                      keywords: ['Coğrafya', 'Ülkeler', 'Doğa'],
                    ),
                    const SizedBox(height: 12),
                    _buildEventCard(
                      context,
                      title: 'Spor Tutkunu',
                      subtitle: 'Spor kuralları, efsaneler ve daha fazlası.',
                      icon: Icons.sports_soccer,
                      color: Colors.lightBlueAccent,
                      keywords: ['Spor'],
                    ),
                    const SizedBox(height: 12),
                    _buildEventCard(
                      context,
                      title: 'Sinema & Sanat',
                      subtitle: 'Film replikleri ve sanat dünyası.',
                      icon: Icons.movie_filter,
                      color: Colors.pinkAccent,
                      keywords: ['Sinema', 'Sanat', 'Dizi', 'Televizyon'],
                    ),
                    const SizedBox(height: 12),
                    _buildEventCard(
                      context,
                      title: 'Bilim İnsanı',
                      subtitle: 'Bilim, teknoloji ve matematik.',
                      icon: Icons.science,
                      color: Colors.cyanAccent,
                      keywords: ['Bilim', 'Teknoloji', 'Matematik'],
                    ),
                    const SizedBox(height: 12),
                    _buildEventCard(
                      context,
                      title: 'Genel Kültür',
                      subtitle: 'Hayata dair her şeyden karışık sorular.',
                      icon: Icons.lightbulb,
                      color: Colors.purpleAccent,
                      keywords: ['Kültür', 'Hayat', 'Okul', 'Genel'],
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
