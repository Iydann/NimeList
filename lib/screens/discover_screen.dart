import 'dart:async';

import 'package:flutter/material.dart';

import '../models/anime.dart';
import '../services/anime_service.dart';
import '../widgets/anime_feedback.dart';
import '../widgets/anime_grid.dart';
import 'detail_screen.dart';

class DiscoverScreen extends StatefulWidget {
  final String userName;
  final AnimeService animeService;

  const DiscoverScreen({
    super.key,
    required this.userName,
    required this.animeService,
  });

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String _search = '';
  List<Anime> _animeList = [];
  bool _isLoading = true;
  String? _error;
  Timer? _debounce;
  int _requestVersion = 0;

  @override
  void initState() {
    super.initState();
    _loadAnime();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    final query = value.trim();
    if (query == _search) return;

    _debounce?.cancel();
    _search = query;
    if (query.isEmpty) {
      _loadAnime();
      return;
    }

    // Abaikan respons lama segera setelah kata pencarian berubah.
    _requestVersion++;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    _debounce = Timer(const Duration(milliseconds: 500), _loadAnime);
  }

  void _onSearchSubmitted(String value) {
    _debounce?.cancel();
    _search = value.trim();
    _loadAnime();
  }

  Future<void> _loadAnime() async {
    final version = ++_requestVersion;
    final query = _search;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = query.isEmpty
          ? await widget.animeService.getPopularAnime()
          : await widget.animeService.searchAnime(query);
      if (!mounted || version != _requestVersion) return;
      setState(() {
        _animeList = data;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted || version != _requestVersion) return;
      setState(() {
        _error = error is AnimeApiException
            ? error.message
            : 'Gagal mencari anime. Silakan coba lagi.';
        _isLoading = false;
      });
    }
  }

  Widget _buildResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return AnimeFeedback(message: _error!, onRetry: _loadAnime);
    }
    if (_animeList.isEmpty) {
      return const AnimeFeedback(message: 'Anime tidak ditemukan');
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
      appBar: AppBar(title: const Text('Discover')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 16,
          children: [
            TextField(
              onChanged: _onSearchChanged,
              onSubmitted: _onSearchSubmitted,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Search anime...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            Expanded(child: _buildResults()),
          ],
        ),
      ),
    );
  }
}
