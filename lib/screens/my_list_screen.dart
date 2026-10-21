import 'package:flutter/material.dart';

import '../favorite_data.dart';
import '../widgets/anime_poster.dart';
import 'detail_screen.dart';

class MyListScreen extends StatefulWidget {
  final String userName;

  const MyListScreen({super.key, required this.userName});

  @override
  State<MyListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends State<MyListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('My List'),
      ),
      body: myAnimeList.isEmpty
          ? const Center(child: Text('My List masih kosong'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myAnimeList.length,
              itemBuilder: (context, index) {
                final anime = myAnimeList[index];

                return Card(
                  child: ListTile(
                    leading: const AnimePoster(width: 50, borderRadius: 0),
                    title: Text(anime['title']!),
                    subtitle: Text('★ ${anime['score']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        setState(() {
                          myAnimeList.removeAt(index);
                        });
                      },
                    ),
                    onTap: () async {
                      await Navigator.push(
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

                      setState(() {});
                    },
                  ),
                );
              },
            ),
    );
  }
}
