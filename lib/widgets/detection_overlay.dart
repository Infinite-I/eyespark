import 'package:flutter/material.dart';
import '../models/detected_object.dart';

class DetectionOverlay extends StatelessWidget {
  final List<DetectedObject> objects;

  const DetectionOverlay({
    super.key,
    required this.objects,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: objects.map((obj) {
        return Positioned(
          left: obj.boundingBox.left,
          top: obj.boundingBox.top,
          child: Container(
            width: obj.boundingBox.width,
            height: obj.boundingBox.height,
            decoration: BoxDecoration(
              border: Border.all(
                color: obj.isObstacle ? Colors.red : Colors.green,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                color: Colors.black.withOpacity(0.7),
                child: Text(
                  "${obj.label} ${(obj.confidence * 100).toInt()}%",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}