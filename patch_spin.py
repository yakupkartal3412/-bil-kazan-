import os

filepath = r"lib\screens\spin_wheel_screen.dart"

with open(filepath, "r", encoding="utf-8") as f:
    content = f.read()

ad_spin_target = """    if (provider.lastAdSpinDate == today) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bugünlük ekstra video çark hakkınızı kullandınız. Yarın tekrar gelin!')));
      return;
    }

    AdService().showRewardedAd(
      context: context,
      onRewardEarned: (amount) {
        _executeSpin(provider, true);
      },
    );"""

ad_spin_insert = """    if (provider.hasRemovedAds) {
      if (provider.consumeVipAction('spin_wheel')) {
        _executeSpin(provider, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Günlük VIP Ekstra Çark sınırına ulaştınız! (Max 5)')));
      }
      return;
    }

    if (provider.lastAdSpinDate == today) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bugünlük ekstra video çark hakkınızı kullandınız. Yarın tekrar gelin!')));
      return;
    }

    AdService().showRewardedAd(
      context: context,
      onRewardEarned: (amount) {
        _executeSpin(provider, true);
      },
    );"""
content = content.replace(ad_spin_target, ad_spin_insert)

ui_target2 = """                  bool canDoAction = canSpin || canAdSpin;
                  String buttonText = _isSpinning 
                      ? 'ÇEVRİLİYOR...' 
                      : (canSpin 
                          ? 'ÇARKI ÇEVİR' 
                          : (canAdSpin ? 'VİDEO İZLE VE ÇEVİR' : 'YARIN TEKRAR GEL'));"""

ui_insert2 = """                  bool hasVipSpins = provider.hasRemovedAds;
                  bool canDoAction = canSpin || canAdSpin || hasVipSpins;
                  String buttonText = _isSpinning 
                      ? 'ÇEVRİLİYOR...' 
                      : (canSpin 
                          ? 'ÇARKI ÇEVİR' 
                          : (hasVipSpins ? 'VIP ÇARK ÇEVİR' : (canAdSpin ? 'VİDEO İZLE VE ÇEVİR' : 'YARIN TEKRAR GEL')));"""

content = content.replace(ui_target2, ui_insert2)

icon_target = """                                    if (!canSpin && canAdSpin)
                                      const Icon(Icons.ondemand_video, color: Colors.white, size: 20),
                                    if (!canSpin && canAdSpin)
                                      const SizedBox(width: 8),"""

icon_insert = """                                    if (!canSpin && hasVipSpins)
                                      const Icon(Icons.diamond, color: Colors.white, size: 20)
                                    else if (!canSpin && canAdSpin)
                                      const Icon(Icons.ondemand_video, color: Colors.white, size: 20),
                                    if (!canSpin && (canAdSpin || hasVipSpins))
                                      const SizedBox(width: 8),"""

content = content.replace(icon_target, icon_insert)

with open(filepath, "w", encoding="utf-8") as f:
    f.write(content)

print("SUCCESS")
