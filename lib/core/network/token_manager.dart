import 'dart:convert';
import 'local_storage_service.dart';

class TokenManager {
  static final TokenManager _instance = TokenManager._internal();

  factory TokenManager() {
    return _instance;
  }

  TokenManager._internal();

  final _storageService = LocalStorageService();

  Future<String?> getToken() async {
    return _storageService.getToken();
  }

  Future<void> saveToken(String token) async {
    await _storageService.saveToken(token);
  }

  Future<void> removeToken() async {
    await _storageService.removeToken();
  }

  bool isTokenExpired(String token) {
    try {
      // JWT format: header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = parts[1];
      // Add padding if needed
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final json = jsonDecode(decoded);

      final exp = json['exp'] as int?;
      if (exp == null) return true;

      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expiryDate);
    } catch (e) {
      return true;
    }
  }
}
