import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothService {
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  BluetoothDevice? _connectedDevice;
  bool _isScanning = false;

  BluetoothDevice? get connectedDevice => _connectedDevice;
  bool get isScanning => _isScanning;
  bool get isConnected => _connectedDevice != null;

  Future<bool> isBluetoothOn() async {
    try {
      final state = await FlutterBluePlus.adapterState.first;
      return state == BluetoothAdapterState.on;
    } catch (e) {
      debugPrint('Bluetooth check error: $e');
      return false;
    }
  }

  /// Start scanning for BLE devices.
  Stream<BluetoothDevice> startScan({
    Duration timeout = const Duration(seconds: 10),
  }) async* {
    if (_isScanning) return;

    try {
      await FlutterBluePlus.turnOn();
      _isScanning = true;

      await FlutterBluePlus.startScan(timeout: timeout);
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (var r in results) {
          // Yield each device
        }
      });

      await for (final results in FlutterBluePlus.scanResults) {
        for (final result in results) {
          yield result.device;
        }
      }
    } catch (e) {
      debugPrint('Bluetooth scan error: $e');
    } finally {
      _isScanning = false;
      await FlutterBluePlus.stopScan();
      await _scanSubscription?.cancel();
    }
  }

  /// Scan and collect devices into a list (convenience method).
  Future<List<BluetoothDevice>> scanForDevices({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final devices = <String, BluetoothDevice>{};

    try {
      await FlutterBluePlus.turnOn();
      await FlutterBluePlus.startScan(timeout: timeout);

      await for (final results in FlutterBluePlus.scanResults) {
        for (final r in results) {
          devices[r.device.remoteId.str] = r.device;
        }
      }
    } catch (e) {
      debugPrint('Bluetooth scan error: $e');
    } finally {
      await FlutterBluePlus.stopScan();
    }

    return devices.values.toList();
  }

  /// Connect to a device.
  Future<bool> connect(BluetoothDevice device) async {
    try {
      await device.connect();
      _connectedDevice = device;
      return true;
    } catch (e) {
      debugPrint('Bluetooth connect error: $e');
      return false;
    }
  }

  /// Disconnect from current device.
  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.disconnect();
      } catch (e) {
        debugPrint('Bluetooth disconnect error: $e');
      }
      _connectedDevice = null;
    }
  }
}
