import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraView extends StatelessWidget {
  final CameraController? controller;
  final Widget? fallback;

  const CameraView({
    super.key,
    required this.controller,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    if (controller != null && controller!.value.isInitialized) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CameraPreview(controller!),
      );
    }

    return fallback ??
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF020617)],
            ),
          ),
          child: const Center(
            child: Text(
              "No Camera Feed",
              style: TextStyle(color: Colors.white54),
            ),
          ),
        );
  }
}