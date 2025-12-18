// lib/screens/loading_screen.dart

import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil warna dari tema aplikasi yang sedang aktif untuk konsistensi visual
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // Background mengikuti warna surface dari tema (light/dark mode friendly)
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon utama dengan tema warna yang dinamis
            Icon(Icons.calendar_today, 
              size: 80, 
              color: colorScheme.primary
            ),
            const SizedBox(height: 24),
            // Nama aplikasi dengan styling yang sesuai tema
            Text(
              'Daily Planner',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            // Indicator loading yang berputar, warnanya dari secondary theme
            CircularProgressIndicator(color: colorScheme.secondary),
          ],
        ),
      ),
    );
  }
}
