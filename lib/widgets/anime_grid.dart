import 'package:flutter/material.dart';

import 'anime_card.dart';

class AnimeGrid extends StatelessWidget {
  final List<Map<String, String>> animeList;
  final ValueChanged<Map<String, String>> onAnimeTap;

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
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final anime = animeList[index];

        return AnimeCard(
          title: anime['title']!,
          score: anime['score']!,
          onTap: () {
            onAnimeTap(anime);
          },
        );
      },
    );
  }
}
