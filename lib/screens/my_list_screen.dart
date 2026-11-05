import 'package:flutter/material.dart';

import '../favorite_data.dart';
import '../services/anime_service.dart';
import '../widgets/anime_poster.dart';
import 'detail_screen.dart';

class MyListScreen extends StatefulWidget {
  final String userName;
  final AnimeService animeService;

  const MyListScreen({
    super.key,
    required this.userName,
    required this.animeService,
  });

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
                    leading: AnimePoster(
                      imageUrl: anime.imageUrl,
                      width: 50,
                      height: 70,
                      borderRadius: 0,
                    ),
                    title: Text(anime.title),
                    subtitle: Text('★ ${anime.scoreText}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        setState(() {
                          myAnimeList.removeWhere(
                            (item) => item.id == anime.id,
                          );
                        });
                      },
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(
                            anime: anime,
                            userName: widget.userName,
                            animeService: widget.animeService,
                          ),
                        ),
                      );

                      if (mounted) {
                        setState(() {});
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
