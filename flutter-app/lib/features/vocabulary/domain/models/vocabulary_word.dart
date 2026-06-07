class VocabularyWord {
  final String id;
  final String word;
  final String meaning;
  final String translation;
  final DateTime createdAt;

  const VocabularyWord({
    required this.id,
    required this.word,
    required this.meaning,
    required this.translation,
    required this.createdAt,
  });
}
