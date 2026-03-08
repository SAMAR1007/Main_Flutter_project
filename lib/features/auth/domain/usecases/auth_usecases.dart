import 'dart:io';
import '../repositories/auth_repository.dart';
import '../../data/model/auth_response_model.dart';
import '../../data/model/user_model.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<AuthResponse> call({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String phoneNumber,
  }) {
    return repository.register(
      name: name,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      phoneNumber: phoneNumber,
    );
  }
}

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<AuthResponse> call({
    required String email,
    required String password,
  }) {
    return repository.login(
      email: email,
      password: password,
    );
  }
}

class GetProfileUseCase {
  final AuthRepository repository;

  GetProfileUseCase(this.repository);

  Future<UserModel> call() {
    return repository.getProfile();
  }
}

class UpdateProfileUseCase {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<UserModel> call({
    required String userId,
    String? name,
    String? email,
    String? phoneNumber,
    String? password,
    File? image,
  }) {
    return repository.updateProfile(
      userId: userId,
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      image: image,
    );
  }
}

class ForgotPasswordUseCase {
  final AuthRepository repository;

  ForgotPasswordUseCase(this.repository);

  Future<void> call({required String email}) {
    return repository.forgotPassword(email: email);
  }
}

class RequestOtpUseCase {
  final AuthRepository repository;

  RequestOtpUseCase(this.repository);

  Future<void> call({required String email}) {
    return repository.requestOtp(email: email);
  }
}

class VerifyOtpResetPasswordUseCase {
  final AuthRepository repository;

  VerifyOtpResetPasswordUseCase(this.repository);

  Future<void> call({
    required String email,
    required String otp,
    required String password,
  }) {
    return repository.verifyOtpAndResetPassword(
      email: email,
      otp: otp,
      password: password,
    );
  }
}
