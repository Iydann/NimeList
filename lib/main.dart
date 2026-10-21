import 'package:flutter/material.dart';

import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NimeList',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.cyan.shade50,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyan,
          brightness: Brightness.light,
          primary: Colors.cyan.shade900,
          onPrimary: Colors.white,
          primaryContainer: Colors.cyan.shade100,
          onPrimaryContainer: Colors.black87,
          surface: Colors.white,
          onSurface: Colors.black87,
        ),
        appBarTheme: AppBarThemeData(
          backgroundColor: Colors.cyan.shade50,
          foregroundColor: Colors.black87,
          surfaceTintColor: Colors.transparent,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.cyan.shade900,
          unselectedItemColor: Colors.black54,
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        // Gaya input dipakai bersama oleh pencarian dan komentar.
        inputDecorationTheme: InputDecorationThemeData(
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(28)),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
