import '../../domain/models/vocabulary_word.dart';

class VocabularyWordModel extends VocabularyWord {
  const VocabularyWordModel({
    required super.id,
    required super.word,
    required super.meaning,
    required super.translation,
    required super.createdAt,
  });

  factory VocabularyWordModel.fromJson(Map<String, dynamic> json) {
    return VocabularyWordModel(
      id: json['id'],
      word: json['word'],
      meaning: json['meaning'],
      translation: json['translation'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'meaning': meaning,
      'translation': translation,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
