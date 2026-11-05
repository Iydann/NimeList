import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nime_list/services/anime_service.dart';

import 'helpers/anime_api_fixtures.dart';

void main() {
  test(
    'Popular anime uses the tested endpoint and parses its data array',
    () async {
      final service = AnimeService(
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.scheme, 'https');
          expect(request.url.host, 'api.tenrai.org');
          expect(request.url.path, '/v1/top/anime');
          expect(request.url.queryParameters, {
            'filter': 'bypopularity',
            'limit': '10',
            'page': '1',
          });
          return animeListResponse(popularAnimeJson());
        }),
      );
      addTearDown(service.close);

      final anime = await service.getPopularAnime();
      expect(anime, hasLength(4));
      expect(anime.first.id, 52991);
      expect(anime.last.title, 'Solo Leveling');
    },
  );

  test(
    'Search trims and safely encodes spaces, ampersands, and Unicode',
    () async {
      final service = AnimeService(
        client: MockClient((request) async {
          expect(request.url.path, '/v1/anime');
          expect(request.url.queryParameters['q'], 'Frieren & 魔法');
          expect(request.url.queryParameters['limit'], '10');
          expect(request.url.queryParameters['page'], '1');
          return animeListResponse([animeJson()]);
        }),
      );
      addTearDown(service.close);
      expect(
        (await service.searchAnime('  Frieren & 魔法  ')).single.title,
        'Frieren',
      );
    },
  );

  test('Detail reads a data object using the selected anime ID', () async {
    final service = AnimeService(
      client: MockClient((request) async {
        expect(request.url.path, '/v1/anime/16498');
        return jsonResponse({
          'data': animeJson(id: 16498, title: 'Attack on Titan'),
        });
      }),
    );
    addTearDown(service.close);
    final anime = await service.getAnimeDetail(16498);
    expect(anime.id, 16498);
    expect(anime.title, 'Attack on Titan');
    expect(anime.synopsis, defaultSynopsis);
  });

  test('Empty search results are a successful empty list', () async {
    final service = AnimeService(
      client: MockClient((_) async => animeListResponse([])),
    );
    addTearDown(service.close);
    expect(await service.searchAnime('Tidak ada hasil'), isEmpty);
  });

  test('A failed popular request can be retried successfully', () async {
    var attempts = 0;
    final service = AnimeService(
      client: MockClient((_) async {
        attempts++;
        return attempts == 1
            ? jsonResponse({'message': 'Unavailable'}, statusCode: 503)
            : animeListResponse([animeJson()]);
      }),
    );
    addTearDown(service.close);
    await expectLater(
      service.getPopularAnime(),
      throwsA(isA<AnimeApiException>()),
    );
    expect((await service.getPopularAnime()).single.title, 'Frieren');
    expect(attempts, 2);
  });

  test('Rate limiting is exposed as an API error', () async {
    final service = AnimeService(
      client: MockClient(
        (_) async => http.Response(
          '{"message":"Too many requests"}',
          429,
          headers: {'retry-after': '2'},
        ),
      ),
    );
    addTearDown(service.close);
    await expectLater(
      service.getPopularAnime(),
      throwsA(isA<AnimeApiException>()),
    );
  });

  for (final body in ['not JSON', '{"data":{}}', '{"data":[{}]}', 'null']) {
    test('Malformed list response is an API error: $body', () async {
      final service = AnimeService(
        client: MockClient((_) async => http.Response(body, 200)),
      );
      addTearDown(service.close);
      await expectLater(
        service.getPopularAnime(),
        throwsA(isA<AnimeApiException>()),
      );
    });
  }

  test('Connection failures are exposed as API errors', () async {
    final service = AnimeService(
      client: MockClient((_) async => throw http.ClientException('offline')),
    );
    addTearDown(service.close);
    await expectLater(
      service.getPopularAnime(),
      throwsA(isA<AnimeApiException>()),
    );
  });

  test('A request that does not answer times out', () async {
    final pendingResponse = Completer<http.Response>();
    final service = AnimeService(
      client: MockClient((_) => pendingResponse.future),
      timeout: const Duration(milliseconds: 1),
    );
    addTearDown(service.close);
    await expectLater(
      service.getPopularAnime(),
      throwsA(isA<AnimeApiException>()),
    );
    pendingResponse.complete(animeListResponse([]));
  });
}
