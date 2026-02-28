// lib/services/navigation_service.dart
import 'dart:math';
// CORRECTION: Importer Offset
import 'package:flutter/material.dart';
import '../models/obstacle_data.dart';

class NavigationService {
  final Map<String, List<ObstacleData>> _obstacleMemory = {};

  static const double GRID_SIZE = 10.0;
  static const int GRID_CELLS = 20;

  void rememberObstacle(ObstacleData obstacle) {
    String cellKey = _getCellKey(obstacle.distanceCm / 100.0, obstacle.direction);

    if (!_obstacleMemory.containsKey(cellKey)) {
      _obstacleMemory[cellKey] = [];
    }

    _obstacleMemory[cellKey]!.add(obstacle);

    if (_obstacleMemory[cellKey]!.length > 10) {
      _obstacleMemory[cellKey]!.removeAt(0);
    }
  }

  String _getCellKey(double distanceMeters, String direction) {
    double angle = _directionToAngle(direction);
    // CORRECTION: Utiliser Offset correctement
    int x = ((distanceMeters * cos(angle)) + GRID_SIZE/2).clamp(0, GRID_SIZE-1).toInt();
    int y = ((distanceMeters * sin(angle)) + GRID_SIZE/2).clamp(0, GRID_SIZE-1).toInt();

    return '${x}_$y';
  }

  double _directionToAngle(String direction) {
    switch (direction) {
      case 'front': return 0;
      case 'right': return pi/2;
      case 'behind': return pi;
      case 'left': return -pi/2;
      default: return 0;
    }
  }

  // CORRECTION: Retourner List<Offset> correctement
  List<Offset> getHotspots() {
    Map<String, int> density = {};

    _obstacleMemory.forEach((cell, obstacles) {
      density[cell] = obstacles.length;
    });

    var sorted = density.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(5).map((e) {
      var parts = e.key.split('_');
      return Offset(
        double.parse(parts[0]) - GRID_SIZE/2,
        double.parse(parts[1]) - GRID_SIZE/2,
      );
    }).toList();
  }

  String suggestAlternativePath(String currentDirection) {
    var hotspots = getHotspots();
    if (hotspots.isEmpty) return 'continue straight';

    Map<String, int> directionDensity = {
      'front': 0,
      'left': 0,
      'right': 0,
      'behind': 0,
    };

    for (var hotspot in hotspots) {
      double angle = atan2(hotspot.dy, hotspot.dx);
      String dir = _angleToDirection(angle);
      directionDensity[dir] = (directionDensity[dir] ?? 0) + 1;
    }

    var safest = directionDensity.entries
        .where((e) => e.key != currentDirection)
        .reduce((a, b) => a.value < b.value ? a : b);

    return 'turn ${_getTurnDirection(currentDirection, safest.key)}';
  }

  String _angleToDirection(double angle) {
    if (angle > -pi/4 && angle < pi/4) return 'front';
    if (angle >= pi/4 && angle < 3*pi/4) return 'right';
    if (angle >= 3*pi/4 || angle < -3*pi/4) return 'behind';
    return 'left';
  }

  String _getTurnDirection(String current, String target) {
    if (current == 'front') {
      if (target == 'left') return 'left';
      if (target == 'right') return 'right';
    }
    return target;
  }

  double getObstacleDensity() {
    if (_obstacleMemory.isEmpty) return 0.0;

    int total = _obstacleMemory.values.fold(0, (sum, list) => sum + list.length);
    return total / (GRID_CELLS * GRID_CELLS);
  }

  ObstacleData? predictNextObstacle(String currentDirection) {
    var relevant = _obstacleMemory.entries
        .where((e) => e.key.startsWith('${_directionToGrid(currentDirection)}_'))
        .toList();

    if (relevant.isEmpty) return null;

    return relevant
        .expand((e) => e.value)
        .reduce((a, b) => a.timestamp > b.timestamp ? a : b);
  }

  int _directionToGrid(String direction) {
    switch (direction) {
      case 'front': return 10;
      case 'left': return 5;
      case 'right': return 15;
      case 'behind': return 10;
      default: return 10;
    }
  }
}