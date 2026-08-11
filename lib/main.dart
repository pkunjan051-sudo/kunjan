import 'package:flutter/material.dart';
import 'services/favorites_service.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize persistent local storage for Watchlist & Favorites
  await FavoritesService().init();

  runApp(const CinemaCentralApp());
}

class CinemaCentralApp extends StatelessWidget {
  const CinemaCentralApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CinemaCentral',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
