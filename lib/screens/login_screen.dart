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
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () {
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
                      child: Image.asset(
                        'assets/google_signin_button.png',
                        width: 216,
                        height: 48,
                        semanticLabel: 'Sign in with Google',
                      ),
                    ),
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
