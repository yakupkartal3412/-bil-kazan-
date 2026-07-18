import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  int _interstitialLoadAttempts = 0;
  InterstitialAd? _interstitialAd;
  
  int _rewardedLoadAttempts = 0;
  RewardedAd? _rewardedAd;

  // Real Banner ID
  static String get bannerAdUnitId {
    if (Platform.isAndroid) return 'ca-app-pub-1158679315546899/4060029466';
    if (Platform.isIOS) return 'ca-app-pub-3940256099942544/2934735716'; // iOS test for now
    throw UnsupportedError('Unsupported platform');
  }

  // Real Interstitial IDs
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) return 'ca-app-pub-1158679315546899/6723254194';
    if (Platform.isIOS) return 'ca-app-pub-3940256099942544/4411468910'; // iOS test for now
    throw UnsupportedError('Unsupported platform');
  }

  // Real Rewarded IDs
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) return 'ca-app-pub-1158679315546899/9956042330';
    if (Platform.isIOS) return 'ca-app-pub-3940256099942544/1712485313'; // iOS test for now
    throw UnsupportedError('Unsupported platform');
  }

  void initialize() {
    MobileAds.instance.initialize();
    loadInterstitialAd();
    loadRewardedAd();
  }

  // --- INTERSTITIAL (Geçiş) REKLAMI ---
  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialLoadAttempts = 0;
        },
        onAdFailedToLoad: (err) {
          _interstitialLoadAttempts += 1;
          _interstitialAd = null;
          if (_interstitialLoadAttempts <= 3) {
            loadInterstitialAd();
          }
        },
      ),
    );
  }

  void showInterstitialAd({VoidCallback? onCompleted}) {
    if (_interstitialAd == null) {
      if (onCompleted != null) onCompleted();
      return;
    }
    
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadInterstitialAd(); // Load next one
        if (onCompleted != null) onCompleted();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        loadInterstitialAd();
        if (onCompleted != null) onCompleted();
      },
    );
    
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  // --- REWARDED (Ödüllü) REKLAM ---
  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedLoadAttempts = 0;
        },
        onAdFailedToLoad: (err) {
          _rewardedLoadAttempts += 1;
          _rewardedAd = null;
          if (_rewardedLoadAttempts <= 3) {
            loadRewardedAd();
          }
        },
      ),
    );
  }

  void showRewardedAd({required BuildContext context, required Function(int) onRewardEarned, VoidCallback? onClosed}) {
    if (_rewardedAd == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('HATA: Reklam yüklenemedi! İnternetiniz kapalı olabilir veya REKLAM ENGELLEYİCİ kullanıyor olabilirsiniz. Ödül almak için bunları kapatın.'),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 4),
      ));
      loadRewardedAd();
      if (onClosed != null) onClosed();
      return;
    }
    
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadRewardedAd();
        if (onClosed != null) onClosed();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        loadRewardedAd();
        if (onClosed != null) onClosed();
      },
    );
    
    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        onRewardEarned(reward.amount.toInt());
      }
    );
    _rewardedAd = null;
  }
}

// --- BANNER WIDGET ---
class CustomBannerAd extends StatefulWidget {
  const CustomBannerAd({super.key});

  @override
  State<CustomBannerAd> createState() => _CustomBannerAdState();
}

class _CustomBannerAdState extends State<CustomBannerAd> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded && _bannerAd != null) {
      return Container(
        color: Colors.transparent,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    return const SizedBox(height: 50); // Empty space if not loaded yet
  }
}
