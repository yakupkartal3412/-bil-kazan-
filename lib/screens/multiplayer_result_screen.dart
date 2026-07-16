import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/multiplayer_provider.dart';
import '../providers/quiz_provider.dart';
import '../utils/constants.dart';

class MultiplayerResultScreen extends StatefulWidget {
  const MultiplayerResultScreen({super.key});

  @override
  State<MultiplayerResultScreen> createState() => _MultiplayerResultScreenState();
}

class _MultiplayerResultScreenState extends State<MultiplayerResultScreen> {
  bool _rewardGiven = false;

  @override
  Widget build(BuildContext context) {
    final mpProvider = Provider.of<MultiplayerProvider>(context);
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final data = mpProvider.roomData;

    if (data == null) {
      return Scaffold(
        backgroundColor: AppColors.appPurpleBg,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Oda kapandı.', style: TextStyle(color: Colors.white, fontSize: 20)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  mpProvider.leaveRoom();
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('Ana Menüye Dön'),
              )
            ],
          ),
        ),
      );
    }

    bool isFinished = data['status'] == 'finished';
    
    int myScore = mpProvider.isHost ? (data['hostScore'] ?? 0) : (data['guestScore'] ?? 0);
    int oppScore = mpProvider.isHost ? (data['guestScore'] ?? 0) : (data['hostScore'] ?? 0);
    
    String oppName = mpProvider.isHost ? (data['guestName'] ?? 'Rakip') : (data['hostName'] ?? 'Rakip');
    
    bool isWin = myScore > oppScore;
    bool isDraw = myScore == oppScore;

    if (isFinished && !_rewardGiven) {
      _rewardGiven = true;
      if (isWin) {
        Future.microtask(() {
          quizProvider.addCoins(100);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tebrikler! +100 Elmas kazandın! 💎'), backgroundColor: Colors.green));
        });
      }
    }

    return Scaffold(
      backgroundColor: AppColors.appPurpleBg,
      body: SafeArea(
        child: Center(
          child: !isFinished 
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Colors.amberAccent),
                const SizedBox(height: 20),
                Text('$oppName\'in testi bitirmesi bekleniyor...', style: const TextStyle(color: Colors.white, fontSize: 18)),
                const SizedBox(height: 10),
                Text('Senin Puanın: $myScore', style: const TextStyle(color: Colors.amberAccent, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isDraw ? Icons.handshake : (isWin ? Icons.emoji_events : Icons.sentiment_dissatisfied),
                  color: isDraw ? Colors.blueAccent : (isWin ? Colors.amberAccent : Colors.redAccent),
                  size: 100,
                ),
                const SizedBox(height: 20),
                Text(
                  isDraw ? 'BERABERE!' : (isWin ? 'KAZANDIN!' : 'KAYBETTİN!'),
                  style: TextStyle(
                    color: isDraw ? Colors.blueAccent : (isWin ? Colors.amberAccent : Colors.redAccent),
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 30),
                
                // Skor Tablosu
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    children: [
                      _buildScoreRow('Sen', myScore, isWin ? Colors.amberAccent : Colors.white),
                      const Divider(color: Colors.white24, height: 30),
                      _buildScoreRow(oppName, oppScore, !isWin && !isDraw ? Colors.amberAccent : Colors.white),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                if (isWin)
                  const Text('+100 ELMAS', style: TextStyle(color: Colors.cyanAccent, fontSize: 24, fontWeight: FontWeight.bold)),
                  
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    mpProvider.leaveRoom();
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('ANA MENÜ', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 30),
              ],
            ),
        ),
      ),
    );
  }

  Widget _buildScoreRow(String name, int score, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(name, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        Text('$score PT', style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
