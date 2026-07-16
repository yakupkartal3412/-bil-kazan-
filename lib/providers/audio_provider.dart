import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class AudioProvider extends ChangeNotifier with WidgetsBindingObserver {
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  
  Timer? _duckTimer;

  bool _isMusicEnabled = true;
  bool _isSfxEnabled = true;
  bool _isVibrationEnabled = true;

  bool get isMusicEnabled => _isMusicEnabled;
  bool get isSfxEnabled => _isSfxEnabled;
  bool get isVibrationEnabled => _isVibrationEnabled;

  AudioProvider() {
    WidgetsBinding.instance.addObserver(this);
    _initPrefs();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.hidden) {
      if (_isMusicEnabled) {
        _bgmPlayer.pause();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_isMusicEnabled) {
        _bgmPlayer.resume();
      }
    }
  }

  Future<void> _initPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isMusicEnabled = prefs.getBool('isMusicEnabled') ?? true;
    _isSfxEnabled = prefs.getBool('isSfxEnabled') ?? true;
    _isVibrationEnabled = prefs.getBool('isVibrationEnabled') ?? true;
    // Configure BGM player for looping
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    
    if (_isMusicEnabled) {
      await playBgm();
    }
    notifyListeners();
  }

  Future<void> playBgm() async {
    if (!_isMusicEnabled) return;
    try {
      await _bgmPlayer.play(AssetSource('audio/bg_music.mp3'), volume: 0.15);
    } catch (e) {
      // ignore: avoid_print
      print('BGM Play Error: $e');
    }
  }

  Future<void> pauseBgm() async {
    await _bgmPlayer.pause();
  }

  Future<void> resumeBgm() async {
    if (!_isMusicEnabled) return;
    try {
      // Önce volume'u normale getir
      await _bgmPlayer.setVolume(0.15);
      final state = _bgmPlayer.state;
      if (state == PlayerState.paused) {
        await _bgmPlayer.resume();
      } else if (state != PlayerState.playing) {
        // Durmuşsa baştan başlat
        await _bgmPlayer.play(AssetSource('audio/bg_music.mp3'), volume: 0.15);
      }
    } catch (e) {
      debugPrint('BGM Resume Error: $e');
    }
  }

  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
  }

  Future<void> duckBgmTemporarily() async {
    if (!_isMusicEnabled) return;
    
    // Sadece sesi kıs — müziği durdurmuyoruz ki baştan başlamasın
    await _bgmPlayer.setVolume(0.02);
    
    // Önceki timer varsa iptal et ki üst üste binmesin
    _duckTimer?.cancel();
    
    // 5 saniye sonra sesi geri aç
    _duckTimer = Timer(const Duration(seconds: 5), () async {
      await resumeBgm();
    });
  }

  Future<void> playSfx(String fileName) async {
    if (_isVibrationEnabled) {
      if (fileName.contains('wrong')) {
        Vibration.vibrate(duration: 250, amplitude: 255);
      } else if (fileName.contains('correct') || fileName.contains('click') || fileName.contains('tick')) {
        Vibration.vibrate(duration: 50, amplitude: 100);
      }
    }

    if (!_isSfxEnabled) return;
    try {
      double vol = 1.0;
      if (fileName.contains('correct')) {
        vol = 0.15; // Soruyu bilme sesini daha da kıs
      }
      await _sfxPlayer.play(AssetSource('audio/$fileName'), volume: vol);
    } catch (e) {
      // ignore: avoid_print
      print('SFX Play Error: $e');
    }
  }

  Future<void> toggleMusic() async {
    _isMusicEnabled = !_isMusicEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isMusicEnabled', _isMusicEnabled);
    
    if (_isMusicEnabled) {
      playBgm();
    } else {
      stopBgm();
    }
    notifyListeners();
  }

  Future<void> toggleSfx() async {
    _isSfxEnabled = !_isSfxEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSfxEnabled', _isSfxEnabled);
    notifyListeners();
  }

  Future<void> toggleVibration() async {
    _isVibrationEnabled = !_isVibrationEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isVibrationEnabled', _isVibrationEnabled);
    notifyListeners();
  }
}
