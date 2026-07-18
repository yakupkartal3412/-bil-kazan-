import os

filepath = r"lib\providers\quiz_provider.dart"

with open(filepath, "r", encoding="utf-8") as f:
    content = f.read()

# 1. Add Keys
keys_target = "  static const String _roomCardsKey = 'room_cards';"
keys_insert = """  static const String _roomCardsKey = 'room_cards';
  static const String _hasRemovedAdsKey = 'has_removed_ads';
  static const String _vipSurpriseBoxCountKey = 'vip_surprise_box_count';
  static const String _vipSpinCountKey = 'vip_spin_count';
  static const String _vipRoomCardCountKey = 'vip_room_card_count';
  static const String _vipGameReviveCountKey = 'vip_game_revive_count';
  static const String _vipJokerFiftyFiftyCountKey = 'vip_joker_ff_count';
  static const String _vipJokerPhoneCountKey = 'vip_joker_phone_count';
  static const String _vipJokerAudienceCountKey = 'vip_joker_aud_count';
  static const String _vipJokerSkipCountKey = 'vip_joker_skip_count';"""

content = content.replace(keys_target, keys_insert)

# 2. Add Variables & Getters
vars_target = "  int get roomCards => _roomCards;"
vars_insert = """  int get roomCards => _roomCards;
  
  bool _hasRemovedAds = false;
  bool get hasRemovedAds => _hasRemovedAds;
  
  int _vipSurpriseBoxCount = 0;
  int _vipSpinCount = 0;
  int _vipRoomCardCount = 0;
  int _vipGameReviveCount = 0;
  int _vipJokerFiftyFiftyCount = 0;
  int _vipJokerPhoneCount = 0;
  int _vipJokerAudienceCount = 0;
  int _vipJokerSkipCount = 0;"""

content = content.replace(vars_target, vars_insert)

# 3. Add to _loadData
load_target = "    _roomCards = prefs.getInt(_roomCardsKey) ?? 1; // Default 1 kart"
load_insert = """    _roomCards = prefs.getInt(_roomCardsKey) ?? 1; // Default 1 kart
    _hasRemovedAds = prefs.getBool(_hasRemovedAdsKey) ?? false;
    _vipSurpriseBoxCount = prefs.getInt(_vipSurpriseBoxCountKey) ?? 0;
    _vipSpinCount = prefs.getInt(_vipSpinCountKey) ?? 0;
    _vipRoomCardCount = prefs.getInt(_vipRoomCardCountKey) ?? 0;
    _vipGameReviveCount = prefs.getInt(_vipGameReviveCountKey) ?? 0;
    _vipJokerFiftyFiftyCount = prefs.getInt(_vipJokerFiftyFiftyCountKey) ?? 0;
    _vipJokerPhoneCount = prefs.getInt(_vipJokerPhoneCountKey) ?? 0;
    _vipJokerAudienceCount = prefs.getInt(_vipJokerAudienceCountKey) ?? 0;
    _vipJokerSkipCount = prefs.getInt(_vipJokerSkipCountKey) ?? 0;"""

content = content.replace(load_target, load_insert)

# 4. Add to _saveDailyStats
save_target = "    await prefs.setStringList(_claimedMissionsKey, _claimedMissions);"
save_insert = """    await prefs.setStringList(_claimedMissionsKey, _claimedMissions);
    await prefs.setInt(_vipSurpriseBoxCountKey, _vipSurpriseBoxCount);
    await prefs.setInt(_vipSpinCountKey, _vipSpinCount);
    await prefs.setInt(_vipRoomCardCountKey, _vipRoomCardCount);
    await prefs.setInt(_vipGameReviveCountKey, _vipGameReviveCount);
    await prefs.setInt(_vipJokerFiftyFiftyCountKey, _vipJokerFiftyFiftyCount);
    await prefs.setInt(_vipJokerPhoneCountKey, _vipJokerPhoneCount);
    await prefs.setInt(_vipJokerAudienceCountKey, _vipJokerAudienceCount);
    await prefs.setInt(_vipJokerSkipCountKey, _vipJokerSkipCount);"""

content = content.replace(save_target, save_insert)

# 5. Add to daily reset logic
reset_target = "      _claimedMissions.clear();"
reset_insert = """      _claimedMissions.clear();
      _vipSurpriseBoxCount = 0;
      _vipSpinCount = 0;
      _vipRoomCardCount = 0;
      _vipGameReviveCount = 0;
      _vipJokerFiftyFiftyCount = 0;
      _vipJokerPhoneCount = 0;
      _vipJokerAudienceCount = 0;
      _vipJokerSkipCount = 0;"""

content = content.replace(reset_target, reset_insert)

# 6. Add grantVipAccess and consumeVipAction
func_insert = """
  Future<void> grantVipAccess() async {
    _hasRemovedAds = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasRemovedAdsKey, true);
    notifyListeners();
  }

  bool consumeVipAction(String actionType) {
    if (!_hasRemovedAds) return false;
    
    switch (actionType) {
      case 'surprise_box':
        if (_vipSurpriseBoxCount >= 10) return false;
        _vipSurpriseBoxCount++;
        break;
      case 'spin_wheel':
        if (_vipSpinCount >= 5) return false;
        _vipSpinCount++;
        break;
      case 'room_card':
        if (_vipRoomCardCount >= 20) return false;
        _vipRoomCardCount++;
        break;
      case 'game_revive':
        if (_vipGameReviveCount >= 10) return false;
        _vipGameReviveCount++;
        break;
      case 'joker_ff':
        if (_vipJokerFiftyFiftyCount >= 15) return false;
        _vipJokerFiftyFiftyCount++;
        break;
      case 'joker_phone':
        if (_vipJokerPhoneCount >= 15) return false;
        _vipJokerPhoneCount++;
        break;
      case 'joker_aud':
        if (_vipJokerAudienceCount >= 15) return false;
        _vipJokerAudienceCount++;
        break;
      case 'joker_skip':
        if (_vipJokerSkipCount >= 15) return false;
        _vipJokerSkipCount++;
        break;
      default:
        return false;
    }
    
    _saveDailyStats(); // Save counters
    notifyListeners();
    return true;
  }
"""

last_brace = content.rfind("}")
content = content[:last_brace] + func_insert + content[last_brace:]

with open(filepath, "w", encoding="utf-8") as f:
    f.write(content)

print("SUCCESS")
