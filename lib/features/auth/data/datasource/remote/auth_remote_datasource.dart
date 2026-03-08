import '../../model/auth_response_model.dart';
import '../../model/user_model.dart';
import 'dart:io';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String phoneNumber,
  });

  Future<AuthResponse> login({
    required String email,
    required String password,
  });

  Future<UserModel> getProfile();

  Future<UserModel> updateProfile({
    required String userId,
    String? name,
    String? email,
    String? phoneNumber,
    String? password,
    File? image,
  });

  Future<void> forgotPassword({required String email});

  Future<void> requestOtp({required String email});

  Future<void> verifyOtpAndResetPassword({
    required String email,
    required String otp,
    required String password,
  });
}
