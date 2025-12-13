import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/main_screen.dart';
import 'theme/theme_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeData _currentTheme = AppThemes.blueTheme; // DEFAULT BIRU

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  // =====================
  // LOAD TEMA TERSIMPAN
  // =====================
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('app_theme') ?? 0;

    setState(() {
      _currentTheme = _getThemeFromIndex(themeIndex);
    });
  }

  // =====================
  // GANTI TEMA
  // =====================
  void changeTheme(AppTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('app_theme', theme.index);

    setState(() {
      _currentTheme = _getThemeFromIndex(theme.index);
    });
  }

  ThemeData _getThemeFromIndex(int index) {
    switch (index) {
      case 1:
        return AppThemes.pinkTheme;
      case 2:
        return AppThemes.purpleTheme;
      default:
        return AppThemes.blueTheme;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Planner',
      theme: _currentTheme,
      home: MainScreen(onChangeTheme: changeTheme),
      debugShowCheckedModeBanner: false,
    );
  }
}
