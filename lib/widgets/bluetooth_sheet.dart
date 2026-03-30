import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothSheet extends StatefulWidget {
  final Function(BluetoothDevice) onSelect;

  const BluetoothSheet({super.key, required this.onSelect});

  @override
  State<BluetoothSheet> createState() => _BluetoothSheetState();
}

class _BluetoothSheetState extends State<BluetoothSheet> {
  List<BluetoothDevice> devices = [];
  bool scanning = true;

  @override
  void initState() {
    super.initState();
    scan();
  }

  Future<void> scan() async {
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        devices = results.map((r) => r.device).toList();
        scanning = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF020617),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const Text(
            "Bluetooth Devices",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 10),

          if (scanning)
            const CircularProgressIndicator()
          else
            Expanded(
              child: ListView(
                children: devices.map((d) {
                  return ListTile(
                    title: Text(
                      d.remoteId.str,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () => widget.onSelect(d),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}