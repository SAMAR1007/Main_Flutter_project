import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'dart:io';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal();

  String? _token;

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  String? get token => _token;

  Map<String, String> _getHeaders({bool isJson = true}) {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (isJson) {
      headers['Content-Type'] = 'application/json';
    }
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<dynamic> post({
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: _getHeaders(),
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      return _handleResponse(response);
    } on SocketException {
      throw Exception('No internet connection');
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<dynamic> get({
    required String endpoint,
    Map<String, String>? queryParams,
  }) async {
    try {
      var uri = Uri.parse(endpoint);
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }
      final response = await http.get(
        uri,
        headers: _getHeaders(),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      return _handleResponse(response);
    } on SocketException {
      throw Exception('No internet connection');
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<dynamic> put({
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(endpoint),
        headers: _getHeaders(),
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      return _handleResponse(response);
    } on SocketException {
      throw Exception('No internet connection');
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<dynamic> patch({
    required String endpoint,
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse(endpoint),
        headers: _getHeaders(),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      return _handleResponse(response);
    } on SocketException {
      throw Exception('No internet connection');
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<dynamic> delete({
    required String endpoint,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse(endpoint),
        headers: _getHeaders(),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      return _handleResponse(response);
    } on SocketException {
      throw Exception('No internet connection');
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Multipart PUT for profile update with optional image
  Future<dynamic> putMultipart({
    required String endpoint,
    required Map<String, String> fields,
    File? imageFile,
    String imageFieldName = 'image',
  }) async {
    try {
      final uri = Uri.parse(endpoint);
      final request = http.MultipartRequest('PUT', uri);

      // Only set Authorization header; Content-Type is managed by MultipartRequest
      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }
      request.fields.addAll(fields);

      if (imageFile != null) {
        final ext = imageFile.path.split('.').last.toLowerCase();
        final mimeType = switch (ext) {
          'jpg' || 'jpeg' => 'image/jpeg',
          'png' => 'image/png',
          'gif' => 'image/gif',
          'webp' => 'image/webp',
          'avif' => 'image/avif',
          _ => 'image/jpeg', // default to jpeg for camera captures
        };
        request.files.add(
          await http.MultipartFile.fromPath(
            imageFieldName,
            imageFile.path,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw Exception('Request timeout'),
      );

      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } on SocketException {
      throw Exception('No internet connection');
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    // Guard against non-JSON responses (e.g. HTML error pages)
    final contentType = response.headers['content-type'] ?? '';
    if (response.body.trimLeft().startsWith('<') || contentType.contains('text/html')) {
      throw Exception('Server returned an unexpected response. Please check your connection and try again.');
    }

    final body = jsonDecode(response.body);
    switch (response.statusCode) {
      case 200:
      case 201:
        return body;
      case 400:
        throw Exception(body['message'] ?? 'Bad request');
      case 401:
        clearToken();
        throw Exception(body['message'] ?? 'Unauthorized');
      case 403:
        throw Exception(body['message'] ?? 'Forbidden');
      case 404:
        throw Exception(body['message'] ?? 'Not found');
      case 409:
        throw Exception(body['message'] ?? 'Conflict');
      case 500:
        throw Exception(body['message'] ?? 'Server error');
      default:
        throw Exception(body['message'] ?? 'Something went wrong');
    }
  }
}
