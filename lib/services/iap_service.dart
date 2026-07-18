import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';

class IapService {
  static final IapService _instance = IapService._internal();
  factory IapService() => _instance;
  IapService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  bool isAvailable = false;
  List<ProductDetails> products = [];

  // Product IDs
  static const String diamond1000 = 'diamond_1000';
  static const String diamond5000 = 'diamond_5000';
  static const String diamond20000 = 'diamond_20000';
  static const String roomCard10 = 'room_card_10';
  static const String roomCard50 = 'room_card_50';
  static const String jokerPack20 = 'joker_pack_20';
  static const String jokerPack50 = 'joker_pack_50';
  static const String jokerPack100 = 'joker_pack_100';
  static const String avatarEpic = 'avatar_epic';
  static const String avatarLegendary = 'avatar_legendary';
  static const String avatarEinstein = 'avatar_einstein';
  static const String packStarter = 'pack_starter';
  static const String removeAdsVip = 'remove_ads_vip';

  final Set<String> _kIds = {
    diamond1000,
    diamond5000,
    diamond20000,
    roomCard10,
    roomCard50,
    jokerPack20,
    jokerPack50,
    jokerPack100,
    avatarEpic,
    avatarLegendary,
    avatarEinstein,
    packStarter,
    removeAdsVip,
  };

  Future<void> init(BuildContext context) async {
    if (kIsWeb) {
      _loadDummyProducts();
      return;
    }

    try {
      isAvailable = await _inAppPurchase.isAvailable();
      if (isAvailable) {
        final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_kIds);
        if (response.notFoundIDs.isNotEmpty) {
          debugPrint('Not found IAP IDs: ${response.notFoundIDs}');
        }
        products = response.productDetails;
        if (products.isEmpty) {
          _loadDummyProducts();
        }
      } else {
        _loadDummyProducts();
      }

      final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
      _subscription = purchaseUpdated.listen((purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList, context);
      }, onDone: () {
        _subscription.cancel();
      }, onError: (error) {
        debugPrint('IAP Error: $error');
      });
    } catch (e) {
      debugPrint('IAP Init Error: $e');
      _loadDummyProducts();
    }
  }

  void _loadDummyProducts() {
    products = [
      ProductDetails(id: packStarter, title: 'Hoş Geldin Paketi', description: 'Galileo Avatar + 2000 Elmas + 10 Oda + 20 Joker', price: '49.99 ₺', rawPrice: 49.99, currencyCode: 'TRY'),
      ProductDetails(id: diamond1000, title: '1.000 Elmas Çantası', description: '1000 Elmas', price: '14.99 ₺', rawPrice: 14.99, currencyCode: 'TRY'),
      ProductDetails(id: diamond5000, title: '5.000 Elmas Sandığı', description: '5000 Elmas', price: '39.99 ₺', rawPrice: 39.99, currencyCode: 'TRY'),
      ProductDetails(id: diamond20000, title: '20.000 Elmas Kasası', description: '20000 Elmas', price: '99.99 ₺', rawPrice: 99.99, currencyCode: 'TRY'),
      ProductDetails(id: roomCard10, title: 'Hafta Sonu Paketi', description: '10 Oda Kartı', price: '19.99 ₺', rawPrice: 19.99, currencyCode: 'TRY'),
      ProductDetails(id: roomCard50, title: 'Parti Paketi', description: '50 Oda Kartı (Çok Kârlı!)', price: '49.99 ₺', rawPrice: 49.99, currencyCode: 'TRY'),
      ProductDetails(id: jokerPack20, title: 'Joker Kesesi', description: 'Tüm joker türlerinden 20\'şer adet', price: '19.99 ₺', rawPrice: 19.99, currencyCode: 'TRY'),
      ProductDetails(id: jokerPack50, title: 'Joker Sandığı', description: 'Tüm joker türlerinden 50\'şer adet', price: '49.99 ₺', rawPrice: 49.99, currencyCode: 'TRY'),
      ProductDetails(id: jokerPack100, title: 'Mega Joker Kasası', description: 'Tüm joker türlerinden 100\'er adet', price: '99.99 ₺', rawPrice: 99.99, currencyCode: 'TRY'),
      ProductDetails(id: avatarEinstein, title: 'Einstein Avatar', description: 'En Nadir VIP Avatar', price: '89.99 ₺', rawPrice: 89.99, currencyCode: 'TRY'),
      ProductDetails(id: removeAdsVip, title: 'Reklamları Kaldır (VIP)', description: 'Sınırsız Ayrıcalıklar', price: '99.99 ₺', rawPrice: 99.99, currencyCode: 'TRY'),
    ];
    isAvailable = true; // Test mode'da ürünlerin ekranda görünmesi için true yapıyoruz
  }

  void dispose() {
    if (!kIsWeb && isAvailable) {
      _subscription.cancel();
    }
  }

  Future<void> buyProduct(ProductDetails product, BuildContext context) async {
    if (kIsWeb) {
      debugPrint('Web sürümünde gerçek satın alma yapılamaz.');
      return;
    }

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    bool isConsumable = !product.id.startsWith('avatar_') && product.id != removeAdsVip;
    
    try {
      if (isConsumable) {
        await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      } else {
        await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      }
    } catch (e) {
      debugPrint('Satın alma başlatılırken hata: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Satın alma başlatılamadı: $e')));
    }
  }

  Future<void> restorePurchases() async {
    if (!kIsWeb && isAvailable) {
      await _inAppPurchase.restorePurchases();
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList, BuildContext context) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Bekleniyor
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint('Satın alma hatası: ${purchaseDetails.error}');
        } else if (purchaseDetails.status == PurchaseStatus.purchased || purchaseDetails.status == PurchaseStatus.restored) {
          _deliverProduct(purchaseDetails, context);
        }
        
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  void _deliverProduct(PurchaseDetails purchaseDetails, BuildContext context) {
    final provider = Provider.of<QuizProvider>(context, listen: false);
    
    switch (purchaseDetails.productID) {
      case diamond1000:
        provider.grantIAPReward(diamonds: 1000);
        break;
      case diamond5000:
        provider.grantIAPReward(diamonds: 5000);
        break;
      case diamond20000:
        provider.grantIAPReward(diamonds: 20000);
        break;
      case roomCard10:
        provider.grantIAPReward(roomCards: 10);
        break;
      case roomCard50:
        provider.grantIAPReward(roomCards: 50);
        break;
      case jokerPack20:
        provider.grantIAPReward(jokers: 20);
        break;
      case jokerPack50:
        provider.grantIAPReward(jokers: 50);
        break;
      case jokerPack100:
        provider.grantIAPReward(jokers: 100);
        break;
      case packStarter:
        provider.grantIAPReward(diamonds: 2000, roomCards: 10, jokers: 20, avatarUnlocks: ['assets/images/galileo_avatar.png']);
        break;
      case avatarEpic:
        provider.grantIAPReward(avatarUnlocks: ['assets/images/newton_avatar.png']);
        break;
      case avatarLegendary:
        provider.grantIAPReward(avatarUnlocks: ['assets/images/tesla_avatar.png']);
        break;
      case avatarEinstein:
        provider.grantIAPReward(avatarUnlocks: ['assets/images/einstein_avatar.png']);
        break;
      case removeAdsVip:
        provider.grantVipAccess();
        break;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Satın alma başarılı! Ödülleriniz eklendi. 💎🎁'),
      backgroundColor: Colors.green,
    ));
  }
}

class MockPurchaseDetails extends PurchaseDetails {
  MockPurchaseDetails({required String productID, required PurchaseStatus status})
      : super(
          productID: productID,
          purchaseID: 'mock_purchase_id',
          transactionDate: DateTime.now().millisecondsSinceEpoch.toString(),
          verificationData: PurchaseVerificationData(localVerificationData: '', serverVerificationData: '', source: ''),
          status: status,
        );
}
