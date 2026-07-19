import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/ad_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../utils/constants.dart';
import '../widgets/premium_badge.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  int _selectedTab = 0; // 0: Klasik Mod, 1: Sonsuz Mod, 2: Geçmiş
  Timer? _countdownTimer;
  Timer? _dotTimer;
  Duration _timeUntilReset = Duration.zero;
  Stream<QuerySnapshot>? _leaderboardStream;
  bool _hasSeenWeeklyRewardsThisWeek = true;

  @override
  void initState() {
    super.initState();
    _updateStream();
    _calculateTimeUntilReset();
    _checkWeeklyRewardsDot();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateTimeUntilReset();
    });
  }

  Future<void> _checkWeeklyRewardsDot() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String lastSeenStr = prefs.getString('last_seen_weekly_rewards') ?? '';
      
      bool shouldShow = false;
      if (lastSeenStr.isEmpty) {
        shouldShow = true;
      } else {
        DateTime lastSeen = DateTime.parse(lastSeenStr);
        DateTime now = DateTime.now();
        DateTime lastMonday = lastSeen.subtract(Duration(days: lastSeen.weekday - 1));
        DateTime thisMonday = now.subtract(Duration(days: now.weekday - 1));
        
        if (thisMonday.year != lastMonday.year || thisMonday.month != lastMonday.month || thisMonday.day != lastMonday.day) {
          shouldShow = true;
        }
      }

      if (shouldShow && mounted) {
        setState(() {
          _hasSeenWeeklyRewardsThisWeek = false;
        });
        _dotTimer = Timer(const Duration(seconds: 5), () async {
          if (mounted) {
            setState(() {
              _hasSeenWeeklyRewardsThisWeek = true;
            });
            await prefs.setString('last_seen_weekly_rewards', DateTime.now().toIso8601String());
          }
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _dotTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _updateStream() {
    String targetMode = _selectedTab == 0 ? 'Klasik Mod' : (_selectedTab == 1 ? 'Sonsuz Mod' : 'Geçmiş');
    setState(() {
      _leaderboardStream = FirebaseFirestore.instance.collection('leaderboard').where('mode', isEqualTo: targetMode).snapshots();
    });
  }

  void _calculateTimeUntilReset() {
    final now = DateTime.now();
    int daysUntilSunday = DateTime.sunday - now.weekday;
    if (daysUntilSunday < 0) daysUntilSunday += 7;
    
    DateTime nextReset = DateTime(now.year, now.month, now.day, 23, 59, 59).add(Duration(days: daysUntilSunday));
    if (now.isAfter(nextReset)) {
       nextReset = nextReset.add(const Duration(days: 7));
    }
    
    setState(() {
      _timeUntilReset = nextReset.difference(now);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appPurpleBg,
      bottomNavigationBar: !kIsWeb ? const CustomBannerAd() : const SizedBox.shrink(),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GestureDetector(
                        onTap: () => _showWeeklyRewardsInfo(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(color: Colors.orange.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 1),
                            ],
                            border: Border.all(color: Colors.yellow.withValues(alpha: 0.6), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.card_giftcard, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 6),
                              const Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('HAFTALIK', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 1)),
                                  Text('ÖDÜLLER', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (!_hasSeenWeeklyRewardsThisWeek)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(color: Colors.red.withValues(alpha: 0.5), blurRadius: 4, spreadRadius: 1),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  Expanded(
                    child: const Text(
                      'SKOR TABLOSU',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 36),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Countdown Timer (Premium Segmented)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(bottom: 12.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D0533), Color(0xFF0A1A4A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.5), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.2), blurRadius: 14, spreadRadius: 1),
                  ],
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timer_outlined, color: Colors.cyanAccent, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'HAFTALIK SIFIRLAMA',
                        style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                      const SizedBox(width: 12),
                      _buildTimeBox(_timeUntilReset.inDays.toString().padLeft(2, '0'), 'GÜN'),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3),
                        child: Text(':', style: TextStyle(color: Colors.cyanAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      _buildTimeBox((_timeUntilReset.inHours % 24).toString().padLeft(2, '0'), 'SA'),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3),
                        child: Text(':', style: TextStyle(color: Colors.cyanAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      _buildTimeBox((_timeUntilReset.inMinutes % 60).toString().padLeft(2, '0'), 'DK'),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3),
                        child: Text(':', style: TextStyle(color: Colors.cyanAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      _buildTimeBox((_timeUntilReset.inSeconds % 60).toString().padLeft(2, '0'), 'SN'),
                    ],
                  ),
                ),
              ),
            ),
            
            // Mode Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedTab = 0);
                        _updateStream();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedTab == 0 ? Colors.cyanAccent.withValues(alpha: 0.2) : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _selectedTab == 0 ? Colors.cyanAccent : Colors.white24,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          'Klasik',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _selectedTab == 0 ? Colors.cyanAccent : Colors.white54,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedTab = 1);
                        _updateStream();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedTab == 1 ? Colors.cyanAccent.withValues(alpha: 0.2) : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _selectedTab == 1 ? Colors.cyanAccent : Colors.white24,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          'Sonsuz',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _selectedTab == 1 ? Colors.cyanAccent : Colors.white54,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedTab = 2);
                        _updateStream();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedTab == 2 ? Colors.amberAccent.withValues(alpha: 0.2) : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _selectedTab == 2 ? Colors.amberAccent : Colors.white24,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          'Geçmiş',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _selectedTab == 2 ? Colors.amberAccent : Colors.white54,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Podium
            Consumer<QuizProvider>(
              builder: (context, provider, child) {
                String targetMode = _selectedTab == 0 ? 'Klasik Mod' : (_selectedTab == 1 ? 'Sonsuz Mod' : 'Geçmiş');
                return StreamBuilder<QuerySnapshot>(
                  stream: _leaderboardStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.cyanAccent)));
                    }
                    if (snapshot.hasError) {
                      return const Expanded(child: Center(child: Text("Bağlantı Hatası!", style: TextStyle(color: Colors.redAccent))));
                    }
                    
                    List<Map<String, dynamic>> parsedScores = [];
                    if (snapshot.hasData) {
                      for (var doc in snapshot.data!.docs) {
                        String prefix = doc.id.split('_').first;
                        if (prefix.length != 28) {
                          FirebaseFirestore.instance.collection('leaderboard').doc(doc.id).delete();
                          continue;
                        }

                        try {
                          var map = doc.data() as Map<String, dynamic>;
                          map['uid'] = prefix;
                          num sc = map['score'] ?? 0;
                          if (sc > 0) {
                            parsedScores.add(map);
                          }
                        } catch (_) {}
                      }
                    }

                    Map<String, Map<String, dynamic>> bestScores = {};
                    for (var score in parsedScores) {
                      String uid = score['uid'] ?? score['userName'] ?? 'Bilinmeyen';
                      int currentScore = score['score'] ?? 0;
                      
                      if (!bestScores.containsKey(uid) || (bestScores[uid]!['score'] ?? 0) < currentScore) {
                        bestScores[uid] = score;
                      }
                    }
                    
                    if (targetMode == 'Klasik Mod') {
                      String formatted = provider.weeklyScore.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
                      
                      String? myUidKey;
                      for (var key in bestScores.keys) {
                        if (bestScores[key]!['userName'] == provider.userName) {
                          myUidKey = key;
                          break;
                        }
                      }
                      
                      if (myUidKey != null) {
                        if (provider.weeklyScore > bestScores[myUidKey]!['score']) {
                          bestScores[myUidKey]!['score'] = provider.weeklyScore;
                          bestScores[myUidKey]!['moneyString'] = '$formatted ₺';
                        }
                      } else {
                        String fallbackUid = 'local_uid_${DateTime.now().millisecondsSinceEpoch}';
                        bestScores[fallbackUid] = {
                          'mode': 'Klasik Mod',
                          'score': provider.weeklyScore,
                          'moneyString': '$formatted ₺',
                          'userName': provider.userName,
                          'avatar': provider.activeAvatar,
                          'uid': fallbackUid,
                        };
                      }
                    }
                    
                    parsedScores = bestScores.values.toList();
                    parsedScores.sort((a, b) => (b['score'] as num).compareTo(a['score'] as num));

                    int userRank = parsedScores.indexWhere((s) => s['userName'] == provider.userName);
                    Map<String, dynamic>? userScoreMap;
                    if (userRank != -1) {
                      userScoreMap = parsedScores[userRank];
                    }

                    if (parsedScores.length > 50) {
                      parsedScores = parsedScores.sublist(0, 50);
                    }

                return Expanded(
                  child: Column(
                    children: [
                      // Podium
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (parsedScores.length > 1)
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: _buildPodiumItem(
                                  rank: 2,
                                  color: Colors.grey[300]!,
                                  size: 50,
                                  scoreMap: parsedScores[1],
                                  provider: provider,
                                ),
                              ),
                            if (parsedScores.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildPodiumItem(
                                  rank: 1,
                                  color: const Color(0xFFFFD700),
                                  size: 70,
                                  scoreMap: parsedScores[0],
                                  provider: provider,
                                ),
                              ),
                            if (parsedScores.length > 2)
                              Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: _buildPodiumItem(
                                  rank: 3,
                                  color: const Color(0xFFCD7F32),
                                  size: 50,
                                  scoreMap: parsedScores[2],
                                  provider: provider,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // List of other ranks
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          physics: const BouncingScrollPhysics(),
                          itemCount: parsedScores.length > 3 ? parsedScores.length - 3 : 0,
                          itemBuilder: (context, index) {
                            final rank = index + 4;
                            final scoreMap = parsedScores[index + 3];
                            return _buildListRankItem(rank, scoreMap, provider);
                          },
                        ),
                      ),
                      
                      // User's own rank sticky widget
                      if (userScoreMap != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0, bottom: 2.0),
                                child: Text('Senin Sıralaman:', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 11)),
                              ),
                              _buildListRankItem(userRank + 1, userScoreMap, provider, isHighlighted: true),
                            ],
                          ),
                        ),
                      
                      // Bottom Kapat Button
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.menuButtonBg,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Text(
                              'Kapat',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
          ],
        ),
      ),
    );
  }
  void _showWeeklyRewardsInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 40),
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF2A0845),
                      const Color(0xFF1A1A2E).withValues(alpha: 0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.5), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amberAccent.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'HAFTALIK ÖDÜLLER',
                      style: TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Her Pazar gecesi 23:59'da sıfırlanan liderlik tablosunda ilk 10'a gir, muhteşem ödülleri kap!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                    ),
                    const SizedBox(height: 24),
                    _buildRewardTier(1, '2.500 + 10 Bilet', const Color(0xFFFFD700), '1. SIRA', 'assets/images/trophy_gold.png'),
                    _buildRewardTier(2, '1.500 + 5 Bilet', const Color(0xFFC0C0C0), '2. SIRA', 'assets/images/trophy_silver.png'),
                    _buildRewardTier(3, '1.000 + 3 Bilet', const Color(0xFFCD7F32), '3. SIRA', 'assets/images/trophy_bronze.png'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(color: Colors.white24, indent: 20, endIndent: 20),
                    ),
                    _buildRewardTier(null, '250 + 1 Bilet', Colors.white, '4. - 10. SIRA', null),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.amber, Colors.orange],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'SAVAŞA KATIL',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                child: Image.asset(
                  'assets/images/trophy_gold.png',
                  width: 80,
                  height: 80,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRewardTier(int? rank, String diamonds, Color rankColor, String label, String? iconPath) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: rankColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          if (iconPath != null)
            Image.asset(iconPath, width: 32, height: 32)
          else
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: rankColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: rankColor.withValues(alpha: 0.5), width: 1),
              ),
              child: const Center(
                child: Icon(Icons.star, color: Colors.white, size: 18),
              ),
            ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: rankColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3), width: 1),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  children: [
                    Image.asset('assets/images/3d_diamond_clear_nobg.png', width: 20, height: 20),
                    const SizedBox(width: 6),
                    Text(
                      diamonds,
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getBotTitle(String name) {
    if (name.contains('Einstein') || name.contains('Tesla')) return 'Efsane';
    if (name.contains('Newton') || name.contains('Curie')) return 'Dahi';
    if (name.contains('Hawking') || name.contains('Da Vinci')) return 'Profesör';
    if (name.contains('Uzman')) return 'Bilgin';
    if (name.contains('Oyuncu')) return 'Öğrenci';
    if (name.contains('Galileo') || name.contains('Pisagor')) return 'Bilgin';
    return 'Çırak';
  }

  Widget _buildTimeBox(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.cyanAccent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.4), width: 1),
          ),
          child: Text(
            value,
            style: const TextStyle(color: Colors.cyanAccent, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildPodiumItem({required int rank, required Color color, required double size, required Map<String, dynamic> scoreMap, required QuizProvider provider}) {
    String moneyString = scoreMap['moneyString'] ?? '${scoreMap['score']}';
    if (scoreMap['mode'] == 'Sonsuz Mod') {
      moneyString = '${scoreMap['score']} Soru';
    } else if (scoreMap['mode'] == 'Klasik Mod' || scoreMap['mode'] == 'Geçmiş') {
      num sc = scoreMap['score'] ?? 0;
      if (sc >= 1000000) {
        double mil = sc / 1000000;
        moneyString = '${mil == mil.toInt() ? mil.toInt() : mil.toStringAsFixed(1)} Milyon ₺';
      } else if (sc >= 1000) {
        double k = sc / 1000;
        moneyString = '${k == k.toInt() ? k.toInt() : k.toStringAsFixed(1)} Bin ₺';
      } else {
        moneyString = '${sc.toInt()} ₺';
      }
    }
    String rankLabel = rank == 1 ? '🥇 1.' : (rank == 2 ? '🥈 2.' : '🥉 3.');
    bool isUser = scoreMap['userName'] == provider.userName;
    
    String rawAvatar = scoreMap['avatar'] ?? 'einstein_avatar.png';
    if (isUser) rawAvatar = provider.activeAvatar;
    String avatarPath = rawAvatar.startsWith('assets/images/') ? rawAvatar : 'assets/images/$rawAvatar';
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.6), width: 1),
          ),
          child: Text(
            rankLabel,
            style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 12),
          ),
        ),
        const SizedBox(height: 4),
        CircleAvatar(
          radius: size / 2.5,
          backgroundColor: color,
          child: CircleAvatar(
            radius: (size / 2.5) - 3,
            backgroundColor: AppColors.appPurpleBg,
            backgroundImage: AssetImage(avatarPath),
          ),
        ),
        const SizedBox(height: 6),
        Image.asset(
          rank == 1 ? 'assets/images/trophy_gold.png' : (rank == 2 ? 'assets/images/trophy_silver.png' : 'assets/images/trophy_bronze.png'),
          width: size / 1.8,
          height: size / 1.8,
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: size * 1.6,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: PremiumBadge(
              title: scoreMap['userTitle'] ?? (isUser ? provider.userTitle : _getBotTitle(scoreMap['userName'] ?? '')),
              fontSize: 7,
            ),
          ),
        ),
        const SizedBox(height: 2),
        SizedBox(
          width: size * 1.6,
          child: Text(
            isUser ? provider.userName : scoreMap['userName'] ?? 'Sen', 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: false,
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          width: size * 1.6,
          child: Text(
            moneyString,
            style: const TextStyle(color: Colors.white60, fontSize: 9),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: false,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildListRankItem(int rank, Map<String, dynamic> scoreMap, QuizProvider provider, {bool isHighlighted = false}) {
    String moneyString = '';
    if (scoreMap['mode'] == 'Sonsuz Mod') {
      moneyString = '${scoreMap['score']} Soru';
    } else if (scoreMap['mode'] == 'Klasik Mod' || scoreMap['mode'] == 'Geçmiş') {
      num sc = scoreMap['score'] ?? 0;
      if (sc >= 1000000) {
        double mil = sc / 1000000;
        moneyString = '${mil == mil.toInt() ? mil.toInt() : mil.toStringAsFixed(1)} Milyon ₺';
      } else if (sc >= 1000) {
        double k = sc / 1000;
        moneyString = '${k == k.toInt() ? k.toInt() : k.toStringAsFixed(1)} Bin ₺';
      } else {
        moneyString = '${sc.toInt()} ₺';
      }
    } else {
      moneyString = scoreMap['moneyString'] ?? '${scoreMap['score']} ₺';
    }
    bool isUser = scoreMap['userName'] == provider.userName;
    
    String rawAvatar = scoreMap['avatar'] ?? 'einstein_avatar.png';
    if (isUser) rawAvatar = provider.activeAvatar;
    String avatarPath = rawAvatar.startsWith('assets/images/') ? rawAvatar : 'assets/images/$rawAvatar';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.cyan.withValues(alpha: 0.2) : AppColors.menuButtonBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isHighlighted ? Colors.cyanAccent : AppColors.menuButtonBorder, width: isHighlighted ? 1.5 : 0.8),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.rankRed.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              '#$rank', 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 17,
            backgroundImage: AssetImage(avatarPath),
            backgroundColor: Colors.white12,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    PremiumBadge(
                      title: scoreMap['userTitle'] ?? (isUser ? provider.userTitle : _getBotTitle(scoreMap['userName'] ?? '')),
                      fontSize: 7,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        isUser ? provider.userName : scoreMap['userName'] ?? 'Oyuncu',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  moneyString,
                  style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
