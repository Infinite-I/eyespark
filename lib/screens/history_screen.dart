import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
// ignore: unused_import
import '../models/obstacle_data.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detection History')),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final history = appState.getObstacleHistory(limit: 100);

          if (history.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'No detection history',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final obstacle = history[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  title: Text('${obstacle.distanceCm} cm - ${obstacle.direction}'),
                  subtitle: Text(obstacle.obstacleType),
                  trailing: Chip(
                    label: Text(obstacle.urgency.toUpperCase()),
                    backgroundColor: obstacle.urgency == 'high'
                        ? Colors.red
                        : obstacle.urgency == 'medium'
                        ? Colors.orange
                        : Colors.green,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}