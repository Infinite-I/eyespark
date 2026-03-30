import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothService {
  Future<List<BluetoothDevice>> scan() async {
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    final results = await FlutterBluePlus.scanResults.first;
    return results.map((r) => r.device).toList();
  }

  Future<bool> connect(BluetoothDevice device) async {
    try {
      await device.connect();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> disconnect(BluetoothDevice device) async {
    await device.disconnect();
  }
}