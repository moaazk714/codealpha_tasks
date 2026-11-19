class Quote {
  final String id;
  final String text;
  final String author;
  final String category;
  final String authorBio;
  final int quoteNumber;

  const Quote({
    required this.id,
    required this.text,
    required this.author,
    required this.category,
    required this.authorBio,
    required this.quoteNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'author': author,
      'category': category,
      'authorBio': authorBio,
      'quoteNumber': quoteNumber,
    };
  }

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      author: json['author'] as String? ?? 'Unknown',
      category: json['category'] as String? ?? 'Inspiration',
      authorBio: json['authorBio'] as String? ?? '',
      quoteNumber: json['quoteNumber'] as int? ?? 1,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Quote && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
