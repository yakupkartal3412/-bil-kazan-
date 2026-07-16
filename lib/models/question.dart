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
    return Question(
      id: json['id'].toString(),
      text: json['text'],
      options: List<String>.from(json['options']),
      correctOptionIndex: json['correctOptionIndex'],
      difficulty: json['difficulty'],
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
