class Question {
  final String id;
  final String text;
  final List<String> options;
  final int correctOptionIndex;
  final int difficulty; // 1: Kolay, 2: Orta, 3: Zor
  final String category; // Sorunun kategorisi (Aynı kategoriden sorular üst üste gelmesin diye)
  final String? imageUrl; // Opsiyonel gorsel yolu

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctOptionIndex,
    required this.difficulty,
    required this.category,
    this.imageUrl,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    // ID yoksa, sorunun metninden (text) benzersiz bir ID uret
    String generatedId = json['id'] != null 
        ? json['id'].toString() 
        : json['text'].hashCode.toString();

    // Zorluk (Kolay, Orta, Zor stringleri gelirse integer'a cevir)
    int diff = 2; // default Orta
    if (json['difficulty'] != null) {
      if (json['difficulty'] is int) {
        diff = json['difficulty'];
      } else {
        String dStr = json['difficulty'].toString().toLowerCase();
        if (dStr.contains('kolay')) diff = 1;
        else if (dStr.contains('zor')) diff = 3;
      }
    }

    return Question(
      id: generatedId,
      text: json['text'],
      options: List<String>.from(json['options']),
      correctOptionIndex: json['correctOptionIndex'],
      difficulty: diff,
      category: json['category'] ?? 'Genel',
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
      'difficulty': difficulty,
      'category': category,
      'imageUrl': imageUrl,
    };
  }
}
