import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/multiplayer_provider.dart';
import '../utils/constants.dart';
import 'multiplayer_result_screen.dart';
import '../providers/audio_provider.dart';
import '../services/ad_service.dart';
import 'package:flutter/foundation.dart';

class MultiplayerQuizScreen extends StatefulWidget {
  const MultiplayerQuizScreen({super.key});

  @override
  State<MultiplayerQuizScreen> createState() => _MultiplayerQuizScreenState();
}

class _MultiplayerQuizScreenState extends State<MultiplayerQuizScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _bgController;
  late AnimationController _pulseController;
  late AnimationController _particleController;

  int _currentIndex = 0;
  int _score = 0;
  int _timeLeft = 20;
  Timer? _timer;
  
  bool _isAnswered = false;
  int? _selectedIndex;
  bool _isRevealing = false;
  
  late List<dynamic> _questions;
  
  String? _currentEmote;
  Timestamp? _lastEmoteTs;
  Timer? _emoteTimer;
  bool _hasAbandoned = false;

  int _displayedOpponentScore = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..repeat(reverse: true);
    _particleController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();

    final mpProvider = Provider.of<MultiplayerProvider>(context, listen: false);
    if (mpProvider.roomData == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
      return;
    }
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
            if (_timeLeft <= 5) {
              context.read<AudioProvider>().playSfx('tick.wav');
            }
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
              'guestAnswers.': -1,
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

    context.read<AudioProvider>().playSfx('click.wav');
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
      context.read<AudioProvider>().playSfx('correct.mp3');
    } else {
      context.read<AudioProvider>().playSfx('wrong.wav');
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
      if (_currentIndex < 14) {
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
    _bgController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    _timer?.cancel();
    _emoteTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mpProvider = Provider.of<MultiplayerProvider>(context);
    final data = mpProvider.roomData;
    
    if (data == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    
    if (data['status'] == 'abandoned' && !_hasAbandoned) {
       _hasAbandoned = true;
       WidgetsBinding.instance.addPostFrameCallback((_) {
         if (mounted) {
           showDialog(
             context: context,
             barrierDismissible: false,
             builder: (ctx) => AlertDialog(
               backgroundColor: AppColors.surface,
               title: const Text('Maç İptal', style: TextStyle(color: Colors.white)),
               content: const Text('Rakip oyundan ayrıldı. Galip sayılırsınız (veya maç iptal edildi).', style: TextStyle(color: Colors.white70)),
               actions: [
                 TextButton(
                   onPressed: () {
                     Navigator.pop(ctx);
                     Navigator.pop(context);
                   },
                   child: const Text('Tamam', style: TextStyle(color: Colors.amberAccent)),
                 )
               ]
             )
           );
         }
       });
    }
    
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
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Çıkış', style: TextStyle(color: Colors.white)),
            content: const Text('Oyundan çıkmak istediğinize emin misiniz? Maçı kaybetmiş sayılırsınız.', style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hayır', style: TextStyle(color: Colors.grey))),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Evet', style: TextStyle(color: Colors.red))),
            ],
          ),
        );
        if (confirm == true) {
          await mpProvider.leaveRoom();
          if (context.mounted) Navigator.pop(context);
        }
      },
      child: Scaffold(
        bottomNavigationBar: !kIsWeb ? const CustomBannerAd() : const SizedBox.shrink(),
        floatingActionButton: FloatingActionButton(
          onPressed: _showEmoteMenu,
        backgroundColor: const Color(0xFF0C1E4A),
        child: const Text('💬', style: TextStyle(fontSize: 24)),
      ),
      body: Stack(
        children: [
          // ── BACKGROUND ──
          AnimatedBuilder(
            animation: _bgController,
            builder: (_, __) => Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(sin(_bgController.value * 2 * pi) * 0.2, cos(_bgController.value * 2 * pi) * 0.2),
                  radius: 1.4,
                  colors: const [
                    Color(0xFF1A1060),
                    Color(0xFF0C1E4A),
                    Color(0xFF06101E),
                  ],
                ),
              ),
            ),
          ),

          // ── SPARKLE PARTICLES ──
          AnimatedBuilder(
            animation: _particleController,
            builder: (_, __) => CustomPaint(
              painter: _SparklesPainter(_particleController.value),
              child: const SizedBox.expand(),
            ),
          ),

          // ── BLUE GLOW ORBS ──
          Positioned(
            top: -60, left: -60,
            child: Container(
              width: 220, height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [const Color(0xFF1E90FF).withValues(alpha: 0.15), Colors.transparent]),
              ),
            ),
          ),
          Positioned(
            bottom: -80, right: -80,
            child: Container(
              width: 260, height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [const Color(0xFF7B2FFF).withValues(alpha: 0.12), Colors.transparent]),
              ),
            ),
          ),

          // ── MAIN CONTENT ──
          SafeArea(
            child: Column(
              children: [
                // TOP BAR
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildScoreCard('Sen', myScore, Colors.greenAccent),
                      _buildTimer(),
                      _buildScoreCard(opponentName, _displayedOpponentScore, Colors.redAccent),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // PRIZE PILL
                _buildPrizePill(),

                const SizedBox(height: 16),

                // QUESTION BOX
                Expanded(
                  flex: 3,
                  child: _buildQuestionBox(currentQ),
                ),

                const SizedBox(height: 16),
                
                if (_isAnswered && !_isRevealing)
                   Padding(
                     padding: const EdgeInsets.only(bottom: 20),
                     child: Text(' bekleniyor...', style: const TextStyle(color: Colors.amberAccent, fontSize: 16, fontStyle: FontStyle.italic)),
                   ),

                // ANSWER BUTTONS
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          _buildAnswer(0, 'A', currentQ, myChoice, oppChoice, myAvatar, oppAvatar),
                          const SizedBox(height: 8),
                          _buildAnswer(1, 'B', currentQ, myChoice, oppChoice, myAvatar, oppAvatar),
                          const SizedBox(height: 8),
                          _buildAnswer(2, 'C', currentQ, myChoice, oppChoice, myAvatar, oppAvatar),
                          const SizedBox(height: 8),
                          _buildAnswer(3, 'D', currentQ, myChoice, oppChoice, myAvatar, oppAvatar),
                        ],
                      ),
                    ),
                  ),
                ),
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
    ));
  }

  Widget _buildScoreCard(String name, int score, Color color) {
    return Column(
      children: [
        Text(name, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
        Text('$score', style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildTimer() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, __) {
        final isUrgent = _timeLeft <= 5;
        final scale = isUrgent ? (1.0 + _pulseController.value * 0.08) : 1.0;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isUrgent
                    ? [const Color(0xFFFF3D00), const Color(0xFF8B0000)]
                    : [const Color(0xFF6B4A00), const Color(0xFF3A2600)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: isUrgent ? const Color(0xFFFF6D00) : const Color(0xFFFFB629),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isUrgent ? const Color(0xFFFF3D00) : const Color(0xFFFFB629)).withValues(alpha: 0.5),
                  blurRadius: 14, spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$_timeLeft',
                style: TextStyle(
                  color: isUrgent ? Colors.white : const Color(0xFFFFD54F),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrizePill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD84A), Color(0xFFFF9800), Color(0xFFE65100)],
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: const Color(0xFFFFEE58), width: 2),
        boxShadow: [
          const BoxShadow(color: Color(0xFFBF6000), offset: Offset(0, 5), blurRadius: 0),
          BoxShadow(color: const Color(0xFFFFB300).withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 2),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'ONLİNE DUELLO',
            style: TextStyle(
              color: Color(0xFF1A0A00),
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF7F3000).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_currentIndex + 1} / ${_questions.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionBox(dynamic currentQ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A1D45), Color(0xFF061128)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF1E90FF), width: 2),
        boxShadow: [
          BoxShadow(color: const Color(0xFF1E90FF).withValues(alpha: 0.35), blurRadius: 20, spreadRadius: 2),
        ],
      ),
      child: Stack(
        children: [
          Positioned(top: 0, left: 0,
            child: Icon(Icons.auto_awesome, color: const Color(0xFF1E90FF).withValues(alpha: 0.3), size: 18)),
          Positioned(top: 0, right: 0,
            child: Icon(Icons.auto_awesome, color: const Color(0xFF1E90FF).withValues(alpha: 0.3), size: 18)),
          Center(
            child: SingleChildScrollView(
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
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      height: 1.45,
                      shadows: [Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 3)],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswer(int index, String letter, dynamic currentQ, int myChoice, int oppChoice, String myAvatar, String oppAvatar) {
    if (currentQ['options'].length <= index) return const SizedBox();

    final option = currentQ['options'][index];
    bool isCorrect = index == int.tryParse(currentQ['correctOptionIndex']?.toString() ?? '-1');
    bool isMyChoice = index == myChoice;
    bool isOppChoice = index == oppChoice;
    
    // State colors
    Color borderColor;
    List<Color> gradientColors;
    Color letterColor;
    Color? glowColor;

    if (_isRevealing) {
      if (isCorrect) {
        gradientColors = [const Color(0xFF2E7D32), const Color(0xFF1B5E20)];
        borderColor = const Color(0xFF69F0AE);
        letterColor = const Color(0xFF69F0AE);
        glowColor = const Color(0xFF00E676);
      } else if (isMyChoice || isOppChoice) {
        gradientColors = [const Color(0xFFC62828), const Color(0xFF7F0000)];
        borderColor = const Color(0xFFFF5252);
        letterColor = const Color(0xFFFF8A80);
        glowColor = const Color(0xFFFF1744);
      } else {
        gradientColors = [const Color(0xFF0D2157), const Color(0xFF060E2A)];
        borderColor = const Color(0xFF1A3A7A);
        letterColor = const Color(0xFF5C7EC7);
        glowColor = null;
      }
    } else if (_isAnswered && index == _selectedIndex) {
      gradientColors = [const Color(0xFFFF8F00), const Color(0xFFE65100)];
      borderColor = const Color(0xFFFFCC02);
      letterColor = const Color(0xFFFFE082);
      glowColor = const Color(0xFFFF8F00);
    } else {
      gradientColors = [const Color(0xFF0E2766), const Color(0xFF061438)];
      borderColor = const Color(0xFF2979FF);
      letterColor = const Color(0xFFFFB300);
      glowColor = null;
    }

    return GestureDetector(
      onTap: () => _submitAnswer(index, int.tryParse(currentQ['correctOptionIndex']?.toString() ?? '-1') ?? -1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            if (glowColor != null)
              BoxShadow(color: glowColor.withValues(alpha: 0.5), blurRadius: 14, spreadRadius: 1),
            BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 4, offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            if (_isRevealing && isMyChoice)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CircleAvatar(radius: 16, backgroundColor: Colors.white, child: CircleAvatar(radius: 14, backgroundImage: AssetImage(myAvatar))),
              )
            else
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: letterColor.withValues(alpha: 0.15),
                  border: Border.all(color: letterColor, width: 1.5),
                ),
                child: Center(
                  child: Text(letter,
                    style: TextStyle(color: letterColor, fontSize: 18, fontWeight: FontWeight.w900,
                      shadows: const [Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 2)])),
                ),
              ),
            
            const SizedBox(width: 14),
            
            Expanded(
              child: Text(option,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700,
                  shadows: [Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 3)])),
            ),
            
            if (_isRevealing && isOppChoice)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: CircleAvatar(radius: 16, backgroundColor: Colors.white, child: CircleAvatar(radius: 14, backgroundImage: AssetImage(oppAvatar))),
              )
          ],
        ),
      ),
    );
  }
}

class _SparklesPainter extends CustomPainter {
  final double progress;
  static final List<_Sparkle> _sparkles = List.generate(
    30,
    (i) => _Sparkle(
      x: Random(i * 7).nextDouble(),
      y: Random(i * 13).nextDouble(),
      radius: Random(i * 3).nextDouble() * 2 + 0.5,
      speed: Random(i * 11).nextDouble() * 0.5 + 0.2,
      offset: Random(i * 5).nextDouble(),
    ),
  );

  _SparklesPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final s in _sparkles) {
      final t = (progress * s.speed + s.offset) % 1.0;
      final opacity = (sin(t * 2 * pi) * 0.5 + 0.5);
      paint.color = Colors.white.withValues(alpha: opacity * 0.55);
      canvas.drawCircle(Offset(s.x * size.width, s.y * size.height), s.radius, paint);
    }
  }

  @override
  bool shouldRepaint(_SparklesPainter old) => old.progress != progress;
}

class _Sparkle {
  final double x, y, radius, speed, offset;
  _Sparkle({required this.x, required this.y, required this.radius, required this.speed, required this.offset});
}
