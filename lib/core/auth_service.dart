import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import '../data/models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

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
    final box = Hive.box<User>('users');
    return box.get(email);
  }
}
