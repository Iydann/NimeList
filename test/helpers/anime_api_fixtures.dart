import 'dart:convert';

import 'package:http/http.dart' as http;

const defaultSynopsis = 'Sinopsis dari API untuk pengujian.';

Map<String, dynamic> animeJson({
  int id = 52991,
  String title = 'Frieren',
  num? score = 9.1,
  String? synopsis = defaultSynopsis,
}) => {
  'mal_id': id,
  'title': title,
  'score': score,
  'status': 'Finished Airing',
  'images': {
    'jpg': {'image_url': null},
  },
  'synopsis': synopsis,
};

List<Map<String, dynamic>> popularAnimeJson() => [
  animeJson(),
  animeJson(id: 21, title: 'One Piece', score: 8.7),
  animeJson(id: 40748, title: 'Jujutsu Kaisen', score: 8.6),
  animeJson(id: 52299, title: 'Solo Leveling', score: 8.8),
];

http.Response jsonResponse(Object? body, {int statusCode = 200}) =>
    http.Response(
      jsonEncode(body),
      statusCode,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

http.Response animeListResponse(List<Map<String, dynamic>> anime) =>
    jsonResponse({
      'data': anime,
      'pagination': {
        'current_page': 1,
        'has_next_page': false,
        'items': {'count': anime.length, 'total': anime.length, 'per_page': 10},
      },
    });

Future<http.Response> defaultApiResponse(http.Request request) async {
  final anime = popularAnimeJson();
  if (request.url.path == '/v1/top/anime') {
    return animeListResponse(anime);
  }
  if (request.url.path == '/v1/anime') {
    final query = request.url.queryParameters['q']!.toLowerCase();
    return animeListResponse(
      anime
          .where(
            (entry) => (entry['title'] as String).toLowerCase().contains(query),
          )
          .toList(),
    );
  }
  final id = int.tryParse(request.url.pathSegments.last);
  final matchingAnime = anime.where((entry) => entry['mal_id'] == id);
  if (matchingAnime.isNotEmpty) {
    return jsonResponse({'data': matchingAnime.single});
  }
  return jsonResponse({'message': 'Anime tidak ditemukan'}, statusCode: 404);
}
