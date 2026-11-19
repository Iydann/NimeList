import 'package:flutter/material.dart';

import '../services/anime_service.dart';
import 'main_screen.dart';

class LoginScreen extends StatelessWidget {
  final AnimeService? animeService;

  const LoginScreen({super.key, this.animeService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 16,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/Icon.png',
                      width: 112,
                      height: 112,
                      semanticLabel: 'Logo NimeList',
                    ),
                  ),
                  const Text(
                    'NimeList',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Temukan dan simpan anime favoritmu.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainScreen(
                            userName: 'Abdullah',
                            animeService: animeService,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1F1F1F),
                      minimumSize: const Size(double.infinity, 52),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFDADCE0)),
                      ),
                    ),
                    icon: Image.asset(
                      'assets/google_logo.png',
                      width: 20,
                      height: 20,
                      excludeFromSemantics: true,
                    ),
                    label: const Text('Login dengan Google'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
