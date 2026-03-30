import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_state.dart';
import 'screens/loading_screen.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const EyeSparkApp(),
    ),
  );
}

class EyeSparkApp extends StatelessWidget {
  const EyeSparkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EyeSpark AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const LoadingScreen(),
    );
  }
}