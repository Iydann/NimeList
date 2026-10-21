import 'package:flutter/material.dart';

import 'anime_poster.dart';

class AnimeCard extends StatelessWidget {
  final String title;
  final String score;
  final VoidCallback onTap;

  const AnimeCard({
    super.key,
    required this.title,
    required this.score,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(child: AnimePoster()),
          const SizedBox(height: 6),
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
