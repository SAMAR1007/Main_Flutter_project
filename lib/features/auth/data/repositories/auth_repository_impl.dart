import 'dart:io';
import '../model/auth_response_model.dart';
import '../model/user_model.dart';
import '../datasource/remote/auth_remote_datasource.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String phoneNumber,
  }) async {
    return await remoteDataSource.register(
      name: name,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      phoneNumber: phoneNumber,
    );
  }

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return await remoteDataSource.login(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserModel> getProfile() async {
    return await remoteDataSource.getProfile();
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
    return await remoteDataSource.updateProfile(
      userId: userId,
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      image: image,
    );
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await remoteDataSource.forgotPassword(email: email);
  }

  @override
  Future<void> requestOtp({required String email}) async {
    await remoteDataSource.requestOtp(email: email);
  }

  @override
  Future<void> verifyOtpAndResetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    await remoteDataSource.verifyOtpAndResetPassword(
      email: email,
      otp: otp,
      password: password,
    );
  }
}
