// lib/services/audio_service.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

enum SoundEffect {
  connect,
  disconnect,
  alertHigh,
  alertMedium,
  alertLow,
  beacon,
  success,
  error,
}

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isMuted = false;
  double _volume = 0.8;

  // Note: Ajoutez ces fichiers dans assets/sounds/
  static const Map<SoundEffect, String> _soundPaths = {
    SoundEffect.connect: 'sounds/connect.mp3',
    SoundEffect.disconnect: 'sounds/disconnect.mp3',
    SoundEffect.alertHigh: 'sounds/alert_high.mp3',
    SoundEffect.alertMedium: 'sounds/alert_medium.mp3',
    SoundEffect.alertLow: 'sounds/alert_low.mp3',
    SoundEffect.beacon: 'sounds/beacon.mp3',
    SoundEffect.success: 'sounds/success.mp3',
    SoundEffect.error: 'sounds/error.mp3',
  };

  void setMuted(bool muted) => _isMuted = muted;
  void setVolume(double volume) => _volume = volume.clamp(0.0, 1.0);

  Future<void> playSound(SoundEffect effect) async {
    if (_isMuted) return;

    try {
      await _player.setVolume(_volume);
      await _player.play(AssetSource(_soundPaths[effect]!));
    } catch (e) {
      debugPrint('❌ Error playing sound: $e');
    }
  }

  Future<void> playAlert(String urgency) async {
    switch (urgency) {
      case 'high':
        await playSound(SoundEffect.alertHigh);
        break;
      case 'medium':
        await playSound(SoundEffect.alertMedium);
        break;
      case 'low':
        await playSound(SoundEffect.alertLow);
        break;
    }
  }

  Future<void> playBeaconPattern() async {
    if (_isMuted) return;

    // Pattern: bip...bip...bip
    for (int i = 0; i < 3; i++) {
      await playSound(SoundEffect.beacon);
      await Future.delayed(const Duration(milliseconds: 800));
    }
  }

  void dispose() {
    _player.dispose();
  }
}