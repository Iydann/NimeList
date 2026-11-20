import 'package:flutter/material.dart';

import '../models/anime.dart';
import '../models/app_user.dart';
import '../services/anime_service.dart';
import '../services/nimelist_repository.dart';
import '../widgets/anime_feedback.dart';
import '../widgets/anime_poster.dart';
import 'detail_screen.dart';

class MyListScreen extends StatefulWidget {
  final AppUser user;
  final NimeListRepository repository;
  final AnimeService animeService;

  const MyListScreen({
    super.key,
    required this.user,
    required this.repository,
    required this.animeService,
  });

  @override
  State<MyListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends State<MyListScreen> {
  List<Anime> _favorites = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await widget.repository.getFavorites();
      if (!mounted) return;
      setState(() {
        _favorites = data;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load My List. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFavorite(Anime anime) async {
    try {
      await widget.repository.removeFavorite(anime.id);
      if (!mounted) return;
      setState(() {
        _favorites.removeWhere((item) => item.id == anime.id);
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to remove from My List.')),
      );
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return AnimeFeedback(message: _error!, onRetry: _loadFavorites);
    }
    if (_favorites.isEmpty) {
      return const Center(child: Text('Your list is empty.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final anime = _favorites[index];

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
              onPressed: () => _removeFavorite(anime),
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(
                    anime: anime,
                    user: widget.user,
                    repository: widget.repository,
                    animeService: widget.animeService,
                  ),
                ),
              );

              if (mounted) {
                _loadFavorites();
              }
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My List')),
      body: _buildBody(),
    );
  }
}
