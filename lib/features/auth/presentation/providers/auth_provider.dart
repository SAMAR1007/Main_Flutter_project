import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../data/model/user_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/local_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final RegisterUseCase registerUseCase;
  final LoginUseCase loginUseCase;
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final ApiClient apiClient;
  final LocalStorageService storageService;

  AuthProvider({
    required this.registerUseCase,
    required this.loginUseCase,
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.apiClient,
    required this.storageService,
  });

  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _currentUser;
  bool _isAuthenticated = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  /// Initialize auth state from stored token
  Future<void> initAuth() async {
    try {
      final token = await storageService.getToken();
      final isLoggedIn = await storageService.isLoggedIn();

      if (token != null && isLoggedIn) {
        apiClient.setToken(token);
        // Try to fetch profile to validate token
        try {
          _currentUser = await getProfileUseCase();
          _isAuthenticated = true;
          // Update stored user data
          await storageService.saveUser(_currentUser!.toJson());
        } catch (e) {
          // Token expired or invalid — clear everything
          await _clearAuthState();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing auth: $e');
      }
    }
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String phoneNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await registerUseCase(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        phoneNumber: phoneNumber,
      );

      if (!response.success) {
        _errorMessage = response.message ?? 'Registration failed';
        return false;
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await loginUseCase(
        email: email,
        password: password,
      );

      if (!response.success || response.token == null) {
        _errorMessage = response.message ?? 'Login failed';
        return false;
      }

      // Store token and set in ApiClient
      final token = response.token!;
      apiClient.setToken(token);
      await storageService.saveToken(token);
      await storageService.setLoggedIn(true);

      // Fetch user profile
      try {
        _currentUser = await getProfileUseCase();
        await storageService.saveUser(_currentUser!.toJson());
      } catch (e) {
        if (kDebugMode) {
          print('Error fetching profile after login: $e');
        }
      }

      _isAuthenticated = true;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProfile() async {
    try {
      _currentUser = await getProfileUseCase();
      await storageService.saveUser(_currentUser!.toJson());
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching profile: $e');
      }
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? email,
    String? phoneNumber,
    String? password,
    File? image,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await updateProfileUseCase(
        userId: _currentUser!.id,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        image: image,
      );

      _currentUser = updatedUser;
      await storageService.saveUser(updatedUser.toJson());
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _clearAuthState();
    notifyListeners();
  }

  Future<void> _clearAuthState() async {
    _currentUser = null;
    _isAuthenticated = false;
    _errorMessage = null;
    apiClient.clearToken();
    await storageService.removeToken();
    await storageService.removeUser();
    await storageService.setLoggedIn(false);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
