import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/multiplayer_provider.dart';
import '../utils/constants.dart';
import 'multiplayer_result_screen.dart';

class MultiplayerQuizScreen extends StatefulWidget {
  const MultiplayerQuizScreen({super.key});

  @override
  State<MultiplayerQuizScreen> createState() => _MultiplayerQuizScreenState();
}

class _MultiplayerQuizScreenState extends State<MultiplayerQuizScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  int _score = 0;
  int _timeLeft = 20;
  Timer? _timer;
  
  bool _isAnswered = false;
  int? _selectedIndex;
  bool _isRevealing = false;
  
  late List<dynamic> _questions;
  
  // Emote state
  String? _currentEmote;
  Timestamp? _lastEmoteTs;
  Timer? _emoteTimer;

  int _displayedOpponentScore = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final mpProvider = Provider.of<MultiplayerProvider>(context, listen: false);
    _questions = mpProvider.roomData!['questions'];
    _startTimer();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (!_isAnswered && _timeLeft > 0) {
        _timer?.cancel();
        setState(() {
          _isAnswered = true;
          _timeLeft = 0;
          _selectedIndex = -1;
        });
        _submitAnswer(-1, -1);
      }
    }
  }

  void _startTimer() {
    final mpProvider = Provider.of<MultiplayerProvider>(context, listen: false);
    int baseTime = 20;
    var currentQuestion = _questions[_currentIndex];
    int charCount = currentQuestion['text'].toString().length;
    for (var option in currentQuestion['options']) {
      charCount += option.toString().length;
    }
    int extraTime = (charCount / 15).floor();
    _timeLeft = baseTime + extraTime;
    if (_timeLeft > 90) _timeLeft = 90;

    _isAnswered = false;
    _isRevealing = false;
    _selectedIndex = null;
    _timer?.cancel();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_timeLeft > 0) {
            _timeLeft--;
          } else {
            _timer?.cancel();
            if (!_isAnswered) {
              _submitAnswer(-1, -1);
            }
          }
        });
      }
    });

    if (mpProvider.isHost) {
      Future.delayed(Duration(seconds: _timeLeft + 5), () {
        if (!mounted) return;
        final roomData = mpProvider.roomData;
        if (roomData != null) {
          Map guestAns = roomData['guestAnswers'] ?? {};
          if (!guestAns.containsKey(_currentIndex.toString())) {
            FirebaseFirestore.instance.collection('rooms').doc(mpProvider.roomId).update({
              'guestAnswers.$_currentIndex': -1,
            });
          }
        }
      });
    }
  }

  void _submitAnswer(int index, int correctIndex) {
    if (_isAnswered) return;
    
    _timer?.cancel();
    setState(() {
      _isAnswered = true;
      _selectedIndex = index;
    });

    Provider.of<MultiplayerProvider>(context, listen: false).submitAnswer(_currentIndex, index);
  }

  void _startReveal(dynamic hostChoiceRaw, dynamic guestChoiceRaw) {
    setState(() {
      _isRevealing = true;
      _timer?.cancel();
    });
    
    final mpProvider = Provider.of<MultiplayerProvider>(context, listen: false);
    final data = mpProvider.roomData;
    bool isHost = mpProvider.isHost;
    
    int hostChoice = int.tryParse(hostChoiceRaw?.toString() ?? '-1') ?? -1;
    int guestChoice = int.tryParse(guestChoiceRaw?.toString() ?? '-1') ?? -1;
    
    int myChoice = isHost ? hostChoice : guestChoice;
    
    final currentQ = _questions[_currentIndex];
    int correctIndex = int.tryParse(currentQ['correctOptionIndex']?.toString() ?? '-1') ?? -1;
    
    if (myChoice == correctIndex) {
      int diff = int.tryParse(currentQ['difficulty']?.toString() ?? '2') ?? 2;
      int points = diff == 1 ? 10 : diff == 2 ? 20 : 30;
      _score += points;
      mpProvider.updateScore(_score);
    }
    
    int oppScoreCalculated = 0;
    Map<String, dynamic> hostAns = data?['hostAnswers'] ?? {};
    Map<String, dynamic> guestAns = data?['guestAnswers'] ?? {};
    
    for (int i = 0; i <= _currentIndex; i++) {
      int oppC = isHost 
          ? int.tryParse(guestAns[i.toString()]?.toString() ?? '-1') ?? -1
          : int.tryParse(hostAns[i.toString()]?.toString() ?? '-1') ?? -1;
      int corr = int.tryParse(_questions[i]['correctOptionIndex']?.toString() ?? '-1') ?? -1;
      if (oppC != -1 && oppC == corr) {
        int d = int.tryParse(_questions[i]['difficulty']?.toString() ?? '2') ?? 2;
        oppScoreCalculated += (d == 1 ? 10 : d == 2 ? 20 : 30);
      }
    }
    
    setState(() {
      _displayedOpponentScore = oppScoreCalculated;
    });
    
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (_currentIndex < 9) {
        if (isHost) {
          mpProvider.moveToNextQuestion(_currentIndex + 1);
        }
      } else {
        mpProvider.finishGame(_score);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MultiplayerResultScreen()));
      }
    });
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
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _emoteTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mpProvider = Provider.of<MultiplayerProvider>(context);
    final data = mpProvider.roomData;
    
    if (data == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    
    int syncedIndex = data['currentQuestionIndex'] ?? 0;
    if (syncedIndex > _currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _currentIndex = syncedIndex;
          _isRevealing = false;
        });
        _startTimer();
      });
    }

    Map<String, dynamic> hostAns = data['hostAnswers'] ?? {};
    Map<String, dynamic> guestAns = data['guestAnswers'] ?? {};
    
    bool hostDidAnswer = hostAns.containsKey(_currentIndex.toString());
    bool guestDidAnswer = guestAns.containsKey(_currentIndex.toString());
    
    if (hostDidAnswer && guestDidAnswer && !_isRevealing && syncedIndex == _currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isRevealing) {
          _startReveal(hostAns[_currentIndex.toString()], guestAns[_currentIndex.toString()]);
        }
      });
    }

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
    
    final currentQ = _questions[_currentIndex];
    
    int myScore = _score;
    String opponentName = mpProvider.isHost ? (data['guestName'] ?? 'Rakip') : (data['hostName'] ?? 'Rakip');
    
    String myAvatar = mpProvider.isHost ? (data['hostAvatar'] ?? 'assets/images/einstein_avatar.png') : (data['guestAvatar'] ?? 'assets/images/einstein_avatar.png');
    String oppAvatar = mpProvider.isHost ? (data['guestAvatar'] ?? 'assets/images/einstein_avatar.png') : (data['hostAvatar'] ?? 'assets/images/einstein_avatar.png');
    if (!myAvatar.startsWith('assets')) myAvatar = 'assets/images/$myAvatar';
    if (!oppAvatar.startsWith('assets')) oppAvatar = 'assets/images/$oppAvatar';

    int myChoice = -1;
    int oppChoice = -1;
    if (_isRevealing) {
       myChoice = mpProvider.isHost ? int.tryParse(hostAns[_currentIndex.toString()]?.toString() ?? '-1') ?? -1 : int.tryParse(guestAns[_currentIndex.toString()]?.toString() ?? '-1') ?? -1;
       oppChoice = mpProvider.isHost ? int.tryParse(guestAns[_currentIndex.toString()]?.toString() ?? '-1') ?? -1 : int.tryParse(hostAns[_currentIndex.toString()]?.toString() ?? '-1') ?? -1;
    }
    
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildScoreCard('Sen', myScore, Colors.greenAccent),
                      Text('$_timeLeft', style: const TextStyle(color: Colors.amberAccent, fontSize: 36, fontWeight: FontWeight.bold)),
                      _buildScoreCard(opponentName, _displayedOpponentScore, Colors.redAccent),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  LinearProgressIndicator(
                    value: (_currentIndex + 1) / 10,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.amberAccent),
                  ),
                  const SizedBox(height: 10),
                  Text('Soru ${_currentIndex + 1} / 10', style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
                  
                  const Spacer(),
                  
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (currentQ['imageUrl'] != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                currentQ['imageUrl'],
                                height: 120,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        Text(
                          currentQ['text'],
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  
                  if (_isAnswered && !_isRevealing)
                     Padding(
                       padding: const EdgeInsets.only(bottom: 20),
                       child: Text('$opponentName bekleniyor...', style: const TextStyle(color: Colors.amberAccent, fontSize: 16, fontStyle: FontStyle.italic)),
                     ),

                  ...List.generate(4, (index) {
                    bool isCorrect = index == currentQ['correctOptionIndex'];
                    bool isMyChoice = index == myChoice;
                    bool isOppChoice = index == oppChoice;
                    
                    Color btnColor = AppColors.menuButtonBg;
                    if (_isRevealing) {
                      if (isCorrect) {
                        btnColor = Colors.green.shade700;
                      } else if (isMyChoice || isOppChoice) {
                        btnColor = Colors.red.shade700;
                      }
                    } else if (_isAnswered && index == _selectedIndex) {
                      btnColor = Colors.orangeAccent.shade700;
                    }
                    
                    return GestureDetector(
                      onTap: () => _submitAnswer(index, currentQ['correctOptionIndex']),
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: btnColor,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: (_isAnswered && index == _selectedIndex) ? Colors.white : AppColors.menuButtonBorder, width: 2),
                        ),
                        child: Row(
                          children: [
                            if (_isRevealing && isMyChoice)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: CircleAvatar(radius: 14, backgroundColor: Colors.white, child: CircleAvatar(radius: 12, backgroundImage: AssetImage(myAvatar))),
                              )
                            else
                              const SizedBox(width: 28),
                              
                            Expanded(
                              child: Text(
                                currentQ['options'][index],
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            
                            if (_isRevealing && isOppChoice)
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: CircleAvatar(radius: 14, backgroundColor: Colors.white, child: CircleAvatar(radius: 12, backgroundImage: AssetImage(oppAvatar))),
                              )
                            else
                              const SizedBox(width: 28),
                          ]
                        )
                      ),
                    );
                  }),
                  const Spacer(),
                ],
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
  
  Widget _buildScoreCard(String name, int score, Color color) {
    return Column(
      children: [
        Text(name, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
        Text('$score', style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w900)),
      ],
    );
  }
}
