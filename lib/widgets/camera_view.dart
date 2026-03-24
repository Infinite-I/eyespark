import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// A stable camera preview widget with proper constraints.
class CameraView extends StatefulWidget {
  final CameraController? controller;
  final bool showPlaceholder;

  const CameraView({
    super.key,
    required this.controller,
    this.showPlaceholder = false,
  });

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showPlaceholder) {
      return _buildPlaceholder();
    }

    final controller = widget.controller;
    if (controller == null || !controller.value.isInitialized) {
      return _buildPlaceholder();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRect(
          child: OverflowBox(
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.previewSize?.height ?? 1,
                height: controller.value.previewSize?.width ?? 1,
                child: CameraPreview(controller),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_off_rounded,
              size: 64,
              color: Colors.white38,
            ),
            const SizedBox(height: 16),
            Text(
              'Camera loading...',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ESP32 stream coming soon',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
