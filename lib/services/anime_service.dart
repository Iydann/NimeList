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
    final cached = _popularAnime;
    if (cached != null) {
      return cached;
    }
    final pending = _popularRequest;
    if (pending != null) {
      return pending;
    }

    // Home dan Discover berbagi hasil selama sesi aplikasi berjalan.
    final request = _getAnimeList('top/anime', {
      'filter': 'bypopularity',
      'limit': '10',
      'page': '1',
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
    return _getAnimeList('anime', {'q': search, 'limit': '10', 'page': '1'});
  }

  Future<Anime> getAnimeDetail(int id) async {
    final data = await _getData('anime/$id');
    if (data is! Map<String, dynamic>) {
      throw const AnimeApiException('Data detail anime tidak valid.');
    }
    try {
      return Anime.fromJson(data);
    } on FormatException {
      throw const AnimeApiException('Data detail anime tidak valid.');
    }
  }

  Future<List<Anime>> _getAnimeList(
    String path,
    Map<String, String> query,
  ) async {
    final data = await _getData(path, query: query);
    if (data is! List) {
      throw const AnimeApiException('Data daftar anime tidak valid.');
    }
    try {
      return data.map((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Data anime tidak valid.');
        }
        return Anime.fromJson(item);
      }).toList();
    } on FormatException {
      throw const AnimeApiException('Data daftar anime tidak valid.');
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
              ? 'Terlalu banyak permintaan. Tunggu sebentar lalu coba lagi.'
              : 'Terlalu banyak permintaan. Coba lagi dalam $wait detik.',
        );
      }
      if (response.statusCode != 200) {
        throw AnimeApiException(
          response.statusCode == 404
              ? 'Anime tidak ditemukan.'
              : 'Gagal memuat anime. Silakan coba lagi.',
        );
      }

      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json is! Map<String, dynamic> || !json.containsKey('data')) {
        throw const FormatException('Respons API tidak valid.');
      }
      return json['data'];
    } on TimeoutException {
      throw const AnimeApiException(
        'Koneksi terlalu lama. Periksa internet lalu coba lagi.',
      );
    } on http.ClientException {
      throw const AnimeApiException(
        'Tidak dapat terhubung. Periksa koneksi internetmu.',
      );
    } on FormatException {
      throw const AnimeApiException('Respons server tidak dapat dibaca.');
    }
  }

  void close() => _client.close();
}
