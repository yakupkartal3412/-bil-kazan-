import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  int _factIndex = 0;
  
  final List<String> _facts = [
    "İnsan beyninde yaklaşık 86 milyar nöron bulunur.",
    "Bal arıları, dans ederek iletişim kurar.",
    "Dünyadaki en sert doğal madde, elmastır.",
    "Ahtapotların üç kalbi vardır.",
    "Venüs, Güneş Sistemi'nde saat yönünde dönen tek gezegendir.",
  ];

  @override
  void initState() {
    super.initState();
    _facts.shuffle();
    
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000), // 5 seconds loading
    );

    _progressController.addListener(() {
      setState(() {
        // Change fact every 33%
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
    await Future.delayed(const Duration(milliseconds: 5500));
    
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
          transitionDuration: const Duration(milliseconds: 800),
        )
      );
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = _progressController.value;
    bool isComplete = progress >= 0.99;
    
    return Scaffold(
      backgroundColor: const Color(0xFF070B19), // Deeper space navy
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                // Glowing Avatar
                Container(
                  padding: const EdgeInsets.all(2), // Thin border
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
                const SizedBox(height: 35),
                // Split Text: MİLY (White) ARDER (Cyan)
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
                
                // Loading Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    children: [
                      // Progress Bar
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
                              child: Container(
                                width: constraints.maxWidth * progress,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: const LinearGradient(
                                    colors: [Colors.lightBlueAccent, Colors.cyanAccent],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.cyanAccent.withValues(alpha: 0.6),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Percentage
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
                
                // Dynamic Fact Box or Ready Text
                SizedBox(
                  height: 60,
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
                            margin: const EdgeInsets.symmetric(horizontal: 30),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _facts[_factIndex],
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
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
