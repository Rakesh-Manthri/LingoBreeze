import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/vocabulary_word_model.dart';

abstract class VocabularyRemoteDataSource {
  Future<List<VocabularyWordModel>> getWords();
  Future<VocabularyWordModel> addWord({
    required String word,
    required String meaning,
    required String translation,
  });
}

class VocabularyRemoteDataSourceImpl implements VocabularyRemoteDataSource {
  final ApiClient client;

  VocabularyRemoteDataSourceImpl(this.client);

  @override
  Future<List<VocabularyWordModel>> getWords() async {
    final response = await client.get(ApiConstants.wordsEndpoint);
    final List data = response['data'];
    return data.map((json) => VocabularyWordModel.fromJson(json)).toList();
  }

  @override
  Future<VocabularyWordModel> addWord({
    required String word,
    required String meaning,
    required String translation,
  }) async {
    final response = await client.post(
      ApiConstants.wordsEndpoint,
      {
        'word': word,
        'meaning': meaning,
        'translation': translation,
      },
    );
    return VocabularyWordModel.fromJson(response['data']);
  }
}
