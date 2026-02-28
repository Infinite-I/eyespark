// lib/services/ble_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/obstacle_data.dart';
import '../models/device_status.dart';
import '../models/user_settings.dart';

class BLEService extends ChangeNotifier {
  static final BLEService _instance = BLEService._internal();
  factory BLEService() => _instance;
  BLEService._internal();

  static const String serviceUUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  static const String obstacleCharUUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  static const String statusCharUUID = "beb5483e-36e1-4688-b7f5-ea07361b26a9";

  BluetoothDevice? _connectedDevice;
  bool _isConnected = false;
  bool _isScanning = false;
  List<ScanResult> _scanResults = [];
  String? _lastError;

  BluetoothDevice? get connectedDevice => _connectedDevice;
  bool get isConnected => _isConnected;
  bool get isScanning => _isScanning;
  List<ScanResult> get scanResults => _scanResults;
  String? get lastError => _lastError;

  final StreamController<ObstacleData> _obstacleController =
  StreamController<ObstacleData>.broadcast();
  final StreamController<DeviceStatus> _statusController =
  StreamController<DeviceStatus>.broadcast();

  Stream<ObstacleData> get obstacleStream => _obstacleController.stream;
  Stream<DeviceStatus> get statusStream => _statusController.stream;

  Future<void> initialize() async {
    try {
      if (await FlutterBluePlus.isSupported == false) {
        _lastError = 'Bluetooth not supported on this device';
        notifyListeners();
        return;
      }

      FlutterBluePlus.adapterState.listen((state) {
        debugPrint('📡 Bluetooth state: $state');
        if (state == BluetoothAdapterState.off) {
          _lastError = 'Please enable Bluetooth';
          notifyListeners();
        }
      });

      debugPrint('✅ BLE Service initialized');
    } catch (e) {
      _lastError = 'BLE initialization error: $e';
      debugPrint('❌ $_lastError');
    }
  }

  Future<void> startScan() async {
    try {
      _scanResults.clear();
      _isScanning = true;
      _lastError = null;
      notifyListeners();

      if (await FlutterBluePlus.isScanning.first) {
        await FlutterBluePlus.stopScan();
      }

      // Version compatible avec flutter_blue_plus 1.32.8
      FlutterBluePlus.startScan(
        withServices: [], // Liste des UUIDs de services à rechercher
        timeout: const Duration(seconds: 10),
      );

      FlutterBluePlus.scanResults.listen((results) {
        _scanResults = results;
        notifyListeners();
      });

      Future.delayed(const Duration(seconds: 10), () {
        if (_isScanning) {
          stopScan();
        }
      });

      debugPrint('🔍 Scan started');
    } catch (e) {
      _lastError = 'Scan error: $e';
      _isScanning = false;
      debugPrint('❌ $_lastError');
      notifyListeners();
    }
  }

  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
      _isScanning = false;
      notifyListeners();
      debugPrint('🛑 Scan stopped');
    } catch (e) {
      _lastError = 'Stop scan error: $e';
      debugPrint('❌ $_lastError');
    }
  }

  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      _lastError = null;
      debugPrint('🔌 Connecting to ${device.platformName}...');

      await device.connect(autoConnect: false);
      await device.discoverServices();

      _connectedDevice = device;
      _isConnected = true;

      await _listenToCharacteristics(device);

      notifyListeners();
      debugPrint('✅ Connected to ${device.platformName}');
      return true;
    } catch (e) {
      _lastError = 'Connection error: $e';
      _isConnected = false;
      debugPrint('❌ $_lastError');
      notifyListeners();
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
        _connectedDevice = null;
      }
      _isConnected = false;
      notifyListeners();
      debugPrint('🔌 Disconnected');
    } catch (e) {
      _lastError = 'Disconnect error: $e';
      debugPrint('❌ $_lastError');
    }
  }

  Future<void> _listenToCharacteristics(BluetoothDevice device) async {
    try {
      List<BluetoothService> services = await device.servicesList;
      for (BluetoothService service in services) {
        if (service.uuid.toString().toLowerCase() == serviceUUID.toLowerCase()) {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toLowerCase() == obstacleCharUUID.toLowerCase()) {
              _subscribeToCharacteristic(characteristic, 'obstacle');
            } else if (characteristic.uuid.toString().toLowerCase() == statusCharUUID.toLowerCase()) {
              _subscribeToCharacteristic(characteristic, 'status');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error getting services: $e');
    }
  }

  void _subscribeToCharacteristic(BluetoothCharacteristic characteristic, String type) {
    characteristic.setNotifyValue(true);
    characteristic.lastValueStream.listen((value) {
      if (value.isNotEmpty) {
        try {
          String jsonString = utf8.decode(value);
          Map<String, dynamic> jsonData = json.decode(jsonString);

          if (type == 'obstacle') {
            ObstacleData obstacle = ObstacleData.fromJson(jsonData);
            _obstacleController.add(obstacle);
            debugPrint('📡 Obstacle received: ${obstacle.distanceCm}cm');
          } else if (type == 'status') {
            DeviceStatus status = DeviceStatus.fromJson(jsonData);
            _statusController.add(status);
            debugPrint('📊 Status received: ${status.batteryPercent}%');
          }
        } catch (e) {
          debugPrint('❌ Error parsing data: $e');
        }
      }
    });
  }

  Future<void> writeSettings(UserSettings settings) async {
    if (_connectedDevice == null || !_isConnected) return;

    try {
      Map<String, dynamic> settingsMap = {
        'type': 'settings',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'data': settings.toJson(),
      };

      String jsonString = json.encode(settingsMap);
      List<int> bytes = utf8.encode(jsonString);

      var services = await _connectedDevice!.discoverServices();
      for (var service in services) {
        if (service.uuid.toString().toLowerCase() == serviceUUID.toLowerCase()) {
          for (var characteristic in service.characteristics) {
            if (characteristic.properties.write) {
              await characteristic.write(bytes);
              debugPrint('⚙️ Settings sent to device');
              return;
            }
          }
        }
      }
    } catch (e) {
      _lastError = 'Error writing settings: $e';
      debugPrint('❌ $_lastError');
    }
  }

  List<BluetoothDevice> getDiscoveredDevices() {
    return _scanResults.map((result) => result.device).toList();
  }

  @override
  void dispose() {
    _obstacleController.close();
    _statusController.close();
    disconnect();
    super.dispose();
  }
}