import 'package:flutter/material.dart';

class ControlPanel extends StatelessWidget {
  final VoidCallback onScan;
  final VoidCallback onVoice;

  const ControlPanel({
    super.key,
    required this.onScan,
    required this.onVoice,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: onScan,
          icon: const Icon(Icons.visibility),
          label: const Text("Scan"),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: onVoice,
          icon: const Icon(Icons.mic),
          label: const Text("Voice"),
        ),
      ],
    );
  }
}