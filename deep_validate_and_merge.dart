import 'dart:io';
import 'dart:convert';
import 'dart:math';

String normalizeText(String text) {
  return text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9ğüşıöç]'), '').trim();
}

void main() async {
  List<dynamic> finalQuestions = [];
  Set<String> seenTexts = {};
  Random rand = Random();
  
  // We want EXACTLY 2369 questions in questions.json 
  // so that 2369 + 631 (event_questions) = 3000 TOTAL.
  final int targetLimit = 2369;

  File mainFile = File('assets/questions.json');
  if (await mainFile.exists()) {
    String content = await mainFile.readAsString();
    List<dynamic> existing = json.decode(content);
    for (var item in existing) {
      if (item is Map && item.containsKey('text')) {
        String norm = normalizeText(item['text'].toString());
        if (!seenTexts.contains(norm)) {
          seenTexts.add(norm);
          finalQuestions.add(item);
        }
      }
    }
    print('Loaded ${finalQuestions.length} existing valid questions.');
  }

  int addedCount = 0;
  int duplicateCount = 0;
  int errorCount = 0;

  Directory brainDir = Directory(r'C:\Users\lenovo\.gemini\antigravity\brain');
  List<FileSystemEntity> agentDirs = brainDir.listSync().whereType<Directory>().toList();
  
  for (var dir in agentDirs) {
    if (finalQuestions.length >= targetLimit) break; // Reached exactly our limit
    
    Directory scratchDir = Directory('${dir.path}/scratch');
    if (scratchDir.existsSync()) {
      var files = scratchDir.listSync().whereType<File>().where((f) => f.path.contains(RegExp(r'b_new_\d+\.json$'))).toList();
      for (var f in files) {
        if (finalQuestions.length >= targetLimit) break; // Limit check inside file loop
        try {
          String content = f.readAsStringSync();
          content = content.replaceAll('```json', '').replaceAll('```', '').trim();
          List<dynamic> items = json.decode(content);
          
          for (var q in items) {
            if (finalQuestions.length >= targetLimit) break; // Limit check per item
            
            if (q is Map && q.containsKey('text') && q.containsKey('options')) {
              List<dynamic> opts = q['options'];
              if (opts.length == 4) {
                Set<String> optSet = opts.map((e) => e.toString().trim()).toSet();
                if (optSet.length < 4) {
                  errorCount++;
                  continue;
                }
                
                String norm = normalizeText(q['text'].toString());
                if (seenTexts.contains(norm)) {
                  duplicateCount++;
                } else {
                  seenTexts.add(norm);
                  int origCorrectIdx = q['correctOptionIndex'] is int ? q['correctOptionIndex'] : 0;
                  if (origCorrectIdx < 0 || origCorrectIdx > 3) origCorrectIdx = 0;
                  
                  String correctText = opts[origCorrectIdx].toString();
                  opts.shuffle(rand);
                  q['correctOptionIndex'] = opts.indexOf(correctText);
                  
                  finalQuestions.add(q);
                  addedCount++;
                }
              } else {
                errorCount++;
              }
            } else {
              errorCount++;
            }
          }
        } catch (e) {
          print('Error reading ${f.path}: $e');
        }
      }
    }
  }

  print('Generated Added: $addedCount');
  print('Duplicates Dropped: $duplicateCount');
  print('Errors Dropped: $errorCount');
  print('Total Final Questions: ${finalQuestions.length}');

  JsonEncoder encoder = JsonEncoder.withIndent('  ');
  await mainFile.writeAsString(encoder.convert(finalQuestions));
  print('Deep validation and exact limit merge complete. Saved to assets/questions.json');
}
