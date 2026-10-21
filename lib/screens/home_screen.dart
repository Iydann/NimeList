import 'package:flutter/material.dart';

import '../widgets/anime_grid.dart';
import '../widgets/app_logo.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  List<Map<String, String>> _animeList = [];

  @override
  void initState() {
    super.initState();
    _loadAnime();
  }

  // Simulasi mengambil data dari API.
  Future<List<Map<String, String>>> _getAnime() async {
    await Future.delayed(const Duration(seconds: 2));

    return [
      {'title': 'Frieren', 'score': '9.1', 'status': 'Finished Airing'},
      {'title': 'One Piece', 'score': '8.7', 'status': 'Currently Airing'},
      {'title': 'Jujutsu Kaisen', 'score': '8.6', 'status': 'Finished Airing'},
      {'title': 'Solo Leveling', 'score': '8.8', 'status': 'Finished Airing'},
    ];
  }

  Future<void> _loadAnime() async {
    final data = await _getAnime();

    if (!mounted) {
      return;
    }

    setState(() {
      _animeList = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogo(excludeFromSemantics: true),
            SizedBox(width: 10),
            Text('NimeList'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.cyan.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Featured Anime',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Temukan anime favoritmu',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Popular Anime',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : AnimeGrid(
                      animeList: _animeList,
                      onAnimeTap: (anime) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(
                              title: anime['title']!,
                              score: anime['score']!,
                              status: anime['status']!,
                              userName: widget.userName,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
