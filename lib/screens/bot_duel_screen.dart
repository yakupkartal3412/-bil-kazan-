import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/question.dart';
import '../providers/quiz_provider.dart';
import '../providers/audio_provider.dart';
import '../widgets/joker_dialogs.dart';
import 'dart:math' as math;

enum ArenaTheme { magma, ice, cyberpunk, classic }

class ArenaColors {
  final Color background1;
  final Color background2;
  final Color primary;
  final Color secondary;
  final String name;
  ArenaColors(this.background1, this.background2, this.primary, this.secondary, this.name);
}

class BotDuelScreen extends StatefulWidget {
  final int entryFee;
  
  const BotDuelScreen({super.key, this.entryFee = 0});

  @override
  State<BotDuelScreen> createState() => _BotDuelScreenState();
}

class _BotDuelScreenState extends State<BotDuelScreen> {
  int playerScore = 0;
  int botScore = 0;
  int currentQuestionIndex = 0;
  
  List<Question> questions = [];
  
  bool playerAnswered = false;
  int? playerSelectedOption;
  
  bool botAnswered = false;
  int? botSelectedOption;
  
  bool showResult = false;
  
  Timer? botTimer;
  Timer? roundTimer;
  Timer? botSabotageTimer;
  int timeLeft = 15;
  
  final math.Random random = math.Random();

  late String botName;
  late String botAvatar;

  // Arena System
  late ArenaTheme currentTheme;
  late ArenaColors arenaColors;

  // Joker System (Classic 4 Jokers)
  int fiftyFiftyUses = 0;
  int phoneUses = 0;
  int audienceUses = 0;
  int skipUses = 0;
  
  List<int> hiddenOptions = [];
  Question? playerOverrideQuestion;
  Question? botOverrideQuestion; // For bot's own variations if needed

  @override
  void initState() {
    super.initState();
    _generateBotIdentity();
    _pickArena();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.entryFee > 0) {
        final provider = context.read<QuizProvider>();
        provider.deductCoins(widget.entryFee);
      }
      _loadQuestions();
    });
  }

  void _pickArena() {
    final themes = ArenaTheme.values;
    currentTheme = themes[random.nextInt(themes.length)];
    
    switch (currentTheme) {
      case ArenaTheme.magma:
        arenaColors = ArenaColors(Colors.black87, Colors.red.shade900, Colors.deepOrangeAccent, Colors.orangeAccent, "🔥 Magma Arenası");
        break;
      case ArenaTheme.ice:
        arenaColors = ArenaColors(Colors.black87, Colors.blue.shade900, Colors.cyanAccent, Colors.lightBlueAccent, "❄️ Buzul Arenası");
        break;
      case ArenaTheme.cyberpunk:
        arenaColors = ArenaColors(Colors.black87, Colors.purple.shade900, Colors.purpleAccent, Colors.pinkAccent, "👾 Cyberpunk Arenası");
        break;
      case ArenaTheme.classic:
        arenaColors = ArenaColors(Colors.black87, Colors.black87, Colors.amberAccent, Colors.orangeAccent, "⚔️ Klasik Arena");
        break;
    }
  }

  void _generateBotIdentity() {
    final List<String> adjectives = ["Zeki", "Çılgın", "Hızlı", "Sinsi", "Pro", "Efsane", "Gölge", "Usta", "Gizemli", "Kurnaz", "Büyük", "Cesur", "Dahi", "Yenilmez", "Karanlık"];
    final List<String> nouns = ["Gamer", "Ninja", "Kral", "Şövalye", "Beyin", "Avcı", "Oyuncu", "Efsane", "Titan", "Şampiyon", "Patron", "Üstat", "Bilge"];
    final String adj = adjectives[random.nextInt(adjectives.length)];
    final String noun = nouns[random.nextInt(nouns.length)];
    final int number = random.nextInt(999) + 1;
    botName = "$adj $noun $number";

    final List<String> botAvatars = [
      'assets/images/einstein_avatar.png',
      'assets/images/tesla_avatar.png',
      'assets/images/curie_avatar.png',
      'assets/images/davinci_avatar.png',
      'assets/images/newton_avatar.png',
      'assets/images/galileo_avatar.png',
      'assets/images/darwin_avatar.png',
      'assets/images/hawking_avatar.png',
      'assets/images/turing_avatar.png',
      'assets/images/pythagoras_avatar.png',
      'assets/images/edison_avatar.png',
      'assets/images/bell_avatar.png',
    ];
    botAvatar = botAvatars[random.nextInt(botAvatars.length)];
  }

  void _loadQuestions() {
    final provider = context.read<QuizProvider>();
    questions = provider.get15MixedQuestions();
    _startRound();
  }

  void _startRound() {
    botTimer?.cancel();
    roundTimer?.cancel();
    
    timeLeft = 15;
    playerAnswered = false;
    playerSelectedOption = null;
    botAnswered = false;
    botSelectedOption = null;
    showResult = false;
    
    playerOverrideQuestion = null;
    botOverrideQuestion = null;
    
    hiddenOptions.clear();

    // Start 15s timer
    roundTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
          if (timeLeft <= 5 && timeLeft > 0) {
             context.read<AudioProvider>().playSfx('tick.wav');
          }
        } else {
          timer.cancel();
          if (!playerAnswered) {
            playerSelectedOption = -1;
            playerAnswered = true;
          }
          if (!botAnswered) {
            botSelectedOption = -1;
            botAnswered = true;
          }
          _evaluateRound();
        }
      });
    });

    // Bot Answer Logic (Tick based)
    int baseBotDelay = random.nextInt(8) + 3; 
    int currentBotTick = 0;
    
    botTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || showResult || botAnswered) {
        timer.cancel();
        return;
      }
      
      currentBotTick++; 
      
      if (currentBotTick >= baseBotDelay) {
        timer.cancel();
        setState(() {
          botAnswered = true;
          _determineBotAnswer();
          if (playerAnswered) _evaluateRound();
        });
      }
    });
  }

  // --- Joker Uses ---
  void _useFiftyFifty() {
    if (fiftyFiftyUses >= 2 || showResult || playerAnswered) return;
    context.read<AudioProvider>().playSfx('click.wav');
    if (fiftyFiftyUses > 0) {
      final provider = context.read<QuizProvider>();
      if (!provider.deductCoins(25)) {
        _showNotEnoughCoins();
        return;
      }
    }
    
    setState(() {
      fiftyFiftyUses++;
      Question pQ = playerOverrideQuestion ?? questions[currentQuestionIndex];
      
      List<int> wrongOptions = [0, 1, 2, 3];
      wrongOptions.remove(pQ.correctOptionIndex);
      wrongOptions.shuffle(random);
      
      hiddenOptions = [wrongOptions[0], wrongOptions[1]];
    });
  }

  void _usePhone() {
    if (phoneUses >= 2 || showResult || playerAnswered) return;
    context.read<AudioProvider>().playSfx('click.wav');
    final provider = context.read<QuizProvider>();
    if (phoneUses > 0) {
      if (!provider.deductCoins(25)) {
        _showNotEnoughCoins();
        return;
      }
    }
    setState(() => phoneUses++);
    Question pQ = playerOverrideQuestion ?? questions[currentQuestionIndex];
    String friendAvatar = provider.activeAvatar.startsWith('assets') ? provider.activeAvatar : 'assets/images/${provider.activeAvatar}';
    
    showDialog(
      context: context,
      builder: (context) => PhoneCallDialog(
        correctOption: pQ.options[pQ.correctOptionIndex],
        avatarPath: friendAvatar,
      ),
    );
  }

  void _useAudience() {
    if (audienceUses >= 2 || showResult || playerAnswered) return;
    context.read<AudioProvider>().playSfx('click.wav');
    if (audienceUses > 0) {
      final provider = context.read<QuizProvider>();
      if (!provider.deductCoins(25)) {
        _showNotEnoughCoins();
        return;
      }
    }
    setState(() => audienceUses++);
    Question pQ = playerOverrideQuestion ?? questions[currentQuestionIndex];
    showDialog(
      context: context,
      builder: (context) => AudienceChartDialog(
        correctOptionIndex: pQ.correctOptionIndex,
        options: pQ.options,
      ),
    );
  }

  void _useSkip() {
    if (skipUses >= 2 || showResult || playerAnswered) return;
    context.read<AudioProvider>().playSfx('click.wav');
    if (skipUses > 0) {
      final provider = context.read<QuizProvider>();
      if (!provider.deductCoins(25)) {
        _showNotEnoughCoins();
        return;
      }
    }
    setState(() {
      skipUses++;
      hiddenOptions.clear(); // Reset 50:50 if used on old question
      final provider = context.read<QuizProvider>();
      playerOverrideQuestion = provider.getRandomQuestionsForDuel(1).first;
    });
  }
  
  void _showNotEnoughCoins() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Joker için yeterli elmasın yok! (25 💎)'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ------------------------

  void _determineBotAnswer() {
    Question bQ = botOverrideQuestion ?? questions[currentQuestionIndex];
    int chance = random.nextInt(100);
    
    int correctChance = 0;
    if (bQ.difficulty == 1) {
      correctChance = 98;
    } else if (bQ.difficulty == 2) {
      correctChance = 75;
    } else if (bQ.difficulty == 3) {
      correctChance = 40;
    }

    if (chance < correctChance) {
      botSelectedOption = bQ.correctOptionIndex;
    } else {
      List<int> wrongOptions = [0, 1, 2, 3];
      wrongOptions.remove(bQ.correctOptionIndex);
      botSelectedOption = wrongOptions[random.nextInt(wrongOptions.length)];
    }
  }

  void _handlePlayerAnswer(int optionIndex) {
    if (playerAnswered || showResult) return;
    context.read<AudioProvider>().playSfx('click.wav');
    setState(() {
      playerAnswered = true;
      playerSelectedOption = optionIndex;
      if (botAnswered) _evaluateRound();
    });
  }

  int _getPoints(Question q) {
    if (q.difficulty == 1) return 10;
    if (q.difficulty == 2) return 20;
    return 30;
  }

  void _evaluateRound() {
    roundTimer?.cancel();
    botTimer?.cancel();

    Question pQ = playerOverrideQuestion ?? questions[currentQuestionIndex];
    Question bQ = botOverrideQuestion ?? questions[currentQuestionIndex];
    
    if (playerSelectedOption == pQ.correctOptionIndex) {
      context.read<AudioProvider>().playSfx('correct.mp3');
    } else {
      context.read<AudioProvider>().playSfx('wrong.wav');
    }
    
    setState(() {
      showResult = true;
      if (playerSelectedOption == pQ.correctOptionIndex) playerScore += _getPoints(pQ);
      if (botSelectedOption == bQ.correctOptionIndex) botScore += _getPoints(bQ);
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (currentQuestionIndex + 1 >= 15) {
        _showWinnerDialog();
      } else {
        setState(() {
          currentQuestionIndex++;
          _startRound();
        });
      }
    });
  }

  void _showWinnerDialog() {
    bool playerWins = playerScore > botScore;
    bool isTie = playerScore == botScore;

    String title = isTie ? "BERABERE!" : (playerWins ? "KAZANDIN!" : "KAYBETTİN!");
    Color titleColor = isTie ? Colors.orangeAccent : (playerWins ? Colors.greenAccent : Colors.redAccent);
    IconData icon = isTie ? Icons.handshake : (playerWins ? Icons.emoji_events : Icons.sentiment_very_dissatisfied);

    int entryFee = widget.entryFee;
    int reward = 0;
    
    if (entryFee > 0) {
      if (playerWins) {
        reward = entryFee * 2;
        context.read<QuizProvider>().addCoins(reward);
      } else if (isTie) {
        reward = entryFee; // Return the bet
        context.read<QuizProvider>().addCoins(reward);
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [arenaColors.background1, arenaColors.background2],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: titleColor.withValues(alpha: 0.5), width: 2),
              boxShadow: [
                BoxShadow(color: titleColor.withValues(alpha: 0.2), blurRadius: 20, spreadRadius: 5),
              ]
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: titleColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: Icon(icon, color: titleColor, size: 80),
                  ),
                  const SizedBox(height: 24),
                  Text(title, style: TextStyle(color: titleColor, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: 2), textAlign: TextAlign.center),
                  
                  if (entryFee > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: titleColor.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            playerWins ? '+$reward' : (isTie ? 'İADE: $reward' : '-$entryFee'),
                            style: TextStyle(color: titleColor, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.diamond, color: Colors.cyanAccent, size: 20),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  Container(height: 1, color: Colors.white24),
                  const SizedBox(height: 16),
                  const Text('SKOR TABLOSU', style: TextStyle(color: Colors.white54, fontSize: 14, letterSpacing: 2)),
                  const SizedBox(height: 12),
                  
                  // Player Score Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: AssetImage(
                          context.read<QuizProvider>().activeAvatar.startsWith('assets') 
                              ? context.read<QuizProvider>().activeAvatar 
                              : 'assets/images/${context.read<QuizProvider>().activeAvatar}'
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text('Sen: $playerScore Puan', 
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Bot Score Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: AssetImage(botAvatar),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text('$botName: $botScore Puan', 
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: titleColor.withValues(alpha: 0.2),
                        foregroundColor: titleColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: titleColor.withValues(alpha: 0.5))),
                      ),
                      child: const Text('MENÜYE DÖN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  @override
  void dispose() {
    botTimer?.cancel();
    roundTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));
    
    Question pQ = playerOverrideQuestion ?? questions[currentQuestionIndex];
    final provider = context.watch<QuizProvider>();
    String userAvatar = provider.activeAvatar.startsWith('assets') ? provider.activeAvatar : 'assets/images/${provider.activeAvatar}';

    String questionTextDisplay = pQ.text;

    return Scaffold(
      body: Stack(
        children: [
          // Premium background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.4,
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
            top: -60, left: -60,
            child: Container(
              width: 220, height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  arenaColors.primary.withValues(alpha: 0.18),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: -80, right: -80,
            child: Container(
              width: 260, height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  arenaColors.secondary.withValues(alpha: 0.13),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          SafeArea(
          child: Column(
            children: [
              // Arena Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                color: arenaColors.primary.withValues(alpha: 0.2),
                child: Text(
                  arenaColors.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: arenaColors.secondary, fontWeight: FontWeight.bold, letterSpacing: 4),
                ),
              ),
              
              // Header: User vs Bot
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // User Profile & Sabotages
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(radius: 20, backgroundImage: AssetImage(userAvatar)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Sen', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                Text('$playerScore Puan', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 8),

                    // Bot Profile
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(botName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text('$botScore Puan', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          CircleAvatar(radius: 20, backgroundImage: AssetImage(botAvatar)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              Divider(color: arenaColors.primary.withValues(alpha: 0.4), thickness: 2),
              
              // Main content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                      // Progress and Timer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white24)),
                            child: Text('Soru: ${currentQuestionIndex + 1}/15', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          
                          // Circular Timer
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator(
                                  value: timeLeft / 15,
                                  backgroundColor: Colors.white12,
                                  color: timeLeft <= 5 ? Colors.redAccent : arenaColors.secondary,
                                  strokeWidth: 4,
                                ),
                              ),
                              Text('$timeLeft', style: TextStyle(color: timeLeft <= 5 ? Colors.redAccent : Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                            ],
                          ),
                          
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20), border: Border.all(color: arenaColors.secondary)),
                            child: Text(
                              pQ.difficulty == 1 ? 'Kolay' : (pQ.difficulty == 2 ? 'Orta' : 'Zor'), 
                              style: TextStyle(color: arenaColors.secondary, fontWeight: FontWeight.bold)
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Status text
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: arenaColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          showResult 
                              ? "Sonuçlar!" 
                              : (botAnswered ? "Rakip cevapladı, sıra sende!" : (playerAnswered ? "Rakip düşünülüyor..." : "Herkes düşünüyor...")),
                          style: TextStyle(
                            color: showResult ? Colors.white : (botAnswered ? Colors.greenAccent : (playerAnswered ? Colors.orangeAccent : Colors.white54)),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Question text
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0A1D45), Color(0xFF061128)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF1E90FF), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1E90FF).withValues(alpha: 0.35),
                              blurRadius: 18, spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Text(
                                questionTextDisplay,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  height: 1.3,
                                  shadows: [Shadow(color: Colors.black, offset: Offset(1,1), blurRadius: 3)],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 15),
                      
                      // Options (Hexagon Buttons)
                      Column(
                        children: List.generate(4, (i) {
                          if (hiddenOptions.contains(i)) {
                            return const SizedBox(height: 52); // Keep space
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _buildOptionButton(i, pQ.options[i], pQ.correctOptionIndex),
                          );
                        }),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Classic Jokers
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: arenaColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildPremiumJoker(
                              icon: Icons.star_half_rounded,
                              label: 'Yarı Yarıya',
                              sublabel: fiftyFiftyUses == 0 ? 'ÜCRETSİZ' : '25 💎',
                              isDisabled: fiftyFiftyUses >= 2,
                              color: const Color(0xFF1976D2),
                              onTap: _useFiftyFifty,
                            ),
                            _buildPremiumJoker(
                              icon: Icons.call_rounded,
                              label: 'Telefon',
                              sublabel: phoneUses == 0 ? 'ÜCRETSİZ' : '25 💎',
                              isDisabled: phoneUses >= 2,
                              color: const Color(0xFF7B2FFF),
                              onTap: _usePhone,
                            ),
                            _buildPremiumJoker(
                              icon: Icons.bar_chart_rounded,
                              label: 'Seyirci',
                              sublabel: audienceUses == 0 ? 'ÜCRETSİZ' : '25 💎',
                              isDisabled: audienceUses >= 2,
                              color: const Color(0xFF00897B),
                              onTap: _useAudience,
                            ),
                            _buildPremiumJoker(
                              icon: Icons.rocket_launch_rounded,
                              label: 'Soruyu Geç',
                              sublabel: skipUses == 0 ? 'ÜCRETSİZ' : '25 💎',
                              isDisabled: skipUses >= 2,
                              color: const Color(0xFFE53935),
                              onTap: _useSkip,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),   // Expanded
            ],
          ),
          ),   // SafeArea
        ],
      ),   // Stack
    );   // Scaffold
  }

  Widget _buildPremiumJoker({
    required IconData icon,
    required String label,
    String? sublabel,
    required bool isDisabled,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Opacity(
        opacity: isDisabled ? 0.35 : 1.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [color.withValues(alpha: 0.9), color.withValues(alpha: 0.4)],
                  center: const Alignment(-0.3, -0.3),
                ),
                border: Border.all(color: color.withValues(alpha: 0.8), width: 2.0),
                boxShadow: [
                  BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 1),
                  BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 4, offset: const Offset(0, 3)),
                ],
              ),
              child: Center(
                child: Icon(icon, color: Colors.white, size: 22,
                  shadows: const [Shadow(color: Colors.black, blurRadius: 4)]),
              ),
            ),
            const SizedBox(height: 3),
            Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700,
                shadows: [Shadow(color: Colors.black, blurRadius: 2)])),
            if (sublabel != null)
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54, borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: color.withValues(alpha: 0.5), width: 0.5),
                ),
                child: Text(sublabel, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(int optionIndex, String text, int correctIndex) {
    List<Color> gradientColors;
    Color borderColor;
    Color letterColor;
    Color? glowColor;
    String letter = ['A', 'B', 'C', 'D'][optionIndex];
    String displayText = text;

    if (!showResult) {
      if (playerAnswered && playerSelectedOption == optionIndex) {
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
    } else {
      if (optionIndex == correctIndex) {
        gradientColors = [const Color(0xFF2E7D32), const Color(0xFF1B5E20)];
        borderColor = const Color(0xFF69F0AE);
        letterColor = const Color(0xFF69F0AE);
        glowColor = const Color(0xFF00E676);
      } else if (playerSelectedOption == optionIndex) {
        gradientColors = [const Color(0xFFC62828), const Color(0xFF7F0000)];
        borderColor = const Color(0xFFFF5252);
        letterColor = const Color(0xFFFF8A80);
        glowColor = const Color(0xFFFF1744);
      } else if (botSelectedOption == optionIndex && botOverrideQuestion == null) {
        gradientColors = [const Color(0xFFE65100), const Color(0xFF6D3200)];
        borderColor = Colors.orangeAccent;
        letterColor = Colors.orangeAccent;
        glowColor = Colors.orange;
      } else {
        gradientColors = [const Color(0xFF0D2157), const Color(0xFF060E2A)];
        borderColor = const Color(0xFF1A3A7A);
        letterColor = const Color(0xFF5C7EC7);
        glowColor = null;
      }
    }

    return Stack(
      children: [
        GestureDetector(
          onTap: () => _handlePlayerAnswer(optionIndex),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft, end: Alignment.bottomRight,
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
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: letterColor.withValues(alpha: 0.15),
                    border: Border.all(color: letterColor, width: 1.5),
                  ),
                  child: Center(
                    child: Text(letter,
                      style: TextStyle(color: letterColor, fontSize: 16, fontWeight: FontWeight.w900,
                        shadows: const [Shadow(color: Colors.black, offset: Offset(1,1), blurRadius: 2)])),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(displayText,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700,
                      shadows: [Shadow(color: Colors.black, offset: Offset(1,1), blurRadius: 3)])),
                ),
              ],
            ),
          ),
        ),
        // Bot indicator overlay
        if (showResult && botSelectedOption == optionIndex && botOverrideQuestion == null)
          Positioned(
            right: 12,
            top: 0, bottom: 0,
            child: Center(
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white,
                child: CircleAvatar(radius: 14, backgroundImage: AssetImage(botAvatar)),
              ),
            ),
          ),
      ],
    );
  }
}
