import 'package:flutter/foundation.dart';
import 'dart:io';
import '../../model/auth_response_model.dart';
import '../../model/user_model.dart';
import 'auth_remote_datasource.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String phoneNumber,
  }) async {
    try {
      final response = await apiClient.post(
        endpoint: ApiEndpoints.register,
        body: {
          'name': name,
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
          'phoneNumber': phoneNumber,
        },
      );

      return AuthResponse.fromRegisterJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Register Error: $e');
      }
      rethrow;
    }
  }

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.post(
        endpoint: ApiEndpoints.login,
        body: {
          'email': email,
          'password': password,
        },
      );

      return AuthResponse.fromLoginJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Login Error: $e');
      }
      rethrow;
    }
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      final response = await apiClient.get(
        endpoint: ApiEndpoints.profile,
      );
      final data = response['data'];
      return UserModel.fromJson(data);
    } catch (e) {
      if (kDebugMode) {
        print('Get Profile Error: $e');
      }
      rethrow;
    }
  }

  @override
  Future<UserModel> updateProfile({
    required String userId,
    String? name,
    String? email,
    String? phoneNumber,
    String? password,
    File? image,
  }) async {
    try {
      final fields = <String, String>{};
      if (name != null) fields['name'] = name;
      if (email != null) fields['email'] = email;
      if (phoneNumber != null) fields['phoneNumber'] = phoneNumber;
      if (password != null) fields['password'] = password;

      final response = await apiClient.putMultipart(
        endpoint: ApiEndpoints.updateUser(userId),
        fields: fields,
        imageFile: image,
      );

      final data = response['data'];
      return UserModel.fromJson(data);
    } catch (e) {
      if (kDebugMode) {
        print('Update Profile Error: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await apiClient.post(
        endpoint: ApiEndpoints.forgotPassword,
        body: {'email': email},
      );
    } catch (e) {
      if (kDebugMode) {
        print('Forgot Password Error: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> requestOtp({required String email}) async {
    try {
      await apiClient.post(
        endpoint: ApiEndpoints.otpRequest,
        body: {'email': email},
      );
    } catch (e) {
      if (kDebugMode) {
        print('Request OTP Error: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> verifyOtpAndResetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    try {
      await apiClient.post(
        endpoint: ApiEndpoints.otpVerify,
        body: {
          'email': email,
          'otp': otp,
          'password': password,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Verify OTP Error: $e');
      }
      rethrow;
    }
  }
}
