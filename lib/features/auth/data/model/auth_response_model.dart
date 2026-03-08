import 'user_model.dart';

class AuthResponse {
  final bool success;
  final String? token;
  final UserModel? user;
  final String? message;

  AuthResponse({
    required this.success,
    this.token,
    this.user,
    this.message,
  });

  /// Login response: { message, data: { token } }
  factory AuthResponse.fromLoginJson(Map<String, dynamic> json) {
    final data = json['data'];
    return AuthResponse(
      success: data != null && data['token'] != null,
      token: data?['token'],
      message: json['message'],
    );
  }

  /// Register response: { message, user: { ... } }
  factory AuthResponse.fromRegisterJson(Map<String, dynamic> json) {
    final userData = json['user'];
    return AuthResponse(
      success: userData != null,
      user: userData != null ? UserModel.fromJson(userData) : null,
      message: json['message'],
    );
  }

  /// Profile response: { message, data: { _id, name, email, ... } }
  factory AuthResponse.fromProfileJson(Map<String, dynamic> json) {
    final data = json['data'];
    return AuthResponse(
      success: data != null,
      user: data != null ? UserModel.fromJson(data) : null,
      message: json['message'],
    );
  }

  /// Update profile response: { message, data: { ... } }
  factory AuthResponse.fromUpdateJson(Map<String, dynamic> json) {
    final data = json['data'];
    return AuthResponse(
      success: data != null,
      user: data != null ? UserModel.fromJson(data) : null,
      message: json['message'],
    );
  }
}
