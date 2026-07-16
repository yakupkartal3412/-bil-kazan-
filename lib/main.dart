import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/audio_provider.dart';
import 'providers/multiplayer_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/constants.dart';

import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDKn6XaOflGRKWRcsHihwlRj2u_XKsyGZw",
        authDomain: "milyarder-test-oyunu.firebaseapp.com",
        projectId: "milyarder-test-oyunu",
        storageBucket: "milyarder-test-oyunu.firebasestorage.app",
        messagingSenderId: "752758648467",
        appId: "1:752758648467:web:468a7e29dfbb9373b7e766",
        measurementId: "G-SBEK6PESRL",
      ),
    );
  } else {
    // Android için (google-services.json kullanır)
    await Firebase.initializeApp();
  }
  
  if (!kIsWeb) {
    AdService().initialize();
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AudioProvider(), lazy: false),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => MultiplayerProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Milyarder Trivia Test Oyunu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
