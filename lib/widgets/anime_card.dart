import 'package:flutter/material.dart';

import 'anime_poster.dart';

class AnimeCard extends StatelessWidget {
  final String title;
  final String score;
  final String? imageUrl;
  final VoidCallback onTap;

  const AnimeCard({
    super.key,
    required this.title,
    required this.score,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: AnimePoster(imageUrl: imageUrl)),
          const SizedBox(height: 16),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('★ $score'),
        ],
      ),
    );
  }
}
