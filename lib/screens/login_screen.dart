import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/anime_service.dart';
import '../services/nimelist_repository.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  final AnimeService? animeService;
  final NimeListRepository? repository;

  const LoginScreen({super.key, this.animeService, this.repository});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final NimeListRepository _repository =
      widget.repository ?? SupabaseNimeListRepository();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final user = await _repository.restoreSession();
      if (!mounted || user == null) return;
      _openMain(user);
    } catch (_) {
      // Tetap di halaman login jika sesi lama tidak bisa dipulihkan.
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final user = await _repository.signInWithGoogle();
      if (!mounted) return;
      if (user != null) {
        _openMain(user);
        return;
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Sign-in failed: $error')));
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _openMain(AppUser user) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(
          user: user,
          repository: _repository,
          animeService: widget.animeService,
        ),
      ),
    );
  }

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
                      semanticLabel: 'NimeList logo',
                    ),
                  ),
                  const Text(
                    'NimeList',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Discover and save your favorite anime.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: _handleGoogleSignIn,
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
