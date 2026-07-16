import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Millionaire Theme Colors
  static Color darkBackground = const Color(0xFF0D0D36); 
  static Color lightBackground = const Color(0xFF2A2A72); 
  
  static Color boxFill = const Color(0xFF000000); 
  static Color boxBorder = const Color(0xFF0055FF); 
  static Color boxHighlight = const Color(0xFFFF9900); 
  static Color boxCorrect = const Color(0xFF00FF00); 
  
  static Color textGold = const Color(0xFFFFCC00); 
  static Color textWhite = Colors.white;
  
  static Color ladderText = const Color(0xFFFF9900);
  static Color ladderCurrentBg = const Color(0xFFFF6600); 
  
  // Legacy Aliases for Home/Result Screens
  static Color primary = const Color(0xFF0D0D36);
  static Color primaryVariant = const Color(0xFF2A2A72);
  static Color secondary = const Color(0xFFFF9900);
  static Color accent = const Color(0xFF00FF00);
  static Color error = const Color(0xFFFF1744);
  static Color background = const Color(0xFF0D0D36);
  static Color surface = const Color(0xFF1A1A5A);
  static Color darkText = const Color(0xFF000000);
  static Color lightText = Colors.white;
  static Color greyText = Colors.grey;
  
  // New UI Redesign Colors
  static Color appPurpleBg = const Color(0xFF260D4D);
  static Color menuButtonBg = const Color(0xFF0A1128); 
  static Color menuButtonBorder = const Color(0xFF00E5FF); 
  static Color rankRed = const Color(0xFFE60000); 
  
  static LinearGradient goldGradient = const LinearGradient(
    colors: [Color(0xFFFFE000), Color(0xFFFFA500)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  static LinearGradient backgroundGradient = const LinearGradient(
    colors: [Color(0xFF2A2A72), Color(0xFF0D0D36)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static LinearGradient buttonGradient = const LinearGradient(
    colors: [Color(0xFFFFCC00), Color(0xFFFF9900)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static void applyTheme(String themeName) {
    if (themeName == 'Karanlık Mod') {
      darkBackground = const Color(0xFF121212);
      lightBackground = const Color(0xFF2C2C2C);
      appPurpleBg = const Color(0xFF000000);
      menuButtonBg = const Color(0xFF1A1A1A);
      menuButtonBorder = const Color(0xFF00E5FF);
      boxBorder = const Color(0xFF00E5FF);
      backgroundGradient = const LinearGradient(colors: [Color(0xFF2C2C2C), Color(0xFF121212)], begin: Alignment.topCenter, end: Alignment.bottomCenter);
    } else if (themeName == 'Okyanus') {
      darkBackground = const Color(0xFF001524);
      lightBackground = const Color(0xFF002B4A);
      appPurpleBg = const Color(0xFF001F36);
      menuButtonBg = const Color(0xFF00182B);
      menuButtonBorder = const Color(0xFF00D4FF);
      boxBorder = const Color(0xFF00D4FF);
      backgroundGradient = const LinearGradient(colors: [Color(0xFF002B4A), Color(0xFF001524)], begin: Alignment.topCenter, end: Alignment.bottomCenter);
    } else if (themeName == 'Matrix') {
      darkBackground = const Color(0xFF001A00);
      lightBackground = const Color(0xFF003300);
      appPurpleBg = const Color(0xFF001100);
      menuButtonBg = const Color(0xFF002200);
      menuButtonBorder = const Color(0xFF00FF41);
      boxBorder = const Color(0xFF00FF41);
      backgroundGradient = const LinearGradient(colors: [Color(0xFF003300), Color(0xFF001A00)], begin: Alignment.topCenter, end: Alignment.bottomCenter);
    } else if (themeName == 'Gün Batımı') {
      darkBackground = const Color(0xFF3D0C02);
      lightBackground = const Color(0xFF5A1405);
      appPurpleBg = const Color(0xFF2D0901);
      menuButtonBg = const Color(0xFF1F0601);
      menuButtonBorder = const Color(0xFFFF6B35);
      boxBorder = const Color(0xFFFF6B35);
      backgroundGradient = const LinearGradient(colors: [Color(0xFF5A1405), Color(0xFF3D0C02)], begin: Alignment.topCenter, end: Alignment.bottomCenter);
    } else if (themeName == 'Neon Mor') {
      darkBackground = const Color(0xFF1A0033);
      lightBackground = const Color(0xFF330066);
      appPurpleBg = const Color(0xFF110022);
      menuButtonBg = const Color(0xFF0D001A);
      menuButtonBorder = const Color(0xFFBF00FF);
      boxBorder = const Color(0xFFBF00FF);
      backgroundGradient = const LinearGradient(colors: [Color(0xFF330066), Color(0xFF1A0033)], begin: Alignment.topCenter, end: Alignment.bottomCenter);
    } else if (themeName == 'Altın') {
      darkBackground = const Color(0xFF1C1800);
      lightBackground = const Color(0xFF3B3300);
      appPurpleBg = const Color(0xFF1A1600);
      menuButtonBg = const Color(0xFF141000);
      menuButtonBorder = const Color(0xFFFFD700);
      boxBorder = const Color(0xFFFFD700);
      backgroundGradient = const LinearGradient(colors: [Color(0xFF3B3300), Color(0xFF1C1800)], begin: Alignment.topCenter, end: Alignment.bottomCenter);
    } else if (themeName == 'Kızıl Ateş') {
      darkBackground = const Color(0xFF2D0000);
      lightBackground = const Color(0xFF4A0000);
      appPurpleBg = const Color(0xFF1F0000);
      menuButtonBg = const Color(0xFF140000);
      menuButtonBorder = const Color(0xFFFF3333);
      boxBorder = const Color(0xFFFF3333);
      backgroundGradient = const LinearGradient(colors: [Color(0xFF4A0000), Color(0xFF2D0000)], begin: Alignment.topCenter, end: Alignment.bottomCenter);
    } else if (themeName == 'Kutup Gecesi') {
      darkBackground = const Color(0xFF001122);
      lightBackground = const Color(0xFF002244);
      appPurpleBg = const Color(0xFF000811);
      menuButtonBg = const Color(0xFF000B1A);
      menuButtonBorder = const Color(0xFF00FFCC);
      boxBorder = const Color(0xFF00FFCC);
      backgroundGradient = const LinearGradient(colors: [Color(0xFF002244), Color(0xFF001122)], begin: Alignment.topCenter, end: Alignment.bottomCenter);
    } else {
      // Varsayılan Tema (Mor/Neon)
      darkBackground = const Color(0xFF0D0D36); 
      lightBackground = const Color(0xFF2A2A72); 
      appPurpleBg = const Color(0xFF260D4D);
      menuButtonBg = const Color(0xFF0A1128); 
      menuButtonBorder = const Color(0xFF00E5FF); 
      boxBorder = const Color(0xFF0055FF); 
      backgroundGradient = const LinearGradient(colors: [Color(0xFF2A2A72), Color(0xFF0D0D36)], begin: Alignment.topCenter, end: Alignment.bottomCenter);
    }
    
    // Legacy aliases
    primary = darkBackground;
    primaryVariant = lightBackground;
    background = darkBackground;
    surface = lightBackground;
  }
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.darkBackground,
      scaffoldBackgroundColor: AppColors.darkBackground, 
      textTheme: GoogleFonts.robotoTextTheme().apply(
        bodyColor: AppColors.textWhite,
        displayColor: AppColors.textWhite,
      ),
    );
  }
}
