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
      // 4 haneli rastgele kod üret
      _roomId = (Random().nextInt(9000) + 1000).toString();
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
      }).timeout(const Duration(seconds: 5), onTimeout: () {
        throw TimeoutException('Sunucuya bağlanılamadı. Lütfen internet bağlantınızı kontrol edin veya Firebase ayarlarınızı doğrulayın.');
      });

      _listenToRoom();
      return true;
    } catch (e) {
      _errorMessage = 'Oda kurulamadı: $e';
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
      final snapshot = await roomRef.get().timeout(const Duration(seconds: 5), onTimeout: () {
        throw TimeoutException('Sunucuya bağlanılamadı.');
      });

      if (!snapshot.exists) {
        _errorMessage = 'Oda bulunamadı. Kodu kontrol edin.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final data = snapshot.data() as Map<String, dynamic>;
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

  // ODAYI DİNLE
  void _listenToRoom() {
    if (_roomId == null) return;

    _roomSubscription?.cancel();
    _roomSubscription = _firestore.collection('rooms').doc(_roomId).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        _roomData = snapshot.data() as Map<String, dynamic>;
        
        // Eğer ikisi de bitirdiyse ve status hala playing ise finished yap
        if (_roomData!['status'] == 'playing') {
          bool hFin = _roomData!['hostFinished'] ?? false;
          bool gFin = _roomData!['guestFinished'] ?? false;
          if (hFin && gFin && _isHost) {
            _firestore.collection('rooms').doc(_roomId).update({'status': 'finished'});
          }
        }
        
        notifyListeners();
      }
    });
  }

  // OYUNDAN ÇIK / LOBİDEN AYRIL
  Future<void> leaveRoom() async {
    if (_roomId != null) {
      if (_isHost && _roomData?['status'] == 'waiting') {
        // Host beklerken çıkarsa odayı sil
        await _firestore.collection('rooms').doc(_roomId).delete();
      } else if (!_isHost && _roomData?['status'] == 'waiting') {
        // Guest beklerken çıkarsa guest bilgilerini temizle
        await _firestore.collection('rooms').doc(_roomId).update({
          'guestId': null,
          'guestName': null,
          'guestAvatar': null,
        });
      }
    }
    
    _roomSubscription?.cancel();
    _roomId = null;
    _roomData = null;
    _isHost = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    super.dispose();
  }
}
