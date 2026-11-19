import 'package:flutter/material.dart';

import '../favorite_data.dart';
import '../models/anime.dart';
import '../services/anime_service.dart';
import '../widgets/anime_feedback.dart';
import '../widgets/anime_poster.dart';

class DetailScreen extends StatefulWidget {
  final Anime anime;
  final String userName;
  final AnimeService animeService;

  const DetailScreen({
    super.key,
    required this.anime,
    required this.userName,
    required this.animeService,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final TextEditingController _commentController = TextEditingController();

  final List<Map<String, String>> _comments = [
    {'name': 'NimeList User', 'content': 'Alurnya seru bet'},
  ];

  Anime? _anime;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAnime();
  }

  Future<void> _loadAnime() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final anime = await widget.animeService.getAnimeDetail(widget.anime.id);
      if (!mounted) return;

      setState(() {
        _anime = anime;
        _isLoading = false;

        // Lengkapi favorit yang sudah ada dengan poster dan data terbaru.
        final favoriteIndex = myAnimeList.indexWhere(
          (item) => item.id == anime.id,
        );
        if (favoriteIndex != -1) {
          myAnimeList[favoriteIndex] = anime;
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error is AnimeApiException
            ? error.message
            : 'Detail anime belum bisa dimuat. Silakan coba lagi.';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Widget _buildAvatar(String name) {
    final trimmed = name.trim();
    final initial = trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();
    return CircleAvatar(
      backgroundColor: Colors.grey.shade200,
      foregroundColor: Colors.black87,
      child: Text(initial),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anime Detail')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? AnimeFeedback(message: _errorMessage!, onRetry: _loadAnime)
          : _buildDetails(_anime!),
    );
  }

  Widget _buildDetails(Anime anime) {
    final isFavorite = myAnimeList.any((item) => item.id == anime.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          AnimePoster(imageUrl: anime.imageUrl, height: 260, borderRadius: 12),
          Text(
            anime.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Score: ${anime.scoreText}'),
              Text('Status: ${anime.status}'),
            ],
          ),
          const Text(
            'Sinopsis',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            anime.synopsis?.isNotEmpty == true
                ? anime.synopsis!
                : 'Sinopsis belum tersedia.',
          ),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                if (isFavorite) {
                  myAnimeList.removeWhere((item) => item.id == anime.id);
                } else {
                  myAnimeList.add(anime);
                }
              });
            },
            icon: Icon(
              isFavorite
                  ? Icons.bookmark_remove_outlined
                  : Icons.bookmark_add_outlined,
            ),
            label: Text(isFavorite ? 'Remove from My List' : 'Add to My List'),
          ),
          const Text(
            'Komentar',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Row(
            spacing: 16,
            children: [
              _buildAvatar(widget.userName),
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Tulis komentar...',
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                final text = _commentController.text.trim();
                if (text.isNotEmpty) {
                  setState(() {
                    _comments.add({'name': widget.userName, 'content': text});
                  });
                  _commentController.clear();
                }
              },
              child: const Text('Post Comment'),
            ),
          ),
          Column(
            children: [
              for (var i = 0; i < _comments.length; i++)
                Card(
                  child: ListTile(
                    leading: _buildAvatar(_comments[i]['name']!),
                    title: Text(_comments[i]['name']!),
                    subtitle: Text(_comments[i]['content']!),
                    trailing: _comments[i]['name'] == widget.userName
                        ? IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () {
                              setState(() => _comments.removeAt(i));
                            },
                          )
                        : null,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
