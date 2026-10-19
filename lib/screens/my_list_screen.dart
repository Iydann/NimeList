import 'package:flutter/material.dart';
import 'detail_screen.dart';

class MyListScreen extends StatefulWidget {
  const MyListScreen({super.key});

  @override
  State<MyListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends State<MyListScreen> {
  final List<Map<String, String>> _myAnime = [
    {'title': 'Frieren', 'score': '9.1', 'status': 'Finished Airing'},
    {'title': 'One Piece', 'score': '8.7', 'status': 'Currently Airing'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My List')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _myAnime.length,
        itemBuilder: (context, index) {
          final anime = _myAnime[index];

          return Card(
            child: ListTile(
              leading: Container(
                width: 50,
                color: Colors.blueGrey.shade700,
              ),
              title: Text(anime['title']!),
              subtitle: Text('★ ${anime['score']}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  setState(() {
                    _myAnime.removeAt(index);
                  });
                },
              ),
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
