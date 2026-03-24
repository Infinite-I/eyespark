import 'dart:ui';

import 'package:flutter/material.dart';

import '../providers/app_state.dart';

/// Overlays bounding boxes and labels for detected objects.
class DetectionOverlay extends StatelessWidget {
  final List<DetectedObjectInfo> objects;
  final Size imageSize;
  final Size previewSize;
  final bool mirror;

  const DetectionOverlay({
    super.key,
    required this.objects,
    required this.imageSize,
    required this.previewSize,
    this.mirror = false,
  });

  @override
  Widget build(BuildContext context) {
    if (objects.isEmpty) return const SizedBox.shrink();

    return CustomPaint(
      painter: _DetectionPainter(
        objects: objects,
        imageSize: imageSize,
        previewSize: previewSize,
        mirror: mirror,
      ),
      size: Size.infinite,
    );
  }
}

class _DetectionPainter extends CustomPainter {
  final List<DetectedObjectInfo> objects;
  final Size imageSize;
  final Size previewSize;
  final bool mirror;

  _DetectionPainter({
    required this.objects,
    required this.imageSize,
    required this.previewSize,
    required this.mirror,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (imageSize.width == 0 || imageSize.height == 0) return;

    final scaleX = size.width / imageSize.height;
    final scaleY = size.height / imageSize.width;
    final scale = scaleX < scaleY ? scaleX : scaleY;
    final offsetX = (size.width - imageSize.height * scale) / 2;
    final offsetY = (size.height - imageSize.width * scale) / 2;

    for (final obj in objects) {
      double left = obj.boundingBox.left;
      double top = obj.boundingBox.top;
      double right = obj.boundingBox.right;
      double bottom = obj.boundingBox.bottom;

      if (mirror) {
        left = imageSize.height - obj.boundingBox.right;
        right = imageSize.height - obj.boundingBox.left;
      }

      final rect = Rect.fromLTRB(
        offsetX + left * scale,
        offsetY + top * scale,
        offsetX + right * scale,
        offsetY + bottom * scale,
      );

      // Glowing border
      final paint = Paint()
        ..color = Colors.cyan.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawRect(rect, paint);

      // Label background
      final label = '${obj.label} ${(obj.confidence * 100).round()}%';
      final textSpan = TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final labelRect = Rect.fromLTWH(
        rect.left,
        rect.top - 20,
        textPainter.width + 8,
        18,
      );

      final bgPaint = Paint()
        ..color = Colors.cyan.withOpacity(0.9)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(labelRect, const Radius.circular(4)),
        bgPaint,
      );
      textPainter.paint(
        canvas,
        Offset(rect.left + 4, rect.top - 18),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DetectionPainter oldDelegate) {
    return oldDelegate.objects != objects;
  }
}
