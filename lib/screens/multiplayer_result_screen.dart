import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/multiplayer_provider.dart';
import '../providers/quiz_provider.dart';
import '../utils/constants.dart';
import 'multiplayer_quiz_screen.dart';

class MultiplayerResultScreen extends StatefulWidget {
  const MultiplayerResultScreen({super.key});

  @override
  State<MultiplayerResultScreen> createState() => _MultiplayerResultScreenState();
}

class _MultiplayerResultScreenState extends State<MultiplayerResultScreen> {
  bool _iRequestedRematch = false;
  bool _rematchDialogShowing = false;
  
  // Emote state
  String? _currentEmote;
  Timestamp? _lastEmoteTs;
  Timer? _emoteTimer;

  @override
  void dispose() {
    _emoteTimer?.cancel();
    super.dispose();
  }

  void _requestRematch() {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final mpProvider = Provider.of<MultiplayerProvider>(context, listen: false);
    
    if (quizProvider.roomCards <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yeterli Oda Kartınız yok! Marketten satın alabilirsiniz.'), backgroundColor: Colors.red)
      );
      return;
    }
    
    _iRequestedRematch = true;
    mpProvider.requestRematch();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rövanş isteği gönderildi. Rakip bekleniyor...'), backgroundColor: Colors.orange)
    );
  }

  void _showEmoteMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _emoteBtn('😂', ctx),
            _emoteBtn('😡', ctx),
            _emoteBtn('👏', ctx),
            _emoteBtn('😭', ctx),
            _emoteBtn('🤯', ctx),
          ],
        ),
      ),
    );
  }

  Widget _emoteBtn(String emoji, BuildContext ctx) {
    return GestureDetector(
      onTap: () {
        Provider.of<MultiplayerProvider>(context, listen: false).sendEmote(emoji);
        Navigator.pop(ctx);
        _triggerEmoteAnim(emoji);
      },
      child: Text(emoji, style: const TextStyle(fontSize: 40)),
    );
  }

  void _triggerEmoteAnim(String emoji) {
    setState(() => _currentEmote = emoji);
    _emoteTimer?.cancel();
    _emoteTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _currentEmote = null);
    });
  }

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
              const Text('Oda kapandı veya rakip ayrıldı.', style: TextStyle(color: Colors.white, fontSize: 20)),
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
    
    // Rematch Logic handling
    if (data['status'] == 'playing') {
       WidgetsBinding.instance.addPostFrameCallback((_) {
         if (_iRequestedRematch) {
            quizProvider.useRoomCard();
         }
         Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MultiplayerQuizScreen()));
       });
       return Scaffold(backgroundColor: AppColors.appPurpleBg, body: const Center(child: CircularProgressIndicator()));
    }
    
    String? requesterId = data['rematchRequestedBy'];
    String? currentUid = mpProvider.currentUserId;
    
    if (requesterId != null && requesterId != currentUid && !_rematchDialogShowing) {
       _rematchDialogShowing = true;
       WidgetsBinding.instance.addPostFrameCallback((_) {
         showDialog(
           context: context,
           barrierDismissible: false,
           builder: (ctx) => AlertDialog(
             backgroundColor: AppColors.surface,
             title: const Text('Rövanş İsteği', style: TextStyle(color: Colors.amberAccent)),
             content: const Text('Rakip rövanş istiyor! Kabul ediyor musun? (Ücretsiz)', style: TextStyle(color: Colors.white)),
             actions: [
               TextButton(
                 onPressed: () {
                   mpProvider.declineRematch();
                   _rematchDialogShowing = false;
                   Navigator.pop(ctx);
                 },
                 child: const Text('Reddet', style: TextStyle(color: Colors.redAccent)),
               ),
               ElevatedButton(
                 onPressed: () {
                   _rematchDialogShowing = false;
                   final rawQuestions = quizProvider.getRandomQuestionsForDuel(10);
                   List<Map<String, dynamic>> newQuestions = rawQuestions.map((q) => q.toMap()).toList();
                   mpProvider.acceptRematch(newQuestions);
                   Navigator.pop(ctx);
                 },
                 style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                 child: const Text('Kabul Et', style: TextStyle(color: Colors.white)),
               )
             ]
           )
         ).then((_) => _rematchDialogShowing = false);
       });
    }

    if (requesterId == null && _iRequestedRematch) {
      _iRequestedRematch = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rakip rövanşı reddetti.'), backgroundColor: Colors.red));
      });
    }
    
    // Emote Handling
    String emoteField = mpProvider.isHost ? 'guestEmote' : 'hostEmote';
    if (data[emoteField] != null) {
      Timestamp ts = data[emoteField]['timestamp'] ?? Timestamp.now();
      if (DateTime.now().difference(ts.toDate()).inSeconds < 3) {
        if (_lastEmoteTs != ts) { 
           _lastEmoteTs = ts;
           WidgetsBinding.instance.addPostFrameCallback((_) {
             _triggerEmoteAnim(data[emoteField]['emote']);
           });
        }
      }
    }
    
    int myScore = mpProvider.isHost ? (data['hostScore'] ?? 0) : (data['guestScore'] ?? 0);
    int oppScore = mpProvider.isHost ? (data['guestScore'] ?? 0) : (data['hostScore'] ?? 0);
    
    String oppName = mpProvider.isHost ? (data['guestName'] ?? 'Rakip') : (data['hostName'] ?? 'Rakip');

    String myAvatar = mpProvider.isHost ? (data['hostAvatar'] ?? 'assets/images/einstein_avatar.png') : (data['guestAvatar'] ?? 'assets/images/einstein_avatar.png');
    String oppAvatar = mpProvider.isHost ? (data['guestAvatar'] ?? 'assets/images/einstein_avatar.png') : (data['hostAvatar'] ?? 'assets/images/einstein_avatar.png');
    
    if (!myAvatar.startsWith('assets')) myAvatar = 'assets/images/$myAvatar';
    if (!oppAvatar.startsWith('assets')) oppAvatar = 'assets/images/$oppAvatar';
    
    bool isWin = myScore > oppScore;
    bool isDraw = myScore == oppScore;

    return Scaffold(
      backgroundColor: AppColors.appPurpleBg,
      floatingActionButton: FloatingActionButton(
        onPressed: _showEmoteMenu,
        backgroundColor: Colors.white24,
        child: const Text('💬', style: TextStyle(fontSize: 24)),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
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
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: isDraw ? Colors.blueAccent.withValues(alpha: 0.5) : (isWin ? Colors.amberAccent.withValues(alpha: 0.5) : Colors.redAccent.withValues(alpha: 0.5)),
                            blurRadius: 30,
                            spreadRadius: 10,
                          )
                        ]
                      ),
                      child: Icon(
                        isDraw ? Icons.handshake : (isWin ? Icons.emoji_events : Icons.sentiment_dissatisfied),
                        color: isDraw ? Colors.blueAccent : (isWin ? Colors.amberAccent : Colors.redAccent),
                        size: 100,
                      ),
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
                    const SizedBox(height: 40),
                    
                    // Skor Tablosu
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF141E30), Color(0xFF243B55)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3), width: 2),
                        boxShadow: [
                          BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.1), blurRadius: 20, spreadRadius: 2),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.white12,
                                  backgroundImage: AssetImage(myAvatar),
                                ),
                                const SizedBox(height: 12),
                                Text('Sen', style: TextStyle(color: isWin ? Colors.amberAccent : Colors.white, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 8),
                                Text('$myScore', style: TextStyle(color: isWin ? Colors.amberAccent : Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: const Text('VS', style: TextStyle(color: Colors.white54, fontSize: 24, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold)),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.white12,
                                  backgroundImage: AssetImage(oppAvatar),
                                ),
                                const SizedBox(height: 12),
                                Text(oppName, style: TextStyle(color: !isWin && !isDraw ? Colors.amberAccent : Colors.white, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 8),
                                Text('$oppScore', style: TextStyle(color: !isWin && !isDraw ? Colors.amberAccent : Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    if (requesterId == currentUid)
                       const Padding(
                         padding: EdgeInsets.only(bottom: 20),
                         child: Text('Rövanş isteği gönderildi, bekleniyor...', style: TextStyle(color: Colors.orangeAccent, fontSize: 16, fontStyle: FontStyle.italic)),
                       )
                    else if (requesterId == null)
                       Padding(
                         padding: const EdgeInsets.only(bottom: 20),
                         child: ElevatedButton.icon(
                           onPressed: _requestRematch,
                           icon: const Icon(Icons.refresh, color: Colors.white),
                           label: const Text('RÖVANŞ İSTE (1 Bilet)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                           style: ElevatedButton.styleFrom(
                             backgroundColor: Colors.orangeAccent.shade700,
                             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                           ),
                         ),
                       ),
                    
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Colors.cyanAccent, Colors.blue]),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          mpProvider.leaveRoom();
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('ANA MENÜYE DÖN', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          
          if (_currentEmote != null)
              Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.5, end: 1.5),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, val, child) {
                    return Transform.scale(
                      scale: val,
                      child: Opacity(
                        opacity: val < 1.0 ? val : (1.5 - val) * 2,
                        child: Text(_currentEmote!, style: const TextStyle(fontSize: 100)),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
