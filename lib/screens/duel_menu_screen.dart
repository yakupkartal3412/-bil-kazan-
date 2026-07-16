import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import 'split_screen_vs.dart';
import 'bot_duel_screen.dart';
import 'multiplayer_lobby_screen.dart';

class DuelMenuScreen extends StatelessWidget {
  const DuelMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A), // Çok koyu premium arka plan
      body: Stack(
        children: [
          // Arka plan parlamaları (Neon Orbs)
          Positioned(top: -50, left: -50, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.blueAccent.withValues(alpha: 0.15), blurRadius: 100, spreadRadius: 50)]))),
          Positioned(bottom: -50, right: -50, child: Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.redAccent.withValues(alpha: 0.15), blurRadius: 100, spreadRadius: 50)]))),
          Positioned(top: 300, left: 50, child: Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.purpleAccent.withValues(alpha: 0.1), blurRadius: 100, spreadRadius: 50)]))),

          SafeArea(
            child: Column(
              children: [
                // Özel Premium AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'DÜELLO MODU',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3.0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Dengelemek için
                    ],
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(
                          child: Text(
                            'RAKİBİNİ SEÇ',
                            style: TextStyle(
                              color: Colors.white54, 
                              fontSize: 14, 
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4.0
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Rastgele Rakip Butonu
                        _buildModeCard(
                          context,
                          title: 'GLOBAL YARIŞ',
                          subtitle: 'Rastgele rakiplere karşı nefes kesen online arena!',
                          icon: Icons.public,
                          primaryColor: Colors.cyanAccent,
                          secondaryColor: Colors.blue.shade800,
                          onTap: () {
                            _showBettingDialog(context);
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Yerel Düello Butonu
                        _buildModeCard(
                          context,
                          title: 'YEREL DÜELLO (AYNI EKRAN)',
                          subtitle: 'Aynı ekranı paylaşarak hızını kapıştır!',
                          icon: Icons.splitscreen,
                          primaryColor: Colors.amberAccent,
                          secondaryColor: Colors.deepOrange.shade800,
                          onTap: () {
                            _showNameInputDialog(context);
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Online Arkadaşla Oyna Butonu
                        _buildModeCard(
                          context,
                          title: 'ARKADAŞINLA OYNA (ONLİNE)',
                          subtitle: 'Ayrı telefonlardan, Oda Kodu ile aynı soruları çöz!',
                          icon: Icons.wifi_tethering,
                          primaryColor: Colors.purpleAccent,
                          secondaryColor: Colors.purple.shade900,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const MultiplayerLobbyScreen()),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color primaryColor,
    required Color secondaryColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 140),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white.withValues(alpha: 0.03), // Glassmorphism arka plan
          border: Border.all(color: primaryColor.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(color: primaryColor.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Sağ alt köşe dev ikon
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(icon, size: 140, color: Colors.white.withValues(alpha: 0.05)),
              ),
              // Renk geçişli gradient efekti (Sol kenar)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 6,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 32.0, right: 24.0, top: 24.0, bottom: 24.0),
                child: Row(
                  children: [
                    // Sol taraftaki premium ikon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [primaryColor.withValues(alpha: 0.2), secondaryColor.withValues(alpha: 0.1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: primaryColor.withValues(alpha: 0.5), width: 1),
                        boxShadow: [
                          BoxShadow(color: primaryColor.withValues(alpha: 0.2), blurRadius: 12)
                        ],
                      ),
                      child: Icon(icon, size: 32, color: primaryColor),
                    ),
                    const SizedBox(width: 20),
                    // Yazılar
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white, 
                              fontSize: 20, 
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6), 
                              fontSize: 13,
                              height: 1.4
                            ),
                          ),
                        ],
                      ),
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

  void _showNameInputDialog(BuildContext context) {
    final quizProvider = context.read<QuizProvider>();
    final TextEditingController p1Controller = TextEditingController(text: quizProvider.lastDuelP1Name);
    final TextEditingController p2Controller = TextEditingController(text: quizProvider.lastDuelP2Name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5))),
          title: const Text('Oyuncu İsimleri', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: p1Controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: '1. Oyuncu (Alt Taraf)',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: p2Controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: '2. Oyuncu (Üst Taraf)',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
                  ),
                ),
                if (quizProvider.lastDuelP1Series > 0 || quizProvider.lastDuelP2Series > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      'İsimleri değiştirmezseniz ${quizProvider.lastDuelP1Series}-${quizProvider.lastDuelP2Series} serisine kaldığınız yerden devam edersiniz.',
                      style: const TextStyle(color: Colors.amberAccent, fontSize: 11, fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Close name dialog
                    _showLocalLeaderboardDialog(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.amber.shade600, Colors.amber.shade900],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amberAccent.withValues(alpha: 0.4),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: Colors.amberAccent, width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.emoji_events, color: Colors.white, size: 28),
                        SizedBox(width: 12),
                        Text(
                          'VIP ŞAMPİYONLAR TABLOSU', 
                          style: TextStyle(
                            color: Colors.white, 
                            fontWeight: FontWeight.w900, 
                            fontSize: 15,
                            letterSpacing: 1.2,
                            shadows: [Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(1, 2))]
                          )
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                String p1Name = p1Controller.text.trim().isEmpty ? 'KULLANICI 1' : p1Controller.text.trim();
                String p2Name = p2Controller.text.trim().isEmpty ? 'KULLANICI 2' : p2Controller.text.trim();
                
                // Kaldığı yerden devam mantığı
                int p1Series = 0;
                int p2Series = 0;
                if (p1Name == quizProvider.lastDuelP1Name && p2Name == quizProvider.lastDuelP2Name) {
                  p1Series = quizProvider.lastDuelP1Series;
                  p2Series = quizProvider.lastDuelP2Series;
                }

                Navigator.pop(context); // Dialogu kapat
                Navigator.push(context, MaterialPageRoute(builder: (_) => SplitScreenVS(
                  p1Name: p1Name, 
                  p2Name: p2Name,
                  p1SeriesWins: p1Series,
                  p2SeriesWins: p2Series,
                )));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: Colors.black87),
              child: const Text('MEYDAN OKU!', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      }
    );
  }

  void _showClearLeaderboardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5))),
          title: const Text('Tabloyu Temizle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text('Yerel şampiyonlar tablosundaki tüm puanları silmek istediğinize emin misiniz? Bu işlem geri alınamaz.', style: TextStyle(color: Colors.white70)),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 120,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey.shade700, Colors.grey.shade900],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white54, width: 2),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
                child: const Text('İptal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, shadows: [Shadow(color: Colors.black, blurRadius: 2, offset: Offset(1, 1))])),
              ),
            ),
            GestureDetector(
              onTap: () {
                context.read<QuizProvider>().clearLocalDuelScores();
                Navigator.pop(context);
                _showLocalLeaderboardDialog(context);
              },
              child: Container(
                width: 120,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.redAccent, Colors.red.shade900],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.redAccent.shade100, width: 2),
                  boxShadow: [
                    BoxShadow(color: Colors.redAccent.withValues(alpha: 0.5), blurRadius: 10, offset: const Offset(0, 2)),
                  ],
                ),
                child: const Text('Evet, Sil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, shadows: [Shadow(color: Colors.black, blurRadius: 2, offset: Offset(1, 1))])),
              ),
            ),
          ],
        );
      }
    );
  }

  void _showLocalLeaderboardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final scores = context.watch<QuizProvider>().localDuelScores;
        var sortedEntries = scores.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
        
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF161625),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.4), width: 1.5),
              boxShadow: [
                BoxShadow(color: Colors.amberAccent.withValues(alpha: 0.05), blurRadius: 20, spreadRadius: 2),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.amberAccent.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.emoji_events, color: Colors.amberAccent, size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'VIP ŞAMPİYONLAR', 
                              style: TextStyle(color: Colors.amberAccent, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2.0),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (scores.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.white38),
                        onPressed: () {
                          Navigator.pop(context);
                          _showClearLeaderboardDialog(context);
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () {
                        Navigator.pop(context);
                        _showNameInputDialog(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Aynı cihazda en çok puan toplayan oyuncular', style: TextStyle(color: Colors.white38, fontSize: 12)),
                const SizedBox(height: 24),
                
                if (sortedEntries.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Text('HENÜZ MAÇ OYNANMADI', style: TextStyle(color: Colors.white24, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    ),
                  )
                else
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: sortedEntries.take(10).map((e) {
                          int rank = sortedEntries.indexOf(e) + 1;
                          Color rankColor = rank == 1 ? Colors.amber : (rank == 2 ? Colors.grey.shade400 : (rank == 3 ? Colors.brown.shade300 : Colors.white24));
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '#$rank', 
                                      style: TextStyle(
                                        color: rankColor, 
                                        fontSize: 16, 
                                        fontWeight: FontWeight.w900
                                      )
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      e.key.toUpperCase(), 
                                      style: const TextStyle(
                                        color: Colors.white, 
                                        fontSize: 15, 
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5
                                      )
                                    ),
                                  ],
                                ),
                                Text(
                                  '${e.value} PT', 
                                  style: const TextStyle(
                                    color: Colors.amberAccent, 
                                    fontSize: 14, 
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5
                                  )
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }
    );
  }
  
  void _showBettingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF161625),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3), width: 2),
              boxShadow: [
                BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.1), blurRadius: 20, spreadRadius: 5),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.diamond, color: Colors.cyanAccent, size: 28),
                      const SizedBox(width: 8),
                      const Text(
                        'GİRİŞ BEDELİ',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Kazanmak için risk almalısın! Ne kadar yüksek bedel ödersen, kazandığında ödül havuzundan o kadar fazla Elmas alırsın.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  
                  // Wrap to avoid overflow
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildBetOption(context, amount: 10, label: 'ACEMİ'),
                      _buildBetOption(context, amount: 50, label: 'CESUR'),
                      _buildBetOption(context, amount: 100, label: 'İDDİALI', isPremium: true),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('İPTAL', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
  
  Widget _buildBetOption(BuildContext context, {required int amount, required String label, bool isPremium = false}) {
    Color color = isPremium ? Colors.amberAccent : Colors.cyanAccent;
    return GestureDetector(
      onTap: () {
        final provider = context.read<QuizProvider>();
        if (provider.totalCoins >= amount) {
          Navigator.pop(context); // Close dialog
          Navigator.push(context, MaterialPageRoute(builder: (context) => BotDuelScreen(entryFee: amount)));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Yeterli elmasın yok! (Gereken: $amount 💎)'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Container(
        width: 130,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$amount', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                const SizedBox(width: 4),
                const Icon(Icons.diamond, color: Colors.cyanAccent, size: 20),
              ],
            ),
            const SizedBox(height: 4),
            Text('Ödül: ${amount * 2}', style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
