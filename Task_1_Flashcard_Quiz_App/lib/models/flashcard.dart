/// Represents a single flashcard with a question, answer, and optional metadata.
class Flashcard {
  final String id;
  final String question;
  final String answer;
  final String category;
  final List<String> tags;
  final String confidence; // 'New', 'Review', 'Mastered'

  const Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    this.category = 'Flutter Basics',
    this.tags = const [],
    this.confidence = 'New',
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final question = json['question'];
    final answer = json['answer'];
    final category = json['category'];
    final tags = json['tags'];
    final confidence = json['confidence'];

    if (id is! String || question is! String || answer is! String) {
      throw const FormatException('Flashcard is missing required text fields.');
    }
    if (category != null && category is! String ||
        confidence != null && confidence is! String ||
        tags != null && (tags is! List || tags.any((tag) => tag is! String))) {
      throw const FormatException('Flashcard contains invalid metadata.');
    }

    return Flashcard(
      id: id,
      question: question,
      answer: answer,
      category: category as String? ?? 'Flutter Basics',
      tags: tags == null ? const [] : List<String>.from(tags as List),
      confidence: confidence as String? ?? 'New',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'answer': answer,
    'category': category,
    'tags': tags,
    'confidence': confidence,
  };

  /// Creates a copy of this Flashcard with updated fields.
  Flashcard copyWith({
    String? id,
    String? question,
    String? answer,
    String? category,
    List<String>? tags,
    String? confidence,
  }) {
    return Flashcard(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      confidence: confidence ?? this.confidence,
    );
  }
}
