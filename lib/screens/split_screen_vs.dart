import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/question.dart';
import '../providers/quiz_provider.dart';
import '../providers/audio_provider.dart';
import 'dart:math' as math;

enum ArenaTheme { magma, ice, cyberpunk, classic }

class ArenaColors {
  final Color background1;
  final Color background2;
  final String name;
  ArenaColors(this.background1, this.background2, this.name);
}

class SplitScreenVS extends StatefulWidget {
  final String p1Name;
  final String p2Name;
  final int p1SeriesWins;
  final int p2SeriesWins;

  const SplitScreenVS({
    super.key,
    this.p1Name = 'KULLANICI 1',
    this.p2Name = 'KULLANICI 2',
    this.p1SeriesWins = 0,
    this.p2SeriesWins = 0,
  });

  @override
  State<SplitScreenVS> createState() => _SplitScreenVSState();
}

class _SplitScreenVSState extends State<SplitScreenVS> {
  int player1Score = 0; // Top
  int player2Score = 0; // Bottom
  final int totalQuestions = 15;

  List<Question> questions = [];
  int currentQuestionIndex = 0;

  int? p1SelectedOption;
  int? p2SelectedOption;
  bool p1IsStunned = false; 
  bool p2IsStunned = false; 
  bool roundEnded = false;

  final math.Random random = math.Random();

  // Arena System
  late ArenaTheme currentTheme;
  late ArenaColors arenaColors;
  late Color p1ThemeColor;
  late Color p2ThemeColor;

  // Sabotage System (4 Abilities)
  int p1IceUses = 0;
  int p1BlindUses = 0;
  int p1TurtleUses = 0;
  int p1RerollUses = 0;
  
  int p2IceUses = 0;
  int p2BlindUses = 0;
  int p2TurtleUses = 0;
  int p2RerollUses = 0;

  bool p1IsFrozen = false;
  bool p1IsBlind = false;
  bool p1IsTurtle = false;
  
  bool p2IsFrozen = false;
  bool p2IsBlind = false;
  bool p2IsTurtle = false;

  Timer? p1FreezeTimer;
  Timer? p1BlindTimer;
  Timer? p1TurtleTimer;
  
  Timer? p2FreezeTimer;
  Timer? p2BlindTimer;
  Timer? p2TurtleTimer;

  int p1TurtleVisibleChars = 0;
  int p2TurtleVisibleChars = 0;

  Question? p1OverrideQuestion;
  Question? p2OverrideQuestion;

  int timeLeft = 20;
  Timer? roundTimer;

  String? p1Warning;
  String? p2Warning;
  Timer? p1WarningTimer;
  Timer? p2WarningTimer;

  void _showPlayerWarning(int playerIndex, String message) {
    if (!mounted) return;
    setState(() {
      if (playerIndex == 1) {
        p1Warning = message;
        p1WarningTimer?.cancel();
        p1WarningTimer = Timer(const Duration(seconds: 2), () {
          if (mounted) setState(() => p1Warning = null);
        });
      } else {
        p2Warning = message;
        p2WarningTimer?.cancel();
        p2WarningTimer = Timer(const Duration(seconds: 2), () {
          if (mounted) setState(() => p2Warning = null);
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _pickArena();
    _loadQuestions();
    _startRoundTimer();
  }

  void _pickArena() {
    final themes = ArenaTheme.values;
    currentTheme = themes[random.nextInt(themes.length)];
    
    switch (currentTheme) {
      case ArenaTheme.magma:
        arenaColors = ArenaColors(Colors.black87, Colors.red.shade900, "🔥 MAGMA ARENASI");
        p1ThemeColor = Colors.redAccent;
        p2ThemeColor = Colors.amberAccent;
        break;
      case ArenaTheme.ice:
        arenaColors = ArenaColors(Colors.black87, Colors.blue.shade900, "❄️ BUZUL ARENASI");
        p1ThemeColor = Colors.blueAccent;
        p2ThemeColor = Colors.cyanAccent;
        break;
      case ArenaTheme.cyberpunk:
        arenaColors = ArenaColors(Colors.black87, Colors.purple.shade900, "👾 CYBERPUNK");
        p1ThemeColor = Colors.pinkAccent;
        p2ThemeColor = Colors.greenAccent;
        break;
      case ArenaTheme.classic:
        arenaColors = ArenaColors(Colors.black87, Colors.black87, "⚔️ KLASİK");
        p1ThemeColor = Colors.redAccent;
        p2ThemeColor = Colors.blueAccent;
        break;
    }
  }

  void _loadQuestions() {
    final provider = context.read<QuizProvider>();
    questions = provider.getRandomQuestionsForDuel(totalQuestions);
  }

  void _startRoundTimer() {
    roundTimer?.cancel();
    
    int baseTime = 20;
    var q = questions[currentQuestionIndex];
    int charCount = q.text.length;
    for (var option in q.options) {
      charCount += option.length;
    }
    int extraTime = (charCount / 15).floor();
    timeLeft = baseTime + extraTime;
    if (timeLeft > 90) timeLeft = 90;

    roundTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || roundEnded) {
        timer.cancel();
        return;
      }
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
          if (timeLeft <= 5 && timeLeft > 0) {
             context.read<AudioProvider>().playSfx('tick.wav');
          }
        } else {
          timer.cancel();
          _handleTimeOut();
        }
      });
    });
  }

  void _handleTimeOut() {
    setState(() {
      roundEnded = true;
      p1IsStunned = true; // Both frozen/stunned because time is up
      p2IsStunned = true;
    });
    
    p1TurtleTimer?.cancel();
    p2TurtleTimer?.cancel();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (currentQuestionIndex + 1 >= totalQuestions) {
        _showWinner();
      } else {
        setState(() {
          currentQuestionIndex++;
          p1SelectedOption = null;
          p2SelectedOption = null;
          p1IsStunned = false;
          p2IsStunned = false;
          roundEnded = false;
          p1OverrideQuestion = null;
          p2OverrideQuestion = null;
          p1IsTurtle = false;
          p2IsTurtle = false;
          p1TurtleVisibleChars = 0;
          p2TurtleVisibleChars = 0;
          _startRoundTimer();
        });
      }
    });
  }

  // --- Sabotage Logic ---
  void _castIce(int casterIndex) {
    if (roundEnded) return;
    if (casterIndex == 1) {
      if (p1IceUses >= 2 || p2IsFrozen) return;
      if (p1IceUses == 1) {
        final p = context.read<QuizProvider>();
        if (p.totalCoins >= 20) { p.deductCoins(20); }
        else { _showPlayerWarning(casterIndex, 'Yeterli paranız yok! (20 Para)'); return; }
      }
      context.read<AudioProvider>().playSfx('click.wav');
      setState(() { p1IceUses++; p2IsFrozen = true; });
      p2FreezeTimer?.cancel();
      p2FreezeTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => p2IsFrozen = false);
      });
    } else {
      if (p2IceUses >= 2 || p1IsFrozen) return;
      if (p2IceUses == 1) {
        final p = context.read<QuizProvider>();
        if (p.totalCoins >= 20) { p.deductCoins(20); }
        else { _showPlayerWarning(casterIndex, 'Yeterli paranız yok! (20 Para)'); return; }
      }
      context.read<AudioProvider>().playSfx('click.wav');
      setState(() { p2IceUses++; p1IsFrozen = true; });
      p1FreezeTimer?.cancel();
      p1FreezeTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => p1IsFrozen = false);
      });
    }
  }

  void _castBlind(int casterIndex) {
    if (roundEnded) return;
    if (casterIndex == 1) {
      if (p1BlindUses >= 2 || p2IsBlind) return;
      if (p1BlindUses == 1) {
        final p = context.read<QuizProvider>();
        if (p.totalCoins >= 20) { p.deductCoins(20); }
        else { _showPlayerWarning(casterIndex, 'Yeterli paranız yok! (20 Para)'); return; }
      }
      context.read<AudioProvider>().playSfx('click.wav');
      setState(() { p1BlindUses++; p2IsBlind = true; });
      p2BlindTimer?.cancel();
      p2BlindTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => p2IsBlind = false);
      });
    } else {
      if (p2BlindUses >= 2 || p1IsBlind) return;
      if (p2BlindUses == 1) {
        final p = context.read<QuizProvider>();
        if (p.totalCoins >= 20) { p.deductCoins(20); }
        else { _showPlayerWarning(casterIndex, 'Yeterli paranız yok! (20 Para)'); return; }
      }
      context.read<AudioProvider>().playSfx('click.wav');
      setState(() { p2BlindUses++; p1IsBlind = true; });
      p1BlindTimer?.cancel();
      p1BlindTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => p1IsBlind = false);
      });
    }
  }

  void _castTurtle(int casterIndex) {
    if (roundEnded) return;
    if (casterIndex == 1) {
      if (p1TurtleUses >= 2 || p2IsTurtle) return;
      if (p1TurtleUses == 1) {
        final p = context.read<QuizProvider>();
        if (p.totalCoins >= 20) { p.deductCoins(20); }
        else { _showPlayerWarning(casterIndex, 'Yeterli paranız yok! (20 Para)'); return; }
      }
      context.read<AudioProvider>().playSfx('click.wav');
      setState(() {
        p1TurtleUses++;
        p2IsTurtle = true;
        p2TurtleVisibleChars = 0;
      });
      p2TurtleTimer?.cancel();
      p2TurtleTimer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
        if (!mounted || roundEnded) { timer.cancel(); return; }
        Question q = p2OverrideQuestion ?? questions[currentQuestionIndex];
        setState(() {
          if (p2TurtleVisibleChars < q.text.length) { p2TurtleVisibleChars++; }
          else { timer.cancel(); }
        });
      });
    } else {
      if (p2TurtleUses >= 2 || p1IsTurtle) return;
      if (p2TurtleUses == 1) {
        final p = context.read<QuizProvider>();
        if (p.totalCoins >= 20) { p.deductCoins(20); }
        else { _showPlayerWarning(casterIndex, 'Yeterli paranız yok! (20 Para)'); return; }
      }
      context.read<AudioProvider>().playSfx('click.wav');
      setState(() {
        p2TurtleUses++;
        p1IsTurtle = true;
        p1TurtleVisibleChars = 0;
      });
      p1TurtleTimer?.cancel();
      p1TurtleTimer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
        if (!mounted || roundEnded) { timer.cancel(); return; }
        Question q = p1OverrideQuestion ?? questions[currentQuestionIndex];
        setState(() {
          if (p1TurtleVisibleChars < q.text.length) { p1TurtleVisibleChars++; }
          else { timer.cancel(); }
        });
      });
    }
  }

  void _castReroll(int casterIndex) {
    if (roundEnded) return;
    if (casterIndex == 1) {
      if (p1RerollUses >= 2) return;
      if (p1RerollUses == 1) {
        final p = context.read<QuizProvider>();
        if (p.totalCoins >= 20) { p.deductCoins(20); }
        else { _showPlayerWarning(casterIndex, 'Yeterli paranız yok! (20 Para)'); return; }
      }
      context.read<AudioProvider>().playSfx('click.wav');
      setState(() {
        p1RerollUses++;
        final provider = context.read<QuizProvider>();
        p1OverrideQuestion = provider.getRandomQuestionsForDuel(1).first;
        if (p1IsTurtle) p1TurtleVisibleChars = 0;
      });
    } else {
      if (p2RerollUses >= 2) return;
      if (p2RerollUses == 1) {
        final p = context.read<QuizProvider>();
        if (p.totalCoins >= 20) { p.deductCoins(20); }
        else { _showPlayerWarning(casterIndex, 'Yeterli paranız yok! (20 Para)'); return; }
      }
      context.read<AudioProvider>().playSfx('click.wav');
      setState(() {
        p2RerollUses++;
        final provider = context.read<QuizProvider>();
        p2OverrideQuestion = provider.getRandomQuestionsForDuel(1).first;
        if (p2IsTurtle) p2TurtleVisibleChars = 0;
      });
    }
  }
  // ----------------------

  void _handleAnswer(int playerIndex, int optionIndex) {
    if (roundEnded) return;
    if (playerIndex == 1 && (p1IsStunned || p1IsFrozen)) return;
    if (playerIndex == 2 && (p2IsStunned || p2IsFrozen)) return;

    Question myQ = playerIndex == 1 
        ? (p1OverrideQuestion ?? questions[currentQuestionIndex]) 
        : (p2OverrideQuestion ?? questions[currentQuestionIndex]);

    // Cannot answer if turtle text isn't finished
    if (playerIndex == 1 && p1IsTurtle && p1TurtleVisibleChars < myQ.text.length) return;
    if (playerIndex == 2 && p2IsTurtle && p2TurtleVisibleChars < myQ.text.length) return;

    bool isCorrect = (optionIndex == myQ.correctOptionIndex);
    context.read<AudioProvider>().playSfx('click.wav');

    setState(() {
      if (playerIndex == 1) {
        p1SelectedOption = optionIndex;
      } else {
        p2SelectedOption = optionIndex;
      }

      if (isCorrect) {
        context.read<AudioProvider>().playSfx('correct.mp3');
        if (playerIndex == 1) {
          player1Score += 10;
        } else {
          player2Score += 10;
        }
        roundEnded = true;
      } else {
        context.read<AudioProvider>().playSfx('wrong.wav');
        if (playerIndex == 1) {
          p1IsStunned = true;
        } else {
          p2IsStunned = true;
        }
        
        if (p1IsStunned && p2IsStunned) {
          roundEnded = true;
        }
      }
    });

    if (roundEnded) {
      p1TurtleTimer?.cancel();
      p2TurtleTimer?.cancel();
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        
        if (currentQuestionIndex + 1 >= totalQuestions) {
          _showWinner();
        } else {
          setState(() {
            currentQuestionIndex++;
            p1SelectedOption = null;
            p2SelectedOption = null;
            p1IsStunned = false;
            p2IsStunned = false;
            roundEnded = false;
            p1OverrideQuestion = null;
            p2OverrideQuestion = null;
            p1IsTurtle = false;
            p2IsTurtle = false;
            p1TurtleVisibleChars = 0;
            p2TurtleVisibleChars = 0;
            _startRoundTimer();
          });
        }
      });
    }
  }

  void _showWinner() {
    bool p1Wins = player1Score > player2Score;
    bool isTie = player1Score == player2Score;
    
    // Updated Series Wins
    int nextP1Wins = widget.p1SeriesWins + (p1Wins ? 1 : 0);
    int nextP2Wins = widget.p2SeriesWins + (!isTie && !p1Wins ? 1 : 0);
    String seriesScore = "SERİ: ${widget.p1Name} $nextP1Wins - $nextP2Wins ${widget.p2Name}";
    
    // Arkadaş modunda kazanılan puanları ve seri durumunu kaydet
    final provider = context.read<QuizProvider>();
    provider.addLocalDuelScore(widget.p1Name, player1Score);
    provider.addLocalDuelScore(widget.p2Name, player2Score);
    provider.saveLastDuelState(widget.p1Name, widget.p2Name, nextP1Wins, nextP2Wins);

    Color titleColor = isTie ? Colors.orangeAccent : (p1Wins ? p1ThemeColor : p2ThemeColor);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {

        // Yardımcı fonksiyon: Her oyuncu için kendi yönüne bakan sonuç kartı oluşturur
        Widget buildResultCard(bool isUpsideDown, String playerTitle, String scoreText, bool thisPlayerWon, bool isTieCard) {
          String cardTitle = isTieCard ? "BERABERE!" : (thisPlayerWon ? "🏆 KAZANDIN!" : "💥 KAYBETTİN!");
          Color cardColor = isTieCard ? Colors.orangeAccent : (thisPlayerWon ? Colors.greenAccent : Colors.redAccent);
          IconData cardIcon = isTieCard ? Icons.handshake : (thisPlayerWon ? Icons.emoji_events : Icons.sentiment_dissatisfied);

          return RotatedBox(
            quarterTurns: isUpsideDown ? 2 : 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [arenaColors.background1, arenaColors.background2],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cardColor.withValues(alpha: 0.5), width: 2),
                boxShadow: [
                  BoxShadow(color: cardColor.withValues(alpha: 0.2), blurRadius: 15, spreadRadius: 3),
                ]
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: cardColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: Icon(cardIcon, color: cardColor, size: 48),
                  ),
                  const SizedBox(height: 10),
                  Text(cardTitle, style: TextStyle(color: cardColor, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.2), textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text(seriesScore.toUpperCase(), style: const TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Container(height: 1, color: Colors.white24),
                  const SizedBox(height: 8),
                  Text(playerTitle, style: const TextStyle(color: Colors.white54, fontSize: 13, letterSpacing: 2)),
                  const SizedBox(height: 4),
                  Text(scoreText, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.grey.shade700, Colors.grey.shade900],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white54, width: 1.5),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 6, offset: const Offset(0, 3)),
                              ],
                            ),
                            child: const Text('MENÜ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1, shadows: [Shadow(color: Colors.black, blurRadius: 2, offset: Offset(1, 1))])),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SplitScreenVS(
                              p1Name: widget.p1Name,
                              p2Name: widget.p2Name,
                              p1SeriesWins: nextP1Wins,
                              p2SeriesWins: nextP2Wins,
                            )));
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [titleColor.withValues(alpha: 0.8), titleColor.withValues(alpha: 0.4)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: titleColor, width: 1.5),
                              boxShadow: [
                                BoxShadow(color: titleColor.withValues(alpha: 0.5), blurRadius: 8, offset: const Offset(0, 2)),
                              ],
                            ),
                            child: const Text('RÖVANŞ!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1, shadows: [Shadow(color: Colors.black, blurRadius: 2, offset: Offset(1, 1))])),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        }

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Player 2 Side (Upside Down)
                buildResultCard(true, widget.p2Name.toUpperCase(), '$player2Score - $player1Score', !p1Wins && !isTie, isTie),
                const SizedBox(height: 16),
                // Player 1 Side (Normal)
                buildResultCard(false, widget.p1Name.toUpperCase(), '$player1Score - $player2Score', p1Wins && !isTie, isTie),
              ],
            ),
          ),
        );
      }
    );
  }

  @override
  void dispose() {
    roundTimer?.cancel();
    p1FreezeTimer?.cancel();
    p1BlindTimer?.cancel();
    p1TurtleTimer?.cancel();
    p2FreezeTimer?.cancel();
    p2BlindTimer?.cancel();
    p2TurtleTimer?.cancel();
    p1WarningTimer?.cancel();
    p2WarningTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget buildTimerWidget() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer, color: timeLeft <= 5 ? Colors.redAccent : Colors.amber, size: 12),
            const SizedBox(width: 4),
            Text('$timeLeft', style: TextStyle(color: timeLeft <= 5 ? Colors.redAccent : Colors.amber, fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    if (questions.isEmpty) return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Premium background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  Color(0xFF1A1060),
                  Color(0xFF0C1E4A),
                  Color(0xFF06101E),
                ],
              ),
            ),
          ),
          // Glow orbs
          Positioned(
            top: -80, left: -80,
            child: Container(
              width: 260, height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [p1ThemeColor.withValues(alpha: 0.15), Colors.transparent]),
              ),
            ),
          ),
          Positioned(
            bottom: -80, right: -80,
            child: Container(
              width: 260, height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [p2ThemeColor.withValues(alpha: 0.15), Colors.transparent]),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Player 1 Area (Rotated 180 degrees)
                Expanded(
                  child: Transform.rotate(
                    angle: math.pi,
                    child: _buildPlayerArea(1),
                  ),
                ),
                
                // Divider (Scoreboard, Timer & Arena Name)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF05122B), // Koyu mavi zemin
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF1E88E5), width: 2),
                    boxShadow: [
                      BoxShadow(color: Colors.blueAccent.withValues(alpha: 0.3), offset: const Offset(0, 0), blurRadius: 20, spreadRadius: 2),
                      BoxShadow(color: Colors.black.withValues(alpha: 0.8), offset: const Offset(0, 6), blurRadius: 10),
                    ]
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Player 1 (Upside down)
                      Expanded(
                        child: Transform.rotate(
                          angle: math.pi,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FittedBox(fit: BoxFit.scaleDown, child: Text('${widget.p1Name.toUpperCase()} 🏆 ${widget.p1SeriesWins}', style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1))),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FittedBox(fit: BoxFit.scaleDown, child: Text('$player1Score', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, shadows: [Shadow(color: Colors.blue, blurRadius: 10)]))),
                                  const SizedBox(width: 8),
                                  buildTimerWidget(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Center (Timer & Arena)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E88E5).withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.lightBlueAccent, width: 1),
                              ),
                              child: Text(arenaColors.name, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            ),
                            const SizedBox(height: 6),
                            Text('${currentQuestionIndex + 1}/$totalQuestions', style: const TextStyle(color: Colors.amberAccent, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1)),
                          ],
                        ),
                      ),
                      
                      // Player 2
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FittedBox(fit: BoxFit.scaleDown, child: Text('${widget.p2Name.toUpperCase()} 🏆 ${widget.p2SeriesWins}', style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1))),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                buildTimerWidget(),
                                const SizedBox(width: 8),
                                FittedBox(fit: BoxFit.scaleDown, child: Text('$player2Score', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, shadows: [Shadow(color: Colors.blue, blurRadius: 10)]))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Player 2 Area (Normal)
                Expanded(
                  child: _buildPlayerArea(2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerArea(int playerIndex) {
    String? warningMsg = playerIndex == 1 ? p1Warning : p2Warning;
    Color themeColor = playerIndex == 1 ? p1ThemeColor : p2ThemeColor;
    bool isStunned = playerIndex == 1 ? p1IsStunned : p2IsStunned;
    bool isFrozen = playerIndex == 1 ? p1IsFrozen : p2IsFrozen;
    bool isBlind = playerIndex == 1 ? p1IsBlind : p2IsBlind;
    bool isTurtle = playerIndex == 1 ? p1IsTurtle : p2IsTurtle;

    int iceUses = playerIndex == 1 ? p1IceUses : p2IceUses;
    int blindUses = playerIndex == 1 ? p1BlindUses : p2BlindUses;
    int turtleUses = playerIndex == 1 ? p1TurtleUses : p2TurtleUses;
    int rerollUses = playerIndex == 1 ? p1RerollUses : p2RerollUses;

    Question myQ = playerIndex == 1 
        ? (p1OverrideQuestion ?? questions[currentQuestionIndex]) 
        : (p2OverrideQuestion ?? questions[currentQuestionIndex]);

    int turtleVisibleChars = playerIndex == 1 ? p1TurtleVisibleChars : p2TurtleVisibleChars;

    String questionTextDisplay = myQ.text;
    if (isTurtle) {
      questionTextDisplay = questionTextDisplay.substring(0, math.min(turtleVisibleChars, questionTextDisplay.length));
    }

    bool opponentWonRound = false;
    if (roundEnded) {
      Question opponentQ = playerIndex == 1 
          ? (p2OverrideQuestion ?? questions[currentQuestionIndex]) 
          : (p1OverrideQuestion ?? questions[currentQuestionIndex]);
      
      if (playerIndex == 1 && p2SelectedOption == opponentQ.correctOptionIndex) opponentWonRound = true;
      if (playerIndex == 2 && p1SelectedOption == opponentQ.correctOptionIndex) opponentWonRound = true;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Stack(
        children: [
          Column(
            children: [
              // Question Text Card & Sabotage Buttons
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    // Sabotage Buttons (Left side)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSabotageBtn('🔀', rerollUses, () => _castReroll(playerIndex)),
                        _buildSabotageBtn('🕶️', blindUses, () => _castBlind(playerIndex)),
                      ],
                    ),                     // Question
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0A1D45), Color(0xFF061128)],
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF1E90FF), width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1E90FF).withValues(alpha: 0.3),
                              blurRadius: 15, spreadRadius: 3,
                            ),
                            BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 8, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (myQ.imageUrl != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        myQ.imageUrl!,
                                        height: 70,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                Text(
                                  questionTextDisplay,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white, fontSize: 14,
                                    fontWeight: FontWeight.bold, height: 1.3,
                                    shadows: [Shadow(color: Colors.black, offset: Offset(1,1), blurRadius: 3)],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Sabotage Buttons (Right side)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSabotageBtn('🐢', turtleUses, () => _castTurtle(playerIndex)),
                        _buildSabotageBtn('❄️', iceUses, () => _castIce(playerIndex)),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Options Area
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: _buildOptionButton(playerIndex, 0, myQ.options[0], myQ.correctOptionIndex, themeColor, 'A', isBlind)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildOptionButton(playerIndex, 1, myQ.options[1], myQ.correctOptionIndex, themeColor, 'B', isBlind)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: _buildOptionButton(playerIndex, 2, myQ.options[2], myQ.correctOptionIndex, themeColor, 'C', isBlind)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildOptionButton(playerIndex, 3, myQ.options[3], myQ.correctOptionIndex, themeColor, 'D', isBlind)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Warning Overlay
          if (warningMsg != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)],
                ),
                child: Text(
                  warningMsg,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
            ),
            
          // Stun Overlay (Yanlış Cevap)
          if (isStunned)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black87, themeColor.withValues(alpha: 0.4)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: themeColor, width: 3),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.block, color: themeColor, size: 90),
                    const SizedBox(height: 16),
                    Text(
                      'YANLIŞ CEVAP!\nKİLİTLENDİN',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: themeColor, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 3),
                    ),

                  ],
                ),
              ),
            ),
          
          // Frozen Overlay (Sabotage)
          if (isFrozen)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.lightBlue.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.lightBlueAccent, width: 3),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.ac_unit, color: Colors.lightBlueAccent, size: 90),
                    SizedBox(height: 16),
                    Text(
                      'DONDURULDUN!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.lightBlueAccent, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 3),
                    ),
                  ],
                ),
              ),
            ),
            
          // Rakip Hızlı Bildi Overlay
          if (!isStunned && opponentWonRound)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.5), width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.flash_on, color: Colors.amber, size: 80),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'RAKİP DAHA HIZLIYDI!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.amberAccent, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSabotageBtn(String emoji, int uses, VoidCallback onTap) {
    bool hasUses = uses < 2;
    int remaining = 2 - uses;
    bool requiresDiamond = uses == 1;
    
    return GestureDetector(
      onTap: hasUses ? onTap : null,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: hasUses 
                ? (requiresDiamond 
                    ? [Colors.orangeAccent, Colors.deepOrange.shade800] // Elmaslıysa Turuncu Premium
                    : [const Color(0xFF29B6F6), const Color(0xFF0277BD)]) // Ücretsizse Parlak mavi
                : [Colors.grey.shade700, Colors.grey.shade900], // Bitişse gri
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: hasUses 
                ? (requiresDiamond ? Colors.orangeAccent : Colors.lightBlueAccent) 
                : Colors.grey, 
            width: 2
          ),
          boxShadow: [
            if (hasUses) BoxShadow(
              color: (requiresDiamond ? Colors.orangeAccent : Colors.lightBlueAccent).withValues(alpha: 0.5), 
              blurRadius: 10, spreadRadius: 1
            ),
            BoxShadow(color: Colors.black.withValues(alpha: 0.6), offset: const Offset(0, 4), blurRadius: 4),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Inner glow/bevel effect
            Container(
              margin: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
              ),
            ),
            Text(emoji, style: TextStyle(fontSize: 22, color: hasUses ? Colors.white : Colors.white54)),
            if (!hasUses)
              Icon(Icons.block, color: Colors.red.withValues(alpha: 0.7), size: 28),
            // Diamond Icon if it costs diamond
            if (requiresDiamond && hasUses)
              const Positioned(
                bottom: 4,
                child: Icon(Icons.diamond, color: Colors.white, size: 12),
              ),
            // Uses counter
            if (hasUses)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.black87, 
                    shape: BoxShape.circle,
                    border: Border.all(color: requiresDiamond ? Colors.orange : Colors.lightBlue, width: 1)
                  ),
                  child: Text('$remaining', style: TextStyle(color: requiresDiamond ? Colors.orange : Colors.lightBlue, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(int playerIndex, int optionIndex, String text, int correctIndex, Color themeColor, String prefix, bool isBlind) {
    List<Color> gradientColors;
    Color borderColor;
    Color letterColor;
    Color? glowColor;
    String displayText = isBlind ? '?????' : text;
    int? mySelection = playerIndex == 1 ? p1SelectedOption : p2SelectedOption;

    if (roundEnded) {
      if (optionIndex == correctIndex) {
        gradientColors = [const Color(0xFF2E7D32), const Color(0xFF1B5E20)];
        borderColor = const Color(0xFF69F0AE);
        letterColor = const Color(0xFF69F0AE);
        glowColor = const Color(0xFF00E676);
      } else if (mySelection == optionIndex) {
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
    } else {
      if (mySelection == optionIndex) {
        gradientColors = [const Color(0xFF1565C0), const Color(0xFF0D47A1)];
        borderColor = Colors.lightBlueAccent;
        letterColor = Colors.lightBlueAccent;
        glowColor = Colors.lightBlueAccent;
      } else {
        gradientColors = [const Color(0xFF0E2766), const Color(0xFF061438)];
        borderColor = const Color(0xFF2979FF);
        letterColor = const Color(0xFFFFB300);
        glowColor = null;
      }
    }

    return GestureDetector(
      onTap: () => _handleAnswer(playerIndex, optionIndex),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            if (glowColor != null)
              BoxShadow(color: glowColor.withValues(alpha: 0.5), blurRadius: 12, spreadRadius: 1),
            BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 4, offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            // Letter box
            Container(
              width: 40,
              decoration: BoxDecoration(
                color: letterColor.withValues(alpha: 0.15),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12), bottomLeft: Radius.circular(12),
                ),
                border: Border(right: BorderSide(color: borderColor.withValues(alpha: 0.5), width: 1.5)),
              ),
              child: Center(
                child: Text(prefix,
                  style: TextStyle(color: letterColor, fontWeight: FontWeight.w900, fontSize: 18,
                    shadows: const [Shadow(color: Colors.black, offset: Offset(1,1), blurRadius: 2)])),
              ),
            ),
            // Answer text
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Text(
                      displayText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white, fontSize: 12,
                        fontWeight: FontWeight.bold, height: 1.2,
                        shadows: [Shadow(color: Colors.black, offset: Offset(1,1), blurRadius: 3)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
