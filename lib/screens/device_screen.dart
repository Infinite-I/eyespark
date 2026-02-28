// lib/screens/device_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Info'),
        backgroundColor: Colors.black,
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (!appState.isConnected) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bluetooth_disabled, size: 100, color: Colors.grey),
                  const SizedBox(height: 20),
                  const Text(
                    'No device connected',
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/connect');
                    },
                    child: const Text('Connect Device'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildInfoTile('Device Name', 'ESP32 Camera'),
              _buildInfoTile('Status', 'Connected', color: Colors.green),
              _buildInfoTile('Battery', '${appState.currentStatus?.batteryPercent ?? 85}%'),
              _buildInfoTile('Temperature', '${appState.currentStatus?.temperatureC ?? 32}°C'),
              _buildInfoTile('Uptime', appState.currentStatus?.getUptimeFormatted() ?? '2h 30m'),
              _buildInfoTile('Camera', appState.currentStatus?.cameraStatus ?? 'Active'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => appState.disconnect(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Disconnect'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, {Color color = Colors.white}) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(label, style: const TextStyle(color: Colors.grey)),
        trailing: Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}