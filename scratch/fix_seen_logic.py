import re
import os

path = r'C:\Users\lenovo\ogrenkazan\bil_kazan\lib\providers\quiz_provider.dart'

with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Add _seenGlobalIdsKey
content = content.replace("static const String _seenClassicIdsKey = 'seen_classic_ids';", 
                          "static const String _seenGlobalIdsKey = 'seen_global_ids';\n  static const String _seenEventIdsKey = 'seen_event_ids';")
content = re.sub(r"static const String _seenEndlessIdsKey = 'seen_endless_ids';\s*", "", content)
content = re.sub(r"static const String _seenDuelIdsKey = 'seen_duel_ids';\s*", "", content)
content = re.sub(r"static const String _seenEventIdsKey = 'seen_event_ids';\s*", "", content) # Clean up if it was there twice

content = content.replace("static const String _cycleStartDateKey", "static const String _seenEventIdsKey = 'seen_event_ids';\n  static const String _cycleStartDateKey")

# 2. Replace Sets
content = content.replace("Set<String> _seenClassicIds = {};", "Set<String> _seenGlobalIds = {};")
content = re.sub(r"Set<String> _seenEndlessIds = {};\s*", "", content)
content = re.sub(r"Set<String> _seenDuelIds = {};\s*", "", content)

# 3. Replace loading in _loadData
content = content.replace("_seenClassicIds = (prefs.getStringList(_seenClassicIdsKey) ?? []).toSet();", "_seenGlobalIds = (prefs.getStringList(_seenGlobalIdsKey) ?? []).toSet();")
content = re.sub(r"_seenEndlessIds = \(prefs\.getStringList\(_seenEndlessIdsKey\) \?\? \[\]\)\.toSet\(\);\s*", "", content)
content = re.sub(r"_seenDuelIds = \(prefs\.getStringList\(_seenDuelIdsKey\) \?\? \[\]\)\.toSet\(\);\s*", "", content)

# 4. Fix _saveSeenQuestions
save_func_old = """  Future<void> _saveSeenQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_seenClassicIdsKey, _seenClassicIds.toList());
    await prefs.setStringList(_seenEndlessIdsKey, _seenEndlessIds.toList());
    await prefs.setStringList(_seenDuelIdsKey, _seenDuelIds.toList());
    await prefs.setStringList(_seenEventIdsKey, _seenEventIds.toList());
  }"""
save_func_new = """  Future<void> _saveSeenQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_seenGlobalIdsKey, _seenGlobalIds.toList());
    await prefs.setStringList(_seenEventIdsKey, _seenEventIds.toList());
  }
  
  void _checkGlobalSeenReset() {
    // 3000 soru baraji
    if (_seenGlobalIds.length >= 2950) { // Biraz pay birakalim
      _seenGlobalIds.clear();
      _saveSeenQuestions();
    }
  }

  List<Question> _getGlobalUnseen(List<Question> pool, int count) {
    _checkGlobalSeenReset();
    List<Question> unseen = pool.where((q) => !_seenGlobalIds.contains(q.id)).toList();
    unseen.shuffle(dart_math.Random());
    return unseen.take(count).toList();
  }
  
  List<Question> _fillRemaining(List<Question> current, int targetCount) {
    if (current.length >= targetCount) return current;
    _checkGlobalSeenReset();
    
    // Eksik varsa diger havuzlardan karisik cek
    List<Question> allQ = [..._easyQuestions, ..._mediumQuestions, ..._hardQuestions];
    List<Question> unseen = allQ.where((q) => !_seenGlobalIds.contains(q.id)).toList();
    unseen.shuffle(dart_math.Random());
    
    for (var q in unseen) {
      if (!current.any((c) => c.id == q.id)) {
        current.add(q);
        if (current.length >= targetCount) break;
      }
    }
    
    if (current.length < targetCount) {
       _seenGlobalIds.clear(); // Zorunlu sifirlama
       _saveSeenQuestions();
       return _fillRemaining(current, targetCount);
    }
    return current;
  }
"""
content = content.replace(save_func_old, save_func_new)

# 5. Replace _getUnseenClassic usages with _getGlobalUnseen
content = content.replace("_getUnseenClassic", "_getGlobalUnseen")

# 6. Replace get15MixedQuestions logic
get15_old = """  List<Question> get15MixedQuestions() {
    if (!_isDataLoaded) return [];
    final questions = [
      ..._getGlobalUnseen(_easyQuestions, 5),
      ..._getGlobalUnseen(_mediumQuestions, 5),
      ..._getGlobalUnseen(_hardQuestions, 5),
    ];
    for (final q in questions) { _seenClassicIds.add(q.id); }
    _saveSeenQuestions();
    return questions;
  }"""
get15_new = """  List<Question> get15MixedQuestions() {
    if (!_isDataLoaded) return [];
    List<Question> questions = [
      ..._getGlobalUnseen(_easyQuestions, 5),
      ..._getGlobalUnseen(_mediumQuestions, 5),
      ..._getGlobalUnseen(_hardQuestions, 5),
    ];
    questions = _fillRemaining(questions, 15);
    for (final q in questions) { _seenGlobalIds.add(q.id); }
    _saveSeenQuestions();
    return questions;
  }"""
content = content.replace(get15_old, get15_new)

# Remove the old _getUnseenClassic body which was renamed to _getGlobalUnseen earlier
old_getunseen_body = """  List<Question> _getGlobalUnseen(List<Question> pool, int count) {
    List<Question> unseen = pool.where((q) => !_seenClassicIds.contains(q.id)).toList();
    if (unseen.length < count) {
      // Bu zorluk seviyesindeki tüm sorular bitti — sadece bu pool'u sıfırla
      for (final q in pool) { _seenClassicIds.remove(q.id); }
      unseen = List.from(pool);
    }
    unseen.shuffle(dart_math.Random());
    return unseen.take(count).toList();
  }"""
content = content.replace(old_getunseen_body, "")


# 7. Replace getRandomQuestionsForDuel logic
old_duel = """  List<Question> getRandomQuestionsForDuel(int count) {
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
  }"""
new_duel = """  List<Question> getRandomQuestionsForDuel(int count) {
    if (!_isDataLoaded) return [];
    List<Question> selected = [];
    selected = _fillRemaining(selected, count);
    for (final q in selected) { _seenGlobalIds.add(q.id); }
    _saveSeenQuestions();
    return selected;
  }"""
content = content.replace(old_duel, new_duel)

# 8. startNewGame logic changes
# We need to find the startNewGame body
start_game_pattern = r"""    if \(mode == GameMode\.classic\) \{
      // Klasik mod: her zorluktan 5 soru, ayrı classic seen set kullan
      _currentQuestions = \[
        \.\.\._getGlobalUnseen\(_easyQuestions, 5\),
        \.\.\._getGlobalUnseen\(_mediumQuestions, 5\),
        \.\.\._getGlobalUnseen\(_hardQuestions, 5\),
      \];
      // Hepsini classic seen'e ekle
      for \(final q in _currentQuestions\) \{ _seenClassicIds\.add\(q\.id\); \}
    \} else \{
      // Endless mod: ayrı endless seen set kullan
      final unseenEasy = _easyQuestions\.where\(\(q\) => !_seenEndlessIds\.contains\(q\.id\)\)\.toList\(\)\.\.shuffle\(\);
      final unseenMedium = _mediumQuestions\.where\(\(q\) => !_seenEndlessIds\.contains\(q\.id\)\)\.toList\(\)\.\.shuffle\(\);
      final unseenHard = _hardQuestions\.where\(\(q\) => !_seenEndlessIds\.contains\(q\.id\)\)\.toList\(\)\.\.shuffle\(\);
      
      _currentQuestions = \[\.\.\.unseenEasy, \.\.\.unseenMedium, \.\.\.unseenHard\];
      
      if \(_currentQuestions\.isEmpty\) \{
        // Tüm sorular görüldü, sıfırla
        _seenEndlessIds\.clear\(\);
        _currentQuestions = \[
          \.\.\._easyQuestions\.\.shuffle\(\),
          \.\.\._mediumQuestions\.\.shuffle\(\),
          \.\.\._hardQuestions\.\.shuffle\(\)
        \];
        if \(_currentQuestions\.isNotEmpty\) \{
          for \(final q in _currentQuestions\) \{ _seenEndlessIds\.add\(q\.id\); \}
        \}
      \} else \{
        for \(final q in _currentQuestions\) \{ _seenEndlessIds\.add\(q\.id\); \}
      \}
    \}"""

new_start_game = """    if (mode == GameMode.classic) {
      _currentQuestions = [
        ..._getGlobalUnseen(_easyQuestions, 5),
        ..._getGlobalUnseen(_mediumQuestions, 5),
        ..._getGlobalUnseen(_hardQuestions, 5),
      ];
      _currentQuestions = _fillRemaining(_currentQuestions, 15);
      for (final q in _currentQuestions) { _seenGlobalIds.add(q.id); }
    } else {
      // Endless mod
      List<Question> endlessQ = [];
      endlessQ = _fillRemaining(endlessQ, 100); // 100 soru buffer alalim
      _currentQuestions = endlessQ;
      for (final q in _currentQuestions) { _seenGlobalIds.add(q.id); }
    }"""
content = re.sub(start_game_pattern, new_start_game, content, flags=re.MULTILINE|re.DOTALL)


# Final fallback replacing remaining _seenClassicIds
content = content.replace("_seenClassicIds", "_seenGlobalIds")
content = content.replace("_seenEndlessIds", "_seenGlobalIds")
content = content.replace("_seenDuelIds", "_seenGlobalIds")

# Check if there are any errors or missing imports
with open(path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Python script executed successfully.")
