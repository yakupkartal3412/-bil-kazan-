import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Subtle, elegant zoom in
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    _navigateNext();
  }

  Future<void> _navigateNext() async {
    // Animasyonun tamamlanması için bekle (kullanıcının isteği üzerine +3 saniye eklendi)
    await Future.delayed(const Duration(milliseconds: 5500));
    
    if (!mounted) return;
    
    // Auth durumunu daha güvenilir şekilde kontrol et (sadece anlık currentUser değil, state'i bekle)
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Eğer anlık null ise, Firebase'in session'ı yüklemesini 1 saniye kadar bekle
      try {
        user = await FirebaseAuth.instance.authStateChanges().first;
      } catch (_) {}
    }
    
    // Hala null ise (yani ilk defa oyuna giriyorsa), otomatik olarak Misafir Girişi yap!
    if (user == null) {
      try {
        await FirebaseAuth.instance.signInAnonymously();
      } catch (_) {}
    }

    // Her durumda (eski hesap veya yeni misafir) direkt Ana Ekrana yönlendir.
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Lüks lacivert arkaplan
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Elegant Premium Einstein Bust
                    Container(
                      padding: const EdgeInsets.all(2), // Thin border
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.6), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyanAccent.withValues(alpha: 0.15),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/einstein_splash.png',
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    // Minimalist Premium Typography
                    const Text(
                      'MİLYARDER',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        letterSpacing: 12,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'ZEKANI KONUŞTUR',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: Colors.white.withValues(alpha: 0.6),
                        letterSpacing: 8,
                      ),
                    ),
                    const SizedBox(height: 70),
                    // Sleek Loading Indicator
                    SizedBox(
                      width: 120,
                      height: 2,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
