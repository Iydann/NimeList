import 'package:flutter/material.dart';

import '../models/anime.dart';
import 'anime_card.dart';

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

        return AnimeCard(
          title: anime.title,
          score: anime.scoreText,
          imageUrl: anime.imageUrl,
          onTap: () {
            onAnimeTap(anime);
          },
        );
      },
    );
  }
}
