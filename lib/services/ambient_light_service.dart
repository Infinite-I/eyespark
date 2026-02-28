// lib/services/ambient_light_service.dart
// SUPPRIMER l'import de sensors_plus
import 'package:flutter/material.dart';
import 'dart:async';

class AmbientLightService extends ChangeNotifier {
  double _lightLevel = 0.0;
  bool _nightMode = false;
  Timer? _checkTimer;

  double get lightLevel => _lightLevel;
  bool get nightMode => _nightMode;

  static const double DARK_THRESHOLD = 10.0;
  static const double BRIGHT_THRESHOLD = 100.0;

  AmbientLightService() {
    _init();
  }

  void _init() {
    try {
      _updateNightModeByTime();

      // Mettre à jour toutes les minutes
      _checkTimer = Timer.periodic(const Duration(minutes: 1), (_) {
        _updateNightModeByTime();
      });

      debugPrint('🌙 Ambient light service initialized (time-based mode)');
    } catch (e) {
      debugPrint('❌ Ambient light service error: $e');
      _updateNightModeByTime();
    }
  }

  void _updateNightModeByTime() {
    var hour = DateTime.now().hour;
    bool newMode = hour < 6 || hour > 20;
    if (newMode != _nightMode) {
      _nightMode = newMode;
      notifyListeners();
      debugPrint('🌙 Night mode: $_nightMode (hour: $hour)');
    }
  }

  double getRecommendedVolume() {
    if (_nightMode) return 0.3;
    if (_lightLevel < 50) return 0.5;
    return 0.8;
  }

  double getRecommendedBrightness() {
    if (_nightMode) return 0.2;
    if (_lightLevel > BRIGHT_THRESHOLD) return 1.0;
    return 0.6;
  }

  Color getRecommendedThemeColor() {
    if (_nightMode) return Colors.deepPurple;
    if (_lightLevel > BRIGHT_THRESHOLD) return Colors.amber;
    return Colors.blue;
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }
}