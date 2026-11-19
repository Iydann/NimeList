import 'package:flutter/material.dart';

import '../models/anime.dart';
import 'anime_poster.dart';

class AnimeGrid extends StatelessWidget {
  final List<Anime> animeList;
  final ValueChanged<Anime> onAnimeTap;

  const AnimeGrid({
    super.key,
    required this.animeList,
    required this.onAnimeTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: animeList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final anime = animeList[index];

        return GestureDetector(
          onTap: () => onAnimeTap(anime),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              Expanded(child: AnimePoster(imageUrl: anime.imageUrl)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    anime.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('★ ${anime.scoreText}'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
