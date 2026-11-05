import 'package:flutter/material.dart';

import '../favorite_data.dart';
import '../models/anime.dart';
import '../services/anime_service.dart';
import '../widgets/anime_feedback.dart';
import '../widgets/anime_poster.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/user_avatar.dart';

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
      if (!mounted) {
        return;
      }

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
    } on AnimeApiException catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = error.message;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Detail anime belum bisa dimuat. Silakan coba lagi.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Anime Detail'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? AnimeFeedback(message: _errorMessage!, onRetry: _loadAnime)
          : _buildDetails(_anime!),
    );
  }

  Widget _buildDetails(Anime anime) {
    final isFavorite = myAnimeList.any((item) => item.id == anime.id);
    final synopsis = anime.synopsis?.trim();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimePoster(imageUrl: anime.imageUrl, height: 260, borderRadius: 12),
          const SizedBox(height: 16),
          Text(
            anime.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text('Score: ${anime.scoreText}'),
          Text('Status: ${anime.status}'),
          const SizedBox(height: 16),
          const Text(
            'Sinopsis',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            synopsis == null || synopsis.isEmpty
                ? 'Sinopsis belum tersedia.'
                : synopsis,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              onPressed: () {
                setState(() {
                  if (isFavorite) {
                    myAnimeList.removeWhere((item) => item.id == anime.id);
                  } else {
                    myAnimeList.add(anime);
                  }
                });
              },
              icon: isFavorite
                  ? Icons.bookmark_remove_outlined
                  : Icons.bookmark_add_outlined,
              label: isFavorite ? 'Remove from My List' : 'Add to My List',
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Komentar',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              UserAvatar(name: widget.userName),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  controller: _commentController,
                  hintText: 'Tulis komentar...',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: AppButton(
              label: 'Post Comment',
              onPressed: () {
                final text = _commentController.text.trim();
                if (text.isNotEmpty) {
                  setState(() {
                    _comments.add({'name': widget.userName, 'content': text});
                  });
                  _commentController.clear();
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _comments.length,
            itemBuilder: (context, index) {
              final comment = _comments[index];
              final isMyComment = comment['name'] == widget.userName;

              return Card(
                child: ListTile(
                  leading: UserAvatar(name: comment['name']!),
                  title: Text(
                    comment['name']!,
                    style: const TextStyle(color: Colors.black87),
                  ),
                  subtitle: Text(comment['content']!),
                  trailing: isMyComment
                      ? IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            setState(() {
                              _comments.removeAt(index);
                            });
                          },
                        )
                      : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
