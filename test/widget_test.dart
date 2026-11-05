import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nime_list/favorite_data.dart';
import 'package:nime_list/main.dart';
import 'package:nime_list/models/anime.dart';
import 'package:nime_list/screens/detail_screen.dart';
import 'package:nime_list/screens/discover_screen.dart';
import 'package:nime_list/screens/home_screen.dart';
import 'package:nime_list/screens/login_screen.dart';
import 'package:nime_list/screens/main_screen.dart';
import 'package:nime_list/services/anime_service.dart';

import 'helpers/anime_api_fixtures.dart';

AnimeService testService([
  Future<http.Response> Function(http.Request)? handler,
]) {
  final service = AnimeService(
    client: MockClient(handler ?? defaultApiResponse),
  );
  addTearDown(service.close);
  return service;
}

Future<void> openMain(WidgetTester tester, AnimeService service) async {
  await tester.pumpWidget(MyApp(animeService: service));
  await tester.tap(find.text('Login dengan Google'));
  await tester.pumpAndSettle();
}

Future<void> selectTab(WidgetTester tester, IconData icon) async {
  await tester.tap(
    find.descendant(
      of: find.byType(BottomNavigationBar),
      matching: find.byIcon(icon),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    final originalFavorites = List<Anime>.of(myAnimeList);
    addTearDown(() {
      myAnimeList
        ..clear()
        ..addAll(originalFavorites);
    });
  });

  testWidgets('Login is replaced and API detail returns to the selected tab', (
    tester,
  ) async {
    await openMain(tester, testService());
    expect(find.byType(LoginScreen, skipOffstage: false), findsNothing);
    expect(Navigator.canPop(tester.element(find.byType(MainScreen))), isFalse);

    const tabIcons = [Icons.home_outlined, Icons.search, Icons.bookmark_border];
    for (var index = 0; index < tabIcons.length; index++) {
      await selectTab(tester, tabIcons[index]);
      expect(find.byType(BackButton), findsNothing);
      await tester.ensureVisible(find.text('Frieren'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Frieren'));
      await tester.pumpAndSettle();
      expect(find.byType(DetailScreen), findsOneWidget);
      expect(find.text(defaultSynopsis), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(DetailScreen), findsNothing);
      expect(find.byType(BackButton), findsNothing);
      expect(
        tester
            .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
            .currentIndex,
        index,
      );
      expect(
        Navigator.canPop(tester.element(find.byType(MainScreen))),
        isFalse,
      );
    }
  });

  testWidgets(
    'Leaving Home during a pending API request does not update disposed state',
    (tester) async {
      final pendingResponse = Completer<http.Response>();
      final service = testService((_) => pendingResponse.future);
      await tester.pumpWidget(MyApp(animeService: service));
      await tester.tap(find.text('Login dengan Google'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(BottomNavigationBar),
          matching: find.byIcon(Icons.search),
        ),
      );
      await tester.pump();
      pendingResponse.complete(animeListResponse(popularAnimeJson()));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Frieren'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('API search, favorites by ID, and local comments work together', (
    tester,
  ) async {
    await openMain(tester, testService());
    await selectTab(tester, Icons.search);
    await tester.enterText(find.byType(TextField), 'Solo');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.text('Frieren'), findsNothing);
    expect(find.text('Solo Leveling'), findsOneWidget);

    await tester.ensureVisible(find.text('Solo Leveling'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Solo Leveling'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Add to My List'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add to My List'));
    await tester.pumpAndSettle();
    expect(find.text('Remove from My List'), findsOneWidget);
    expect(myAnimeList.any((anime) => anime.id == 52299), isTrue);

    await tester.ensureVisible(find.byType(TextField));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Komentar dari pengujian');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Post Comment'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Post Comment'));
    await tester.pumpAndSettle();
    expect(find.text('Komentar dari pengujian'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );

    final ownComment = find.ancestor(
      of: find.text('Komentar dari pengujian'),
      matching: find.byType(Card),
    );
    final deleteComment = find.descendant(
      of: ownComment,
      matching: find.byIcon(Icons.delete_outline),
    );
    await tester.ensureVisible(deleteComment);
    await tester.pumpAndSettle();
    await tester.tap(deleteComment);
    await tester.pumpAndSettle();
    expect(find.text('Komentar dari pengujian'), findsNothing);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await selectTab(tester, Icons.bookmark_border);
    expect(find.text('Solo Leveling'), findsOneWidget);
    final favoriteCard = find.ancestor(
      of: find.text('Solo Leveling'),
      matching: find.byType(Card),
    );
    await tester.tap(
      find.descendant(
        of: favoriteCard,
        matching: find.byIcon(Icons.delete_outline),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Solo Leveling'), findsNothing);
    expect(myAnimeList.any((anime) => anime.id == 52299), isFalse);
  });

  testWidgets('Home displays an API error and retries successfully', (
    tester,
  ) async {
    var attempts = 0;
    final service = testService((_) async {
      attempts++;
      return attempts == 1
          ? jsonResponse({'message': 'Unavailable'}, statusCode: 503)
          : animeListResponse([animeJson()]);
    });
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(userName: 'Abdullah', animeService: service),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Coba lagi'), findsOneWidget);
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(find.text('Frieren'), findsOneWidget);
    expect(find.text('Coba lagi'), findsNothing);
    expect(attempts, 2);
  });

  testWidgets('Home has an empty state for a successful empty response', (
    tester,
  ) async {
    final service = testService((_) async => animeListResponse([]));
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(userName: 'Abdullah', animeService: service),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Belum ada anime untuk ditampilkan'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets(
    'Discover debounces typing, shows empty results, and resets a blank query',
    (tester) async {
      final queries = <String>[];
      final service = testService((request) async {
        if (request.url.path == '/v1/anime') {
          queries.add(request.url.queryParameters['q']!);
          return animeListResponse([]);
        }
        return animeListResponse(popularAnimeJson());
      });
      await tester.pumpWidget(
        MaterialApp(
          home: DiscoverScreen(userName: 'Abdullah', animeService: service),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'F');
      await tester.pump(const Duration(milliseconds: 200));
      await tester.enterText(find.byType(TextField), 'Fri');
      await tester.pump(const Duration(milliseconds: 200));
      await tester.enterText(find.byType(TextField), 'Frieren');
      await tester.pump(const Duration(milliseconds: 499));
      expect(queries, isEmpty);
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pumpAndSettle();
      expect(queries, ['Frieren']);
      expect(find.text('Anime tidak ditemukan'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(queries, ['Frieren']);
      expect(find.text('Frieren'), findsOneWidget);
      expect(find.text('Anime tidak ditemukan'), findsNothing);
    },
  );

  testWidgets('A slower old search cannot overwrite the latest query results', (
    tester,
  ) async {
    final oldResponse = Completer<http.Response>();
    final latestResponse = Completer<http.Response>();
    final service = testService((request) {
      final query = request.url.queryParameters['q'];
      if (query == 'Frieren') return oldResponse.future;
      if (query == 'Solo') return latestResponse.future;
      return defaultApiResponse(request);
    });
    await tester.pumpWidget(
      MaterialApp(
        home: DiscoverScreen(userName: 'Abdullah', animeService: service),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Frieren');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.enterText(find.byType(TextField), 'Solo');
    await tester.pump(const Duration(milliseconds: 500));

    latestResponse.complete(
      animeListResponse([animeJson(id: 52299, title: 'Solo Leveling')]),
    );
    await tester.pumpAndSettle();
    expect(find.text('Solo Leveling'), findsOneWidget);
    oldResponse.complete(animeListResponse([animeJson()]));
    await tester.pumpAndSettle();
    expect(find.text('Solo Leveling'), findsOneWidget);
    expect(find.text('Frieren'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Detail can retry a failed API request and show its synopsis', (
    tester,
  ) async {
    var attempts = 0;
    final service = testService((_) async {
      attempts++;
      return attempts == 1
          ? jsonResponse({'message': 'Unavailable'}, statusCode: 503)
          : jsonResponse({'data': animeJson()});
    });
    await tester.pumpWidget(
      MaterialApp(
        home: DetailScreen(
          anime: Anime.fromJson(animeJson()),
          userName: 'Abdullah',
          animeService: service,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Coba lagi'), findsOneWidget);
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(find.text(defaultSynopsis), findsOneWidget);
    expect(attempts, 2);
  });
}
