import 'package:flutter_test/flutter_test.dart';
import 'package:nime_list/models/anime.dart';

import 'helpers/anime_api_fixtures.dart';

void main() {
  test('Anime reads API identity, numeric score, poster, and synopsis', () {
    final json = animeJson(id: 16498, title: 'Shingeki no Kyojin', score: 8.58);
    json['images'] = {
      'jpg': {'image_url': 'https://example.com/poster.jpg'},
    };
    final anime = Anime.fromJson(json);

    expect(anime.id, 16498);
    expect(anime.title, 'Shingeki no Kyojin');
    expect(anime.score, 8.58);
    expect(anime.status, 'Finished Airing');
    expect(anime.imageUrl, 'https://example.com/poster.jpg');
    expect(anime.synopsis, defaultSynopsis);
  });

  test('An integer score is accepted as a number', () {
    expect(Anime.fromJson(animeJson(score: 9)).score, 9.0);
  });

  test('Unrated anime can have null score, poster, and synopsis', () {
    final anime = Anime.fromJson(animeJson(score: null, synopsis: null));
    expect(anime.score, isNull);
    expect(anime.scoreText, 'N/A');
    expect(anime.imageUrl, isNull);
    expect(anime.synopsis, isNull);
  });

  test('An entry without a valid identity is rejected', () {
    final json = animeJson()..remove('mal_id');
    expect(() => Anime.fromJson(json), throwsFormatException);
  });
}
