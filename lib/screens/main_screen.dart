import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/anime_service.dart';
import '../services/nimelist_repository.dart';
import 'discover_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'my_list_screen.dart';

class MainScreen extends StatefulWidget {
  final AppUser user;
  final NimeListRepository repository;
  final AnimeService? animeService;

  const MainScreen({
    super.key,
    required this.user,
    required this.repository,
    this.animeService,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late final AnimeService _animeService = widget.animeService ?? AnimeService();

  @override
  void dispose() {
    if (widget.animeService == null) {
      _animeService.close();
    }
    super.dispose();
  }

  Future<void> _logout() async {
    try {
      await widget.repository.signOut();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            animeService: widget.animeService,
            repository: widget.repository,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Sign-out failed: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: switch (_selectedIndex) {
        0 => HomeScreen(
          user: widget.user,
          repository: widget.repository,
          animeService: _animeService,
          onLogout: _logout,
        ),
        1 => DiscoverScreen(
          user: widget.user,
          repository: widget.repository,
          animeService: _animeService,
        ),
        _ => MyListScreen(
          user: widget.user,
          repository: widget.repository,
          animeService: _animeService,
        ),
      },
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Discover'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: 'My List',
          ),
        ],
      ),
    );
  }
}
