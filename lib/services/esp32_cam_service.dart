// lib/services/esp32_cam_service.dart
import 'dart:async';
// SUPPRIMÉ: import 'dart:typed_data'; (déjà inclus dans foundation)
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ESP32CamService extends ChangeNotifier {
  static final ESP32CamService _instance = ESP32CamService._internal();
  factory ESP32CamService() => _instance;
  ESP32CamService._internal();

  String? _cameraIp;
  bool _isConnected = false;
  bool _isStreaming = false;
  Timer? _streamTimer;
  Uint8List _lastFrame = Uint8List(0);
  int _frameRate = 5;
  String? _lastError;

  String? get cameraIp => _cameraIp;
  bool get isConnected => _isConnected;
  bool get isStreaming => _isStreaming;
  Uint8List get lastFrame => _lastFrame;
  String? get lastError => _lastError;

  Future<bool> connectToCamera(String ipAddress) async {
    try {
      _lastError = null;

      final client = http.Client();
      try {
        final response = await client
            .get(Uri.parse('http://$ipAddress/status'))
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          _cameraIp = ipAddress;
          _isConnected = true;
          notifyListeners();
          debugPrint('✅ Connected to ESP32-CAM at $ipAddress');
          return true;
        }
      } catch (e) {
        _lastError = 'Connection timeout or error: $e';
        debugPrint('❌ $_lastError');
      } finally {
        client.close();
      }
    } catch (e) {
      _lastError = 'Failed to connect: $e';
      debugPrint('❌ $_lastError');
    }
    return false;
  }

  Future<void> startStream() async {
    if (!_isConnected || _cameraIp == null) return;

    _isStreaming = true;
    notifyListeners();

    _streamTimer = Timer.periodic(
      Duration(milliseconds: (1000 / _frameRate).round()),
          (_) => _fetchFrame(),
    );

    debugPrint('📷 Stream started');
  }

  void stopStream() {
    _streamTimer?.cancel();
    _isStreaming = false;
    notifyListeners();
    debugPrint('📷 Stream stopped');
  }

  Future<void> _fetchFrame() async {
    if (_cameraIp == null) return;

    try {
      final client = http.Client();
      try {
        final response = await client
            .get(Uri.parse('http://$_cameraIp/capture'))
            .timeout(const Duration(milliseconds: 500));

        if (response.statusCode == 200) {
          _lastFrame = response.bodyBytes;
          notifyListeners();
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ Frame fetch error: $e');
        }
      } finally {
        client.close();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error in _fetchFrame: $e');
      }
    }
  }

  Future<Uint8List?> capturePhoto() async {
    if (!_isConnected || _cameraIp == null) return null;

    try {
      final client = http.Client();
      try {
        final response = await client
            .get(Uri.parse('http://$_cameraIp/capture'))
            .timeout(const Duration(seconds: 2));

        if (response.statusCode == 200) {
          debugPrint('📸 Photo captured');
          return response.bodyBytes;
        }
      } catch (e) {
        _lastError = 'Error capturing photo: $e';
        debugPrint('❌ $_lastError');
      } finally {
        client.close();
      }
    } catch (e) {
      _lastError = 'Error in capturePhoto: $e';
      debugPrint('❌ $_lastError');
    }
    return null;
  }

  Future<void> setFlash(bool on) async {
    if (!_isConnected || _cameraIp == null) return;

    try {
      final client = http.Client();
      try {
        await client.get(
          Uri.parse('http://$_cameraIp/control?var=led&val=${on ? 1 : 0}'),
        );
        debugPrint('💡 Flash ${on ? 'ON' : 'OFF'}');
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('❌ Error controlling flash: $e');
    }
  }

  void disconnect() {
    stopStream();
    _isConnected = false;
    _cameraIp = null;
    _lastFrame = Uint8List(0);
    _lastError = null;
    notifyListeners();
    debugPrint('🔌 Camera disconnected');
  }

  @override
  void dispose() {
    _streamTimer?.cancel();
    disconnect();
    super.dispose();
  }
}