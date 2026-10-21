import 'package:flutter/material.dart';

import '../widgets/anime_grid.dart';
import '../widgets/app_text_field.dart';
import 'detail_screen.dart';

class DiscoverScreen extends StatefulWidget {
  final String userName;

  const DiscoverScreen({super.key, required this.userName});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String _search = '';

  final List<Map<String, String>> _animeList = [
    {'title': 'Frieren', 'score': '9.1', 'status': 'Finished Airing'},
    {'title': 'One Piece', 'score': '8.7', 'status': 'Currently Airing'},
    {'title': 'Jujutsu Kaisen', 'score': '8.6', 'status': 'Finished Airing'},
    {'title': 'Solo Leveling', 'score': '8.8', 'status': 'Finished Airing'},
  ];

  @override
  Widget build(BuildContext context) {
    final filteredAnime = _animeList.where((anime) {
      return anime['title']!.toLowerCase().contains(_search.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Discover'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AppTextField(
              hintText: 'Search anime...',
              prefixIcon: Icons.search,
              onChanged: (value) {
                setState(() {
                  _search = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AnimeGrid(
                animeList: filteredAnime,
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
