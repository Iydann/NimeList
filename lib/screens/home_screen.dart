import 'package:flutter/material.dart';

import '../models/anime.dart';
import '../services/anime_service.dart';
import '../widgets/anime_feedback.dart';
import '../widgets/anime_grid.dart';
import '../widgets/app_logo.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final AnimeService animeService;

  const HomeScreen({
    super.key,
    required this.userName,
    required this.animeService,
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
      if (!mounted) {
        return;
      }
      setState(() {
        _animeList = data;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error is AnimeApiException
            ? error.message
            : 'Gagal memuat anime. Silakan coba lagi.';
        _isLoading = false;
      });
    }
  }

  Widget _buildAnimeList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final error = _error;
    if (error != null) {
      return AnimeFeedback(message: error, onRetry: _loadAnime);
    }
    if (_animeList.isEmpty) {
      return const AnimeFeedback(message: 'Belum ada anime untuk ditampilkan');
    }
    return AnimeGrid(
      animeList: _animeList,
      onAnimeTap: (anime) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              anime: anime,
              userName: widget.userName,
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
        automaticallyImplyLeading: false,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogo(excludeFromSemantics: true),
            SizedBox(width: 16),
            Text('NimeList'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.cyan.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Featured Anime',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Temukan anime favoritmu',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Popular Anime',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildAnimeList()),
          ],
        ),
      ),
    );
  }
}
