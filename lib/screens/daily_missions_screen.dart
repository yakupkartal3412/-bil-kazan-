import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../utils/constants.dart';

class DailyMissionsScreen extends StatelessWidget {
  const DailyMissionsScreen({super.key});

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
          'Günlük Mücadele',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: Consumer<QuizProvider>(
        builder: (context, provider, child) {
          int dailyCompleted = 0;
          if (provider.dailyGamesPlayed >= 1 || provider.claimedMissions.contains('play_1_game')) dailyCompleted++;
          if (provider.dailyCorrectAnswers >= 5 || provider.claimedMissions.contains('answer_5_questions')) dailyCompleted++;
          if (provider.dailyJokersUsed >= 1 || provider.claimedMissions.contains('use_1_joker')) dailyCompleted++;
          if (provider.dailyCorrectAnswers >= 10 || provider.claimedMissions.contains('answer_10_questions')) dailyCompleted++;
          if (provider.dailyGamesPlayed >= 3 || provider.claimedMissions.contains('play_3_games')) dailyCompleted++;

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
                    const Text('Tamamlanan Görevler:', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('$dailyCompleted / 5', style: TextStyle(color: AppColors.textGold, fontSize: 20, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildMissionCard(
                      context: context,
                      provider: provider,
                      missionId: 'play_1_game',
                      title: 'Güne Başlangıç',
                      desc: 'Bugün 1 oyun oyna.',
                      currentProgress: provider.dailyGamesPlayed,
                      target: 1,
                      reward: 10,
                    ),
                    _buildMissionCard(
                      context: context,
                      provider: provider,
                      missionId: 'answer_5_questions',
                      title: 'Hedefe Doğru',
                      desc: 'Bugün 5 soru doğru bil.',
                      currentProgress: provider.dailyCorrectAnswers,
                      target: 5,
                      reward: 15,
                    ),
                    _buildMissionCard(
                      context: context,
                      provider: provider,
                      missionId: 'use_1_joker',
                      title: 'Joker Uzmanı',
                      desc: 'Bugün 1 Joker kullan.',
                      currentProgress: provider.dailyJokersUsed,
                      target: 1,
                      reward: 10,
                    ),
                    _buildMissionCard(
                      context: context,
                      provider: provider,
                      missionId: 'answer_10_questions',
                      title: 'Soru Avcısı',
                      desc: 'Bugün 10 soru doğru bil.',
                      currentProgress: provider.dailyCorrectAnswers,
                      target: 10,
                      reward: 25,
                    ),
                    _buildMissionCard(
                      context: context,
                      provider: provider,
                      missionId: 'play_3_games',
                      title: 'Oyun Tutkunu',
                      desc: 'Bugün 3 oyun oyna.',
                      currentProgress: provider.dailyGamesPlayed,
                      target: 3,
                      reward: 20,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMissionCard({
    required BuildContext context,
    required QuizProvider provider,
    required String missionId,
    required String title,
    required String desc,
    required int currentProgress,
    required int target,
    required int reward,
  }) {
    bool isCompleted = currentProgress >= target;
    bool isClaimed = provider.claimedMissions.contains(missionId);
    int displayedProgress = currentProgress > target ? target : currentProgress;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.menuButtonBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isClaimed ? Colors.grey : (isCompleted ? Colors.greenAccent : AppColors.menuButtonBorder),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isClaimed 
                    ? Colors.grey.withValues(alpha: 0.2) 
                    : (isCompleted ? Colors.green.withValues(alpha: 0.2) : Colors.white12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isClaimed ? Icons.done_all : (isCompleted ? Icons.check_circle : Icons.track_changes),
                color: isClaimed ? Colors.grey : (isCompleted ? Colors.greenAccent : Colors.white),
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isClaimed ? Colors.grey : Colors.white, 
                      fontSize: 18, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: TextStyle(
                      color: isClaimed ? Colors.grey : Colors.white70, 
                      fontSize: 14
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'İlerleme: $displayedProgress/$target',
                    style: TextStyle(
                      color: isClaimed ? Colors.grey : (isCompleted ? Colors.greenAccent : Colors.orangeAccent), 
                      fontSize: 14, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                Row(
                  children: [
                    Text('+$reward', style: TextStyle(color: isClaimed ? Colors.grey : Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(width: 4),
                    Icon(Icons.diamond, color: isClaimed ? Colors.grey : Colors.cyanAccent, size: 16),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: (isCompleted && !isClaimed) 
                      ? () {
                          provider.claimMissionReward(missionId, reward);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isClaimed ? Colors.grey : (isCompleted ? Colors.green : Colors.grey),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    isClaimed ? 'ALINDI' : (isCompleted ? 'AL' : 'BEKLİYOR'),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
