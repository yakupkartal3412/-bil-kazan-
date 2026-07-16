import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/audio_provider.dart';
import '../utils/constants.dart';

class DailyRewardsScreen extends StatelessWidget {
  const DailyRewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appPurpleBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'GÜNLÜK ÖDÜLLER',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Consumer<QuizProvider>(
          builder: (context, provider, child) {
            final statusList = provider.cycleStatus;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Column(
                children: [
                  const Text(
                    '7 Günlük Hediye Takvimi',
                    style: TextStyle(color: Colors.amberAccent, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Kaçırdığınız günleri reklam izleyerek telafi edebilirsiniz!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  
                  // Days 1 to 6 (Grid)
                  Expanded(
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        return _buildRewardCard(context, provider, index, statusList[index]);
                      },
                    ),
                  ),
                  
                  // Day 7 (Big Banner)
                  _buildDay7Banner(context, provider, statusList[6]),
                  
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRewardCard(BuildContext context, QuizProvider provider, int dayIndex, int status) {
    int baseMultiplier = dayIndex + 1;
    int diamondReward = baseMultiplier * 15;
    int cashReward = baseMultiplier * 20000;
    String cashStr = cashReward >= 1000 ? '${cashReward ~/ 1000}K' : '$cashReward';

    return GestureDetector(
      onTap: () => _handleCardTap(context, provider, dayIndex, status),
      child: Container(
        decoration: BoxDecoration(
          color: _getCardColor(status),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: status == 1 ? Colors.amberAccent : Colors.white12,
            width: status == 1 ? 2 : 1,
          ),
          boxShadow: status == 1 ? [BoxShadow(color: Colors.amber.withValues(alpha: 0.3), blurRadius: 10, spreadRadius: 1)] : [],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('GÜN ${dayIndex + 1}', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/3d_diamond_clear_nobg.png', width: 24, height: 24),
                    const SizedBox(width: 4),
                    Text('$diamondReward', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/3d_cash_icon_nobg.png', width: 24, height: 24),
                    const SizedBox(width: 4),
                    Text(cashStr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            if (status == 2)
              Container(
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(16)),
                child: const Center(
                  child: Icon(Icons.check_circle, color: Colors.greenAccent, size: 40),
                ),
              ),
            if (status == 3)
              Container(
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(16)),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.ondemand_video, color: Colors.amberAccent, size: 36),
                      SizedBox(height: 4),
                      Text('Kurtar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            if (status == 0)
              Container(
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(16)),
                child: const Center(
                  child: Icon(Icons.lock, color: Colors.white54, size: 32),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDay7Banner(BuildContext context, QuizProvider provider, int status) {
    int diamondReward = 150;
    String cashStr = '150 Bin';

    return GestureDetector(
      onTap: () => _handleCardTap(context, provider, 6, status),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: status == 1 ? [BoxShadow(color: Colors.orange.withValues(alpha: 0.5), blurRadius: 15, spreadRadius: 2)] : [],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.stars, color: Colors.white, size: 40),
                    Text('7. GÜN', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset('assets/images/3d_diamond_clear_nobg.png', width: 32, height: 32),
                        const SizedBox(width: 8),
                        Text('$diamondReward Elmas', style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Image.asset('assets/images/3d_cash_icon_nobg.png', width: 32, height: 32),
                        const SizedBox(width: 8),
                        Text('$cashStr ₺', style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            if (status == 2)
              Container(
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.greenAccent, size: 50),
                      SizedBox(width: 8),
                      Text('ALINDI', style: TextStyle(color: Colors.greenAccent, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            if (status == 3)
              Container(
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.ondemand_video, color: Colors.amberAccent, size: 50),
                      Text('Reklam İzle & Kurtar', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            if (status == 0)
              Container(
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                child: const Center(
                  child: Icon(Icons.lock, color: Colors.white54, size: 50),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getCardColor(int status) {
    switch (status) {
      case 1: return AppColors.menuButtonBg; // Available (highlighted)
      case 2: return Colors.green.withValues(alpha: 0.2); // Claimed
      case 3: return Colors.red.withValues(alpha: 0.2); // Missed
      case 0:
      default: return Colors.white12; // Locked
    }
  }

  void _handleCardTap(BuildContext context, QuizProvider provider, int dayIndex, int status) async {
    final audio = Provider.of<AudioProvider>(context, listen: false);

    if (status == 1) {
      // Claim today
      final messenger = ScaffoldMessenger.of(context);
      audio.playSfx('cash_register.mp3');
      await provider.claimDailyLoginReward(dayIndex);
      messenger.showSnackBar(
        const SnackBar(content: Text('Ödül başarıyla alındı!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
      );
    } else if (status == 3) {
      // Watch Ad to claim
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.menuButtonBg,
          title: const Row(
            children: [
              Icon(Icons.ondemand_video, color: Colors.amberAccent),
              SizedBox(width: 8),
              Text('Gün Kurtarma', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: const Text(
            'Kaçırdığınız bu günün ödülünü reklam izleyerek kurtarmak ister misiniz?\n\n(Bu özellik yakında eklenecektir. Şimdilik test amaçlı ödül direkt verilecektir.)',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Vazgeç', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amberAccent),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                // Simulate Ad completion and claim
                audio.playSfx('cash_register.mp3');
                await provider.claimDailyLoginReward(dayIndex);
                messenger.showSnackBar(
                  const SnackBar(content: Text('Gününüz kurtarıldı ve ödül alındı!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
                );
              },
              child: const Text('Reklamı İzle', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else if (status == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu gün henüz açılmadı.'), backgroundColor: Colors.orange),
      );
    }
  }
}
