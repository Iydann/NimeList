import 'package:flutter/material.dart';

import '../models/anime.dart';
import '../models/anime_comment.dart';
import '../models/app_user.dart';
import '../services/anime_service.dart';
import '../services/nimelist_repository.dart';
import '../widgets/anime_feedback.dart';
import '../widgets/anime_poster.dart';
import '../widgets/user_avatar.dart';

class DetailScreen extends StatefulWidget {
  final Anime anime;
  final AppUser user;
  final NimeListRepository repository;
  final AnimeService animeService;

  const DetailScreen({
    super.key,
    required this.anime,
    required this.user,
    required this.repository,
    required this.animeService,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final TextEditingController _commentController = TextEditingController();

  Anime? _anime;
  List<AnimeComment> _comments = [];
  bool _isFavorite = false;
  bool _isLoading = true;
  bool _isSavingFavorite = false;
  bool _isPostingComment = false;
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
      final favoriteFuture = widget.repository.isFavorite(anime.id);
      final commentsFuture = widget.repository.getComments(anime.id);
      final isFavorite = await favoriteFuture;
      final comments = await commentsFuture;

      if (!mounted) return;
      setState(() {
        _anime = anime;
        _isFavorite = isFavorite;
        _comments = comments;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error is AnimeApiException
            ? error.message
            : 'Failed to load anime details. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite(Anime anime) async {
    if (_isSavingFavorite) return;
    setState(() => _isSavingFavorite = true);

    try {
      if (_isFavorite) {
        await widget.repository.removeFavorite(anime.id);
      } else {
        await widget.repository.addFavorite(anime);
      }
      if (!mounted) return;
      setState(() {
        _isFavorite = !_isFavorite;
        _isSavingFavorite = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSavingFavorite = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update My List.')),
      );
    }
  }

  Future<void> _postComment(Anime anime) async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isPostingComment) return;

    setState(() => _isPostingComment = true);
    try {
      final created = await widget.repository.addComment(anime, text);
      if (!mounted) return;
      setState(() {
        _comments.insert(0, created);
        _isPostingComment = false;
      });
      _commentController.clear();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isPostingComment = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to post comment.')));
    }
  }

  Future<void> _deleteComment(AnimeComment comment) async {
    try {
      await widget.repository.deleteComment(comment.id);
      if (!mounted) return;
      setState(() {
        _comments.removeWhere((item) => item.id == comment.id);
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete comment.')),
      );
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
      appBar: AppBar(title: const Text('Anime Detail')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? AnimeFeedback(message: _errorMessage!, onRetry: _loadAnime)
          : _buildDetails(_anime!),
    );
  }

  Widget _buildDetails(Anime anime) {
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
              if (anime.genre != null) Text('Genre: ${anime.genre}'),
            ],
          ),
          const Text(
            'Synopsis',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(anime.synopsisBody ?? 'No synopsis available.'),
          if (anime.synopsisSource != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                avatar: const Icon(Icons.menu_book_outlined, size: 16),
                label: Text(anime.synopsisSource!),
                visualDensity: VisualDensity.compact,
                backgroundColor: Colors.cyan.shade100,
                side: BorderSide.none,
              ),
            ),
          ElevatedButton.icon(
            onPressed: _isSavingFavorite ? null : () => _toggleFavorite(anime),
            icon: Icon(
              _isFavorite
                  ? Icons.bookmark_remove_outlined
                  : Icons.bookmark_add_outlined,
            ),
            label: Text(_isFavorite ? 'Remove from My List' : 'Add to My List'),
          ),
          const Text(
            'Comments',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Row(
            spacing: 16,
            children: [
              UserAvatar(
                name: widget.user.name,
                imageUrl: widget.user.avatarUrl,
              ),
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Write a comment...',
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _isPostingComment ? null : () => _postComment(anime),
              child: const Text('Post Comment'),
            ),
          ),
          if (_comments.isEmpty)
            const Text(
              'No comments yet.',
              style: TextStyle(color: Colors.black54),
            )
          else
            Column(
              children: [
                for (final comment in _comments)
                  Card(
                    child: ListTile(
                      leading: UserAvatar(
                        name: comment.userName,
                        imageUrl: comment.userAvatarUrl,
                      ),
                      title: Text(comment.userName),
                      subtitle: Text(comment.content),
                      trailing: comment.userId == widget.user.userId
                          ? IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _deleteComment(comment),
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
