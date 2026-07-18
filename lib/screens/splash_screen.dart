import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'dart:async';
import 'dart:math';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _mathSymbolsController;
  late AnimationController _electricController;
  int _factIndex = 0;
  
  final List<String> _facts = [
    "İnsan beyninde yaklaşık 86 milyar nöron bulunur.",
    "Bal arıları, dans ederek iletişim kurar.",
    "Dünyadaki en sert doğal madde, elmastır.",
    "Ahtapotların üç kalbi vardır.",
    "Venüs, Güneş Sistemi'nde saat yönünde dönen tek gezegendir.",
    "Bir çay kaşığı nötron yıldızı, yaklaşık 6 milyar ton ağırlığındadır.",
    "DNA'mızın %50'si muz DNA'sı ile aynıdır.",
    "Eyfel Kulesi yazın ısıdan genleşerek 15 cm'ye kadar uzayabilir.",
    "Satürn'ün yoğunluğu o kadar düşüktür ki, dev bir havuza konulsa yüzerdi.",
    "Dünya üzerindeki ağaç sayısı, Samanyolu'ndaki yıldız sayısından fazladır.",
    "Sıcak su, soğuk sudan daha hızlı donar (Mpemba Etkisi).",
    "Bir karınca kendi ağırlığının 50 katını taşıyabilir.",
    "İnsan kemiği, oranlandığında çelikten çok daha güçlüdür.",
    "Tarihteki en kısa savaş (İngiltere-Zanzibar) sadece 38 dakika sürmüştür.",
    "Mavi balinaların kalbi o kadar büyüktür ki, bir insan atardamarlarında yüzebilir.",
    "Jüpiter ve Satürn gezegenlerinde elmas yağmurları yağar.",
    "Kulaklarınız ve burnunuz hayatınız boyunca büyümeye devam eder.",
    "Uzayda yerçekimi olmadığı için gözyaşlarınız aşağı dökülmez.",
    "İnsan DNA'sı uç uca eklenseydi, Güneş'e 600 kez gidip gelebilirdi.",
    "Işık hızıyla seyahat etseniz bile Samanyolu galaksisinden çıkmak 100.000 yıl sürer.",
  ];

  @override
  void initState() {
    super.initState();
    _facts.shuffle();
    
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7000), // 7 seconds loading
    );
    
    _mathSymbolsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    
    _electricController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _progressController.addListener(() {
      setState(() {
        if (_progressController.value < 0.33) {
          _factIndex = 0;
        } else if (_progressController.value < 0.66) {
          _factIndex = 1;
        } else if (_progressController.value < 0.99) {
          _factIndex = 2;
        }
      });
    });

    _progressController.forward();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(milliseconds: 8500));
    
    if (!mounted) return;
    
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      try {
        user = await FirebaseAuth.instance.authStateChanges().first;
      } catch (_) {}
    }
    
    if (user == null) {
      try {
        await FirebaseAuth.instance.signInAnonymously();
      } catch (_) {}
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 1200),
        )
      );
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _mathSymbolsController.dispose();
    _electricController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = _progressController.value;
    bool isComplete = progress >= 0.99;
    
    return Scaffold(
      backgroundColor: const Color(0xFF070B19),
      body: Stack(
        children: [
          // Math Symbols Background
          AnimatedBuilder(
            animation: _mathSymbolsController,
            builder: (context, child) {
              return CustomPaint(
                painter: MathSymbolsPainter(animationValue: _mathSymbolsController.value),
                size: Size.infinite,
              );
            },
          ),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                
                // Glowing Avatar with Flare
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.8), width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyanAccent.withValues(alpha: 0.2),
                            blurRadius: 50,
                            spreadRadius: 15,
                          ),
                          BoxShadow(
                            color: Colors.blueAccent.withValues(alpha: 0.2),
                            blurRadius: 80,
                            spreadRadius: 30,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/einstein_splash.png',
                          width: 220,
                          height: 220,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    
                    // Atom Light Flare overlay (appears on left side of image where his hand is)
                    Positioned(
                      left: -20,
                      bottom: 40,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInExpo,
                        width: isComplete ? 1500 : 80, // Massive explosion at 100%
                        height: isComplete ? 1500 : 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withValues(alpha: isComplete ? 1.0 : 0.6),
                              Colors.cyanAccent.withValues(alpha: isComplete ? 0.8 : 0.3),
                              Colors.transparent,
                            ],
                            stops: const [0.1, 0.4, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35),
                
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                      shadows: [
                        Shadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 4)),
                      ],
                    ),
                    children: [
                      TextSpan(text: 'MİLY', style: TextStyle(color: Colors.white)),
                      TextSpan(text: 'ARDER', style: TextStyle(color: Colors.cyanAccent)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'ZEKANI KONUŞTUR',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.6),
                    letterSpacing: 6,
                  ),
                ),
                const Spacer(flex: 2),
                
                // Loading Section with Electric Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    children: [
                      Container(
                        height: 8,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 0.5),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: AnimatedBuilder(
                                animation: _electricController,
                                builder: (context, child) {
                                  return Container(
                                    width: constraints.maxWidth * progress,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.lightBlueAccent, 
                                          Colors.cyanAccent, 
                                          Colors.white.withValues(alpha: _electricController.value)
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.cyanAccent.withValues(alpha: 0.6 + (_electricController.value * 0.4)),
                                          blurRadius: 10 + (_electricController.value * 5),
                                          spreadRadius: 1 + (_electricController.value * 2),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '%${(progress * 100).toInt()}',
                        style: const TextStyle(
                          color: Colors.cyanAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                SizedBox(
                  height: 90,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: isComplete
                        ? const Column(
                            key: ValueKey("ready"),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '⚡ HAZIRSAN ZEKÂNI KONUŞTUR! ⚡',
                                style: TextStyle(
                                  color: Colors.cyanAccent,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'YÜKLEME TAMAMLANDI',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 10,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          )
                        : Container(
                            key: ValueKey(_factIndex),
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF111827).withValues(alpha: 0.6), // Glassmorphism base
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.cyanAccent.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.cyanAccent.withValues(alpha: 0.05),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.lightbulb_outline, color: Colors.amberAccent, size: 22),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    _facts[_factIndex],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.italic,
                                      height: 1.4,
                                      letterSpacing: 0.5,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                
                const Spacer(flex: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MathSymbolsPainter extends CustomPainter {
  final double animationValue;
  final Random random = Random(42); 
  
  MathSymbolsPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final symbols = ['π', '√', 'Σ', '∞', '∫', '≈', 'e', '+', '-'];
    
    for (int i = 0; i < 30; i++) {
      double startX = (random.nextDouble() * size.width * 1.5) - (size.width * 0.25);
      double startY = size.height + (random.nextDouble() * size.height * 2);
      double speed = 0.2 + random.nextDouble() * 0.5;
      
      double currentY = startY - ((animationValue * 10 * size.height * speed) % (size.height * 2));
      if (currentY < -100) currentY += size.height * 2; 
      
      double currentX = startX + sin(animationValue * pi * 2 + i) * 30;
      
      double opacity = 0.05 + random.nextDouble() * 0.15; // Very subtle
      double fontSize = 16 + random.nextDouble() * 24;
      
      textPainter.text = TextSpan(
        text: symbols[i % symbols.length],
        style: TextStyle(
          color: Colors.cyanAccent.withValues(alpha: opacity),
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      );
      
      textPainter.layout();
      textPainter.paint(canvas, Offset(currentX, currentY));
    }
  }

  @override
  bool shouldRepaint(covariant MathSymbolsPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
