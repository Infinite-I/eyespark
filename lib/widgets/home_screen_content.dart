// lib/widgets/home_screen_content.dart (version améliorée)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/ambient_light_service.dart';
import '../theme/app_theme.dart';
import 'animated_obstacle_circle.dart';

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppState, AmbientLightService>(
      builder: (context, appState, lightService, child) {
        return Column(
          children: [
            // Status Bar améliorée
            _buildStatusBar(context, appState, lightService),

            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Cercle animé
                      AnimatedObstacleCircle(
                        distance: appState.currentObstacle?.distanceCm,
                        direction: appState.currentObstacle?.direction,
                        urgency: appState.currentObstacle?.urgency,
                        isConnected: appState.isConnected,
                      ),

                      const SizedBox(height: 32),

                      // Message de statut
                      _buildStatusMessage(appState),

                      const SizedBox(height: 48),

                      // Bouton Test Controls
                      _buildTestButton(context, appState),

                      const SizedBox(height: 24),

                      // Message d'erreur
                      if (appState.lastError != null)
                        _buildErrorMessage(appState.lastError!),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusBar(
      BuildContext context,
      AppState appState,
      AmbientLightService lightService,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: lightService.nightMode
          ? Colors.black87
          : AppTheme.surfaceDark,
      child: Row(
        children: [
          // Indicateur de statut avec animation
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: appState.isConnected
                  ? Colors.green
                  : Colors.red,
              boxShadow: [
                BoxShadow(
                  color: (appState.isConnected ? Colors.green : Colors.red)
                      .withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Texte de statut
          Text(
            appState.isConnected ? 'Connected' : 'Disconnected',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Spacer(),

          // Indicateur de mode nuit
          if (lightService.nightMode)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.nightlight, color: Colors.deepPurple, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Night Mode',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          // Indicateur de batterie
          if (appState.isConnected && appState.currentStatus != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getBatteryColor(
                  appState.currentStatus!.batteryPercent,
                ).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.battery_charging_full,
                    size: 14,
                    color: _getBatteryColor(
                      appState.currentStatus!.batteryPercent,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${appState.currentStatus!.batteryPercent}%',
                    style: TextStyle(
                      color: _getBatteryColor(
                        appState.currentStatus!.batteryPercent,
                      ),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(width: 8),

          // Bouton de connexion
          if (!appState.isConnected)
            _buildConnectButton(context),
        ],
      ),
    );
  }

  Widget _buildConnectButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, '/connect');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryBlue,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text(
        'CONNECT',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatusMessage(AppState appState) {
    if (!appState.isConnected) {
      return const Text(
        '✨ Connect your device to begin',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 16,
        ),
      );
    } else if (appState.currentObstacle == null) {
      return const Text(
        '✅ No obstacles detected',
        style: TextStyle(
          color: Colors.green,
          fontSize: 16,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildTestButton(BuildContext context, AppState appState) {
    return ElevatedButton.icon(
      onPressed: () {
        _showTestControls(context, appState);
      },
      icon: const Icon(Icons.science),
      label: const Text(
        'TEST CONTROLS',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTestControls(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _TestControlsSheet(appState: appState),
    );
  }

  Color _getBatteryColor(int percent) {
    if (percent > 60) return Colors.green;
    if (percent > 20) return Colors.orange;
    return Colors.red;
  }
}

// Sous-feuille de test
class _TestControlsSheet extends StatelessWidget {
  final AppState appState;

  const _TestControlsSheet({required this.appState});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Titre
          const Text(
            'TEST CONTROLS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          // Boutons distance
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TestButton(
                label: 'Close',
                color: Colors.orange,
                onPressed: () {
                  Navigator.pop(context);
                  appState.testObstacle(30, 'front', 'high');
                },
              ),
              _TestButton(
                label: 'Medium',
                color: Colors.yellow,
                onPressed: () {
                  Navigator.pop(context);
                  appState.testObstacle(100, 'front', 'medium');
                },
              ),
              _TestButton(
                label: 'Far',
                color: Colors.green,
                onPressed: () {
                  Navigator.pop(context);
                  appState.testObstacle(200, 'front', 'low');
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Boutons direction
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _DirectionButton(
                label: 'Front',
                icon: Icons.arrow_upward,
                onPressed: () {
                  Navigator.pop(context);
                  appState.testObstacle(100, 'front', 'medium');
                },
              ),
              _DirectionButton(
                label: 'Left',
                icon: Icons.arrow_back,
                onPressed: () {
                  Navigator.pop(context);
                  appState.testObstacle(100, 'left', 'medium');
                },
              ),
              _DirectionButton(
                label: 'Right',
                icon: Icons.arrow_forward,
                onPressed: () {
                  Navigator.pop(context);
                  appState.testObstacle(100, 'right', 'medium');
                },
              ),
              _DirectionButton(
                label: 'Behind',
                icon: Icons.arrow_downward,
                onPressed: () {
                  Navigator.pop(context);
                  appState.testObstacle(100, 'behind', 'low');
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Bouton Clear
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    appState.clearObstacle();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.clear),
                  label: const Text('CLEAR'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TestButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _TestButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.black,
        minimumSize: const Size(100, 50),
      ),
      child: Text(label),
    );
  }
}

class _DirectionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _DirectionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.grey),
        minimumSize: const Size(80, 60),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}