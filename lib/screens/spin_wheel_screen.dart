import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/audio_provider.dart';
import '../services/ad_service.dart';
import '../utils/constants.dart';

class SpinWheelScreen extends StatefulWidget {
  const SpinWheelScreen({super.key});

  @override
  State<SpinWheelScreen> createState() => _SpinWheelScreenState();
}

class _SpinWheelScreenState extends State<SpinWheelScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _pulseController;
  
  final List<String> prizes = [
    '100.000 ₺', '5 Elmas', '50.000 ₺', '25 Elmas', '5.000 ₺', '25.000 ₺', '1.000 ₺', 'Pas'
  ];
  
  bool _isSpinning = false;
  double _currentAngle = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _controller.addListener(() {
      setState(() {
        _currentAngle = _animation.value;
      });
    });

    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    // Ekrandan çıkınca müziği her zaman geri aç
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.read<AudioProvider>().resumeBgm();
      }
    });
    super.dispose();
  }

  void _spinNormal() {
    final provider = Provider.of<QuizProvider>(context, listen: false);
    String today = DateTime.now().toString().split(' ')[0];
    if (provider.lastSpinDate == today) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bugünlük çark hakkınızı kullandınız. Yarın tekrar gelin!')));
      return;
    }
    _executeSpin(provider, false);
  }

  void _spinAd() {
    final provider = Provider.of<QuizProvider>(context, listen: false);
    String today = DateTime.now().toString().split(' ')[0];
    if (provider.lastAdSpinDate == today) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bugünlük ekstra video çark hakkınızı kullandınız. Yarın tekrar gelin!')));
      return;
    }

    AdService().showRewardedAd(
      context: context,
      onRewardEarned: (amount) {
        _executeSpin(provider, true);
      },
    );
  }

  void _executeSpin(QuizProvider provider, bool isAdSpin) {
    if (_isSpinning) return;
    
    context.read<AudioProvider>().pauseBgm();
    
    setState(() {
      _isSpinning = true;
    });
    
    final random = Random();
    double sliceAngle = 2 * pi / prizes.length;
    double randomExtraAngle = (random.nextDouble() * 0.8 + 0.1) * sliceAngle; 
    int targetSlice = random.nextInt(prizes.length);
    double targetAngle = (6 * 2 * pi) + (targetSlice * sliceAngle) + randomExtraAngle;
    
    _animation = Tween<double>(begin: 0, end: targetAngle).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart)
    );
    
    int lastTickSlice = -1;
    _animation.addListener(() {
      double normalizedRotation = _animation.value % (2 * pi);
      double pointerAngle = (2 * pi - normalizedRotation) % (2 * pi);
      int currentSlice = (pointerAngle / sliceAngle).floor();
      if (currentSlice != lastTickSlice) {
        lastTickSlice = currentSlice;
        if (mounted) context.read<AudioProvider>().playSfx('tick.wav');
      }
    });
    
    _controller.forward(from: 0).then((_) {
      setState(() {
        _isSpinning = false;
      });
      
      double normalizedRotation = targetAngle % (2 * pi);
      double pointerAngle = (2 * pi - normalizedRotation) % (2 * pi);
      int winningIndex = (pointerAngle / sliceAngle).floor();
      
      String prize = prizes[winningIndex];
      _handlePrize(prize, provider);
      
      if (isAdSpin) {
        provider.updateLastAdSpinDate();
      } else {
        provider.updateLastSpinDate();
      }
      
      if (mounted) context.read<AudioProvider>().playSfx('correct.mp3');
      _showResultDialog(prize);
    });
  }

  void _handlePrize(String prize, QuizProvider provider) {
    if (prize.contains('Elmas')) {
      int amount = int.parse(prize.split(' ')[0]);
      provider.addCoins(amount);
    } else if (prize.contains('₺')) {
      String cleanStr = prize.replaceAll('.', '').replaceAll(' ₺', '');
      int amount = int.parse(cleanStr);
      provider.addMoney(amount);
    }
  }

  void _showResultDialog(String prize) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          elevation: 0,
          content: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.menuButtonBorder, width: 2),
              boxShadow: [
                BoxShadow(color: AppColors.menuButtonBorder.withValues(alpha: 0.3), blurRadius: 30, spreadRadius: 5)
              ]
            ),
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('TEBRİKLER!', 
                  style: TextStyle(color: AppColors.textGold, fontWeight: FontWeight.w900, fontSize: 28, letterSpacing: 3)
                ),
                const SizedBox(height: 30),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.menuButtonBorder.withValues(alpha: 0.1),
                        boxShadow: [
                          BoxShadow(color: AppColors.menuButtonBorder.withValues(alpha: 0.3), blurRadius: 40, spreadRadius: 10)
                        ]
                      ),
                    ),
                    Icon(Icons.workspace_premium, color: AppColors.textGold, size: 90),
                  ],
                ),
                const SizedBox(height: 30),
                Text(prize == 'Pas' ? 'Maalesef bu sefer pas geçtiniz.' : 'Kazanılan Ödül\n$prize', 
                     style: TextStyle(color: AppColors.textWhite, fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    context.read<AudioProvider>().resumeBgm();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.menuButtonBorder,
                    foregroundColor: AppColors.darkBackground,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 10,
                  ),
                  child: const Text('HARİKA!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuizProvider>(context);
    String today = DateTime.now().toString().split(' ')[0];
    bool canSpin = provider.lastSpinDate != today;
    bool canAdSpin = provider.lastAdSpinDate != today;

    // Use dynamic theme colors for wheel
    final List<Color> dynamicSliceColors = [
      Colors.white, const Color(0xFFA00000),
      Colors.white, const Color(0xFFA00000),
      Colors.white, const Color(0xFFA00000),
      Colors.white, const Color(0xFFA00000),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        // Dynamic background
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF8B0000), Color(0xFF300000)],
            center: Alignment.center,
            radius: 1.5,
          ),
        ),
        child: Stack(
          children: [
            // Shimmering Casino Sparkles Background
            Positioned.fill(
              child: CustomPaint(
                painter: CasinoSparklesPainter(),
              ),
            ),
            SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Premium Title
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [AppColors.textGold, AppColors.textWhite, AppColors.textGold],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: const Text(
                  'ŞANS ÇARKI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 6,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF3F1D70),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFFA142FF), width: 2),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFA142FF).withValues(alpha: 0.6), blurRadius: 15, spreadRadius: 2),
                  ]
                ),
                child: const Text('GÜNLÜK ÜCRETSİZ HAKKINIZ: 1', 
                  style: TextStyle(color: Color(0xFFFFD700), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
              const SizedBox(height: 60),
              
              // 2D Flat Premium Casino Wheel
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Black Base (Trapezoid/Stand at the bottom)
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: 140,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF222222),
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.8), blurRadius: 20, offset: const Offset(0, 10)),
                          ]
                        ),
                      ),
                    ),
                    
                    // The Wheel Wrapper
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20), // Lift it slightly above base
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Deep shadow under the wheel
                          Container(
                            width: 340,
                            height: 340,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 40, offset: const Offset(0, 20)),
                              ]
                            ),
                          ),
                            // The rotating wheel
                            Transform.rotate(
                              angle: _currentAngle,
                              child: SizedBox(
                                width: 340,
                                height: 340,
                                child: Stack(
                                  children: [
                                    // 1. Background Wheel Painter
                                    SizedBox.expand(
                                      child: CustomPaint(
                                        painter: ThemedWheelPainter(prizes, dynamicSliceColors),
                                      ),
                                    ),
                                    // 2. 3D Premium Widgets inside slices!
                                    ...List.generate(prizes.length, (i) {
                                      final double sliceAngle = 2 * pi / prizes.length;
                                      final double angle = -pi / 2 + (i * sliceAngle) + (sliceAngle / 2);
                                      
                                      String prizeStr = prizes[i];
                                      bool isDiamond = prizeStr.contains('Elmas');
                                      bool isMoney = prizeStr.contains('₺');
                                      String cleanText = prizeStr.replaceAll(' Elmas', '').replaceAll(' ₺', '');
                                      
                                      // Exact mathematical positioning
                                      double radius = 100.0;
                                      double cx = 170.0 + radius * cos(angle);
                                      double cy = 170.0 + radius * sin(angle);
                                      
                                      bool isLeftHemisphere = cos(angle) < 0;
                                      double rotationAngle = isLeftHemisphere ? angle + pi : angle;
                                      
                                      Color textColor = i % 2 == 0 ? const Color(0xFFA00000) : Colors.white;
                                      List<Shadow> textShadows = []; // Clean text on casino wheel
                                          
                                      Widget textWidget = Text(
                                        cleanText,
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                          shadows: textShadows,
                                        )
                                      );
                                      
                                      Widget imageWidget = Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (isDiamond) Image.asset('assets/images/3d_diamond_clear_nobg.png', width: 20, height: 20),
                                            if (isMoney) Image.asset('assets/images/3d_cash_icon_nobg.png', width: 20, height: 20),
                                          ],
                                        );

                                      return Positioned(
                                        left: cx - 75,
                                        top: cy - 25,
                                        width: 150,
                                        height: 50,
                                        child: Transform.rotate(
                                          angle: rotationAngle,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [textWidget, if (isDiamond || isMoney) const SizedBox(width: 8), imageWidget],
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                            // Glassy shine overlay over the wheel
                            IgnorePointer(
                              child: Container(
                                width: 340,
                                height: 340,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0.1),
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.6),
                                    ],
                                    stops: const [0.0, 0.5, 1.0],
                                  ),
                                ),
                              ),
                            ),
                           ],
                        ),
                      ),
                    
                    // The Pointer (Arrow) floating above
                    Positioned(
                      top: -15,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          // Pointer shadow
                          Transform.translate(
                            offset: const Offset(0, 8),
                            child: const Icon(Icons.arrow_drop_down, color: Colors.black54, size: 90),
                          ),
                          // Pointer body (Golden Shield with Diamond)
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFFFFF9C4), Color(0xFFF9A825), Color(0xFFF57F17)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(bounds),
                            child: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 85),
                          ),
                          const Positioned(
                            top: 15,
                            child: Icon(Icons.diamond, color: Colors.white, size: 24, shadows: [Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2))]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
              
              // Pulsating Premium Button
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  bool canDoAction = canSpin || canAdSpin;
                  String buttonText = _isSpinning 
                      ? 'ÇEVRİLİYOR...' 
                      : (canSpin 
                          ? 'ÇARKI ÇEVİR' 
                          : (canAdSpin ? 'VİDEO İZLE VE ÇEVİR' : 'YARIN TEKRAR GEL'));
                  
                  return Transform.scale(
                    scale: canDoAction && !_isSpinning ? 1.0 + (_pulseController.value * 0.04) : 1.0,
                    child: GestureDetector(
                      onTap: canDoAction && !_isSpinning 
                          ? (canSpin ? _spinNormal : _spinAd)
                          : null,
                      child: Container(
                        width: 280,
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: (!canSpin && canAdSpin) 
                              ? [const Color(0xFF6B21A8), const Color(0xFF4C1D95)] // Video için mor tonu
                              : [const Color(0xFF3F1D70), const Color(0xFF1A0A3A)], // Normal çevirme
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 8)),
                          ],
                          border: Border.all(
                            color: (!canSpin && canAdSpin) ? const Color(0xFFA855F7) : const Color(0xFF5A3B8C), 
                            width: 2
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!canSpin && canAdSpin && !_isSpinning)
                                const Padding(
                                  padding: EdgeInsets.only(right: 8.0),
                                  child: Icon(Icons.ondemand_video, color: Colors.white, size: 28),
                                ),
                              Text(
                                buttonText,
                                style: const TextStyle(
                                  fontSize: 20, 
                                  fontWeight: FontWeight.w900, 
                                  color: Color(0xFFF9A825),
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
          ],
        ),
      ),
    );
  }
}

class ThemedWheelPainter extends CustomPainter {
  final List<String> prizes;
  final List<Color> colors;

  ThemedWheelPainter(this.prizes, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final double sliceAngle = 2 * pi / prizes.length;
    final center = Offset(size.width / 2, size.height / 2);
    
    // Outer Thick Metallic Rim matching casino theme
    final rimPaint = Paint()
      ..shader = const SweepGradient(
        colors: [Color(0xFFF9A825), Color(0xFFFFF9C4), Color(0xFFF57F17), Color(0xFFFFF9C4), Color(0xFFF9A825)],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30; // Very thick rim
    canvas.drawCircle(center, size.width / 2 - 15, rimPaint);

    // Inner wheel area
    final innerRadius = size.width / 2 - 30;
    final innerRect = Rect.fromCenter(center: center, width: innerRadius * 2, height: innerRadius * 2);
    
    for (int i = 0; i < prizes.length; i++) {
      // Draw flat slice background
      final slicePaint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;
        
      canvas.drawArc(innerRect, -pi / 2 + (i * sliceAngle), sliceAngle, true, slicePaint);
      
      // Draw subtle inner shadow for depth
      final depthPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.transparent, 
            Colors.black.withValues(alpha: 0.3),
          ],
          center: Alignment.center,
          radius: 1.0,
        ).createShader(innerRect)
        ..style = PaintingStyle.fill;
      canvas.drawArc(innerRect, -pi / 2 + (i * sliceAngle), sliceAngle, true, depthPaint);
      
      // Draw separator lines (thin gold)
      final borderPaint = Paint()
        ..color = const Color(0xFFF57F17)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawArc(innerRect, -pi / 2 + (i * sliceAngle), sliceAngle, true, borderPaint);
    }
    
    // Draw 24 Glowing Light Bulbs on the Rim
    for (int i = 0; i < 24; i++) {
      final double pegAngle = -pi / 2 + (i * (2 * pi / 24));
      final double pegX = center.dx + (size.width / 2 - 15) * cos(pegAngle);
      final double pegY = center.dy + (size.height / 2 - 15) * sin(pegAngle);
      
      Color glowColor = i % 2 == 0 ? Colors.redAccent.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.8);
      Color innerColor = i % 2 == 0 ? Colors.red.shade200 : Colors.white;
      
      // Bulb Glow
      final pegGlowPaint = Paint()
        ..color = glowColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(pegX, pegY), 8, pegGlowPaint);
      
      // Bulb Center
      final pegPaint = Paint()..color = innerColor;
      canvas.drawCircle(Offset(pegX, pegY), 4, pegPaint);
    }
    
    // Draw Massive Casino Center Hub
    // Hub Drop shadow
    final hubShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(center, 55, hubShadowPaint);

    // Hub Outer Ring
    final hubOuterPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFF57F17), Color(0xFFFFF9C4), Color(0xFFF9A825)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCenter(center: center, width: 110, height: 110));
    canvas.drawCircle(center, 55, hubOuterPaint);
    
    // Hub Inner Plate
    final hubInnerPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFBC02D), Color(0xFFF57F17)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCenter(center: center, width: 90, height: 90));
    canvas.drawCircle(center, 45, hubInnerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CasinoSparklesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42); // fixed seed so they don't jump around
    for (int i = 0; i < 80; i++) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;
      double r = random.nextDouble() * 2 + 1; // radius 1-3
      
      Color particleColor = random.nextBool() ? Colors.redAccent.withValues(alpha: 0.4) : Colors.yellowAccent.withValues(alpha: 0.3);
      final paint = Paint()..color = particleColor;
      canvas.drawCircle(Offset(x, y), r, paint);
      
      // Every 5th sparkle has a glowing halo
      if (i % 5 == 0) {
        final glowPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(Offset(x, y), r * 2.5, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
