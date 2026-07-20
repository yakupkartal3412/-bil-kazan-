import 'package:flutter/foundation.dart';
import '../services/ad_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/quiz_provider.dart';
import '../utils/constants.dart';
import 'quiz_screen.dart';
import 'leaderboard_screen.dart';
import 'store_screen.dart';
import 'invite_screen.dart';
import 'settings_screen.dart';
import 'inventions_screen.dart';
import 'achievements_screen.dart';
import 'how_to_play_screen.dart';
import 'daily_missions_screen.dart';
import 'events_screen.dart';
import 'spin_wheel_screen.dart';
import 'duel_menu_screen.dart';
import 'daily_rewards_screen.dart';
import '../widgets/premium_badge.dart';

class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const AnimatedButton({super.key, required this.child, required this.onTap});

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 0.95).animate(_controller),
        child: widget.child,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isEndlessMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowDailyLogin();
    });
  }

  void _checkAndShowDailyLogin() {
    final provider = Provider.of<QuizProvider>(context, listen: false);
    
    void checkRewards() {
      if (provider.weeklyRewardMessage.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.menuButtonBg,
            title: const Text('Haftalık Ödül!', style: TextStyle(color: Colors.amberAccent)),
            content: Text(provider.weeklyRewardMessage, style: const TextStyle(color: Colors.white)),
            actions: [
              TextButton(
                onPressed: () {
                  provider.clearWeeklyRewardMessage();
                  Navigator.pop(context);
                },
                child: const Text('Tamam', style: TextStyle(color: Colors.amberAccent)),
              ),
            ],
          ),
        );
      }
      
      if (!provider.hasClaimedDailyLogin) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DailyRewardsScreen()),
        );
      }
    }
    
    if (!provider.isDataLoaded) {
      void listener() {
        if (provider.isDataLoaded) {
          provider.removeListener(listener);
          checkRewards();
        }
      }
      provider.addListener(listener);
    } else {
      checkRewards();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appPurpleBg,
      bottomNavigationBar: !kIsWeb ? const CustomBannerAd() : const SizedBox.shrink(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: Column(
                    children: [
                // Top Banner
                _buildTopBanner(context),
                const SizedBox(height: 16),
                
                // Profile Section
                _buildProfileSection(),
                const SizedBox(height: 16),


                // Main Buttons
                ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildMenuButton(
                            icon: Icons.calendar_month,
                            title: 'Ödüller',
                            subtitle: '7 GÜNLÜK',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const DailyRewardsScreen()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMenuButton(
                            icon: Icons.calendar_today,
                            title: 'Görevler',
                            subtitle: 'GÜNLÜK',
                            showRedDot: context.watch<QuizProvider>().hasUnclaimedDailyMissions,
                            onTap: () {
                              context.read<QuizProvider>().checkDailyReset();
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const DailyMissionsScreen()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildMenuButton(
                      icon: Icons.sports_esports,
                      title: 'Yeni Oyun',
                      subtitle: isEndlessMode ? 'SONSUZ MOD' : 'KLASİK MOD',
                      trailing: Switch(
                        value: isEndlessMode,
                        onChanged: (val) {
                          setState(() {
                            isEndlessMode = val;
                          });
                        },
                        activeThumbColor: Colors.redAccent,
                        activeTrackColor: Colors.red[900],
                        inactiveThumbColor: Colors.grey,
                        inactiveTrackColor: Colors.grey[800],
                      ),
                      onTap: () {
                        context.read<QuizProvider>().startNewGame(
                          mode: isEndlessMode ? GameMode.endless : GameMode.classic
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const QuizScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildMenuButton(
                      icon: Icons.event_available,
                      title: 'Özel Etkinlikler',
                      subtitle: 'KATEGORİNİ SEÇ, ÖDÜL KAZAN!',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EventsScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildMenuButton(
                      icon: Icons.sports_kabaddi,
                      title: 'Düello Modu',
                      subtitle: 'ARKADAŞLA VEYA RASTGELE',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DuelMenuScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildMenuButton(
                      icon: Icons.leaderboard,
                      title: 'Skor Tablosu',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildMenuButton(
                      icon: Icons.group_add_rounded,
                      title: 'Davet Et Kazan',
                      subtitle: 'ARKADAŞLARINI ÇAĞIR, KAZAN!',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const InviteScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMenuButton(
                            icon: Icons.shopping_cart,
                            title: 'Mağaza',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => StoreScreen()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMenuButton(
                            icon: Icons.exit_to_app,
                            title: 'Oyunu Kapat',
                            onTap: () {
                              exit(0);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
              ),
            ),
            _buildBottomIcons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBanner(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, provider, child) {
        String moneyText;
        if (provider.weeklyScore >= 1000000) {
          moneyText = '${(provider.weeklyScore / 1000000).toStringAsFixed(1).replaceAll('.0', '')} Milyon ₺';
        } else if (provider.weeklyScore >= 1000) {
          moneyText = '${(provider.weeklyScore / 1000).toStringAsFixed(1).replaceAll('.0', '')} Bin ₺';
        } else {
          moneyText = '${provider.weeklyScore} ₺';
        }
        
        String diamondText = provider.formattedTotalCoins;

        return LayoutBuilder(
          builder: (context, constraints) {
            return FittedBox(
              fit: BoxFit.scaleDown,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Money Section
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/3d_cash_icon_nobg.png',
                  width: 40,
                  height: 40,
                ),
                const SizedBox(width: 6),
                Text(
                  moneyText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2)),
                    ],
                  ),
                ),
              ],
            ),
            // Center Actions (Spin Wheel only now, Invite moved to menu)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 15.0), // sola kaydırmak için sağa boşluk ekliyoruz
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SpinWheelScreen()),
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.amberAccent.withValues(alpha: 0.4), blurRadius: 6, spreadRadius: 0),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/3d_spin_wheel_nobg.png',
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      if (provider.canSpinWheel)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.appPurpleBg, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // Diamond Section
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StoreScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      diamondText,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Image.asset(
                      'assets/images/3d_diamond_clear_nobg.png',
                      width: 36,
                      height: 36,
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1))],
                      ),
                      child: const Icon(Icons.add, size: 18, color: Colors.black, weight: 900),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        ),
        );
        },
        );
      },
    );
  }

  Widget _buildProfileSection() {
    return Consumer<QuizProvider>(
      builder: (context, provider, child) {
        // Zeka Seviyesi (IQ) Algoritması
        int iq = provider.iqLevel;
        
        double winRate = provider.totalQuestionsAnswered == 0 
            ? 0.0 
            : (provider.totalCorrectAnswers / provider.totalQuestionsAnswered);
        int winRatePercent = (winRate * 100).toInt();
        
        // IQ Bar ilerlemesi (Başlangıç 50, Maksimum 200)
        double iqProgress = (iq - 50) / 150; 
        if (iqProgress < 0) iqProgress = 0;
        if (iqProgress > 1) iqProgress = 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: AppColors.menuButtonBg,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.cyanAccent, width: 2)),
                      title: const Text('Detaylı İstatistikler', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(radius: 40, backgroundColor: Colors.white12, backgroundImage: AssetImage(provider.activeAvatar.startsWith('assets') ? provider.activeAvatar : 'assets/images/${provider.activeAvatar}')),
                          const SizedBox(height: 16),
                          _buildStatRow('Zeka Seviyesi (IQ)', '$iq', Icons.psychology),
                          _buildStatRow('Kazanma Oranı', '%$winRatePercent', Icons.percent),
                          _buildStatRow('Toplam Soru', '${provider.totalQuestionsAnswered}', Icons.help_outline),
                          _buildStatRow('Doğru Cevap', '${provider.totalCorrectAnswers}', Icons.check_circle_outline),
                          _buildStatRow('Oynanan Oyun', '${provider.totalGamesPlayed}', Icons.sports_esports),
                          _buildStatRow('Harcanan Joker', '${provider.dailyJokersUsed} (Bugün)', Icons.star_half),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('KAPAT', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
                        )
                      ],
                    );
                  }
                );
              },
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white12,
                backgroundImage: AssetImage(provider.activeAvatar.startsWith('assets') ? provider.activeAvatar : 'assets/images/${provider.activeAvatar}'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('$iq', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 4),
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 4),
                                  child: Text('IQ', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => _showIQInfoDialog(context, provider),
                                  child: const Padding(
                                    padding: EdgeInsets.only(bottom: 4),
                                    child: Icon(Icons.info_outline, color: Colors.cyanAccent, size: 20),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(value: iqProgress, backgroundColor: Colors.blue[900], color: Colors.blue, minHeight: 6),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: () => _showEditNameDialog(context, provider),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  PremiumBadge(title: provider.userTitle),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            provider.userName,
                                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.edit_rounded, color: Colors.cyanAccent, size: 14),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('%$winRatePercent', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 6),
                                const Text('Doğru\ncevap', style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.1)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(value: winRate, backgroundColor: Colors.blue[900], color: Colors.lightBlue, minHeight: 6),
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white12, width: 1),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('${provider.totalCorrectAnswers}', style: const TextStyle(color: Colors.greenAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                                    const Text(' / ', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                                    Text('${provider.totalQuestionsAnswered}', style: const TextStyle(color: Colors.orangeAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
    bool showRedDot = false,
  }) {
    return AnimatedButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.menuButtonBg,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.menuButtonBorder, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: Colors.white, size: 32),
                if (showRedDot)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildBottomIcons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCircleButton(Icons.lightbulb, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => InventionsScreen()));
          }, label: "İCATLAR"),
          _buildCircleButton(Icons.military_tech, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AchievementsScreen()));
          }, label: "BAŞARIMLAR", showRedDot: context.watch<QuizProvider>().hasUnclaimedAchievements),
          _buildCircleButton(Icons.help_outline, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const HowToPlayScreen()));
          }, label: "NASIL\nOYNANIR"),
          _buildCircleButton(Icons.settings, () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
          }, label: "AYARLAR"),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.cyanAccent, size: 20),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, QuizProvider provider) {
    TextEditingController controller = TextEditingController(text: provider.userName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.menuButtonBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.cyanAccent, width: 2)),
          title: const Text('İsmini Değiştir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            maxLength: 15,
            decoration: const InputDecoration(
              hintText: "Yeni ismini gir...",
              hintStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
              counterStyle: TextStyle(color: Colors.white54),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İPTAL', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                provider.updateUserName(controller.text);
                Navigator.pop(context);
              },
              child: const Text('KAYDET', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      }
    );
  }

  void _showIQInfoDialog(BuildContext context, QuizProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.menuButtonBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.cyanAccent, width: 2)),
          title: const Row(
            children: [
              Icon(Icons.psychology, color: Colors.cyanAccent, size: 28),
              SizedBox(width: 10),
              Text('IQ Sistemi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Zeka seviyen (IQ), doğru cevaplama oranın ve tecrübene (çözdüğün soru sayısına) göre hesaplanır.\n\nBaşlangıç IQ seviyesi 10\'dur. Maksimum ulaşılabilecek IQ ise 160\'tır.\n\nUnvan Barajları:',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 12),
                _buildIQLevelRow('Acemi', '10 - 29 IQ', provider.userTitle),
                _buildIQLevelRow('Çömez', '30 - 59 IQ', provider.userTitle),
                _buildIQLevelRow('Çırak', '60 - 89 IQ', provider.userTitle),
                _buildIQLevelRow('Öğrenci', '90 - 109 IQ', provider.userTitle),
                _buildIQLevelRow('Bilgin', '110 - 129 IQ', provider.userTitle),
                _buildIQLevelRow('Profesör', '130 - 144 IQ', provider.userTitle),
                _buildIQLevelRow('Dahi', '145 - 154 IQ', provider.userTitle),
                _buildIQLevelRow('Efsane', '155+ IQ', provider.userTitle),
                const SizedBox(height: 12),
                const Text(
                  'İpucu: Sadece soruları doğru bilmek yetmez, bol bol soru çözerek tecrübe puanını (XP) da artırmalısın!',
                  style: TextStyle(color: Colors.orangeAccent, fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ANLADIM', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
            )
          ],
        );
      }
    );
  }

  Widget _buildIQLevelRow(String title, String iqRange, String userTitle) {
    bool isUserTitle = title == userTitle;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: EdgeInsets.symmetric(horizontal: isUserTitle ? 12.0 : 8.0, vertical: isUserTitle ? 8.0 : 4.0),
      decoration: isUserTitle ? BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.cyanAccent, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.2), blurRadius: 8, spreadRadius: 1),
        ]
      ) : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PremiumBadge(title: title, fontSize: isUserTitle ? 10 : 9),
          Row(
            children: [
              if (isUserTitle) const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Text('(Sen)', style: TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              Text(iqRange, style: TextStyle(color: isUserTitle ? Colors.cyanAccent : Colors.white70, fontWeight: FontWeight.bold, fontSize: isUserTitle ? 14 : 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap, {String? label, bool showRedDot = false}) {
    return AnimatedButton(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.menuButtonBorder, width: 2),
                  color: AppColors.menuButtonBg,
                ),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              if (showRedDot)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.appPurpleBg, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          if (label != null) ...[
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            )
          ]
        ],
      ),
    );
  }
}

class Premium3DPill extends StatelessWidget {
  final Widget child;
  final List<Color> gradientColors;
  final Color shadowColor;
  final Color borderColor;

  const Premium3DPill({
    super.key,
    required this.child,
    required this.gradientColors,
    required this.shadowColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          const BoxShadow(
            color: Colors.black54,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Base Gradient
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: child,
            ),
            
            // Top Gloss Reflection (Glass Highlight)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 18,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.6),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            
            // Bottom Inner Depth Shadow
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 12,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.5),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Top Border Highlight & Bottom Border Shadow (Bevel)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border(
                    top: BorderSide(color: Colors.white.withValues(alpha: 0.8), width: 1.5),
                    bottom: BorderSide(color: Colors.black.withValues(alpha: 0.6), width: 2),
                    left: BorderSide(color: Colors.white.withValues(alpha: 0.4), width: 1),
                    right: BorderSide(color: Colors.black.withValues(alpha: 0.4), width: 1),
                  ),
                ),
              ),
            ),
            
            // Outer Border Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: borderColor, width: 1.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
