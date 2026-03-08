import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import '../data/models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Use 10.0.2.2 for Android emulator (maps to host machine)
  // Use localhost for iOS simulator
  static const String _backendUrl = 'http://10.0.2.2:3002/api/v1';

  Future<bool> signup(User user) async {
    final box = Hive.box<User>('users');
    final String emailKey = user.email.toLowerCase();
    if (box.containsKey(emailKey)) {
      return false; // already registered
    }
    await box.put(emailKey, user);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('logged_in_email', emailKey);
    return true;
  }

  Future<bool> login(String email, String password) async {
    final String emailKey = email.toLowerCase();
    final box = Hive.box<User>('users');
    if (!box.containsKey(emailKey)) return false;
    final user = box.get(emailKey);
    if (user == null) return false;
    if (user.password != password) return false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('logged_in_email', emailKey);
    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    await prefs.remove('logged_in_email');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  Future<User?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('logged_in_email');
    if (email == null) return null;
    
    // Try to get from Hive if box is initialized
    try {
      if (Hive.isBoxOpen('users')) {
        final box = Hive.box<User>('users');
        final user = box.get(email);
        if (user != null) return user;
      }
    } catch (e) {
      // Box not initialized, continue to SharedPreferences fallback
    }
    
    // If not in Hive, try to get from SharedPreferences
    final name = prefs.getString('logged_in_name');
    final profilePicture = prefs.getString('logged_in_profile_picture');
    
    if (name != null) {
      // Create a user object from SharedPreferences data
      return User(
        name: name,
        email: email,
        phone: '', // Phone not stored locally
        password: '', // Password not stored locally for security
        profilePicture: profilePicture,
      );
    }
    
    return null;
  }

  Future<String> uploadProfilePicture(File imageFile) async {
    try {
      final user = await currentUser();
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_backendUrl/auth/upload-profile-picture'),
      );

      // Add file with explicit content type
      final fileBytes = await imageFile.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'profilePicture',
          fileBytes,
          filename: 'profile_picture.jpg',
          contentType: http.MediaType('image', 'jpeg'),
        ),
      );

      // Add user email
      request.fields['email'] = user.email;

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // Parse response and extract image URL
        final Map<String, dynamic> data = json.decode(response.body);
        if (!data['success']) {
          throw Exception(data['message'] ?? 'Upload failed');
        }
        
        final imageUrl = data['imageUrl'];
        
        // Update local user data
        final prefs = await SharedPreferences.getInstance();
        final email = prefs.getString('logged_in_email');
        if (email != null) {
          // Update SharedPreferences
          await prefs.setString('logged_in_profile_picture', imageUrl);
          
          // Also update Hive if available
          try {
            if (Hive.isBoxOpen('users')) {
              final box = Hive.box<User>('users');
              final currentUser = box.get(email);
              if (currentUser != null) {
                currentUser.profilePicture = imageUrl;
                await box.put(email, currentUser);
              }
            }
          } catch (e) {
            // Hive box not available, SharedPreferences update is sufficient
          }
        }

        return imageUrl;
      } else {
        final errorBody = response.body;
        throw Exception('Failed to upload image: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      throw Exception('Error uploading profile picture: $e');
    }
  }
}
