import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../services/ad_service.dart';
import 'dart:math' as dart_math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question.dart';
import '../utils/constants.dart';
import 'package:milyarder_test_oyunu/services/referral_service.dart';

enum GameMode { classic, endless, event }

class QuizProvider extends ChangeNotifier {
  static const String _coinsKey = 'total_coins';
  static const String _moneyKey = 'total_money';
  static const String _highScoresKey = 'high_scores';
  static const String _gamesPlayedKey = 'total_games_played';
  static const String _correctAnswersKey = 'total_correct_answers';
  static const String _totalAnsweredKey = 'total_questions_answered';
  static const String _unlockedAvatarsKey = 'unlocked_avatars';
  static const String _activeAvatarKey = 'active_avatar';
  static const String _unlockedThemesKey = 'unlocked_themes';
  static const String _activeThemeKey = 'active_theme';
  static const String _userNameKey = 'user_name';
  
  static const String _lastPlayedDateKey = 'last_played_date';
  static const String _dailyGamesKey = 'daily_games';
  static const String _dailyCorrectKey = 'daily_correct';
  static const String _dailyJokersKey = 'daily_jokers';
  static const String _claimedMissionsKey = 'claimed_missions';
  static const String _claimedAchievementsKey = 'claimed_achievements';
  static const String _lastSpinDateKey = 'last_spin_date';
  static const String _lastAdSpinDateKey = 'last_ad_spin_date';
  static const String _localDuelScoresKey = 'local_duel_scores';
  static const String _lastDuelP1NameKey = 'last_duel_p1_name';
  static const String _lastDuelP2NameKey = 'last_duel_p2_name';
  static const String _lastDuelP1SeriesKey = 'last_duel_p1_series';
  static const String _lastDuelP2SeriesKey = 'last_duel_p2_series';
  static const String _seenClassicIdsKey = 'seen_classic_ids';
  static const String _seenEndlessIdsKey = 'seen_endless_ids';
  static const String _seenDuelIdsKey = 'seen_duel_ids';
  static const String _seenEventIdsKey = 'seen_event_ids';
  static const String _cycleStartDateKey = 'cycle_start_date';
  static const String _cycleStatusKey = 'cycle_status';
  static const String _hasClaimedDailyLoginKey = 'has_claimed_daily_login';
  
  static const String _weeklyScoreKey = 'weekly_score';
  static const String _lastWeeklyResetDateKey = 'lastWeeklyResetDate';
  static const String _pastWinnersKey = 'past_winners';
  static const String _deviceIdKey = 'device_id';
  static const String _roomCardsKey = 'room_cards';
  
  String _deviceId = '';
  String get deviceId => _deviceId;
  
  int _totalCoins = 0;
  int _totalMoney = 0;
  int _roomCards = 1; // Başlangıç hediyesi 1 kart
  int get roomCards => _roomCards;
  List<String> _highScores = [];
  int _totalGamesPlayed = 0;
  int _gamesPlayedSession = 0;
  int _totalCorrectAnswers = 0;
  int _totalQuestionsAnswered = 0;
  
  List<String> _unlockedAvatars = [];
  String _activeAvatar = 'default_avatar.png';
  List<String> _unlockedThemes = ['Varsayılan Tema'];
  String _activeTheme = 'Varsayılan Tema';
  String _userName = 'Kullanıcı 1';

  String _lastPlayedDate = '';
  String _lastSpinDate = '';
  String _lastAdSpinDate = '';
  int _dailyGamesPlayed = 0;
  int _dailyCorrectAnswers = 0;
  int _dailyJokersUsed = 0;
  List<String> _claimedMissions = [];
  List<String> _claimedAchievements = [];
  Map<String, int> _localDuelScores = {};
  
  String _cycleStartDate = '';
  List<int> _cycleStatus = [1, 0, 0, 0, 0, 0, 0];
  String _lastLoginDate = '';
  bool _hasClaimedDailyLogin = false;
  
  String _lastDuelP1Name = 'KULLANICI 1';
  String _lastDuelP2Name = 'KULLANICI 2';
  int _lastDuelP1Series = 0;
  int _lastDuelP2Series = 0;
  
  int _weeklyScore = 0;
  String _lastWeeklyResetDate = '';
  List<String> _pastWinners = [];
  String _weeklyRewardMessage = '';

  int get totalCoins => _totalCoins;
  int get totalMoney => _totalMoney;
  List<String> get highScores => _highScores;
  int get totalGamesPlayed => _totalGamesPlayed;
  int get totalCorrectAnswers => _totalCorrectAnswers;
  int get totalQuestionsAnswered => _totalQuestionsAnswered;
  List<String> get unlockedAvatars => _unlockedAvatars;
  String get activeAvatar => _activeAvatar;
  List<String> get unlockedThemes => _unlockedThemes;
  String get activeTheme => _activeTheme;
  String get userName => _userName;
  Map<String, int> get localDuelScores => _localDuelScores;
  String get lastSpinDate => _lastSpinDate;
  String get lastAdSpinDate => _lastAdSpinDate;
  
  String get lastDuelP1Name => _lastDuelP1Name;
  String get lastDuelP2Name => _lastDuelP2Name;
  int get lastDuelP1Series => _lastDuelP1Series;
  int get lastDuelP2Series => _lastDuelP2Series;
  
  int get weeklyScore => _weeklyScore;
  List<String> get pastWinners => _pastWinners;
  String get weeklyRewardMessage => _weeklyRewardMessage;
  void clearWeeklyRewardMessage() { _weeklyRewardMessage = ''; notifyListeners(); }

  int get iqLevel {
    if (_totalQuestionsAnswered == 0) return 50; // Başlangıç IQ'su
    
    double winRate = _totalCorrectAnswers / _totalQuestionsAnswered;
    
    // Tecrübe bonusu logaritmik olarak artsın (Örn: 20 soru -> ~9, 500 soru -> ~44)
    double expBonus = dart_math.sqrt(_totalQuestionsAnswered) * 1.2;
    if (expBonus > 70) expBonus = 70;
    
    // Kazanma oranı ağırlığı tecrübe arttıkça artsın (max 1.0)
    double winRateWeight = _totalQuestionsAnswered / 1000;
    if (winRateWeight > 1.0) winRateWeight = 1.0;
    
    // Minimum 20 soru çözmeden winRate bonusu çok etkilemesin, ve max bonus 40 olsun (eskiden 80'di)
    double winRateBonus = 0;
    if (_totalQuestionsAnswered >= 20) {
      winRateBonus = winRate * 40 * winRateWeight;
    }
    
    // Maksimum IQ 160 (50 taban + 70 xp + 40 kazanma oranı)
    int iq = (50 + expBonus + winRateBonus).toInt();
    if (iq > 160) iq = 160;
    if (iq < 50) iq = 50;
    return iq;
  }

  String get userTitle {
    int iq = iqLevel;
    if (iq < 80) return 'Çömez';
    if (iq < 100) return 'Çırak';
    if (iq < 120) return 'Öğrenci';
    if (iq < 135) return 'Bilgin';
    if (iq < 148) return 'Profesör';
    if (iq < 158) return 'Dahi';
    return 'Efsane';
  }
  
  int get dailyGamesPlayed => _dailyGamesPlayed;
  int get dailyCorrectAnswers => _dailyCorrectAnswers;
  int get dailyJokersUsed => _dailyJokersUsed;
  List<String> get claimedMissions => _claimedMissions;
  List<String> get claimedAchievements => _claimedAchievements;
  Set<String> get seenClassicIds => _seenClassicIds;
  String get cycleStartDate => _cycleStartDate;
  List<int> get cycleStatus => _cycleStatus;
  bool get hasClaimedDailyLogin => _hasClaimedDailyLogin;

  bool get canSpinWheel {
    String today = DateTime.now().toString().split(' ')[0];
    return _lastSpinDate != today;
  }

  bool get hasUnclaimedDailyMissions {
    String today = DateTime.now().toString().split(' ')[0];
    if (_lastPlayedDate != today) return false;

    if (_dailyGamesPlayed >= 1 && !_claimedMissions.contains('play_1_game')) return true;
    if (_dailyCorrectAnswers >= 5 && !_claimedMissions.contains('answer_5_questions')) return true;
    if (_dailyJokersUsed >= 1 && !_claimedMissions.contains('use_1_joker')) return true;
    if (_dailyCorrectAnswers >= 10 && !_claimedMissions.contains('answer_10_questions')) return true;
    if (_dailyGamesPlayed >= 3 && !_claimedMissions.contains('play_3_games')) return true;
    return false;
  }

  bool get hasUnclaimedAchievements {
    // 1. Bilgi Küpü (totalCorrectAnswers) - 25 Levels
    final correctTargets = [1, 5, 10, 25, 50, 100, 250, 500, 750, 1000, 1500, 2000, 3000, 4000, 5000, 7500, 10000, 12500, 15000, 20000, 25000, 30000, 40000, 50000, 100000];
    for (int i = 0; i < 25; i++) {
      if (_totalCorrectAnswers >= correctTargets[i] && !_claimedAchievements.contains('Bilgi Küpü ${i + 1}')) return true;
    }

    // 2. Tecrübe (totalGamesPlayed) - 25 Levels
    final gamesTargets = [1, 5, 10, 20, 30, 50, 75, 100, 150, 200, 300, 400, 500, 750, 1000, 1250, 1500, 2000, 2500, 3000, 4000, 5000, 6000, 7500, 10000];
    for (int i = 0; i < 25; i++) {
      if (_totalGamesPlayed >= gamesTargets[i] && !_claimedAchievements.contains('Tecrübe ${i + 1}')) return true;
    }

    // 3. Sorik (totalQuestionsAnswered) - 25 Levels
    final answeredTargets = [5, 10, 25, 50, 100, 250, 500, 1000, 1500, 2000, 3000, 4000, 5000, 7500, 10000, 12500, 15000, 20000, 25000, 30000, 40000, 50000, 75000, 100000, 150000];
    for (int i = 0; i < 25; i++) {
      if (_totalQuestionsAnswered >= answeredTargets[i] && !_claimedAchievements.contains('Sorik ${i + 1}')) return true;
    }

    // 4. Zenginlik (totalMoney) - 25 Levels
    final moneyTargets = [
      1000, 5000, 10000, 25000, 50000, 100000, 250000, 500000, 1000000, 2500000, 
      5000000, 7500000, 10000000, 15000000, 20000000, 25000000, 30000000, 40000000, 
      50000000, 75000000, 100000000, 250000000, 500000000, 750000000, 1000000000
    ];
    for (int i = 0; i < 25; i++) {
      if (_totalMoney >= moneyTargets[i] && !_claimedAchievements.contains('Zenginlik ${i + 1}')) return true;
    }

    return false;
  }

  final List<String> prizeLadder = [
    "100", "200", "300", "500", "1.000",
    "2.000", "4.000", "8.000", "16.000", "32.000",
    "64.000", "125.000", "250.000", "500.000", "1 MİLYON"
  ];

  List<Question> _easyQuestions = [];
  List<Question> _mediumQuestions = [];
  List<Question> _hardQuestions = [];
  List<Question> _eventQuestions = [];
  bool _isDataLoaded = false;
  bool get isDataLoaded => _isDataLoaded;

  // Klasik mod ve Endless mod için AYRI seen setleri — birbirini etkilemesin
  Set<String> _seenClassicIds = {};
  Set<String> _seenEndlessIds = {};
  Set<String> _seenDuelIds = {};
  Set<String> _seenEventIds = {};

  List<Question> _currentQuestions = [];
  int _currentQuestionIndex = 0;
  bool _isAnswered = false;
  bool _isSuspense = false;
  
  VoidCallback? onTick;
  VoidCallback? onTimeOut;
  int? _selectedOptionIndex;
  
  int _timeLeft = 20;
  Timer? _timer;

  GameMode _gameMode = GameMode.classic;
  GameMode get gameMode => _gameMode;
  
  String? _currentEventCategory;
  String? get currentEventCategory => _currentEventCategory;

  bool _usedFiftyFifty = false;
  bool _usedPhone = false;
  bool _usedAudience = false;
  bool _usedSkip = false;
  List<int> _hiddenOptions = [];

  bool get usedFiftyFifty => _usedFiftyFifty;
  bool get usedPhone => _usedPhone;
  bool get usedAudience => _usedAudience;
  bool get usedSkip => _usedSkip;
  List<int> get hiddenOptions => _hiddenOptions;

  List<Question> get currentQuestions => _currentQuestions;
  int get currentQuestionIndex => _currentQuestionIndex;
  bool get isAnswered => _isAnswered;
  bool get isSuspense => _isSuspense;
  int? get selectedOptionIndex => _selectedOptionIndex;
  int get timeLeft => _timeLeft;

  Question get currentQuestion => _currentQuestions[_currentQuestionIndex];
  
  bool get isLastQuestion {
    if (_gameMode == GameMode.endless) {
      return false;
    } else if (_gameMode == GameMode.event) {
      return _currentQuestionIndex >= 29; // 30 questions
    }
    return _currentQuestionIndex >= 14;
  }
  
  int get score => _currentQuestionIndex;

  QuizProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _totalCoins = prefs.getInt(_coinsKey) ?? 0;
    _totalMoney = prefs.getInt(_moneyKey) ?? 0;
    _roomCards = prefs.getInt(_roomCardsKey) ?? 1; // Default 1 kart
    _totalGamesPlayed = prefs.getInt(_gamesPlayedKey) ?? 0;
    _totalCorrectAnswers = prefs.getInt(_correctAnswersKey) ?? 0;
    _totalQuestionsAnswered = prefs.getInt(_totalAnsweredKey) ?? 0;
    _unlockedAvatars = prefs.getStringList(_unlockedAvatarsKey) ?? [];
    _activeAvatar = prefs.getString(_activeAvatarKey) ?? 'default_avatar.png';
    if (_activeAvatar == 'bell_avatar.png' && !_unlockedAvatars.contains('bell_avatar.png')) {
      _activeAvatar = 'default_avatar.png';
    }
    _unlockedThemes = prefs.getStringList(_unlockedThemesKey) ?? ['Varsayılan Tema'];
    _activeTheme = prefs.getString(_activeThemeKey) ?? 'Varsayılan Tema';
    
    String? storedName = prefs.getString(_userNameKey);
    if (storedName == null) {
      _userName = 'Kullanıcı ${dart_math.Random().nextInt(9000) + 1000}';
      prefs.setString(_userNameKey, _userName);
    } else {
      _userName = storedName;
    }
    
    String? storedDeviceId = prefs.getString(_deviceIdKey);
    if (storedDeviceId == null) {
      _deviceId = 'dev_${DateTime.now().millisecondsSinceEpoch}_${dart_math.Random().nextInt(100000)}';
      prefs.setString(_deviceIdKey, _deviceId);
    } else {
      _deviceId = storedDeviceId;
    }
    
    _activeTheme = prefs.getString(_activeThemeKey) ?? 'mor';
    _lastPlayedDate = prefs.getString(_lastPlayedDateKey) ?? '';
    _lastSpinDate = prefs.getString(_lastSpinDateKey) ?? '';
    _lastAdSpinDate = prefs.getString(_lastAdSpinDateKey) ?? '';
    _dailyGamesPlayed = prefs.getInt(_dailyGamesKey) ?? 0;
    _dailyCorrectAnswers = prefs.getInt(_dailyCorrectKey) ?? 0;
    _dailyJokersUsed = prefs.getInt(_dailyJokersKey) ?? 0;
    _claimedMissions = prefs.getStringList(_claimedMissionsKey) ?? [];
    _claimedAchievements = prefs.getStringList(_claimedAchievementsKey) ?? [];
    
    _checkDailyReset();
    
    final savedScores = prefs.getStringList(_highScoresKey) ?? [];
    _highScores = savedScores.where((s) => s.startsWith('{')).toList();

    String savedLocalDuels = prefs.getString(_localDuelScoresKey) ?? '{}';
    try {
      _localDuelScores = Map<String, int>.from(jsonDecode(savedLocalDuels));
    } catch (e) {
      _localDuelScores = {};
    }
    
    _lastDuelP1Name = prefs.getString(_lastDuelP1NameKey) ?? 'KULLANICI 1';
    _lastDuelP2Name = prefs.getString(_lastDuelP2NameKey) ?? 'KULLANICI 2';
    _lastDuelP1Series = prefs.getInt(_lastDuelP1SeriesKey) ?? 0;
    _lastDuelP2Series = prefs.getInt(_lastDuelP2SeriesKey) ?? 0;
    _seenClassicIds = (prefs.getStringList(_seenClassicIdsKey) ?? []).toSet();
    _seenEndlessIds = (prefs.getStringList(_seenEndlessIdsKey) ?? []).toSet();
    _seenDuelIds = (prefs.getStringList(_seenDuelIdsKey) ?? []).toSet();
    _seenEventIds = (prefs.getStringList(_seenEventIdsKey) ?? []).toSet();
    
    // Eski format temizleme — metin tabanlı kayıtları sil
    if (_seenClassicIds.any((id) => id.length > 10)) {
      _seenClassicIds.clear();
      await prefs.remove(_seenClassicIdsKey);
    }
    if (_seenEndlessIds.any((id) => id.length > 10)) {
      _seenEndlessIds.clear();
      await prefs.remove(_seenEndlessIdsKey);
    }
    
    _cycleStartDate = prefs.getString(_cycleStartDateKey) ?? '';
    List<String> statusStrs = prefs.getStringList(_cycleStatusKey) ?? ['1','0','0','0','0','0','0'];
    _cycleStatus = statusStrs.map((s) => int.tryParse(s) ?? 0).toList();
    if (_cycleStatus.length != 7) _cycleStatus = [1, 0, 0, 0, 0, 0, 0];
    
    _lastLoginDate = prefs.getString('last_login_date_v2') ?? '';
    _hasClaimedDailyLogin = prefs.getBool(_hasClaimedDailyLoginKey) ?? false;
    
    _weeklyScore = prefs.getInt(_weeklyScoreKey) ?? 0;
    _lastWeeklyResetDate = prefs.getString(_lastWeeklyResetDateKey) ?? '';
    _pastWinners = prefs.getStringList(_pastWinnersKey) ?? [];

    try {
      final jsonString = await rootBundle.loadString('assets/questions.json');
      final List<dynamic> jsonMap = jsonDecode(jsonString);
      
      final allQuestions = jsonMap.map((q) => Question.fromJson(q)).toList();
      _easyQuestions = allQuestions.where((q) => q.difficulty == 1).toList();
      _mediumQuestions = allQuestions.where((q) => q.difficulty == 2).toList();
      _hardQuestions = allQuestions.where((q) => q.difficulty == 3).toList();
      
      try {
        final eventJsonString = await rootBundle.loadString('assets/event_questions.json');
        final List<dynamic> eventJsonMap = jsonDecode(eventJsonString);
        _eventQuestions = eventJsonMap.map((q) => Question.fromJson(q)).toList();
      } catch (e) {
        debugPrint('Error loading event questions: $e');
      }
      
      _isDataLoaded = true;
    } catch (e) {
      debugPrint('Error loading questions: $e');
    }

    _checkReferralRewards();
    _registerOrUpdateUserInFirebase();
    notifyListeners();
  }

  Future<void> _registerOrUpdateUserInFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final doc = await docRef.get();
        if (!doc.exists) {
          await docRef.set({
            'uid': user.uid,
            'userName': _userName,
            'avatar': _activeAvatar,
            'deviceId': _deviceId,
            'createdAt': FieldValue.serverTimestamp(),
            'lastLogin': FieldValue.serverTimestamp(),
            'isAnonymous': user.isAnonymous,
            'totalMoney': _totalMoney,
            'totalCoins': _totalCoins,
          });
        } else {
          await docRef.update({
            'lastLogin': FieldValue.serverTimestamp(),
            'userName': _userName,
            'avatar': _activeAvatar,
            'totalMoney': _totalMoney,
            'totalCoins': _totalCoins,
          });
        }
      }
    } catch (e) {
      debugPrint('Firebase register error: $e');
    }
  }

  Future<void> _checkReferralRewards() async {
    try {
      final referralService = ReferralService();
      int pendingReward = await referralService.calculateAndClaimPendingRewards();
      if (pendingReward > 0) {
        _totalCoins += pendingReward;
        _saveCoins();
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Referral error: $e");
    }
  }


  List<Question> get15MixedQuestions() {
    if (!_isDataLoaded) return [];
    final questions = [
      ..._getUnseenClassic(_easyQuestions, 5),
      ..._getUnseenClassic(_mediumQuestions, 5),
      ..._getUnseenClassic(_hardQuestions, 5),
    ];
    for (final q in questions) { _seenClassicIds.add(q.id); }
    _saveSeenQuestions();
    return questions;
  }

  Future<void> _saveSeenQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_seenClassicIdsKey, _seenClassicIds.toList());
    await prefs.setStringList(_seenEndlessIdsKey, _seenEndlessIds.toList());
    await prefs.setStringList(_seenDuelIdsKey, _seenDuelIds.toList());
    await prefs.setStringList(_seenEventIdsKey, _seenEventIds.toList());
  }

  // Klasik mod için: zorunlu difficulty ayrımıyla unseen soru seç
  List<Question> _getUnseenClassic(List<Question> pool, int count) {
    List<Question> unseen = pool.where((q) => !_seenClassicIds.contains(q.id)).toList();
    if (unseen.length < count) {
      // Bu zorluk seviyesindeki tüm sorular bitti — sadece bu pool'u sıfırla
      for (final q in pool) { _seenClassicIds.remove(q.id); }
      unseen = List.from(pool);
    }
    unseen.shuffle(dart_math.Random());
    return unseen.take(count).toList();
  }

  List<Question> getRandomQuestionsForDuel(int count) {
    if (!_isDataLoaded) return [];
    List<Question> allQ = [..._easyQuestions, ..._mediumQuestions, ..._hardQuestions];
    List<Question> unseen = allQ.where((q) => !_seenDuelIds.contains(q.id)).toList();
    if (unseen.length < count) {
      _seenDuelIds.clear();
      unseen = List.from(allQ);
    }
    unseen.shuffle(dart_math.Random());
    final selected = unseen.take(count).toList();
    for (final q in selected) { _seenDuelIds.add(q.id); }
    _saveSeenQuestions();
    return selected;
  }

  Future<void> updateUserName(String newName) async {
    if (newName.trim().isEmpty) return;
    _userName = newName.trim();
    
    _updateLeaderboardWithNewProfile(newName: _userName);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, _userName);
    notifyListeners();
  }

  Future<void> addLocalDuelScore(String playerName, int score) async {
    if (playerName.trim().isEmpty) return;
    _localDuelScores[playerName] = (_localDuelScores[playerName] ?? 0) + score;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localDuelScoresKey, jsonEncode(_localDuelScores));
    notifyListeners();
  }
  
  Future<void> saveLastDuelState(String p1Name, String p2Name, int p1Series, int p2Series) async {
    _lastDuelP1Name = p1Name;
    _lastDuelP2Name = p2Name;
    _lastDuelP1Series = p1Series;
    _lastDuelP2Series = p2Series;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastDuelP1NameKey, p1Name);
    await prefs.setString(_lastDuelP2NameKey, p2Name);
    await prefs.setInt(_lastDuelP1SeriesKey, p1Series);
    await prefs.setInt(_lastDuelP2SeriesKey, p2Series);
    notifyListeners();
  }

  Future<void> clearLocalDuelScores() async {
    _localDuelScores.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localDuelScoresKey);
    notifyListeners();
  }
  
  void _updateLeaderboardWithNewProfile({String? newName, String? newAvatar}) {
    bool changed = false;
    List<String> updatedScores = [];
    
    for (String scoreStr in _highScores) {
      try {
        Map<String, dynamic> scoreData = jsonDecode(scoreStr);
        if (newName != null) scoreData['userName'] = newName;
        if (newAvatar != null) scoreData['avatar'] = newAvatar;
        updatedScores.add(jsonEncode(scoreData));
        changed = true;
      } catch (e) {
        updatedScores.add(scoreStr);
      }
    }
    
    if (changed) {
      _highScores = updatedScores;
      _saveHighScores();
    }
  }

  Future<void> claimAchievement(String id, int reward) async {
    if (!_claimedAchievements.contains(id)) {
      _claimedAchievements.add(id);
      _totalCoins += reward;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_claimedAchievementsKey, _claimedAchievements);
      _saveCoins();
      notifyListeners();
    }
  }

  Future<void> _saveCoins() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_coinsKey, _totalCoins);
  }

  Future<void> _saveMoney() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_moneyKey, _totalMoney);
    await prefs.setInt(_weeklyScoreKey, _weeklyScore);
  }

  Future<void> buyRoomCard() async {
    if (_totalCoins >= 50) {
      _totalCoins -= 50;
      _roomCards++;
      final prefs = await SharedPreferences.getInstance();
      prefs.setInt(_coinsKey, _totalCoins);
      prefs.setInt(_roomCardsKey, _roomCards);
      notifyListeners();
    }
  }

  Future<void> useRoomCard() async {
    if (_roomCards > 0) {
      _roomCards--;
      final prefs = await SharedPreferences.getInstance();
      prefs.setInt(_roomCardsKey, _roomCards);
      notifyListeners();
    }
  }

  Future<void> giveFreeRoomCard() async {
    _roomCards++;
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_roomCardsKey, _roomCards);
    notifyListeners();
  }

  bool deductCoins(int amount) {
    if (_totalCoins >= amount) {
      _totalCoins -= amount;
      _saveCoins();
      notifyListeners();
      return true;
    }
    return false;
  }

  void addCoins(int amount) {
    _totalCoins += amount;
    _saveCoins();
    notifyListeners();
  }

  void addMoney(int amount) {
    _totalMoney += amount;
    _weeklyScore += amount;
    _saveMoney();
    notifyListeners();
  }

  Future<void> updateLastSpinDate() async {
    _lastSpinDate = DateTime.now().toString().split(' ')[0];
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_lastSpinDateKey, _lastSpinDate);
    notifyListeners();
  }

  Future<void> updateLastAdSpinDate() async {
    _lastAdSpinDate = DateTime.now().toString().split(' ')[0];
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_lastAdSpinDateKey, _lastAdSpinDate);
    notifyListeners();
  }

  Future<void> buyAvatar(String avatar, int cost) async {
    if (_totalCoins >= cost && !_unlockedAvatars.contains(avatar)) {
      _totalCoins -= cost;
      _unlockedAvatars.add(avatar);
      _activeAvatar = avatar;
      
      _updateLeaderboardWithNewProfile(newAvatar: _activeAvatar);
      
      _saveCoins();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_unlockedAvatarsKey, _unlockedAvatars);
      await prefs.setString(_activeAvatarKey, _activeAvatar);
      notifyListeners();
    }
  }

  Future<void> equipAvatar(String avatar) async {
    if (_unlockedAvatars.contains(avatar)) {
      _activeAvatar = avatar;
      
      _updateLeaderboardWithNewProfile(newAvatar: _activeAvatar);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activeAvatarKey, _activeAvatar);
      notifyListeners();
    }
  }

  Future<void> setActiveAvatar(String avatarPath) async {
    if (_unlockedAvatars.contains(avatarPath)) {
      _activeAvatar = avatarPath;
      
      _updateLeaderboardWithNewProfile(newAvatar: _activeAvatar);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activeAvatarKey, _activeAvatar);
      notifyListeners();
    }
  }

  Future<void> setActiveTheme(String theme) async {
    if (_unlockedThemes.contains(theme)) {
      _activeTheme = theme;
      AppColors.applyTheme(_activeTheme);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activeThemeKey, _activeTheme);
      notifyListeners();
    }
  }

  Future<bool> buyTheme(String theme, int price) async {
    if (_totalCoins >= price && !_unlockedThemes.contains(theme)) {
      if (deductCoins(price)) {
        _unlockedThemes.add(theme);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(_unlockedThemesKey, _unlockedThemes);
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  Future<void> checkDailyReset() async {
    await _checkDailyReset();
  }

  Future<void> resetAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _totalCoins = 0;
    _totalMoney = 0;
    _totalGamesPlayed = 0;
    _totalCorrectAnswers = 0;
    _totalQuestionsAnswered = 0;
    _unlockedAvatars = [];
    _activeAvatar = 'default_avatar.png';
    _unlockedThemes = ['Varsayılan Tema'];
    _activeTheme = 'Varsayılan Tema';
    _userName = 'Kullanıcı ${dart_math.Random().nextInt(9000) + 1000}';
    _highScores = [];
    _claimedAchievements = [];
    _claimedMissions = [];
    _dailyGamesPlayed = 0;
    _dailyCorrectAnswers = 0;
    _dailyJokersUsed = 0;
    notifyListeners();
  }

  Future<void> _checkDailyReset() async {
    String today = DateTime.now().toString().split(' ')[0];
    if (_lastPlayedDate != today) {
      _lastPlayedDate = today;
      _dailyGamesPlayed = 0;
      _dailyCorrectAnswers = 0;
      _dailyJokersUsed = 0;
      _claimedMissions = [];
      _saveDailyStats();
    }
    
    // 7-Day Cycle Check
    if (_lastLoginDate != today) {
      if (_cycleStartDate.isEmpty) {
        _cycleStartDate = today;
        _cycleStatus = [1, 0, 0, 0, 0, 0, 0];
        _hasClaimedDailyLogin = false;
      } else {
        DateTime startDate = DateTime.parse(_cycleStartDate);
        DateTime currentDate = DateTime.parse(today);
        int daysSinceStart = currentDate.difference(startDate).inDays;
        
        if (daysSinceStart >= 7) {
          // Reset cycle
          _cycleStartDate = today;
          _cycleStatus = [1, 0, 0, 0, 0, 0, 0];
          _hasClaimedDailyLogin = false;
        } else {
          // Update missed and available days
          for (int i = 0; i < daysSinceStart; i++) {
            if (_cycleStatus[i] == 1 || _cycleStatus[i] == 0) {
              _cycleStatus[i] = 3; // Missed
            }
          }
          if (_cycleStatus[daysSinceStart] == 0) {
            _cycleStatus[daysSinceStart] = 1; // Available today
          }
          _hasClaimedDailyLogin = _cycleStatus[daysSinceStart] == 2;
        }
      }
      
      _lastLoginDate = today;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cycleStartDateKey, _cycleStartDate);
      await prefs.setStringList(_cycleStatusKey, _cycleStatus.map((e) => e.toString()).toList());
      await prefs.setString('last_login_date_v2', _lastLoginDate);
      await prefs.setBool(_hasClaimedDailyLoginKey, _hasClaimedDailyLogin);
    }
    
    // Weekly Reset Check
    if (_lastWeeklyResetDate.isEmpty) {
      _lastWeeklyResetDate = today;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastWeeklyResetDateKey, _lastWeeklyResetDate);
    } else {
      DateTime lastReset = DateTime.parse(_lastWeeklyResetDate);
      DateTime now = DateTime.now();
      
      DateTime lastMonday = lastReset.subtract(Duration(days: lastReset.weekday - 1));
      DateTime thisMonday = now.subtract(Duration(days: now.weekday - 1));
      
      if (thisMonday.year != lastMonday.year || thisMonday.month != lastMonday.month || thisMonday.day != lastMonday.day) {
        await _processWeeklyRewards();
        _lastWeeklyResetDate = today;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_lastWeeklyResetDateKey, _lastWeeklyResetDate);
      }
    }
    
    _isDataLoaded = true;
    notifyListeners();
  }

  Future<void> _saveDailyStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastPlayedDateKey, _lastPlayedDate);
    await prefs.setInt(_dailyGamesKey, _dailyGamesPlayed);
    await prefs.setInt(_dailyCorrectKey, _dailyCorrectAnswers);
    await prefs.setInt(_dailyJokersKey, _dailyJokersUsed);
    await prefs.setStringList(_claimedMissionsKey, _claimedMissions);
  }

  Future<void> _processWeeklyRewards() async {
    List<Map<String, dynamic>> bots = [
      {'score': 500000, 'userName': 'A. Einstein', 'avatar': 'assets/images/einstein_avatar.png'},
      {'score': 250000, 'userName': 'N. Tesla', 'avatar': 'assets/images/tesla_avatar.png'},
      {'score': 125000, 'userName': 'I. Newton', 'avatar': 'assets/images/newton_avatar.png'},
      {'score': 60000, 'userName': 'M. Curie', 'avatar': 'assets/images/curie_avatar.png'},
      {'score': 30000, 'userName': 'Da Vinci', 'avatar': 'assets/images/davinci_avatar.png'},
      {'score': 15000, 'userName': 'S. Hawking', 'avatar': 'assets/images/hawking_avatar.png'},
      {'score': 10000, 'userName': 'Galileo', 'avatar': 'assets/images/galileo_avatar.png'},
      {'score': 5000, 'userName': 'Pisagor', 'avatar': 'assets/images/pythagoras_avatar.png'},
    ];
    for (int i = 1; i <= 20; i++) {
      int score = 5000 - (i * 200);
      if (score < 100) score = 100;
      bots.add({'score': score, 'userName': 'Oyuncu $i', 'avatar': 'assets/images/einstein_avatar.png'});
    }
    
    List<Map<String, dynamic>> allScores = List.from(bots);
    allScores.add({'score': _weeklyScore, 'userName': _userName, 'avatar': _activeAvatar, 'isUser': true});
    allScores.sort((a, b) => (b['score'] as num).compareTo(a['score'] as num));
    
    _pastWinners.clear();
    for (int i = 0; i < 10 && i < allScores.length; i++) {
      _pastWinners.add(jsonEncode(allScores[i]));
    }
    
    int userRank = allScores.indexWhere((s) => s['isUser'] == true) + 1;
    if (userRank == 1) {
      _totalCoins += 2500;
      _roomCards += 10;
      _weeklyRewardMessage = "Tebrikler! Geçen haftayı 1. sırada tamamladın ve 2.500 Elmas + 10 Oda Kartı kazandın! 🥇";
    } else if (userRank == 2) {
      _totalCoins += 1500;
      _roomCards += 5;
      _weeklyRewardMessage = "Tebrikler! Geçen haftayı 2. sırada tamamladın ve 1.500 Elmas + 5 Oda Kartı kazandın! 🥈";
    } else if (userRank == 3) {
      _totalCoins += 1000;
      _roomCards += 3;
      _weeklyRewardMessage = "Tebrikler! Geçen haftayı 3. sırada tamamladın ve 1.000 Elmas + 3 Oda Kartı kazandın! 🥉";
    } else if (userRank <= 10) {
      _totalCoins += 250;
      _roomCards += 1;
      _weeklyRewardMessage = "Geçen hafta ilk 10'a girmeyi başardın! Ödülün: 250 Elmas + 1 Oda Kartı. 🏆";
    }
    
    _weeklyScore = 0; 
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_pastWinnersKey, _pastWinners);
    await prefs.setInt(_weeklyScoreKey, _weeklyScore);
    await prefs.setInt(_coinsKey, _totalCoins);
  }

  Future<Map<String, int>?> claimDailyLoginReward(int dayIndex) async {
    if (dayIndex < 0 || dayIndex >= 7) return null;
    
    if (_cycleStatus[dayIndex] == 1 || _cycleStatus[dayIndex] == 3) {
      int baseMultiplier = dayIndex + 1;
      int diamondReward = dayIndex == 6 ? 150 : baseMultiplier * 15;
      int cashReward = dayIndex == 6 ? 150000 : baseMultiplier * 20000;
      
      _totalCoins += diamondReward;
      _totalMoney += cashReward;
      _weeklyScore += cashReward;
      
      _cycleStatus[dayIndex] = 2; // Claimed
      
      String today = DateTime.now().toString().split(' ')[0];
      if (_cycleStartDate.isNotEmpty) {
        int d = DateTime.parse(today).difference(DateTime.parse(_cycleStartDate)).inDays;
        if (d == dayIndex) {
          _hasClaimedDailyLogin = true;
        }
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hasClaimedDailyLoginKey, _hasClaimedDailyLogin);
      await prefs.setStringList(_cycleStatusKey, _cycleStatus.map((e) => e.toString()).toList());
      await prefs.setInt(_coinsKey, _totalCoins);
      await prefs.setInt(_moneyKey, _totalMoney);
      await prefs.setInt(_weeklyScoreKey, _weeklyScore);
      
      notifyListeners();
      return {'diamonds': diamondReward, 'cash': cashReward};
    }
    return null;
  }

  Future<void> claimMissionReward(String missionId, int reward) async {
    if (!_claimedMissions.contains(missionId)) {
      _claimedMissions.add(missionId);
      _totalCoins += reward;
      _saveCoins();
      _saveDailyStats();
      notifyListeners();
    }
  }

  void startEventGame(String categoryName, List<String> keywords) {
    if (!_isDataLoaded) return;
    _checkDailyReset();
    
    _currentQuestionIndex = 0;
    _currentMatchDiamonds = 0;
    _guaranteedDiamonds = 0;
    
    _fiftyFiftyUses = 0;
    _phoneUses = 0;
    _audienceUses = 0;
    _skipUses = 0;
    
    _usedFiftyFifty = false;
    _usedPhone = false;
    _usedAudience = false;
    _usedSkip = false;
    _skipUsedThisQuestion = false;

    _gameMode = GameMode.event;
    _currentEventCategory = categoryName;

    List<Question> matching = _eventQuestions.where((q) {
      for (var kw in keywords) {
        if (q.category.toLowerCase().contains(kw.toLowerCase())) return true;
      }
      return false;
    }).toList();
    
    // Yalnızca henüz görülmemiş olanları filtrele
    List<Question> unseen = matching.where((q) => !_seenEventIds.contains(q.id)).toList();
    
    // Eğer 30'dan az unseen soru kaldıysa, o kategori için seen listesini sıfırla
    if (unseen.length < 30) {
      for (var q in matching) {
        _seenEventIds.remove(q.id);
      }
      unseen = matching.toList();
      _saveSeenQuestions();
    }
    
    unseen.shuffle();
    if (unseen.length >= 30) {
      _currentQuestions = unseen.sublist(0, 30);
    } else {
      _currentQuestions = unseen;
    }
    
    // Seçilenleri seen'e ekle
    for (var q in _currentQuestions) {
      _seenEventIds.add(q.id);
    }
    _saveSeenQuestions();
    
    _isAnswered = false;
    _isSuspense = false;
    _selectedOptionIndex = null;
    _hiddenOptions = [];
    
    _startTimer();
    notifyListeners();
  }

  void startNewGame({GameMode mode = GameMode.classic}) {
    if (!_isDataLoaded) return;
    
    _checkDailyReset();
    
    _currentQuestionIndex = 0;
    _currentMatchDiamonds = 0;
    _guaranteedDiamonds = 0;
    
    _fiftyFiftyUses = 0;
    _phoneUses = 0;
    _audienceUses = 0;
    _skipUses = 0;

    _fiftyFiftyUsedThisQuestion = false;
    _phoneUsedThisQuestion = false;
    _audienceUsedThisQuestion = false;
    _skipUsedThisQuestion = false;

    _gameMode = mode;

    if (mode == GameMode.classic) {
      // Klasik mod: her zorluktan 5 soru, ayrı classic seen set kullan
      _currentQuestions = [
        ..._getUnseenClassic(_easyQuestions, 5),
        ..._getUnseenClassic(_mediumQuestions, 5),
        ..._getUnseenClassic(_hardQuestions, 5),
      ];
      // Hepsini classic seen'e ekle
      for (final q in _currentQuestions) { _seenClassicIds.add(q.id); }
    } else {
      // Endless mod: ayrı endless seen set kullan
      final unseenEasy = _easyQuestions.where((q) => !_seenEndlessIds.contains(q.id)).toList()..shuffle();
      final unseenMedium = _mediumQuestions.where((q) => !_seenEndlessIds.contains(q.id)).toList()..shuffle();
      final unseenHard = _hardQuestions.where((q) => !_seenEndlessIds.contains(q.id)).toList()..shuffle();
      
      _currentQuestions = [...unseenEasy, ...unseenMedium, ...unseenHard];
      
      if (_currentQuestions.isEmpty) {
        // Tüm sorular görüldü, sıfırla
        _seenEndlessIds.clear();
        _currentQuestions = [
          ..._easyQuestions..shuffle(),
          ..._mediumQuestions..shuffle(),
          ..._hardQuestions..shuffle()
        ];
      }
      // Hepsini endless seen'e ekle
      for (final q in _currentQuestions) { _seenEndlessIds.add(q.id); }
    }
    _saveSeenQuestions();
    _isAnswered = false;
    _isSuspense = false;
    _totalGamesPlayed++;
    _dailyGamesPlayed++;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt(_gamesPlayedKey, _totalGamesPlayed);
    });
    _saveDailyStats();
    _selectedOptionIndex = null;
    
    _usedFiftyFifty = false;
    _usedPhone = false;
    _usedAudience = false;
    _usedSkip = false;
    _hiddenOptions = [];
    
    _startTimer();
    notifyListeners();
  }
  
  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 20;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        _timeLeft--;
        if (_timeLeft <= 5 && _timeLeft > 0) {
          onTick?.call();
        }
        notifyListeners();
      } else {
        _timer?.cancel();
        _isAnswered = true;
        _selectedOptionIndex = -1; 
        onTimeOut?.call();
        notifyListeners();
      }
    });
  }

  int _fiftyFiftyUses = 0;
  int _phoneUses = 0;
  int _audienceUses = 0;
  int _skipUses = 0;

  bool _fiftyFiftyUsedThisQuestion = false;
  bool _phoneUsedThisQuestion = false;
  bool _audienceUsedThisQuestion = false;
  bool _skipUsedThisQuestion = false;

  int get fiftyFiftyUses => _fiftyFiftyUses;
  int get phoneUses => _phoneUses;
  int get audienceUses => _audienceUses;
  int get skipUses => _skipUses;

  bool get fiftyFiftyUsedThisQuestion => _fiftyFiftyUsedThisQuestion;
  bool get phoneUsedThisQuestion => _phoneUsedThisQuestion;
  bool get audienceUsedThisQuestion => _audienceUsedThisQuestion;
  bool get skipUsedThisQuestion => _skipUsedThisQuestion;

  int _currentMatchDiamonds = 0;
  int _guaranteedDiamonds = 0;

  int get currentMatchDiamonds => _currentMatchDiamonds;
  int get guaranteedDiamonds => _guaranteedDiamonds;

  bool useFiftyFifty() {
    if (_fiftyFiftyUsedThisQuestion || _isAnswered || _fiftyFiftyUses >= 2) return false;
    if (_fiftyFiftyUses > 0) {
      if (!deductCoins(25)) return false;
    }
    _fiftyFiftyUsedThisQuestion = true;
    _fiftyFiftyUses++;
    int correct = currentQuestion.correctOptionIndex;
    List<int> incorrects = [0, 1, 2, 3];
    incorrects.remove(correct);
    incorrects.shuffle();
    _hiddenOptions = [incorrects[0], incorrects[1]];
    notifyListeners();
    return true;
  }

  bool usePhone() {
    if (_phoneUsedThisQuestion || _isAnswered || _phoneUses >= 2) return false;
    if (_phoneUses > 0) {
      if (!deductCoins(25)) return false;
    }
    _phoneUsedThisQuestion = true;
    _phoneUses++;
    _dailyJokersUsed++;
    _saveDailyStats();
    notifyListeners();
    return true;
  }

  bool useAudience() {
    if (_audienceUsedThisQuestion || _isAnswered || _audienceUses >= 2) return false;
    if (_audienceUses > 0) {
      if (!deductCoins(25)) return false;
    }
    _audienceUsedThisQuestion = true;
    _audienceUses++;
    _dailyJokersUsed++;
    _saveDailyStats();
    notifyListeners();
    return true;
  }

  bool useSkipJoker() {
    // Bu soru zaten cevaplanmış veya bu soruda zaten kullanılmışsa çalışmaz
    if (_skipUsedThisQuestion || _isAnswered) return false;
    // Oyun başına 2 hak: ilk ücretsiz, ikinci 25 elmas
    if (_skipUses >= 2) return false;
    
    if (_skipUses > 0) {
      if (!deductCoins(25)) return false;
    }
    
    _skipUsedThisQuestion = true;
    _skipUses++;
    _dailyJokersUsed++;
    _saveDailyStats();
    
    _timer?.cancel();
    _selectedOptionIndex = currentQuestion.correctOptionIndex;
    _isAnswered = true;
    _handleCorrectAnswerDiamonds();
    notifyListeners();
    return true;
  }

  bool revive() {
    if (!_isAnswered || _selectedOptionIndex == currentQuestion.correctOptionIndex) return false;
    if (!deductCoins(500)) return false;
    
    _isAnswered = false;
    _selectedOptionIndex = null;
    _startTimer();
    notifyListeners();
    return true;
  }

  void skipGameOverAndFinish() {
    _finishGame();
  }

  void _handleCorrectAnswerDiamonds() {
    int earned = currentQuestion.difficulty == 1 ? 1 : (currentQuestion.difficulty == 2 ? 2 : 3);
    _currentMatchDiamonds += earned;
    if (_gameMode == GameMode.classic) {
      if (_currentQuestionIndex == 1) _guaranteedDiamonds = _currentMatchDiamonds; // 2nd question
      if (_currentQuestionIndex == 4) _guaranteedDiamonds = _currentMatchDiamonds;
      if (_currentQuestionIndex == 9) _guaranteedDiamonds = _currentMatchDiamonds;
    }
  }

  Future<void> submitAnswer(int selectedIndex) async {
    if (_isAnswered || _isSuspense || _hiddenOptions.contains(selectedIndex)) return; 
    
    _timer?.cancel(); 
    _selectedOptionIndex = selectedIndex;
    _isSuspense = true;
    notifyListeners();
    
    await Future.delayed(const Duration(seconds: 2));
    
    _isSuspense = false;
    _isAnswered = true;
    
    _totalQuestionsAnswered++;
    if (selectedIndex == currentQuestion.correctOptionIndex) {
      _totalCorrectAnswers++;
      _dailyCorrectAnswers++;
      _handleCorrectAnswerDiamonds();
    }
    
    _saveStats();
    _saveDailyStats();
    
    notifyListeners();
  }

  Future<void> _saveStats() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_totalAnsweredKey, _totalQuestionsAnswered);
    prefs.setInt(_correctAnswersKey, _totalCorrectAnswers);
  }

  void walkAway() {
    _timer?.cancel();
    _isAnswered = true;
    _finishGame(isWalkAway: true);
  }

  int _lastEarnedCoins = 0;
  String _lastEarnedMoney = "0 ₺";
  int get lastEarnedCoins => _lastEarnedCoins;
  String get lastEarnedMoney => _lastEarnedMoney;

  void nextQuestion() {
    if (_selectedOptionIndex != currentQuestion.correctOptionIndex) {
      _finishGame();
    } else if (isLastQuestion) {
      _finishGame();
    } else {
      _currentQuestionIndex++;
      if (_gameMode == GameMode.classic) {
        _seenClassicIds.add(_currentQuestions[_currentQuestionIndex].id);
      } else {
        _seenEndlessIds.add(_currentQuestions[_currentQuestionIndex].id);
      }
      _saveSeenQuestions();
      
      _isAnswered = false;
      _selectedOptionIndex = null;
      _hiddenOptions = [];
      
      _fiftyFiftyUsedThisQuestion = false;
      _phoneUsedThisQuestion = false;
      _audienceUsedThisQuestion = false;
      _skipUsedThisQuestion = false;
      
      _startTimer();
      notifyListeners();
    }
  }

  void withdraw() {
    _finishGame(isWalkAway: true);
  }

  void _finishGame({bool isWalkAway = false}) {
    _timer?.cancel();
    
    _gamesPlayedSession++;
    if (_gamesPlayedSession % 3 == 0 && !kIsWeb) {
      AdService().showInterstitialAd();
    }
    
    String moneyString = "0 ₺";
    int moneyValue = 0;
    int coinsEarned = 0;

    bool isWin = _selectedOptionIndex != null && _selectedOptionIndex == currentQuestion.correctOptionIndex;

    if (_gameMode == GameMode.classic) {
      if (isWalkAway) {
        if (_currentQuestionIndex > 0) {
          moneyString = "${prizeLadder[_currentQuestionIndex - 1]} ₺";
          moneyValue = int.parse(prizeLadder[_currentQuestionIndex - 1].replaceAll('.', ''));
        }
        coinsEarned = _currentMatchDiamonds;
      } else if (isWin && isLastQuestion) {
        moneyString = "1.000.000 ₺"; 
        moneyValue = 1000000;
        coinsEarned = _currentMatchDiamonds; // they won
      } else if (!isWin) {
        // Lost
        if (_currentQuestionIndex >= 10) {
          moneyString = "${prizeLadder[9]} ₺"; // Guaranteed at Q10
          moneyValue = int.parse(prizeLadder[9].replaceAll('.', ''));
        } else if (_currentQuestionIndex >= 5) {
          moneyString = "${prizeLadder[4]} ₺"; // Guaranteed at Q5
          moneyValue = int.parse(prizeLadder[4].replaceAll('.', ''));
        } else if (_currentQuestionIndex >= 2) {
          moneyString = "${prizeLadder[1]} ₺"; // Guaranteed at Q2
          moneyValue = int.parse(prizeLadder[1].replaceAll('.', ''));
        }
        coinsEarned = _guaranteedDiamonds;
      } else {
        // Technically shouldn't finish mid-game if they won a question, but just in case
        moneyString = "${prizeLadder[_currentQuestionIndex]} ₺";
        moneyValue = int.parse(prizeLadder[_currentQuestionIndex].replaceAll('.', ''));
        coinsEarned = _currentMatchDiamonds;
      }
    } else if (_gameMode == GameMode.event) {
      if (isWin && isLastQuestion) {
        coinsEarned = 1000;
        _roomCards += 5;
        SharedPreferences.getInstance().then((prefs) => prefs.setInt(_roomCardsKey, _roomCards));
        notifyListeners();
        moneyValue = 0;
        moneyString = "Etkinlik Tamamlandı (+5 Oda Kartı)";
      } else {
        coinsEarned = 0;
        moneyValue = 0;
        moneyString = "Etkinlik Başarısız";
      }
    } else {
      // Endless mode
      coinsEarned = _currentMatchDiamonds;
      moneyValue = _currentQuestionIndex;
      moneyString = "$_currentQuestionIndex Soru";
    }

    _lastEarnedCoins = coinsEarned;
    _lastEarnedMoney = moneyString;

    if (moneyValue > 0 || _gameMode == GameMode.endless || _gameMode == GameMode.event) {
      if (_gameMode == GameMode.classic) {
        _totalMoney += moneyValue;
        _weeklyScore += moneyValue; // Haftalık sıralama için de ekle
      }
      
      final date = DateTime.now().toString().split(' ')[0];
      String modeStr = _gameMode == GameMode.endless ? "Sonsuz Mod" : (_gameMode == GameMode.event ? "Etkinlik Modu" : "Klasik Mod");
      
      final Map<String, dynamic> scoreData = {
        'mode': modeStr,
        'score': moneyValue,
        'moneyString': moneyString,
        'level': _currentQuestionIndex,
        'date': date,
        'avatar': _activeAvatar,
        'userName': _userName,
      };
      
      _highScores.add(jsonEncode(scoreData));
      
      // Push to Firestore
      try {
        String finalId = FirebaseAuth.instance.currentUser?.uid ?? _deviceId;
        String docId = "${finalId}_$modeStr";
        FirebaseFirestore.instance.collection('leaderboard').doc(docId).set(scoreData, SetOptions(merge: true));
      } catch (e) {
        debugPrint("Firestore error: $e");
      }
      
      // Sort descending by score
      _highScores.sort((a, b) {
        try {
          var mapA = jsonDecode(a);
          var mapB = jsonDecode(b);
          return (mapB['score'] as num).compareTo(mapA['score'] as num);
        } catch (e) {
          return 0;
        }
      });

      if (_highScores.length > 500) _highScores = _highScores.sublist(0, 500);
      _saveHighScores();
    }

    _totalCoins += coinsEarned;
    _saveCoins();
    _saveMoney();
    notifyListeners();
  }
  
  Future<void> _saveHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_highScoresKey, _highScores);
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
