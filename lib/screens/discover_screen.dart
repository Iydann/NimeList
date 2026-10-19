import 'package:flutter/material.dart';
import 'detail_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

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
      appBar: AppBar(title: const Text('Discover')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search anime...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _search = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                itemCount: filteredAnime.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  final anime = filteredAnime[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(
                            title: anime['title']!,
                            score: anime['score']!,
                            status: anime['status']!,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.shade700,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          anime['title']!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('★ ${anime['score']}'),
                      ],
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
