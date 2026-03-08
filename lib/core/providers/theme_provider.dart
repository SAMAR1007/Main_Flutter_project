import 'dart:async';
import 'package:flutter/material.dart';
import 'package:light_sensor/light_sensor.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeOption { light, dark, auto }

class ThemeProvider extends ChangeNotifier {
  ThemeOption _themeOption = ThemeOption.light;
  ThemeMode _themeMode = ThemeMode.light;
  StreamSubscription<int>? _lightSubscription;

  // Lux threshold: below this = dark environment
  static const int _luxThreshold = 30;

  ThemeOption get themeOption => _themeOption;
  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('theme_option') ?? 'light';
    switch (saved) {
      case 'dark':
        _themeOption = ThemeOption.dark;
        _themeMode = ThemeMode.dark;
      case 'auto':
        _themeOption = ThemeOption.auto;
        _startLightSensor();
      default:
        _themeOption = ThemeOption.light;
        _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  Future<void> setTheme(ThemeOption option) async {
    _themeOption = option;
    _stopLightSensor();

    switch (option) {
      case ThemeOption.light:
        _themeMode = ThemeMode.light;
      case ThemeOption.dark:
        _themeMode = ThemeMode.dark;
      case ThemeOption.auto:
        _startLightSensor();
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_option', option.name);
    notifyListeners();
  }

  void _startLightSensor() {
    _stopLightSensor();
    try {
      _lightSubscription = LightSensor.luxStream().listen((lux) {
        final newMode = lux < _luxThreshold ? ThemeMode.dark : ThemeMode.light;
        if (_themeMode != newMode) {
          _themeMode = newMode;
          notifyListeners();
        }
      });
    } catch (_) {
      // Sensor not available — fall back to system theme
      _themeMode = ThemeMode.system;
      notifyListeners();
    }
  }

  void _stopLightSensor() {
    _lightSubscription?.cancel();
    _lightSubscription = null;
  }

  @override
  void dispose() {
    _stopLightSensor();
    super.dispose();
  }
}
