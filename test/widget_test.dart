import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nime_list/main.dart';
import 'package:nime_list/models/anime.dart';
import 'package:nime_list/models/anime_comment.dart';
import 'package:nime_list/models/app_user.dart';
import 'package:nime_list/screens/detail_screen.dart';
import 'package:nime_list/screens/discover_screen.dart';
import 'package:nime_list/screens/home_screen.dart';
import 'package:nime_list/screens/login_screen.dart';
import 'package:nime_list/screens/main_screen.dart';
import 'package:nime_list/screens/privacy_policy_screen.dart';
import 'package:nime_list/services/anime_service.dart';
import 'package:nime_list/services/nimelist_repository.dart';

import 'helpers/anime_api_fixtures.dart';

const testUser = AppUser(userId: 1, googleId: 'google-123', name: 'Abdullah');

class FakeNimeListRepository implements NimeListRepository {
  AppUser? _user;
  final List<Anime> favorites;
  final Map<int, List<AnimeComment>> _comments = {};
  int _nextCommentId = 1;

  FakeNimeListRepository({List<Anime>? initialFavorites, AppUser? signedInUser})
    : favorites = List<Anime>.of(
        initialFavorites ??
            [
              const Anime(
                id: 52991,
                title: 'Frieren',
                score: 9.1,
                status: 'Finished Airing',
              ),
              const Anime(
                id: 21,
                title: 'One Piece',
                score: 8.7,
                status: 'Currently Airing',
              ),
            ],
      ),
      _user = signedInUser;

  @override
  AppUser? get currentUser => _user;

  @override
  Future<AppUser?> restoreSession() async => _user;

  @override
  Future<AppUser?> signInWithGoogle() async {
    _user = testUser;
    return _user;
  }

  @override
  Future<void> signOut() async {
    _user = null;
  }

  @override
  Future<List<Anime>> getFavorites() async => List<Anime>.of(favorites);

  @override
  Future<bool> isFavorite(int externalAnimeId) async =>
      favorites.any((anime) => anime.id == externalAnimeId);

  @override
  Future<void> addFavorite(Anime anime) async {
    favorites.removeWhere((item) => item.id == anime.id);
    favorites.insert(0, anime);
  }

  @override
  Future<void> removeFavorite(int externalAnimeId) async {
    favorites.removeWhere((item) => item.id == externalAnimeId);
  }

  @override
  Future<List<AnimeComment>> getComments(int externalAnimeId) async =>
      List<AnimeComment>.of(_comments[externalAnimeId] ?? const []);

  @override
  Future<AnimeComment> addComment(Anime anime, String content) async {
    final user = _user ?? testUser;
    final comment = AnimeComment(
      id: _nextCommentId++,
      userId: user.userId,
      userName: user.name,
      userAvatarUrl: user.avatarUrl,
      content: content.trim(),
      createdAt: DateTime.now(),
    );
    _comments.putIfAbsent(anime.id, () => []).insert(0, comment);
    return comment;
  }

  @override
  Future<void> deleteComment(int commentId) async {
    for (final list in _comments.values) {
      list.removeWhere((comment) => comment.id == commentId);
    }
  }
}

AnimeService testService([
  Future<http.Response> Function(http.Request)? handler,
]) {
  final service = AnimeService(
    client: MockClient(handler ?? defaultApiResponse),
  );
  addTearDown(service.close);
  return service;
}

Future<FakeNimeListRepository> openMain(
  WidgetTester tester,
  AnimeService service, {
  FakeNimeListRepository? repository,
}) async {
  final repo = repository ?? FakeNimeListRepository();
  await tester.pumpWidget(MyApp(animeService: service, repository: repo));
  await tester.tap(find.bySemanticsLabel('Sign in with Google'));
  await tester.pumpAndSettle();
  return repo;
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
      final repo = FakeNimeListRepository();
      await tester.pumpWidget(MyApp(animeService: service, repository: repo));
      await tester.tap(find.bySemanticsLabel('Sign in with Google'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
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

  testWidgets('API search, favorites by ID, and comments work via repository', (
    tester,
  ) async {
    final repo = await openMain(tester, testService());
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
    expect(repo.favorites.any((anime) => anime.id == 52299), isTrue);

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
    expect(repo.favorites.any((anime) => anime.id == 52299), isFalse);
  });

  testWidgets(
    'Logout signs out user, returns to LoginScreen, and re-login works',
    (tester) async {
      final repo = await openMain(tester, testService());
      expect(repo.currentUser, isNotNull);

      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      expect(repo.currentUser, isNull);
      expect(find.byType(LoginScreen), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Sign in with Google'));
      await tester.pumpAndSettle();

      expect(repo.currentUser, isNotNull);
      expect(find.byType(MainScreen), findsOneWidget);
      expect(find.text('Frieren'), findsOneWidget);
    },
  );

  testWidgets(
    'Logout does not pass MainScreen-owned closed AnimeService to LoginScreen',
    (tester) async {
      final repo = FakeNimeListRepository(signedInUser: testUser);
      await tester.pumpWidget(
        MaterialApp(
          home: MainScreen(user: testUser, repository: repo),
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      final loginScreen = tester.widget<LoginScreen>(find.byType(LoginScreen));
      expect(loginScreen.animeService, isNull);
    },
  );

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
        home: HomeScreen(
          user: testUser,
          repository: FakeNimeListRepository(signedInUser: testUser),
          animeService: service,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Try Again'), findsOneWidget);
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(find.text('Frieren'), findsOneWidget);
    expect(find.text('Try Again'), findsNothing);
    expect(attempts, 2);
  });

  testWidgets('Home has an empty state for a successful empty response', (
    tester,
  ) async {
    final service = testService((_) async => animeListResponse([]));
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          user: testUser,
          repository: FakeNimeListRepository(signedInUser: testUser),
          animeService: service,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No anime available to display.'), findsOneWidget);
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
          home: DiscoverScreen(
            user: testUser,
            repository: FakeNimeListRepository(signedInUser: testUser),
            animeService: service,
          ),
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
      expect(find.text('No anime found.'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(queries, ['Frieren']);
      expect(find.text('Frieren'), findsOneWidget);
      expect(find.text('No anime found.'), findsNothing);
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
        home: DiscoverScreen(
          user: testUser,
          repository: FakeNimeListRepository(signedInUser: testUser),
          animeService: service,
        ),
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
          user: testUser,
          repository: FakeNimeListRepository(signedInUser: testUser),
          animeService: service,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Try Again'), findsOneWidget);
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(find.text(defaultSynopsis), findsOneWidget);
    expect(attempts, 2);
  });

  testWidgets('Detail separates [Written by MAL Rewrite] into a Chip badge', (
    tester,
  ) async {
    final service = testService(
      (_) async => jsonResponse({
        'data': animeJson(
          synopsis: 'Clean story body.\n\n[Written by MAL Rewrite]',
        ),
      }),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: DetailScreen(
          anime: Anime.fromJson(animeJson()),
          user: testUser,
          repository: FakeNimeListRepository(signedInUser: testUser),
          animeService: service,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Clean story body.'), findsOneWidget);
    expect(find.textContaining('[Written by MAL Rewrite]'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(Chip),
        matching: find.text('MAL Rewrite'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Privacy Policy can be opened from LoginScreen and HomeScreen', (
    tester,
  ) async {
    final repo = FakeNimeListRepository();
    await tester.pumpWidget(
      MyApp(animeService: testService(), repository: repo),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();
    expect(find.byType(PrivacyPolicyScreen), findsOneWidget);
    expect(find.text('NimeList Privacy Policy'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Sign in with Google'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.privacy_tip_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(PrivacyPolicyScreen), findsOneWidget);
    expect(find.text('1. Information We Collect'), findsOneWidget);
  });
}
