import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return ListView(
            children: [
              SwitchListTile(
                title: const Text('Voice Feedback'),
                subtitle: const Text('Enable spoken alerts'),
                value: appState.settings.voiceEnabled,
                onChanged: (value) {
                  final newSettings = appState.settings.copyWith(
                    voiceEnabled: value,
                  );
                  appState.updateSettings(newSettings);
                },
              ),
              ListTile(
                title: const Text('Audio Volume'),
                subtitle: Slider(
                  value: appState.settings.audioVolume.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 10,
                  label: '${appState.settings.audioVolume}%',
                  onChanged: (value) {
                    final newSettings = appState.settings.copyWith(
                      audioVolume: value.toInt(),
                    );
                    appState.updateSettings(newSettings);
                  },
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text('Sensitivity'),
                subtitle: DropdownButton<String>(
                  value: appState.settings.sensitivity,
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('Low')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'high', child: Text('High')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      final newSettings = appState.settings.copyWith(
                        sensitivity: value,
                      );
                      appState.updateSettings(newSettings);
                    }
                  },
                ),
              ),
              SwitchListTile(
                title: const Text('Haptic Feedback'),
                subtitle: const Text('Vibrate on obstacles'),
                value: appState.settings.hapticEnabled,
                onChanged: (value) {
                  final newSettings = appState.settings.copyWith(
                    hapticEnabled: value,
                  );
                  appState.updateSettings(newSettings);
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Test Voice'),
                subtitle: const Text('Play a test announcement'),
                onTap: () => appState.ttsService.testVoice(),
              ),
            ],
          );
        },
      ),
    );
  }
}