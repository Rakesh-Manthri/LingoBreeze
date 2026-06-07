import 'package:flutter_test/flutter_test.dart';
import 'package:lingobreeze_vocab/features/vocabulary/domain/models/vocabulary_word.dart';

void main() {
  group('Vocabulary Filter & Sort Logic Tests', () {
    final word1 = VocabularyWord(
      id: '1',
      word: 'Apple',
      meaning: 'A delicious red fruit',
      translation: 'Manzana',
      createdAt: DateTime(2026, 6, 7, 10, 0, 0),
    );

    final word2 = VocabularyWord(
      id: '2',
      word: 'Beautiful',
      meaning: 'Pleasing to the eyes',
      translation: 'Hermosa',
      createdAt: DateTime(2026, 6, 7, 11, 0, 0),
    );

    final word3 = VocabularyWord(
      id: '3',
      word: 'Watermelon',
      meaning: 'A juicy summer fruit',
      translation: 'Sandía',
      createdAt: DateTime(2026, 6, 7, 9, 0, 0),
    );

    final list = [word1, word2, word3];

    test('Filter by word name', () {
      const query = 'app';
      final filtered = list.where((w) {
        return w.word.toLowerCase().contains(query) ||
            w.meaning.toLowerCase().contains(query) ||
            w.translation.toLowerCase().contains(query);
      }).toList();

      expect(filtered.length, 1);
      expect(filtered.first.word, 'Apple');
    });

    test('Filter by meaning description', () {
      const query = 'juicy';
      final filtered = list.where((w) {
        return w.word.toLowerCase().contains(query) ||
            w.meaning.toLowerCase().contains(query) ||
            w.translation.toLowerCase().contains(query);
      }).toList();

      expect(filtered.length, 1);
      expect(filtered.first.word, 'Watermelon');
    });

    test('Sort Alphabetical A-Z', () {
      final sorted = List<VocabularyWord>.from(list);
      sorted.sort((a, b) => a.word.toLowerCase().compareTo(b.word.toLowerCase()));

      expect(sorted[0].word, 'Apple');
      expect(sorted[1].word, 'Beautiful');
      expect(sorted[2].word, 'Watermelon');
    });

    test('Sort Alphabetical Z-A', () {
      final sorted = List<VocabularyWord>.from(list);
      sorted.sort((a, b) => b.word.toLowerCase().compareTo(a.word.toLowerCase()));

      expect(sorted[0].word, 'Watermelon');
      expect(sorted[1].word, 'Beautiful');
      expect(sorted[2].word, 'Apple');
    });

    test('Sort by Newest Added', () {
      final sorted = List<VocabularyWord>.from(list);
      sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      expect(sorted[0].word, 'Beautiful'); // 11:00
      expect(sorted[1].word, 'Apple');     // 10:00
      expect(sorted[2].word, 'Watermelon'); // 9:00
    });

    test('Sort by Oldest Added', () {
      final sorted = List<VocabularyWord>.from(list);
      sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      expect(sorted[0].word, 'Watermelon'); // 9:00
      expect(sorted[1].word, 'Apple');     // 10:00
      expect(sorted[2].word, 'Beautiful'); // 11:00
    });
  });
}
