// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'services/ambient_light_service.dart';
import 'services/voice_command_service.dart';
import 'services/audio_service.dart';
import 'services/esp32_cam_service.dart';
import 'services/pdf_export_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/device_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/connection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize all services
  final appState = AppState();
  await appState.initialize();

  final lightService = AmbientLightService();
  final voiceService = VoiceCommandService();
  await voiceService.initialize();

  // Connect voice commands to AppState
  appState.setupVoiceCommands(voiceService);

  final camService = ESP32CamService();

  runApp(
    MultiProvider(
      providers: [
        // Services that need to notify listeners
        ChangeNotifierProvider<AppState>.value(value: appState),
        ChangeNotifierProvider<AmbientLightService>.value(value: lightService),
        ChangeNotifierProvider<VoiceCommandService>.value(value: voiceService),
        ChangeNotifierProvider<ESP32CamService>.value(value: camService),

        // Services that don't need to notify (static providers)
        Provider<AudioService>.value(value: AudioService()),
        Provider<PDFExportService>.value(value: PDFExportService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation Aid Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const MainNavigation(),
        '/connect': (context) => const ConnectionScreen(),
        '/stats': (context) => const StatsScreen(),
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // List of screens in the bottom navigation
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = const [
      HomeScreen(),
      CameraScreen(),
      HistoryScreen(),
      StatsScreen(),
      SettingsScreen(),
      DeviceScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.videocam),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.devices),
            label: 'Device',
          ),
        ],
      ),
    );
  }
}