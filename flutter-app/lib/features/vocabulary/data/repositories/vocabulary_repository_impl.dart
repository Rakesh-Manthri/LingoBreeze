import '../../domain/models/vocabulary_word.dart';
import '../../domain/repositories/vocabulary_repository.dart';
import '../datasources/vocabulary_remote_datasource.dart';

class VocabularyRepositoryImpl implements VocabularyRepository {
  final VocabularyRemoteDataSource remoteDataSource;

  VocabularyRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<VocabularyWord>> getWords() async {
    return await remoteDataSource.getWords();
  }

  @override
  Future<VocabularyWord> addWord({
    required String word,
    required String meaning,
    required String translation,
  }) async {
    return await remoteDataSource.addWord(
      word: word,
      meaning: meaning,
      translation: translation,
    );
  }
}
