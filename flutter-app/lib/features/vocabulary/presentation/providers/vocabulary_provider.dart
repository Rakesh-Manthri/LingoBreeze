import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/models/vocabulary_word.dart';
import '../../domain/repositories/vocabulary_repository.dart';
import '../../data/datasources/vocabulary_remote_datasource.dart';
import '../../data/repositories/vocabulary_repository_impl.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final vocabularyRemoteDataSourceProvider = Provider<VocabularyRemoteDataSource>((ref) {
  return VocabularyRemoteDataSourceImpl(ref.watch(apiClientProvider));
});

final vocabularyRepositoryProvider = Provider<VocabularyRepository>((ref) {
  return VocabularyRepositoryImpl(ref.watch(vocabularyRemoteDataSourceProvider));
});

class VocabularyNotifier extends AsyncNotifier<List<VocabularyWord>> {
  late VocabularyRepository _repository;

  @override
  Future<List<VocabularyWord>> build() async {
    _repository = ref.watch(vocabularyRepositoryProvider);
    return await _repository.getWords();
  }

  Future<void> loadWords() async {
    state = const AsyncValue.loading();
    try {
      final words = await _repository.getWords();
      state = AsyncValue.data(words);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addWord({
    required String word,
    required String meaning,
    required String translation,
  }) async {
    final previousState = state;
    try {
      final newWord = await _repository.addWord(
        word: word,
        meaning: meaning,
        translation: translation,
      );
      
      if (previousState.hasValue) {
        state = AsyncValue.data([newWord, ...previousState.value!]);
      } else {
        state = AsyncValue.data([newWord]);
      }
    } catch (e) {
      // Allow the UI to handle the error, but restore previous state if needed
      rethrow;
    }
  }
}

final vocabularyProvider = AsyncNotifierProvider<VocabularyNotifier, List<VocabularyWord>>(() {
  return VocabularyNotifier();
});

enum SortOption {
  newestAdded,
  oldestAdded,
  alphabeticalAZ,
  alphabeticalZA,
}

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(() {
  return SearchQueryNotifier();
});

class SortByNotifier extends Notifier<SortOption> {
  @override
  SortOption build() => SortOption.newestAdded;

  void update(SortOption option) => state = option;
}

final sortByProvider = NotifierProvider<SortByNotifier, SortOption>(() {
  return SortByNotifier();
});

final filteredVocabularyProvider = Provider<AsyncValue<List<VocabularyWord>>>((ref) {
  final wordsAsync = ref.watch(vocabularyProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  final sortBy = ref.watch(sortByProvider);

  return wordsAsync.whenData((words) {
    var filtered = List<VocabularyWord>.from(words);
    
    // 1. Filter by search query
    if (query.isNotEmpty) {
      filtered = filtered.where((word) {
        return word.word.toLowerCase().contains(query) ||
            word.meaning.toLowerCase().contains(query) ||
            word.translation.toLowerCase().contains(query);
      }).toList();
    }

    // 2. Sort by selected option
    switch (sortBy) {
      case SortOption.newestAdded:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.oldestAdded:
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortOption.alphabeticalAZ:
        filtered.sort((a, b) => a.word.toLowerCase().compareTo(b.word.toLowerCase()));
        break;
      case SortOption.alphabeticalZA:
        filtered.sort((a, b) => b.word.toLowerCase().compareTo(a.word.toLowerCase()));
        break;
    }
    
    return filtered;
  });
});

