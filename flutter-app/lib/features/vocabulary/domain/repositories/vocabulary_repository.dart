import '../models/vocabulary_word.dart';

abstract class VocabularyRepository {
  Future<List<VocabularyWord>> getWords();
  Future<VocabularyWord> addWord({
    required String word,
    required String meaning,
    required String translation,
  });
}
