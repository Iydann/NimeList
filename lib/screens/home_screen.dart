import 'package:flutter/material.dart';

import '../models/anime.dart';
import '../models/app_user.dart';
import '../services/anime_service.dart';
import '../services/nimelist_repository.dart';
import '../widgets/anime_feedback.dart';
import '../widgets/anime_grid.dart';
import '../widgets/user_avatar.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppUser user;
  final NimeListRepository repository;
  final AnimeService animeService;
  final VoidCallback? onLogout;

  const HomeScreen({
    super.key,
    required this.user,
    required this.repository,
    required this.animeService,
    this.onLogout,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  String? _error;
  List<Anime> _animeList = [];

  @override
  void initState() {
    super.initState();
    _loadAnime();
  }

  Future<void> _loadAnime() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await widget.animeService.getPopularAnime();
      if (!mounted) return;
      setState(() {
        _animeList = data;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is AnimeApiException
            ? error.message
            : 'Failed to load anime. Please try again.';
        _isLoading = false;
      });
    }
  }

  Widget _buildAnimeList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return AnimeFeedback(message: _error!, onRetry: _loadAnime);
    }
    if (_animeList.isEmpty) {
      return const AnimeFeedback(message: 'No anime available to display.');
    }
    return AnimeGrid(
      animeList: _animeList,
      onAnimeTap: (anime) {
        Navigator.push(
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          spacing: 16,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/Icon.png',
                width: 32,
                height: 32,
                excludeFromSemantics: true,
              ),
            ),
            const Text('NimeList'),
          ],
        ),
        actions: [
          if (widget.onLogout != null)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: widget.onLogout,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.cyan.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                spacing: 16,
                children: [
                  UserAvatar(
                    name: widget.user.name,
                    imageUrl: widget.user.avatarUrl,
                    size: 44,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Text(
                          'Hello, ${widget.user.name}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const Text(
                          'Discover your favorite anime',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              'Popular Anime',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(child: _buildAnimeList()),
          ],
        ),
      ),
    );
  }
}
