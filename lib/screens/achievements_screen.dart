import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../utils/constants.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

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
          'Başarımlar (Kupa Odası)',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: Consumer<QuizProvider>(
        builder: (context, provider, child) {
          List<Map<String, dynamic>> allData = [];

          // Temiz yuvarlak ödül listeleri (25 seviye)
          const roundRewards = [
            5, 10, 15, 20, 30, 50, 75, 100, 150, 200,
            300, 400, 500, 700, 1000, 1500, 2000, 2500, 3000, 4000,
            5000, 6000, 7500, 10000, 15000,
          ];

          // 1. Bilgi Küpü (totalCorrectAnswers) - 25 Levels
          final correctTargets = [1, 5, 10, 25, 50, 100, 250, 500, 750, 1000, 1500, 2000, 3000, 4000, 5000, 7500, 10000, 12500, 15000, 20000, 25000, 30000, 40000, 50000, 100000];
          for (int i = 0; i < 25; i++) {
            int t = correctTargets[i];
            allData.add({'title': 'Bilgi Küpü ${i + 1}', 'desc': 'Toplam $t soru doğru bil.', 'current': provider.totalCorrectAnswers, 'target': t, 'reward': roundRewards[i]});
          }

          // 2. Tecrübe (totalGamesPlayed) - 25 Levels
          final gamesTargets = [1, 5, 10, 20, 30, 50, 75, 100, 150, 200, 300, 400, 500, 750, 1000, 1250, 1500, 2000, 2500, 3000, 4000, 5000, 6000, 7500, 10000];
          for (int i = 0; i < 25; i++) {
            int t = gamesTargets[i];
            allData.add({'title': 'Tecrübe ${i + 1}', 'desc': 'Toplam $t oyun oyna.', 'current': provider.totalGamesPlayed, 'target': t, 'reward': roundRewards[i]});
          }

          // 3. Sorik (totalQuestionsAnswered) - 25 Levels
          final answeredTargets = [5, 10, 25, 50, 100, 250, 500, 1000, 1500, 2000, 3000, 4000, 5000, 7500, 10000, 12500, 15000, 20000, 25000, 30000, 40000, 50000, 75000, 100000, 150000];
          for (int i = 0; i < 25; i++) {
            int t = answeredTargets[i];
            allData.add({'title': 'Sorik ${i + 1}', 'desc': 'Toplam $t soru cevapla.', 'current': provider.totalQuestionsAnswered, 'target': t, 'reward': roundRewards[i]});
          }

          // 4. Zenginlik (totalMoney) - 25 Levels
          final moneyTargets = [
            1000, 5000, 10000, 25000, 50000, 100000, 250000, 500000, 1000000, 2500000, 
            5000000, 7500000, 10000000, 15000000, 20000000, 25000000, 30000000, 40000000, 
            50000000, 75000000, 100000000, 250000000, 500000000, 750000000, 1000000000
          ];
          for (int i = 0; i < 25; i++) {
            int t = moneyTargets[i];
            String tStr = t >= 1000000 ? '${t ~/ 1000000} Milyon' : (t >= 1000 ? '${t ~/ 1000} Bin' : '$t');
            allData.add({'title': 'Zenginlik ${i + 1}', 'desc': 'Toplam $tStr ₺ kazan.', 'current': provider.totalMoney, 'target': t, 'reward': roundRewards[i]});
          }

          allData.sort((a, b) {
            bool aCompleted = (a['current'] as int) >= (a['target'] as int);
            bool bCompleted = (b['current'] as int) >= (b['target'] as int);
            bool aClaimed = provider.claimedAchievements.contains(a['title']);
            bool bClaimed = provider.claimedAchievements.contains(b['title']);

            // 1. Claimable (Completed but not claimed)
            if (aCompleted && !aClaimed && !(bCompleted && !bClaimed)) return -1;
            if (!(aCompleted && !aClaimed) && (bCompleted && !bClaimed)) return 1;

            // 2. Claimed (goes to the bottom)
            if (aClaimed && !bClaimed) return 1;
            if (!aClaimed && bClaimed) return -1;

            // 3. In Progress (sort by percentage)
            double aProgress = (a['current'] as int) / (a['target'] as int);
            double bProgress = (b['current'] as int) / (b['target'] as int);
            if (aProgress > 1.0) aProgress = 1.0;
            if (bProgress > 1.0) bProgress = 1.0;
            
            return bProgress.compareTo(aProgress);
          });

          int totalCompleted = allData.where((a) => (a['current'] as int) >= (a['target'] as int) || provider.claimedAchievements.contains(a['title'])).length;

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                margin: const EdgeInsets.only(top: 10, left: 16, right: 16),
                decoration: BoxDecoration(
                  color: AppColors.menuButtonBg,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppColors.menuButtonBorder, width: 1.5),
                  boxShadow: [
                    BoxShadow(color: AppColors.menuButtonBorder.withValues(alpha: 0.2), blurRadius: 10, spreadRadius: 1)
                  ]
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: Text('Tamamlanan Başarımlar:', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    Text('$totalCompleted / ${allData.length}', style: TextStyle(color: AppColors.textGold, fontSize: 18, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  physics: const BouncingScrollPhysics(),
                  itemCount: allData.length,
                  itemBuilder: (context, index) {
                    final item = allData[index];
                    return _buildMissionCard(
                      item['title'] as String,
                      item['desc'] as String,
                      item['current'] as int,
                      item['target'] as int,
                      item['reward'] as int,
                      provider,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMissionCard(String title, String desc, int current, int target, int reward, QuizProvider provider) {
    bool isCompleted = current >= target;
    bool isClaimed = provider.claimedAchievements.contains(title);
    int displayedCurrent = current > target ? target : current;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.menuButtonBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted && !isClaimed ? Colors.amberAccent : AppColors.menuButtonBorder,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCompleted ? Colors.amber.withValues(alpha: 0.2) : Colors.white12,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.emoji_events : Icons.military_tech,
                color: isCompleted ? Colors.amberAccent : Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.diamond, color: Colors.cyanAccent, size: 16),
                          const SizedBox(width: 4),
                          Text('$reward', style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (displayedCurrent / target).clamp(0.0, 1.0),
                      backgroundColor: Colors.white12,
                      color: isCompleted ? Colors.amberAccent : Colors.orangeAccent,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '$displayedCurrent / $target',
                        style: TextStyle(
                          color: isCompleted ? Colors.amberAccent : Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isClaimed)
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
                            SizedBox(width: 4),
                            Text('Alındı', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        )
                      else if (isCompleted)
                        GestureDetector(
                          onTap: () => provider.claimAchievement(title, reward),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.amberAccent, Colors.orange],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(color: Colors.amberAccent.withValues(alpha: 0.4), blurRadius: 8, spreadRadius: 1),
                              ],
                            ),
                            child: const Text('Ödülü Al', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
