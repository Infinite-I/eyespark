import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.bluetooth, color: Colors.cyan),
              title: const Text(
                "Bluetooth Status",
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                state.bluetoothConnected
                    ? state.bluetoothDeviceName
                    : "Not connected",
                style: const TextStyle(color: Colors.white54),
              ),
            ),

            const Divider(),

            SwitchListTile(
              value: state.obstacleDetected,
              onChanged: (_) {},
              title: const Text(
                "Obstacle Detection (Auto)",
                style: TextStyle(color: Colors.white),
              ),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: () {
                context.read<AppState>().reset();
              },
              child: const Text("Reset System"),
            ),
          ],
        ),
      ),
    );
  }
}