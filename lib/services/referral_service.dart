import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:math';
import 'dart:io';

class ReferralService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> _getUniqueDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isIOS) {
        final iosDeviceInfo = await deviceInfo.iosInfo;
        return iosDeviceInfo.identifierForVendor ?? 'unknown_ios';
      } else if (Platform.isAndroid) {
        final androidDeviceInfo = await deviceInfo.androidInfo;
        return androidDeviceInfo.id; // Unique ID for Android device
      }
    } catch (e) {
      print("Device Info Error: \$e");
    }
    return 'unknown_device';
  }

  // Kullanıcı için referans kodu oluşturur veya var olanı getirir
  Future<String?> getOrCreateReferralCode() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();

    if (userDoc.exists && userDoc.data()!.containsKey('referralCode')) {
      return userDoc.data()!['referralCode'];
    }

    String newCode = _generateRandomCode(6);
    
    bool isUnique = false;
    while (!isUnique) {
      final codeCheck = await _firestore
          .collection('users')
          .where('referralCode', isEqualTo: newCode)
          .get();
      if (codeCheck.docs.isEmpty) {
        isUnique = true;
      } else {
        newCode = _generateRandomCode(6);
      }
    }

    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'referralCode': newCode,
      'totalReferrals': 0,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return newCode;
  }

  // Başkasının kodunu kullanma (Anti-Hile Korumalı ve Soru Sınırı)
  Future<String> submitReferralCode(String code, int totalQuestionsAnswered) async {
    if (totalQuestionsAnswered != 1) {
      if (totalQuestionsAnswered == 0) {
        return "Davet kodunu girebilmek için önce gidip 1 tane soru çözmelisiniz!";
      } else {
        return "Davet kodunu kaçırdınız! Kodu sadece tam 1 soru çözen yeni oyuncular girebilir.";
      }
    }

    final user = _auth.currentUser;
    if (user == null) return "Giriş yapmalısınız.";

    if (code.trim().isEmpty) return "Geçersiz kod.";
    code = code.toUpperCase().trim();

    // DONANIMSAL ANTİ-HİLE KONTROLÜ (Cihaz başına 1 kullanım sınırı)
    final hwDeviceId = await _getUniqueDeviceId();
    if (hwDeviceId == 'unknown_device' || hwDeviceId.isEmpty) {
      return "Cihazınız doğrulanamadı.";
    }

    final deviceDocRef = _firestore.collection('referral_devices').doc(hwDeviceId);
    final deviceDoc = await deviceDocRef.get();
    
    if (deviceDoc.exists) {
      return "Bu cihazdan daha önce bir davet kodu zaten kullanılmış. Hileye geçit yok!";
    }

    final userDocRef = _firestore.collection('users').doc(user.uid);
    final userDoc = await userDocRef.get();

    // 1. Zaten bir kod kullanmış mı?
    if (userDoc.exists && userDoc.data()!.containsKey('referredBy')) {
      return "Zaten bir referans kodu kullandınız.";
    }

    // 2. Kendi kodunu mu giriyor?
    if (userDoc.exists && userDoc.data()!['referralCode'] == code) {
      return "Kendi referans kodunuzu kullanamazsınız.";
    }

    // 3. Kod gerçek bir kullanıcıya ait mi?
    final codeOwnerQuery = await _firestore
        .collection('users')
        .where('referralCode', isEqualTo: code)
        .limit(1)
        .get();

    if (codeOwnerQuery.docs.isEmpty) {
      return "Böyle bir referans kodu bulunamadı.";
    }

    final codeOwnerDoc = codeOwnerQuery.docs.first;

    // Her şey tamamsa, işlemleri yap
    WriteBatch batch = _firestore.batch();

    // Yeni kullanıcıyı referanslandı olarak işaretle
    batch.set(
        userDocRef,
        {
          'referredBy': code,
          'referredAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true));

    // Davet edenin 'totalReferrals' sayısını artır
    batch.update(codeOwnerDoc.reference, {
      'totalReferrals': FieldValue.increment(1),
    });

    // Cihazı kara listeye al (artık bu cihazdan kod girilemez)
    batch.set(deviceDocRef, {
      'usedByUid': user.uid,
      'usedCode': code,
      'usedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();

    return "SUCCESS";
  }

  // Oyuna her girişte, bekleyen (ödülü alınmamış) referansları kontrol eder ve ARTAN ödülü hesaplar
  Future<int> calculateAndClaimPendingRewards() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (!userDoc.exists || !userDoc.data()!.containsKey('totalReferrals')) {
      return 0;
    }

    int totalReferrals = userDoc.data()!['totalReferrals'] as int;
    
    final prefs = await SharedPreferences.getInstance();
    int claimedReferrals = prefs.getInt('claimed_referrals_\${user.uid}') ?? 0;

    if (totalReferrals > claimedReferrals) {
      int totalReward = 0;
      
      // Progresif Hesaplama: Her yeni davet için 200 + (Sıra * 100) Elmas
      // 1. davet: 200 + 100 = 300
      // 2. davet: 200 + 200 = 400
      // 3. davet: 200 + 300 = 500 vs.
      for (int i = claimedReferrals + 1; i <= totalReferrals; i++) {
        totalReward += 200 + (i * 100);
      }
      
      // Yerel sayacı güncelle
      await prefs.setInt('claimed_referrals_\${user.uid}', totalReferrals);
      
      return totalReward; // Kazanılan toplam elmas miktarını döndür
    }

    return 0;
  }
  
  String _generateRandomCode(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }
}
