import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/audio_provider.dart';

class DailyRewardsScreen extends StatefulWidget {
  const DailyRewardsScreen({super.key});

  @override
  State<DailyRewardsScreen> createState() => _DailyRewardsScreenState();
}

class _DailyRewardsScreenState extends State<DailyRewardsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF2C1959), Color(0xFF0F0C29)],
            center: Alignment.topCenter,
            radius: 1.5,
          ),
        ),
        child: SafeArea(
          child: Consumer<QuizProvider>(
            builder: (context, provider, child) {
              final statusList = provider.cycleStatus;

              return Column(
                children: [
                  // App Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            'GÜNLÜK HEDİYELER',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48), // Balance for back button
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  const Text(
                    'Kaçırdığınız günleri reklam izleyerek telafi edebilirsiniz!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 20),
                  
                  // Main Content constrained for web/desktop
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            children: [
                              // Days 1 to 6 (Grid)
                              Expanded(
                                child: GridView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 0.85, // Better proportion
                                  ),
                                  itemCount: 6,
                                  itemBuilder: (context, index) {
                                    return _buildRewardCard(context, provider, index, statusList[index]);
                                  },
                                ),
                              ),
                              
                              // Day 7 (Big Banner)
                              _buildDay7Banner(context, provider, statusList[6]),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRewardCard(BuildContext context, QuizProvider provider, int dayIndex, int status) {
    int baseMultiplier = dayIndex + 1;
    int diamondReward = baseMultiplier * 15;
    int cashReward = baseMultiplier * 20000;
    String cashStr = cashReward >= 1000 ? '${cashReward ~/ 1000}K' : '$cashReward';

    bool isCurrent = (status == 1);
    bool isClaimed = (status == 2);
    bool isMissed = (status == 3);
    bool isLocked = (status == 0);

    Widget card = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isCurrent 
            ? [Colors.amberAccent.withValues(alpha: 0.2), Colors.orangeAccent.withValues(alpha: 0.1)]
            : [Colors.white.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrent ? Colors.amberAccent : Colors.white.withValues(alpha: 0.15),
          width: isCurrent ? 2 : 1,
        ),
        boxShadow: isCurrent 
          ? [BoxShadow(color: Colors.amber.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 2)] 
          : [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, spreadRadius: 2)],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCurrent ? Colors.amberAccent : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${dayIndex + 1}. GÜN', 
                    style: TextStyle(
                      color: isCurrent ? Colors.black : Colors.white, 
                      fontWeight: FontWeight.w900,
                      fontSize: 12
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/3d_diamond_clear_nobg.png', width: 22, height: 22),
                    const SizedBox(width: 6),
                    Text('$diamondReward', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/3d_cash_icon_nobg.png', width: 22, height: 22),
                    const SizedBox(width: 6),
                    Text(cashStr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
          
          // Overlays
          if (isClaimed)
            Container(
              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(20)),
              child: const Center(
                child: Icon(Icons.check_circle, color: Colors.greenAccent, size: 48),
              ),
            ),
          if (isMissed)
            Container(
              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(20)),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.redAccent),
                      child: const Icon(Icons.ondemand_video, color: Colors.white, size: 24),
                    ),
                    const SizedBox(height: 6),
                    const Text('Kurtar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            ),
          if (isLocked)
            Container(
              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(20)),
              child: const Center(
                child: Icon(Icons.lock, color: Colors.white54, size: 36),
              ),
            ),
        ],
      ),
    );

    return GestureDetector(
      onTap: () => _handleCardTap(context, provider, dayIndex, status),
      child: isCurrent 
        ? AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) => Transform.scale(scale: _pulseAnimation.value, child: card),
          )
        : card,
    );
  }

  Widget _buildDay7Banner(BuildContext context, QuizProvider provider, int status) {
    int diamondReward = 150;
    String cashStr = '150 Bin';
    
    bool isCurrent = (status == 1);
    bool isClaimed = (status == 2);
    bool isMissed = (status == 3);
    bool isLocked = (status == 0);

    Widget banner = Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCurrent 
            ? [const Color(0xFFFFD700), const Color(0xFFFF8C00)]
            : [Colors.amber.withValues(alpha: 0.3), Colors.orange.withValues(alpha: 0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCurrent ? Colors.white : Colors.white.withValues(alpha: 0.2), 
          width: isCurrent ? 3 : 1
        ),
        boxShadow: isCurrent ? [BoxShadow(color: Colors.orange.withValues(alpha: 0.6), blurRadius: 25, spreadRadius: 5)] : [],
      ),
      child: Stack(
        children: [
          // Shine effect
          if (isCurrent)
            Positioned(
              left: -50,
              top: -50,
              child: Container(
                width: 100,
                height: 200,
                transform: Matrix4.rotationZ(0.5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
            ),
            
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.stars, color: isCurrent ? Colors.white : Colors.white54, size: 40),
                    const SizedBox(height: 4),
                    Text('7. GÜN', style: TextStyle(color: isCurrent ? Colors.white : Colors.white54, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  ],
                ),
              ),
              Container(width: 1, height: 80, color: Colors.white.withValues(alpha: 0.3)),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset('assets/images/3d_diamond_clear_nobg.png', width: 36, height: 36),
                          const SizedBox(width: 12),
                          Text('$diamondReward', style: TextStyle(color: isCurrent ? Colors.black87 : Colors.white70, fontSize: 22, fontWeight: FontWeight.w900)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Image.asset('assets/images/3d_cash_icon_nobg.png', width: 36, height: 36),
                          const SizedBox(width: 12),
                          Text('$cashStr ₺', style: TextStyle(color: isCurrent ? Colors.black87 : Colors.white70, fontSize: 20, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          if (isClaimed)
            Container(
              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(24)),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.greenAccent, size: 50),
                    SizedBox(width: 12),
                    Text('ALINDI', style: TextStyle(color: Colors.greenAccent, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  ],
                ),
              ),
            ),
          if (isMissed)
            Container(
              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(24)),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.ondemand_video, color: Colors.redAccent, size: 40),
                    SizedBox(height: 8),
                    Text('Reklam İzle & Kurtar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          if (isLocked)
            Container(
              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(24)),
              child: const Center(
                child: Icon(Icons.lock, color: Colors.white54, size: 50),
              ),
            ),
        ],
      ),
    );

    return GestureDetector(
      onTap: () => _handleCardTap(context, provider, 6, status),
      child: isCurrent 
        ? AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) => Transform.scale(scale: _pulseAnimation.value, child: banner),
          )
        : banner,
    );
  }

  void _handleCardTap(BuildContext context, QuizProvider provider, int dayIndex, int status) async {
    final audio = Provider.of<AudioProvider>(context, listen: false);

    if (status == 1) {
      final messenger = ScaffoldMessenger.of(context);
      audio.playSfx('cash_register.mp3');
      await provider.claimDailyLoginReward(dayIndex);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('🎉 Ödül başarıyla alındı!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), 
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Future.delayed(const Duration(seconds: 1), () {
        if (context.mounted) {
          Navigator.pop(context);
        }
      });
    } else if (status == 3) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E2C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.ondemand_video, color: Colors.redAccent, size: 28),
              SizedBox(width: 12),
              Text('Gün Kurtarma', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            'Kaçırdığınız bu günün ödülünü reklam izleyerek kurtarmak ister misiniz?',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Vazgeç', style: TextStyle(color: Colors.grey, fontSize: 16)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
              ),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                // Simulate Ad completion and claim
                audio.playSfx('cash_register.mp3');
                await provider.claimDailyLoginReward(dayIndex);
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('✅ Gününüz kurtarıldı ve ödül alındı!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), 
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                Future.delayed(const Duration(seconds: 1), () {
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                });
              },
              child: const Text('Reklamı İzle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      );
    } else if (status == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔒 Bu gün henüz açılmadı, lütfen bekleyin.'), 
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
