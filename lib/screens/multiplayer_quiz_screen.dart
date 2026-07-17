import 'dart:async';
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
  
  late List<dynamic> _questions;
  
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
        // Hile Algılandı!
        _timer?.cancel();
        setState(() {
          _isAnswered = true;
          _timeLeft = 0;
          _selectedIndex = -1; // Yanlış
        });
        
        _handleTimeOut();

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF0F2027),
            title: const Text('HİLE TESPİT EDİLDİ!', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            content: const Text('Soruyu çözerken uygulamadan çıktığın için otomatik olarak yanlış cevap vermiş sayıldın!', style: TextStyle(color: Colors.white)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('TAMAM', style: TextStyle(color: Colors.white)),
              )
            ]
          )
        );
      }
    }
  }

  void _startTimer() {
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
    _selectedIndex = null;
    _timer?.cancel();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_timeLeft > 0) {
            _timeLeft--;
          } else {
            _timer?.cancel();
            _handleTimeOut();
          }
        });
      }
    });
  }

  void _handleTimeOut() {
    _isAnswered = true;
    _moveToNextQuestion();
  }

  void _submitAnswer(int index, int correctIndex) {
    if (_isAnswered) return;
    
    _timer?.cancel();
    setState(() {
      _isAnswered = true;
      _selectedIndex = index;
    });

    if (index == correctIndex) {
      // Puan = Kalan Saniye * 10 + 50 (Temel Puan)
      _score += (_timeLeft * 10) + 50;
      Provider.of<MultiplayerProvider>(context, listen: false).updateScore(_score);
    }
    
    _moveToNextQuestion();
  }

  void _moveToNextQuestion() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      
      if (_currentIndex < 9) {
        setState(() {
          _currentIndex++;
        });
        _startTimer();
      } else {
        // Oyun Bitti
        Provider.of<MultiplayerProvider>(context, listen: false).finishGame(_score);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MultiplayerResultScreen()));
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mpProvider = Provider.of<MultiplayerProvider>(context);
    final data = mpProvider.roomData;
    
    if (data == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    
    final currentQ = _questions[_currentIndex];
    
    int myScore = _score;
    int opponentScore = mpProvider.isHost ? (data['guestScore'] ?? 0) : (data['hostScore'] ?? 0);
    String opponentName = mpProvider.isHost ? (data['guestName'] ?? 'Rakip') : (data['hostName'] ?? 'Rakip');
    
    return Scaffold(
      backgroundColor: AppColors.appPurpleBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Üst Kısım (Puan Durumu)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildScoreCard('Sen', myScore, Colors.greenAccent),
                  Text('$_timeLeft', style: const TextStyle(color: Colors.amberAccent, fontSize: 36, fontWeight: FontWeight.bold)),
                  _buildScoreCard(opponentName, opponentScore, Colors.redAccent),
                ],
              ),
              const SizedBox(height: 20),
              
              // İlerleme
              LinearProgressIndicator(
                value: (_currentIndex + 1) / 10,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.amberAccent),
              ),
              const SizedBox(height: 10),
              Text('Soru ${_currentIndex + 1} / 10', style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
              
              const Spacer(),
              
              // Soru
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
              
              // Seçenekler
              ...List.generate(4, (index) {
                bool isCorrect = index == currentQ['correctOptionIndex'];
                bool isSelected = _selectedIndex == index;
                
                Color btnColor = AppColors.menuButtonBg;
                if (_isAnswered) {
                  if (isCorrect) {
                    btnColor = Colors.green.shade700;
                  } else if (isSelected) {
                    btnColor = Colors.red.shade700;
                  }
                }
                
                return GestureDetector(
                  onTap: () => _submitAnswer(index, currentQ['correctOptionIndex']),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: btnColor,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: isSelected ? Colors.white : AppColors.menuButtonBorder, width: 2),
                    ),
                    child: Text(
                      currentQ['options'][index],
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }),
              const Spacer(),
            ],
          ),
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
