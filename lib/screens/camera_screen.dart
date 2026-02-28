// lib/screens/camera_screen.dart
import 'dart:typed_data'; // ADD THIS IMPORT
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/esp32_cam_service.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final TextEditingController _ipController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ESP32-CAM Viewer'),
        backgroundColor: AppTheme.surfaceDark,
      ),
      body: Consumer2<AppState, ESP32CamService>(
        builder: (context, appState, camService, child) {
          return Column(
            children: [
              _buildConnectionBar(context, appState, camService),
              Expanded(
                child: _buildVideoStream(camService),
              ),
              if (camService.isConnected)
                _buildCameraControls(camService),
            ],
          );
        },
      ),
    );
  }

  Widget _buildConnectionBar(BuildContext context, AppState appState, ESP32CamService camService) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: AppTheme.surfaceDark,
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: appState.isConnected ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'ESP32: ${appState.isConnected ? 'Connected' : 'Disconnected'}',
            style: const TextStyle(color: Colors.white),
          ),
          const Spacer(),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: camService.isConnected ? Colors.green : Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Camera: ${camService.isConnected ? 'Connected' : 'Disconnected'}',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(width: 16),
          if (!camService.isConnected)
            ElevatedButton.icon(
              onPressed: () => _showConnectDialog(context),
              icon: const Icon(Icons.videocam),
              label: const Text('Connect Camera'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => camService.disconnect(),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoStream(ESP32CamService camService) {
    if (!camService.isConnected) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_off,
              size: 100,
              color: Colors.grey[800],
            ),
            const SizedBox(height: 20),
            const Text(
              'Camera not connected',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Connect to ESP32-CAM to see the stream',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (!camService.isStreaming) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Stream stopped'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => camService.startStream(),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Stream'),
            ),
          ],
        ),
      );
    }

    if (camService.lastFrame.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Center(
      child: Image.memory(
        camService.lastFrame, // Now this is Uint8List, compatible with Image.memory
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Text('Error loading image'),
          );
        },
      ),
    );
  }

  Widget _buildCameraControls(ESP32CamService camService) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.surfaceDark,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: () async {
              final photo = await camService.capturePhoto();
              if (photo != null && mounted) {
                _showPhotoPreview(context, photo);
              }
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Photo'),
          ),
          IconButton(
            icon: const Icon(Icons.flashlight_on),
            onPressed: () => camService.setFlash(true),
          ),
          IconButton(
            icon: const Icon(Icons.flashlight_off),
            onPressed: () => camService.setFlash(false),
          ),
          IconButton(
            icon: Icon(camService.isStreaming ? Icons.stop : Icons.play_arrow),
            onPressed: () {
              if (camService.isStreaming) {
                camService.stopStream();
              } else {
                camService.startStream();
              }
            },
          ),
        ],
      ),
    );
  }

  void _showConnectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connect ESP32-CAM'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter camera IP address'),
            const SizedBox(height: 16),
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: 'IP Address',
                hintText: '192.168.1.100',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final camService = Provider.of<ESP32CamService>(context, listen: false);
              bool success = await camService.connectToCamera(_ipController.text);
              if (success && mounted) {
                Navigator.pop(context);
                camService.startStream();
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to connect to camera'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  void _showPhotoPreview(BuildContext context, Uint8List photo) { // CHANGE parameter type
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Captured Photo'),
        content: Image.memory(photo), // Now compatible
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}