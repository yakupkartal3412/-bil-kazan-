import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum RoomStatus { waiting, playing, finished }

class MultiplayerProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String? _roomId;
  String? get roomId => _roomId;

  bool _isHost = false;
  bool get isHost => _isHost;

  Map<String, dynamic>? _roomData;
  Map<String, dynamic>? get roomData => _roomData;

  StreamSubscription<DocumentSnapshot>? _roomSubscription;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  // ODA KUR (HOST)
  Future<bool> createRoom(String hostName, String hostAvatar, List<Map<String, dynamic>> questions) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // BUG FIX 1: Kod çakışması — var olan bir oda kodunu üretmemek için kontrol et
      String newCode = '';
      for (int attempt = 0; attempt < 10; attempt++) {
        String candidate = (Random().nextInt(9000) + 1000).toString();
        final existing = await _firestore.collection('rooms').doc(candidate).get();
        if (!existing.exists) {
          newCode = candidate;
          break;
        }
      }
      if (newCode.isEmpty) {
        _errorMessage = 'Oda kodu üretilemedi, tekrar deneyin.';
        return false;
      }

      _roomId = newCode;
      _isHost = true;

      final roomRef = _firestore.collection('rooms').doc(_roomId);
      await roomRef.set({
        'roomId': _roomId,
        'status': 'waiting',
        'hostId': currentUserId,
        'hostName': hostName,
        'hostAvatar': hostAvatar,
        'hostScore': 0,
        'hostFinished': false,
        'guestId': null,
        'guestName': null,
        'guestAvatar': null,
        'guestScore': 0,
        'guestFinished': false,
        'questions': questions,
        'createdAt': FieldValue.serverTimestamp(),
        'currentQuestionIndex': 0,
        'hostAnswers': {},
        'guestAnswers': {},
        'hostEmote': null,
        'guestEmote': null,
        'rematchRequestedBy': null,
        'hostSeriesWins': 0,
        'guestSeriesWins': 0,
      }).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Sunucuya bağlanılamadı. Lütfen internet bağlantınızı kontrol edin.');
      });

      _listenToRoom();
      return true;
    } catch (e) {
      _errorMessage = 'Oda kurulamadı: $e';
      _roomId = null;
      _isHost = false;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ODAYA KATIL (GUEST)
  Future<bool> joinRoom(String code, String guestName, String guestAvatar) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final roomRef = _firestore.collection('rooms').doc(code);
      final snapshot = await roomRef.get().timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Sunucuya bağlanılamadı.');
      });

      if (!snapshot.exists) {
        _errorMessage = 'Oda bulunamadı. Kodu kontrol edin.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final data = snapshot.data() as Map<String, dynamic>;
      
      // BUG FIX 2: Kendi odasına girmeyi engelle
      if (data['hostId'] == currentUserId) {
        _errorMessage = 'Kendi odasına katılamazsın!';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (data['status'] != 'waiting') {
        _errorMessage = 'Oyun çoktan başlamış veya bitmiş.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (data['guestId'] != null) {
        _errorMessage = 'Oda dolu!';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await roomRef.update({
        'guestId': currentUserId,
        'guestName': guestName,
        'guestAvatar': guestAvatar,
      });

      _roomId = code;
      _isHost = false;
      _listenToRoom();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Odaya katılırken hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // OYUNU BAŞLAT (Sadece Host)
  Future<void> startGame() async {
    if (_roomId != null && _isHost) {
      await _firestore.collection('rooms').doc(_roomId).update({
        'status': 'playing'
      });
    }
  }

  // PUAN GÜNCELLE
  Future<void> updateScore(int currentScore) async {
    if (_roomId == null) return;
    
    String field = _isHost ? 'hostScore' : 'guestScore';
    await _firestore.collection('rooms').doc(_roomId).update({
      field: currentScore,
    });
  }

  // OYUNU BİTİR
  Future<void> finishGame(int finalScore) async {
    if (_roomId == null) return;

    String scoreField = _isHost ? 'hostScore' : 'guestScore';
    String finishedField = _isHost ? 'hostFinished' : 'guestFinished';

    await _firestore.collection('rooms').doc(_roomId).update({
      scoreField: finalScore,
      finishedField: true,
    });
  }

  // CEVAP GÖNDER (Senkron Oyun)
  Future<void> submitAnswer(int qIndex, int ansIndex) async {
    if (_roomId == null) return;
    String fieldPrefix = _isHost ? 'hostAnswers' : 'guestAnswers';
    await _firestore.collection('rooms').doc(_roomId).update({
      '$fieldPrefix.$qIndex': ansIndex,
    });
  }

  // SONRAKİ SORUYA GEÇ (Sadece Host)
  Future<void> moveToNextQuestion(int nextIndex) async {
    if (_roomId == null || !_isHost) return;
    await _firestore.collection('rooms').doc(_roomId).update({
      'currentQuestionIndex': nextIndex,
    });
  }

  // EMOTE GÖNDER
  Future<void> sendEmote(String emote) async {
    if (_roomId == null) return;
    String field = _isHost ? 'hostEmote' : 'guestEmote';
    await _firestore.collection('rooms').doc(_roomId).update({
      field: {
        'emote': emote,
        'timestamp': FieldValue.serverTimestamp(),
      }
    });
  }

  // RÖVANŞ İSTE
  Future<void> requestRematch() async {
    if (_roomId == null) return;
    await _firestore.collection('rooms').doc(_roomId).update({
      'rematchRequestedBy': currentUserId,
    });
  }

  // RÖVANŞ KABUL ET
  Future<void> acceptRematch(List<Map<String, dynamic>> newQuestions) async {
    if (_roomId == null) return;
    await _firestore.collection('rooms').doc(_roomId).update({
      'status': 'playing',
      'hostScore': 0,
      'guestScore': 0,
      'hostFinished': false,
      'guestFinished': false,
      'questions': newQuestions,
      'currentQuestionIndex': 0,
      'hostAnswers': {},
      'guestAnswers': {},
      'hostEmote': null,
      'guestEmote': null,
      'rematchRequestedBy': null,
    });
  }

  // RÖVANŞ REDDET
  Future<void> declineRematch() async {
    if (_roomId == null) return;
    await _firestore.collection('rooms').doc(_roomId).update({
      'rematchRequestedBy': null,
    });
  }

  bool _isFinishing = false;

  // ODAYI DİNLE
  void _listenToRoom() {
    if (_roomId == null) return;

    _roomSubscription?.cancel();
    _roomSubscription = _firestore.collection('rooms').doc(_roomId).snapshots().listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data() as Map<String, dynamic>;
        _roomData = data;
        
        // Host tarafında bitişi işle — ama sadece bir kez tetikle
        if (data['status'] == 'playing' && _isHost && !_isFinishing) {
          bool hFin = data['hostFinished'] ?? false;
          bool gFin = data['guestFinished'] ?? false;
          if (hFin && gFin) {
            _isFinishing = true;
            int hScore = data['hostScore'] ?? 0;
            int gScore = data['guestScore'] ?? 0;
            int hWins = data['hostSeriesWins'] ?? 0;
            int gWins = data['guestSeriesWins'] ?? 0;

            if (hScore > gScore) {
              hWins++;
            } else if (gScore > hScore) {
              gWins++;
            }

            _firestore.collection('rooms').doc(_roomId).update({
              'status': 'finished',
              'hostSeriesWins': hWins,
              'guestSeriesWins': gWins
            }).then((_) {
              _isFinishing = false;
            }).catchError((_) {
              _isFinishing = false;
            });
          }
        }
        
        notifyListeners();
      } else {
        // Doküman silindiyse veya veri yoksa odayı temizle
        _roomData = null;
        notifyListeners();
      }
    });
  }

  // OYUNDAN ÇIK / LOBİDEN AYRIL
  Future<void> leaveRoom() async {
    try {
      _roomSubscription?.cancel();
      _roomSubscription = null;
      if (_roomId != null) {
        if (_roomData?['status'] == 'playing') {
          await _firestore.collection('rooms').doc(_roomId).update({'status': 'abandoned'});
        } else if (_isHost && _roomData?['status'] == 'waiting') {
          await _firestore.collection('rooms').doc(_roomId).delete();
        } else if (!_isHost && _roomData?['status'] == 'waiting') {
          await _firestore.collection('rooms').doc(_roomId).update({
            'guestId': null,
            'guestName': null,
            'guestAvatar': null,
          });
        }
      }
    } catch (_) {
      // Ignored: network failure during leave shouldn't block local cleanup
    } finally {
      _roomId = null;
      _roomData = null;
      _isHost = false;
      _isFinishing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    super.dispose();
  }
}
