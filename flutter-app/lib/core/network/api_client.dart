import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../errors/failures.dart';

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConstants.timeout);
      return _processResponse(response);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      ).timeout(ApiConstants.timeout);
      return _processResponse(response);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      final message = json.decode(response.body)['error']?['message'] ?? 'Server Error';
      throw ServerFailure(message);
    }
  }
}
