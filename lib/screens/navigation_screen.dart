// lib/screens/navigation_screen.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  Position? _currentPosition;
  String _locationMessage = 'Localisation en cours...';
  bool _isLoading = false;
  List<Position> _locationHistory = [];

  @override
  void initState() {
    super.initState();
    _checkLocationServices();
  }

  Future<void> _checkLocationServices() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationMessage = '⚠️ Service de localisation désactivé';
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationMessage = '⚠️ Permission de localisation refusée';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationMessage = '⚠️ Permission définitivement refusée';
      });
      return;
    }

    _getCurrentLocation();
    _startLocationUpdates();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _locationMessage = 'Obtention de la position...';
    });

    try {
      // CORRECT pour geolocator 10.1.0
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _locationMessage = '📍 Lat: ${position.latitude.toStringAsFixed(6)}\n'
            'Lon: ${position.longitude.toStringAsFixed(6)}\n'
            'Altitude: ${position.altitude.toStringAsFixed(1)}m\n'
            'Précision: ${position.accuracy.toStringAsFixed(1)}m';
        _isLoading = false;
      });

      _locationHistory.add(position);
      if (_locationHistory.length > 10) {
        _locationHistory.removeAt(0);
      }
    } catch (e) {
      setState(() {
        _locationMessage = '❌ Erreur: $e';
        _isLoading = false;
      });
    }
  }

  void _startLocationUpdates() {
    // CORRECTION: Version geolocator 10.1.0 - paramètres corrects
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    Geolocator.getPositionStream(
      locationSettings: locationSettings, // Paramètre correct
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _locationMessage = '📍 Lat: ${position.latitude.toStringAsFixed(6)}\n'
              'Lon: ${position.longitude.toStringAsFixed(6)}';
        });

        _locationHistory.add(position);
        if (_locationHistory.length > 20) {
          _locationHistory.removeAt(0);
        }
      }
    });
  }

  double _calculateDistance(Position start, Position end) {
    return Geolocator.distanceBetween(
      start.latitude, start.longitude,
      end.latitude, end.longitude,
    );
  }

  double _calculateTotalDistance() {
    if (_locationHistory.length < 2) return 0.0;
    double total = 0.0;
    for (int i = 1; i < _locationHistory.length; i++) {
      total += _calculateDistance(_locationHistory[i - 1], _locationHistory[i]);
    }
    return total;
  }

  double _calculateAverageSpeed() {
    if (_locationHistory.length < 2) return 0.0;
    double totalSpeed = 0.0;
    for (int i = 1; i < _locationHistory.length; i++) {
      double distance = _calculateDistance(
        _locationHistory[i - 1],
        _locationHistory[i],
      );
      double time = _locationHistory[i].timestamp
          .difference(_locationHistory[i - 1].timestamp)
          .inSeconds
          .toDouble();
      if (time > 0) {
        totalSpeed += distance / time;
      }
    }
    return totalSpeed / (_locationHistory.length - 1);
  }

  Duration _calculateTotalTime() {
    if (_locationHistory.isEmpty) return Duration.zero;
    return _locationHistory.last.timestamp
        .difference(_locationHistory.first.timestamp);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aide Navigation'),
        content: const Text(
          '1. Activez votre Bluetooth\n'
              '2. Connectez-vous à l\'ESP32\n'
              '3. Activez la localisation\n'
              '4. Rafraîchissez pour obtenir votre position\n'
              '5. Les statistiques se mettent à jour automatiquement',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation'),
        backgroundColor: AppTheme.surfaceDark,
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Position actuelle',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_isLoading)
                          const Center(
                            child: CircularProgressIndicator(),
                          )
                        else
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _locationMessage,
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isLoading ? null : _getCurrentLocation,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Rafraîchir'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                            ),
                            if (_currentPosition != null)
                              ElevatedButton.icon(
                                onPressed: () {
                                  // Ouvrir dans Google Maps
                                },
                                icon: const Icon(Icons.map),
                                label: const Text('Ouvrir dans Maps'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.bluetooth, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Connexion ESP32',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              appState.isConnected
                                  ? '✅ Appareil connecté'
                                  : '❌ Aucun appareil connecté',
                              style: TextStyle(
                                color: appState.isConnected
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            if (!appState.isConnected)
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/connect');
                                },
                                child: const Text('Connecter'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                if (_locationHistory.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.analytics, color: Colors.purple),
                              SizedBox(width: 8),
                              Text(
                                'Statistiques',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildStatRow(
                            'Distance parcourue',
                            '${_calculateTotalDistance().toStringAsFixed(1)} m',
                            Icons.straighten,
                          ),
                          _buildStatRow(
                            'Vitesse moyenne',
                            '${_calculateAverageSpeed().toStringAsFixed(1)} m/s',
                            Icons.speed,
                          ),
                          _buildStatRow(
                            'Temps total',
                            _formatDuration(_calculateTotalTime()),
                            Icons.timer,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      _showHelpDialog(context);
                    },
                    icon: const Icon(Icons.help_outline),
                    label: const Text('Comment utiliser la navigation ?'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}