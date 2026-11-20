import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/anime.dart';

class AnimeApiException implements Exception {
  final String message;

  const AnimeApiException(this.message);

  @override
  String toString() => message;
}

class AnimeService {
  final http.Client _client;
  final Duration timeout;
  List<Anime>? _popularAnime;
  Future<List<Anime>>? _popularRequest;

  AnimeService({
    http.Client? client,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client();

  Future<List<Anime>> getPopularAnime() async {
    if (_popularAnime != null) return _popularAnime!;
    if (_popularRequest != null) return _popularRequest!;

    final request = _getAnimeList('top/anime', {
      'filter': 'bypopularity',
      'limit': '10',
      'page': '1',
      'sfw': 'true',
    });
    _popularRequest = request;
    try {
      final anime = await request;
      _popularAnime = anime;
      return anime;
    } finally {
      _popularRequest = null;
    }
  }

  Future<List<Anime>> searchAnime(String query) {
    final search = query.trim();
    if (search.isEmpty) {
      return getPopularAnime();
    }
    return _getAnimeList('anime', {
      'q': search,
      'limit': '10',
      'page': '1',
      'sfw': 'true',
    });
  }

  Future<Anime> getAnimeDetail(int id) async {
    final data = await _getData('anime/$id');
    if (data is! Map<String, dynamic>) {
      throw const AnimeApiException('Invalid anime detail data.');
    }
    final Anime anime;
    try {
      anime = Anime.fromJson(data);
    } on FormatException {
      throw const AnimeApiException('Invalid anime detail data.');
    }
    if (!anime.isSfw) {
      throw const AnimeApiException(
        'This anime is restricted by the Safe For Work (SFW) filter.',
      );
    }
    return anime;
  }

  Future<List<Anime>> _getAnimeList(
    String path,
    Map<String, String> query,
  ) async {
    final data = await _getData(path, query: query);
    if (data is! List) {
      throw const AnimeApiException('Invalid anime list data.');
    }
    try {
      return data
          .map((item) {
            if (item is! Map<String, dynamic>) {
              throw const FormatException('Invalid anime data.');
            }
            return Anime.fromJson(item);
          })
          .where((anime) => anime.isSfw)
          .toList();
    } on FormatException {
      throw const AnimeApiException('Invalid anime list data.');
    }
  }

  Future<Object?> _getData(String path, {Map<String, String>? query}) async {
    final uri = Uri.https('api.tenrai.org', '/v1/$path', query);
    try {
      final response = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(timeout);

      if (response.statusCode == 429) {
        final wait = int.tryParse(response.headers['retry-after'] ?? '');
        throw AnimeApiException(
          wait == null
              ? 'Too many requests. Please wait a moment and try again.'
              : 'Too many requests. Try again in $wait seconds.',
        );
      }
      if (response.statusCode != 200) {
        throw AnimeApiException(
          response.statusCode == 404
              ? 'Anime not found.'
              : 'Failed to load anime. Please try again.',
        );
      }

      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json is! Map<String, dynamic> || !json.containsKey('data')) {
        throw const FormatException('Invalid API response.');
      }
      return json['data'];
    } on TimeoutException {
      throw const AnimeApiException(
        'Connection timed out. Please check your internet and try again.',
      );
    } on http.ClientException {
      throw const AnimeApiException(
        'Unable to connect. Please check your internet connection.',
      );
    } on FormatException {
      throw const AnimeApiException('Unable to read server response.');
    }
  }

  void close() => _client.close();
}
