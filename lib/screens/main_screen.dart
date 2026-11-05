import 'package:flutter/material.dart';

import '../services/anime_service.dart';
import 'discover_screen.dart';
import 'home_screen.dart';
import 'my_list_screen.dart';

class MainScreen extends StatefulWidget {
  final String userName;
  final AnimeService? animeService;

  const MainScreen({super.key, required this.userName, this.animeService});

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

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(userName: widget.userName, animeService: _animeService),
      DiscoverScreen(userName: widget.userName, animeService: _animeService),
      MyListScreen(userName: widget.userName, animeService: _animeService),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
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
