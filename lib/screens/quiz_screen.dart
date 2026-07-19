import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../providers/quiz_provider.dart';
import '../providers/audio_provider.dart';
import '../services/ad_service.dart';
import '../widgets/joker_dialogs.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _bgController;
  late AnimationController _pulseController;
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..repeat(reverse: true);
    _particleController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<QuizProvider>();
      final audio = context.read<AudioProvider>();
      provider.onTick = () {
        if (mounted) audio.playSfx('tick.wav');
      };
      provider.onTimeOut = () {
        // Sessiz (Oyun sonu)
      };
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    _bgController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      final provider = Provider.of<QuizProvider>(context, listen: false);
      if (!provider.isAnswered && provider.timeLeft > 0 && !provider.isSuspense) {
        // Hile Algılandı!
        provider.punishCheat();
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

  void _handleAnswerTap(QuizProvider provider, int index) async {
    if (provider.isSuspense || provider.isAnswered) return;
    
    final audioProvider = context.read<AudioProvider>();
    
    if (mounted) {
      audioProvider.playSfx('click.wav');
    }
    
    await provider.submitAnswer(index);
    
    if (mounted) {
      bool isCorrect = provider.selectedOptionIndex == provider.currentQuestion.correctOptionIndex;
      bool isGameOver = !isCorrect || 
                        (provider.gameMode == GameMode.classic && provider.currentQuestionIndex >= 14) || 
                        (provider.gameMode == GameMode.event && provider.currentQuestionIndex >= 29) || 
                        (provider.gameMode == GameMode.endless && !isCorrect);
      
      if (!isGameOver) {
        if (isCorrect) {
          audioProvider.playSfx('correct.mp3');
        } else {
          audioProvider.playSfx('wrong.wav');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<QuizProvider>(
        builder: (context, provider, child) {
          if (provider.currentQuestions.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFFB629)));
          }
          final question = provider.currentQuestion;
          return Stack(
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
                          Row(
                            children: [
                              // Diamond pill
                              _buildDiamondPill(provider),
                              if (provider.gameMode == GameMode.classic && provider.currentQuestionIndex > 0 && !provider.isAnswered) ...[
                                const SizedBox(width: 12),
                                _buildWithdrawButton(provider),
                              ],
                            ],
                          ),
                          // Timer
                          _buildTimer(provider),
                        ],
                      ),
                    ),

                    const SizedBox(height: 6),

                    // PRIZE PILL
                    _buildPrizePill(provider),



                    const SizedBox(height: 6),

                    // QUESTION BOX
                    Expanded(
                      flex: 3,
                      child: _buildQuestionBox(question),
                    ),

                    const SizedBox(height: 4),

                    // JOKER ROW
                    _buildJokerRow(provider),

                    const SizedBox(height: 4),

                    // ANSWER BUTTONS
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              _buildAnswer(provider, 0, 'A'),
                              const SizedBox(height: 8),
                              _buildAnswer(provider, 1, 'B'),
                              const SizedBox(height: 8),
                              _buildAnswer(provider, 2, 'C'),
                              const SizedBox(height: 8),
                              _buildAnswer(provider, 3, 'D'),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // DEVAM / PADDING
                    if (provider.isAnswered)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6, top: 4),
                        child: _buildNextButton(provider),
                      )
                    else
                      const SizedBox(height: 6),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── WIDGETS ──────────────────────────────────────────────────────

  Widget _buildDiamondPill(QuizProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0E2257), Color(0xFF081635)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF2196F3), width: 1.5),
        boxShadow: [BoxShadow(color: const Color(0xFF2196F3).withValues(alpha: 0.4), blurRadius: 12, spreadRadius: 1)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/3d_diamond_clear_nobg.png', width: 26, height: 26),
          const SizedBox(width: 6),
          Text(provider.formattedTotalCoins,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(width: 8),
          Container(
            width: 22, height: 22,
            decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle),
            child: const Icon(Icons.add, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTimer(QuizProvider provider) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, __) {
        final isUrgent = provider.timeLeft <= 5;
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
                '${provider.timeLeft}',
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

  Widget _buildPrizePill(QuizProvider provider) {
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
          Text(
              provider.gameMode == GameMode.classic
                  ? '${provider.prizeLadder[provider.currentQuestionIndex]} 💵'
                  : (provider.gameMode == GameMode.event ? (provider.currentEventCategory ?? 'ETKİNLİK').toUpperCase() : 'SONSUZ MOD'),
            style: const TextStyle(
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
                  provider.gameMode == GameMode.classic
                      ? '${provider.currentQuestionIndex + 1} / 15'
                      : (provider.gameMode == GameMode.event 
                           ? '${provider.currentQuestionIndex + 1} / 30' 
                           : 'Seviye ${provider.currentQuestionIndex + 1}'),
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                ),
                if (provider.gameMode == GameMode.classic && 
                    (provider.currentQuestionIndex == 1 || provider.currentQuestionIndex == 4 || provider.currentQuestionIndex == 9))
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.shade700,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white70, width: 1),
                      ),
                      child: const Text('BARAJ', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionBox(dynamic question) {
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
          // Corner ornaments
          Positioned(top: 0, left: 0,
            child: Icon(Icons.auto_awesome, color: const Color(0xFF1E90FF).withValues(alpha: 0.3), size: 18)),
          Positioned(top: 0, right: 0,
            child: Icon(Icons.auto_awesome, color: const Color(0xFF1E90FF).withValues(alpha: 0.3), size: 18)),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (question.imageUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          question.imageUrl!,
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  Text(
                    question.text,
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

  Widget _buildJokerRow(QuizProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildJoker(
            icon: Icons.exposure_minus_2_rounded,
            label: 'Yarı Yarıya',
            sublabel: provider.fiftyFiftyUses >= 2 ? null : (provider.fiftyFiftyUses == 0 ? 'ÜCRETSİZ' : (provider.jokerFiftyFiftyTokens > 0 ? '1 🃏' : '25 💎')),
            isDisabled: provider.fiftyFiftyUsedThisQuestion || provider.fiftyFiftyUses >= 2,
            color: const Color(0xFFFFB300),
            onTap: () {
              if (provider.fiftyFiftyUsedThisQuestion || provider.fiftyFiftyUses >= 2) return;
              context.read<AudioProvider>().playSfx('click.wav');
              if (!provider.useFiftyFifty()) { _showNotEnough(); }
            },
          ),
          _buildJoker(
            icon: Icons.call_rounded,
            label: 'Telefon',
            sublabel: provider.phoneUses >= 2 ? null : (provider.phoneUses == 0 ? 'ÜCRETSİZ' : (provider.jokerPhoneTokens > 0 ? '1 🃏' : '25 💎')),
            isDisabled: provider.phoneUsedThisQuestion || provider.phoneUses >= 2,
            color: const Color(0xFF7B2FFF),
            onTap: () {
              if (provider.phoneUsedThisQuestion || provider.phoneUses >= 2) return;
              context.read<AudioProvider>().playSfx('click.wav');
              if (provider.usePhone()) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) => PhoneCallDialog(
                    correctOption: provider.currentQuestion.options[provider.currentQuestion.correctOptionIndex],
                    avatarPath: provider.activeAvatar.startsWith('assets') ? provider.activeAvatar : 'assets/images/${provider.activeAvatar}',
                  ),
                );
              } else {
                _showNotEnough();
              }
            },
          ),
          _buildJoker(
            icon: Icons.bar_chart_rounded,
            label: 'Seyirci',
            sublabel: provider.audienceUses >= 2 ? null : (provider.audienceUses == 0 ? 'ÜCRETSİZ' : (provider.jokerAudienceTokens > 0 ? '1 🃏' : '25 💎')),
            isDisabled: provider.audienceUsedThisQuestion || provider.audienceUses >= 2,
            color: const Color(0xFF00897B),
            onTap: () {
              if (provider.audienceUsedThisQuestion || provider.audienceUses >= 2) return;
              context.read<AudioProvider>().playSfx('click.wav');
              if (provider.useAudience()) {
                showDialog(
                  context: context,
                  builder: (ctx) => AudienceChartDialog(
                    correctOptionIndex: provider.currentQuestion.correctOptionIndex,
                    options: provider.currentQuestion.options,
                  ),
                );
              } else {
                _showNotEnough();
              }
            },
          ),
          _buildJoker(
            icon: Icons.rocket_launch_rounded,
            label: 'Soruyu Geç',
            sublabel: provider.skipUses >= 2 ? null : (provider.skipUses == 0 ? 'ÜCRETSİZ' : (provider.jokerSkipTokens > 0 ? '1 🃏' : '25 💎')),
            isDisabled: provider.skipUsedThisQuestion || provider.skipUses >= 2 || provider.isAnswered,
            color: const Color(0xFFE53935),
            onTap: () {
              if (provider.skipUsedThisQuestion || provider.skipUses >= 2 || provider.isAnswered) return;
              context.read<AudioProvider>().playSfx('click.wav');
              if (!provider.useSkipJoker()) { _showNotEnough(); }
            },
          ),
        ],
      ),
    );
  }

  void _showNotEnough() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yeterli Elmas veya Joker hakkınız yok!'), behavior: SnackBarBehavior.floating),
    );
  }

  Widget _buildJoker({
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
              width: 60, height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [color.withValues(alpha: 0.9), color.withValues(alpha: 0.4)],
                  center: const Alignment(-0.3, -0.3),
                ),
                border: Border.all(color: color.withValues(alpha: 0.8), width: 2.5),
                boxShadow: [
                  BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 14, spreadRadius: 1),
                  BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 4, offset: const Offset(0, 3)),
                ],
              ),
              child: Center(
                child: Icon(icon, color: Colors.white, size: 26,
                  shadows: const [Shadow(color: Colors.black, blurRadius: 6)]),
              ),
            ),
            const SizedBox(height: 5),
            Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700,
                shadows: [Shadow(color: Colors.black, blurRadius: 4)])),
            if (sublabel != null)
              Text(sublabel,
                style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 9, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswer(QuizProvider provider, int index, String letter) {
    if (provider.currentQuestion.options.length <= index) return const SizedBox();
    if (provider.fiftyFiftyUsedThisQuestion && provider.hiddenOptions.contains(index)) {
      return SizedBox(height: 56);
    }

    final option = provider.currentQuestion.options[index];
    
    // State colors
    Color borderColor;
    List<Color> gradientColors;
    Color letterColor;
    Color? glowColor;

    if (provider.isSuspense && provider.selectedOptionIndex == index) {
      gradientColors = [const Color(0xFFFF8F00), const Color(0xFFE65100)];
      borderColor = const Color(0xFFFFCC02);
      letterColor = const Color(0xFFFFE082);
      glowColor = const Color(0xFFFF8F00);
    } else if (provider.isAnswered) {
      if (index == provider.currentQuestion.correctOptionIndex) {
        gradientColors = [const Color(0xFF2E7D32), const Color(0xFF1B5E20)];
        borderColor = const Color(0xFF69F0AE);
        letterColor = const Color(0xFF69F0AE);
        glowColor = const Color(0xFF00E676);
      } else if (index == provider.selectedOptionIndex) {
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
      gradientColors = [const Color(0xFF0E2766), const Color(0xFF061438)];
      borderColor = const Color(0xFF2979FF);
      letterColor = const Color(0xFFFFB300);
      glowColor = null;
    }

    return GestureDetector(
      onTap: () => _handleAnswerTap(provider, index),
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
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton(QuizProvider provider) {
    return GestureDetector(
      onTap: () {
        bool isCorrect = provider.selectedOptionIndex == provider.currentQuestion.correctOptionIndex;
        bool isGameOver = !isCorrect || provider.isLastQuestion;
        
        // Show 2nd chance ad dialog if wrong answer and not yet used ad revive
        if (!isCorrect && !provider.usedAdReviveThisGame && provider.gameMode != GameMode.event) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF0F2027),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Colors.amber, width: 2),
              ),
              title: const Text('2. BİR ŞANS İSTER MİSİN?', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
              content: const Text(
                'Yanlış cevap verdin ancak elenmek zorunda değilsin! Kısa bir video izleyerek soruya kaldığın yerden (2. bir şansla) devam edebilirsin.',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    provider.nextQuestion();
                    if (isGameOver) {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ResultScreen()));
                    }
                  },
                  child: const Text('HAYIR, ELENEYİM', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton.icon(
                  icon: Icon(provider.hasRemovedAds ? Icons.diamond : Icons.ondemand_video, color: Colors.white),
                  label: Text(provider.hasRemovedAds ? 'VIP BEDAVA DEVAM ET' : 'VİDEO İZLE VE DEVAM ET', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: provider.hasRemovedAds ? Colors.green : Colors.amber,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (provider.hasRemovedAds) {
                      if (provider.consumeVipAction('game_revive')) {
                        provider.reviveWithAd();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('VIP Ayrıcalığı: Canlandınız!'), backgroundColor: Colors.green));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Günlük VIP Revive sınırına ulaştınız! (Max 10)')));
                        provider.walkAway(); // Walk away automatically if limit reached to avoid cheating
                      }
                    } else {
                      AdService().showRewardedAd(
                        context: context,
                        onRewardEarned: (_) {
                          provider.reviveWithAd();
                        },
                        onClosed: () {}, // Do nothing if closed early without reward
                      );
                    }
                  },
                ),
              ],
            ),
          );
        } else {
          provider.nextQuestion();
          if (isGameOver) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ResultScreen()));
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD740), Color(0xFFFF8F00)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: const Color(0xFFFFEE58), width: 1.5),
          boxShadow: [
            const BoxShadow(color: Color(0xFFBF6000), offset: Offset(0, 4), blurRadius: 0),
            BoxShadow(color: const Color(0xFFFFB300).withValues(alpha: 0.5), blurRadius: 16),
          ],
        ),
        child: const Text(
          'DEVAM ET  ▶',
          style: TextStyle(color: Color(0xFF1A0A00), fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
      ),
    );
  }

  Widget _buildWithdrawButton(QuizProvider provider) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF0F2027),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFFFF9800), width: 2),
            ),
            title: const Text('Çekilmek İstiyor Musun?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            content: Text(
              'Şu ana kadar kazandığın ${provider.prizeLadder[provider.currentQuestionIndex - 1]} ₺ ödülü alıp yarışmadan ayrılacaksın. Kararın kesin mi?',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('İPTAL', style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  provider.withdraw();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ResultScreen()));
                },
                child: const Text('EVET, ÇEKİL', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF5252), Color(0xFFD32F2F), Color(0xFFB71C1C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.redAccent.shade100, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.6),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
              const BoxShadow(
                color: Colors.white24,
                blurRadius: 4,
                spreadRadius: 0,
                offset: Offset(-2, -2),
              ),
            ],
          ),
          child: const Icon(
            Icons.exit_to_app_rounded,
            color: Colors.white,
            size: 24,
            shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(1, 1))],
          ),
        ),
    );
  }
}

// ── SPARKLE PAINTER ────────────────────────────────────────────────

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
