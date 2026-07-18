import os

filepath = r"lib\screens\quiz_screen.dart"

with open(filepath, "r", encoding="utf-8") as f:
    content = f.read()

quiz_target = """                  icon: const Icon(Icons.ondemand_video, color: Colors.white),
                  label: const Text('VİDEO İZLE VE DEVAM ET', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    AdService().showRewardedAd(
                      context: context,
                      onRewardEarned: (_) {
                        provider.reviveWithAd();
                      },
                      onClosed: () {}, // Do nothing if closed early without reward
                    );
                  },"""

quiz_insert = """                  icon: Icon(provider.hasRemovedAds ? Icons.diamond : Icons.ondemand_video, color: Colors.white),
                  label: Text(provider.hasRemovedAds ? 'VIP BEDAVA DEVAM ET' : 'VİDEO İZLE VE DEVAM ET', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: provider.hasRemovedAds ? Colors.green : Colors.amber,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (provider.hasRemovedAds) {
                      if (provider.consumeVipAction('game_revive')) {
                        provider.reviveWithAd();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('VIP Ayrıcalığı: Canlandınız!'), backgroundColor: Colors.green));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Günlük VIP Revive sınırına ulaştınız! (Max 10)')));
                        provider.walkAway(); // Walk away automatically if limit reached to avoid cheating
                      }
                    } else {
                      AdService().showRewardedAd(
                        context: context,
                        onRewardEarned: (_) {
                          provider.reviveWithAd();
                        },
                        onClosed: () {}, // Do nothing if closed early without reward
                      );
                    }
                  },"""
content = content.replace(quiz_target, quiz_insert)

with open(filepath, "w", encoding="utf-8") as f:
    f.write(content)

print("SUCCESS")
