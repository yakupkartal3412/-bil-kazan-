import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/audio_provider.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<QuizProvider>();
      final audio = context.read<AudioProvider>();
      final score = provider.score;
      final percentage = provider.gameMode == GameMode.classic ? (score / 15) * 100 : (score / 50) * 100;
      if (percentage == 100) {
        audio.duckBgmTemporarily();
        audio.playSfx('applause.mp3');
      } else if (percentage >= 60) {
        audio.playSfx('correct.mp3');
      } else {
        audio.playSfx('wrong.wav');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)], // Premium dark background
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Consumer<QuizProvider>(
            builder: (context, provider, child) {
              final score = provider.score;
              final total = provider.gameMode == GameMode.classic ? 15 : null;
              final coinsEarned = provider.lastEarnedCoins;
              final percentage = provider.gameMode == GameMode.classic ? (score / 15) * 100 : (score / 50) * 100;
              
              // Parse money safely for animation
              final moneyStr = provider.lastEarnedMoney.replaceAll(' ₺', '').replaceAll('₺', '').replaceAll('.', '').trim();
              final moneyEarned = int.tryParse(moneyStr) ?? 0;
              
              String message;
              String trophyAsset;
              if (percentage == 100) {
                message = "Mükemmel! Hepsini Bildin 🏆";
                trophyAsset = 'assets/images/trophy_gold.png';
              } else if (percentage >= 60) {
                message = "Tebrikler! İyi İş Çıkardın 👏";
                trophyAsset = 'assets/images/trophy_silver.png';
              } else {
                message = "Daha İyisini Yapabilirsin 💪";
                trophyAsset = 'assets/images/trophy_bronze.png';
              }

              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 3D Trophy Icon with Bounce Animation (No square background)
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 1200),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: child,
                          );
                        },
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: percentage == 100 ? Colors.amberAccent : (percentage >= 60 ? Colors.grey.shade300 : Colors.brown.shade400), 
                              width: 4
                            ),
                            boxShadow: [
                              const BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 5)),
                              BoxShadow(
                                color: percentage == 100 ? Colors.amber.withValues(alpha: 0.4) : (percentage >= 60 ? Colors.white24 : Colors.transparent), 
                                blurRadius: 30, 
                                spreadRadius: 5
                              ),
                            ],
                            image: DecorationImage(
                              image: AssetImage(trophyAsset),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Message Text
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22, // Reduced from 26
                          fontWeight: FontWeight.w900, 
                          color: Colors.white, 
                          letterSpacing: 1.2, 
                          shadows: [Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2))]
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Glassmorphism Score Card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, spreadRadius: -5)
                              ]
                            ),
                            child: Column(
                              children: [
                                // Animated Score
                                TweenAnimationBuilder(
                                  tween: IntTween(begin: 0, end: score),
                                  duration: const Duration(milliseconds: 1500),
                                  builder: (context, value, child) {
                                    return Text(
                                      total != null ? '$value / $total' : '$value',
                                      style: TextStyle(
                                        fontSize: 42, // Reduced from 54
                                        fontWeight: FontWeight.w900, 
                                        color: Colors.white, 
                                        shadows: [Shadow(color: Colors.blueAccent.withValues(alpha: 0.8), blurRadius: 15)]
                                      ),
                                    );
                                  },
                                ),
                                const Text('Doğru Cevap', style: TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w500)), // Reduced from 18
                                
                                const SizedBox(height: 16),
                                Divider(color: Colors.white.withValues(alpha: 0.2), thickness: 1),
                                const SizedBox(height: 16),
                                
                                // Animated Diamonds
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/images/3d_diamond_clear_nobg.png', width: 36, height: 36), // Reduced from 45
                                    const SizedBox(width: 12),
                                    TweenAnimationBuilder(
                                      tween: IntTween(begin: 0, end: coinsEarned),
                                      duration: const Duration(milliseconds: 1500),
                                      builder: (context, value, child) {
                                        return Text('+$value Elmas', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.cyanAccent, shadows: [Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(1, 2))])); // Reduced from 26
                                      },
                                    ),
                                  ],
                                ),
                                
                                if (provider.gameMode == GameMode.classic) ...[
                                  const SizedBox(height: 12),
                                  // Animated Money
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset('assets/images/3d_cash_icon_nobg.png', width: 36, height: 36), // Reduced from 45
                                      const SizedBox(width: 12),
                                      TweenAnimationBuilder(
                                        tween: IntTween(begin: 0, end: moneyEarned),
                                        duration: const Duration(milliseconds: 1500),
                                        builder: (context, value, child) {
                                          // Add dots for thousands separator natively
                                          String formatted = value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
                                          return Text('+$formatted ₺', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.greenAccent, shadows: [Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(1, 2))])); // Reduced from 26
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // 3D Premium Button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: double.infinity,
                          height: 55, // Reduced from 65
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)], 
                              begin: Alignment.topCenter, 
                              end: Alignment.bottomCenter
                            ),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white70, width: 2),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.6), offset: const Offset(0, 6), blurRadius: 8), // Depth shadow
                              BoxShadow(color: Colors.white.withValues(alpha: 0.3), offset: const Offset(0, -2), blurRadius: 4), // Top highlight
                              BoxShadow(color: Colors.orangeAccent.withValues(alpha: 0.5), blurRadius: 15, spreadRadius: 1), // Outer glow
                            ]
                          ),
                          child: const Center(
                            child: Text(
                              'ANA MENÜYE DÖN', 
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: 1.5) // Reduced from 20
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
