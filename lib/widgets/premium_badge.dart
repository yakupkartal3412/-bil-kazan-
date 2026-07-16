import 'package:flutter/material.dart';

class PremiumBadge extends StatelessWidget {
  final String title;
  final double fontSize;
  
  const PremiumBadge({
    super.key, 
    required this.title,
    this.fontSize = 8,
  });

  @override
  Widget build(BuildContext context) {
    List<Color> colors;
    Color textColor = Colors.black87;
    double blur = 4.0;
    
    // strip out brackets if passed from old leaderboard code like "[Öğrenci]"
    String cleanTitle = title.replaceAll('[', '').replaceAll(']', '').trim();
    
    switch (cleanTitle) {
      case 'Çömez':
        colors = [Colors.grey[400]!, Colors.grey[600]!];
        blur = 0;
        break;
      case 'Çırak':
        colors = [Colors.brown[400]!, Colors.brown[600]!];
        textColor = Colors.white;
        blur = 2;
        break;
      case 'Öğrenci':
        colors = [const Color(0xFF4FC3F7), const Color(0xFF0288D1)]; // Blue
        textColor = Colors.white;
        break;
      case 'Bilgin':
        colors = [const Color(0xFF81C784), const Color(0xFF388E3C)]; // Green
        textColor = Colors.white;
        break;
      case 'Profesör':
        colors = [const Color(0xFFBA68C8), const Color(0xFF7B1FA2)]; // Purple
        textColor = Colors.white;
        break;
      case 'Dahi':
        colors = [const Color(0xFFFF8F00), const Color(0xFFFFD54F)]; // Gold/Orange
        break;
      case 'Efsane':
        colors = [const Color(0xFFFF1744), const Color(0xFFD50000)]; // Red/Neon
        textColor = Colors.white;
        blur = 8;
        break;
      default:
        colors = [Colors.blue, Colors.lightBlue];
        textColor = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(4),
        border: cleanTitle == 'Efsane' ? Border.all(color: Colors.yellowAccent, width: 1.5) : null,
        boxShadow: [
          if (blur > 0)
            BoxShadow(color: colors[0].withValues(alpha: 0.6), blurRadius: blur, spreadRadius: 0),
        ],
      ),
      child: Text(
        cleanTitle.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: cleanTitle == 'Efsane' ? fontSize + 1 : fontSize,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
          shadows: cleanTitle == 'Efsane' ? [const Shadow(color: Colors.black54, blurRadius: 2, offset: Offset(1,1))] : null
        ),
      ),
    );
  }
}
