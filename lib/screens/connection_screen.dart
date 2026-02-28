// lib/screens/connection_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class ConnectionScreen extends StatelessWidget {
  const ConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Device'),
        backgroundColor: Colors.black,
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          // Afficher les erreurs dans un SnackBar
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (appState.lastError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(appState.lastError!),
                  backgroundColor: Colors.red,
                ),
              );
            }
          });

          // Si déjà connecté
          if (appState.isConnected) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.bluetooth_connected,
                    size: 100,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Device Connected',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      appState.disconnect();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text('Disconnect'),
                  ),
                ],
              ),
            );
          }

          // Liste des appareils
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Available Devices',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    if (appState.isScanning)
                      const CircularProgressIndicator()
                    else
                      ElevatedButton.icon(
                        onPressed: () => appState.startScan(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Scan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: appState.getDiscoveredDevices().isEmpty
                    ? const Center(
                  child: Text(
                    'No devices found.\nTap Scan to start searching.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
                    : ListView.builder(
                  itemCount: appState.getDiscoveredDevices().length,
                  itemBuilder: (context, index) {
                    final device = appState.getDiscoveredDevices()[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      color: Colors.grey[900],
                      child: ListTile(
                        title: Text(
                          device.platformName.isEmpty
                              ? 'Unknown Device'
                              : device.platformName,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          device.remoteId.toString(),
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () async {
                            bool success = await appState.connectToDevice(device);
                            if (success) {
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: const Text('Connect'),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}