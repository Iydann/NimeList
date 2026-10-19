import 'package:flutter/material.dart';
import 'detail_screen.dart';

class MyListScreen extends StatelessWidget {
  const MyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> myAnime = [
      {'title': 'Frieren', 'score': '9.1', 'status': 'Finished Airing'},
      {'title': 'One Piece', 'score': '8.7', 'status': 'Currently Airing'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('My List')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: myAnime.length,
        itemBuilder: (context, index) {
          final anime = myAnime[index];

          return Card(
            child: ListTile(
              leading: Container(
                width: 50,
                color: Colors.blueGrey.shade700,
              ),
              title: Text(anime['title']!),
              subtitle: Text('★ ${anime['score']}'),
              trailing: const Icon(Icons.chevron_right),
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
            ),
          );
        },
      ),
    );
  }
}
