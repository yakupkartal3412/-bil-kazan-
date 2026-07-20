import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/multiplayer_provider.dart';
import '../providers/quiz_provider.dart';
import '../services/ad_service.dart';
import '../utils/constants.dart';
import 'multiplayer_quiz_screen.dart';

class MultiplayerLobbyScreen extends StatefulWidget {
  const MultiplayerLobbyScreen({super.key});

  @override
  State<MultiplayerLobbyScreen> createState() => _MultiplayerLobbyScreenState();
}

class _MultiplayerLobbyScreenState extends State<MultiplayerLobbyScreen> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mpProvider = Provider.of<MultiplayerProvider>(context, listen: false);
      mpProvider.leaveRoom(); // Ekrana girerken eski odayı temizle
    });
  }

  Future<void> _createRoom() async {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final mpProvider = Provider.of<MultiplayerProvider>(context, listen: false);

    if (quizProvider.roomCards <= 0) {
      _showBuyCardDialog(quizProvider);
      return;
    }

    // Odayı kurmadan önce kartı harca
    await quizProvider.useRoomCard();

    // Rastgele 15 soru ek (5 kolay, 5 orta, 5 zor)
    final rawQuestions = quizProvider.get15MixedQuestions();
    List<Map<String, dynamic>> questions = rawQuestions.map((q) => q.toMap()).toList();

    bool success = await mpProvider.createRoom(
      quizProvider.userName,
      quizProvider.activeAvatar,
      questions,
    );
    
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mpProvider.errorMessage), backgroundColor: Colors.red));
    }
  }

  void _showBuyCardDialog(QuizProvider quizProvider) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.cyanAccent, width: 2)),
          title: const Text('Oda Kartı Gerekli', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.credit_card, size: 60, color: Colors.cyanAccent),
              const SizedBox(height: 15),
              const Text(
                'Oda kurabilmek için 1 adet Oda Kartına ihtiyacınız var. 50 Elmas karşılığında satın almak ister misiniz?',
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text('Mevcut Elmas: ${quizProvider.totalCoins} 💎', style: const TextStyle(color: Colors.amberAccent, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    if (quizProvider.hasRemovedAds) {
                      if (quizProvider.consumeVipAction('room_card')) {
                        quizProvider.giveFreeRoomCard();
                        Navigator.pop(ctx);
                        _createRoom();
                      } else {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Günlük VIP Bedava Oda Kartı sınırına ulaştınız! (Max 20)')));
                      }
                    } else {
                      AdService().showRewardedAd(
                        context: context,
                        onRewardEarned: (amount) {
                          quizProvider.giveFreeRoomCard();
                        },
                        onClosed: () {
                          Navigator.pop(ctx);
                          if (quizProvider.roomCards > 0) {
                             _createRoom();
                          }
                        }
                      );
                    }
                  },
                  icon: Icon(quizProvider.hasRemovedAds ? Icons.diamond : Icons.ondemand_video, color: Colors.white),
                  label: Text(quizProvider.hasRemovedAds ? 'VIP BEDAVA AL' : 'VİDEO İZLE VE KAZAN', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: quizProvider.hasRemovedAds ? Colors.green : Colors.purpleAccent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('İPTAL', style: TextStyle(color: Colors.white54)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (quizProvider.totalCoins >= 50) {
                          quizProvider.buyRoomCard();
                          Navigator.pop(ctx);
                          _createRoom(); 
                        } else {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yeterli elmasınız yok!'), backgroundColor: Colors.red));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                      ),
                      child: const Text('SATIN AL (50)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _joinRoomDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.amberAccent, width: 2)),
          title: const Text('Odaya Katıl', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 5),
            textAlign: TextAlign.center,
            maxLength: 4,
            decoration: const InputDecoration(
              hintText: '4 Haneli Kod',
              hintStyle: TextStyle(color: Colors.white30, letterSpacing: 0),
              counterText: '',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İPTAL', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_codeController.text.length == 4) {
                  final quizProvider = Provider.of<QuizProvider>(context, listen: false);
                  final mpProvider = Provider.of<MultiplayerProvider>(context, listen: false);
                  
                  Navigator.pop(ctx);
                  bool success = await mpProvider.joinRoom(
                    _codeController.text,
                    quizProvider.userName,
                    quizProvider.activeAvatar,
                  );
                  if (!success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mpProvider.errorMessage)));
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amberAccent),
              child: const Text('KATIL', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mpProvider = Provider.of<MultiplayerProvider>(context);

    if (mpProvider.roomData != null && mpProvider.roomData!['status'] == 'playing') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MultiplayerQuizScreen()));
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A), // Koyu premium arka plan
      body: Stack(
        children: [
          // Arka plan parlamaları (Neon Orbs)
          Positioned(top: -100, left: -50, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.purpleAccent.withValues(alpha: 0.15), blurRadius: 120, spreadRadius: 60)]))),
          Positioned(bottom: -50, right: -50, child: Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.15), blurRadius: 100, spreadRadius: 50)]))),

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
                        onPressed: () {
                          mpProvider.leaveRoom();
                          Navigator.pop(context);
                        },
                      ),
                      const Expanded(
                        child: Text(
                          'ARKADAŞINLA OYNA',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                
                // --- ELMAS VE ODA KARTI BİLGİ PANELİ ---
                Consumer<QuizProvider>(
                  builder: (context, quizProvider, child) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              Image.asset('assets/images/3d_diamond_clear_nobg.png', width: 28, height: 28),
                              const SizedBox(width: 8),
                              Text(
                                '${quizProvider.totalCoins}',
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Container(width: 1, height: 30, color: Colors.white24),
                          Row(
                            children: [
                              Image.asset('assets/images/room_card.png', width: 32, height: 32),
                              const SizedBox(width: 8),
                              Text(
                                '${quizProvider.roomCards} Kart',
                                style: const TextStyle(color: Colors.cyanAccent, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                // --- BEDAVA KART KAZAN BUTONU ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final quizProvider = Provider.of<QuizProvider>(context, listen: false);
                      if (quizProvider.hasRemovedAds) {
                        if (quizProvider.consumeVipAction('room_card')) {
                          quizProvider.giveFreeRoomCard();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('VIP Ayrıcalığı: 1 Oda Kartı kazandınız!'), backgroundColor: Colors.green));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Günlük VIP Bedava Oda Kartı sınırına ulaştınız! (Max 20)')));
                        }
                      } else {
                        AdService().showRewardedAd(
                          context: context,
                          onRewardEarned: (amount) {
                            quizProvider.giveFreeRoomCard();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tebrikler! 1 Oda Kartı kazandınız.'), backgroundColor: Colors.green));
                          },
                        );
                      }
                    },
                    icon: Icon(Provider.of<QuizProvider>(context).hasRemovedAds ? Icons.diamond : Icons.ondemand_video, color: Colors.white, size: 20),
                    label: Text(Provider.of<QuizProvider>(context).hasRemovedAds ? 'VIP BEDAVA AL' : 'BEDAVA KART KAZAN', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Provider.of<QuizProvider>(context).hasRemovedAds ? Colors.green : Colors.orangeAccent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
                
                Expanded(
                  child: mpProvider.isLoading 
                      ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
                      : mpProvider.roomId == null
                          ? _buildInitialView()
                          : _buildRoomView(mpProvider),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialView() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Havalı bir ikon / logo alanı
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black26,
                border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3), width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.2), blurRadius: 40, spreadRadius: 10),
                ],
              ),
              child: const Icon(Icons.hub_outlined, size: 90, color: Colors.cyanAccent),
            ),
            const SizedBox(height: 30),
            const Text(
              'REKABET BAŞLASIN!',
              style: TextStyle(
                color: Colors.white, 
                fontSize: 26, 
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
                shadows: [Shadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 4))]
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                'Oda kur veya arkadaşının odasına katıl. Aynı soruları kim daha hızlı çözerse kazanır!',
                style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 50),
            
            // Oda Kur Butonu
            _buildPremiumButton(
              title: 'ODA KUR',
              subtitle: 'Yeni bir arena yarat',
              icon: Icons.add_circle_outline,
              primaryColor: Colors.amberAccent,
              secondaryColor: Colors.deepOrange,
              onTap: _createRoom,
            ),
            
            const SizedBox(height: 20),
            
            // Odaya Katıl Butonu
            _buildPremiumButton(
              title: 'ODAYA KATIL',
              subtitle: 'Arkadaşının kodunu gir',
              icon: Icons.login,
              primaryColor: Colors.cyanAccent,
              secondaryColor: Colors.blue.shade800,
              onTap: _joinRoomDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumButton({
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
        width: 320,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              secondaryColor.withValues(alpha: 0.8),
              secondaryColor.withValues(alpha: 0.4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryColor.withValues(alpha: 0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: primaryColor, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.5), size: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomView(MultiplayerProvider mpProvider) {
    final data = mpProvider.roomData;
    if (data == null) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.amberAccent, width: 2),
          ),
          child: Column(
            children: [
              const Text('ODA KODU', style: TextStyle(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.bold)),
              Text(
                mpProvider.roomId!,
                style: const TextStyle(color: Colors.amberAccent, fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: 10),
              ),
              const Text('Arkadaşına bu kodu ver!', style: TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildPlayerCard(data['hostName'], data['hostAvatar'], 'KURUCU'),
            const Text('VS', style: TextStyle(color: Colors.amberAccent, fontSize: 32, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold)),
            _buildPlayerCard(data['guestName'], data['guestAvatar'], 'RAKİP'),
          ],
        ),
        const Spacer(),
        if (mpProvider.isHost)
          ElevatedButton(
            onPressed: data['guestId'] != null ? () => mpProvider.startGame() : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: data['guestId'] != null ? Colors.green : Colors.grey,
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: Text(
              data['guestId'] != null ? 'OYUNU BAŞLAT' : 'BEKLENİYOR...',
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          )
        else
          const Text(
            'Kurucunun odayı başlatması bekleniyor...',
            style: TextStyle(color: Colors.white70, fontSize: 16, fontStyle: FontStyle.italic),
          ),
        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildPlayerCard(String? name, String? avatar, String role) {
    bool isEmpty = name == null;
    String? avatarPath = avatar;
    if (avatarPath != null && !avatarPath.startsWith('assets')) {
      avatarPath = 'assets/images/$avatarPath';
    }
    
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: isEmpty ? Colors.grey[800] : Colors.amberAccent,
          child: CircleAvatar(
            radius: 37,
            backgroundColor: AppColors.appPurpleBg,
            backgroundImage: !isEmpty && avatarPath != null ? AssetImage(avatarPath) : null,
            child: isEmpty ? const Icon(Icons.person_outline, size: 40, color: Colors.grey) : null,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          isEmpty ? 'Bekleniyor...' : name,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          role,
          style: TextStyle(color: isEmpty ? Colors.grey : Colors.amberAccent, fontSize: 12),
        ),
      ],
    );
  }
}
