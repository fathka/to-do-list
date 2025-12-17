// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/main_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/welcome_screen.dart';
import 'theme/theme_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // MEMUAT TEMA SEBELUM RUNAPP AGAR LOADING PAGE LANGSUNG BERWARNA
  final prefs = await SharedPreferences.getInstance();
  final themeIndex = prefs.getInt('app_theme') ?? 0;
  AppTheme initialTheme = AppTheme.values[themeIndex];

  runApp(MyApp(initialTheme: initialTheme));
}

class MyApp extends StatefulWidget {
  final AppTheme initialTheme;
  const MyApp({super.key, required this.initialTheme});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppTheme _currentTheme;
  bool _isLoading = true;
  bool _showWelcome = false;

  @override
  void initState() {
    super.initState();
    _currentTheme = widget.initialTheme;
    _startAppSequence();
  }

  // LOGIKA SEQUENCE: LOADING -> WELCOME -> MAIN
  Future<void> _startAppSequence() async {
    // 1. Durasi Loading Page (Warna akan sesuai tema karena _currentTheme sudah ada)
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _showWelcome = true; // Selalu tampilkan welcome screen setelah loading
    });
  }

  void _completeWelcome() {
    setState(() {
      _showWelcome = false; // Pindah ke MainScreen
    });
  }

  void changeTheme(AppTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('app_theme', theme.index);
    setState(() {
      _currentTheme = theme;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget homeWidget;

    if (_isLoading) {
      homeWidget = const LoadingScreen();
    } else if (_showWelcome) {
      homeWidget = WelcomeScreen(onWelcomeComplete: _completeWelcome);
    } else {
      homeWidget = MainScreen(onChangeTheme: changeTheme);
    }

    return MaterialApp(
      title: 'Daily Planner',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.getTheme(_currentTheme),
      home: homeWidget,
    );
  }
}
