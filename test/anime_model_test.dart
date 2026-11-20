import 'package:flutter_test/flutter_test.dart';
import 'package:nime_list/models/anime.dart';
import 'package:nime_list/models/anime_comment.dart';
import 'package:nime_list/models/app_user.dart';

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
    expect(anime.genre, 'Adventure, Fantasy');
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

  test('SFW check blocks Rx and R+ ratings and allows general ratings', () {
    expect(Anime.fromJson(animeJson(rating: 'G - All Ages')).isSfw, isTrue);
    expect(
      Anime.fromJson(animeJson(rating: 'PG-13 - Teens 13 or older')).isSfw,
      isTrue,
    );
    expect(
      Anime.fromJson(animeJson(rating: 'R - 17+ (violence & profanity)')).isSfw,
      isTrue,
    );
    expect(Anime.fromJson(animeJson(rating: null)).isSfw, isTrue);
    expect(
      Anime.fromJson(animeJson(rating: 'R+ - Mild Nudity')).isSfw,
      isFalse,
    );
    expect(Anime.fromJson(animeJson(rating: 'Rx - Hentai')).isSfw, isFalse);
  });

  test('Synopsis separates trailing MAL Rewrite and Source attributions', () {
    final malAnime = Anime.fromJson(
      animeJson(
        synopsis: 'An elf mage journeys north.\n\n[Written by MAL Rewrite]',
      ),
    );
    expect(malAnime.synopsisBody, 'An elf mage journeys north.');
    expect(malAnime.synopsisSource, 'MAL Rewrite');

    final sourceAnime = Anime.fromJson(
      animeJson(synopsis: 'A young hunter levels up.\n\n(Source: Crunchyroll)'),
    );
    expect(sourceAnime.synopsisBody, 'A young hunter levels up.');
    expect(sourceAnime.synopsisSource, 'Crunchyroll');

    final plainAnime = Anime.fromJson(
      animeJson(synopsis: 'Plain synopsis without attribution.'),
    );
    expect(plainAnime.synopsisBody, 'Plain synopsis without attribution.');
    expect(plainAnime.synopsisSource, isNull);
  });

  test('AppUser and AnimeComment parse Google avatar URLs', () {
    final user = AppUser.fromJson({
      'user_id': 1,
      'google_id': 'g-123',
      'name': 'Iydain',
      'avatar_url': 'https://lh3.googleusercontent.com/a/avatar',
    });
    expect(user.avatarUrl, 'https://lh3.googleusercontent.com/a/avatar');

    final comment = AnimeComment.fromJson({
      'comment_id': 10,
      'user_id': 1,
      'content': 'Great episode!',
      'created_at': '2026-11-20T00:00:00Z',
      'users': {
        'name': 'Iydain',
        'avatar_url': 'https://lh3.googleusercontent.com/a/avatar',
      },
    });
    expect(comment.userName, 'Iydain');
    expect(comment.userAvatarUrl, 'https://lh3.googleusercontent.com/a/avatar');
  });
}
