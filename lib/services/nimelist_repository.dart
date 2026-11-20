import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/anime.dart';
import '../models/anime_comment.dart';
import '../models/app_user.dart';

abstract class NimeListRepository {
  AppUser? get currentUser;

  Future<AppUser?> restoreSession();
  Future<AppUser?> signInWithGoogle();
  Future<void> signOut();

  Future<List<Anime>> getFavorites();
  Future<bool> isFavorite(int externalAnimeId);
  Future<void> addFavorite(Anime anime);
  Future<void> removeFavorite(int externalAnimeId);

  Future<List<AnimeComment>> getComments(int externalAnimeId);
  Future<AnimeComment> addComment(Anime anime, String content);
  Future<void> deleteComment(int commentId);
}

class SupabaseNimeListRepository implements NimeListRepository {
  static Future<void>? _googleInitFuture;

  final SupabaseClient _client;
  AppUser? _currentUser;

  SupabaseNimeListRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  @override
  AppUser? get currentUser => _currentUser;

  Future<void> _ensureGoogleInitialized() {
    return _googleInitFuture ??= GoogleSignIn.instance.initialize(
      serverClientId: SupabaseConfig.googleWebClientId,
    );
  }

  @override
  Future<AppUser?> restoreSession() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) {
      _currentUser = null;
      return null;
    }

    final metadata = authUser.userMetadata ?? const <String, dynamic>{};
    final metadataAvatar = _extractAvatarUrl(metadata);

    final existing = await _client
        .from('users')
        .select('user_id, google_id, name, avatar_url')
        .eq('auth_user_id', authUser.id)
        .maybeSingle();

    if (existing != null) {
      if (existing['avatar_url'] == null && metadataAvatar != null) {
        final updated = await _client
            .from('users')
            .update({'avatar_url': metadataAvatar})
            .eq('auth_user_id', authUser.id)
            .select('user_id, google_id, name, avatar_url')
            .single();
        _currentUser = AppUser.fromJson(updated);
      } else {
        _currentUser = AppUser.fromJson(existing);
      }
      return _currentUser;
    }

    final fallbackName =
        (metadata['full_name'] ?? metadata['name'] ?? authUser.email ?? 'User')
            .toString();
    final googleId = (metadata['provider_id'] ?? metadata['sub'] ?? authUser.id)
        .toString();

    final created = await _client
        .from('users')
        .upsert({
          'auth_user_id': authUser.id,
          'google_id': googleId,
          'name': fallbackName,
          'avatar_url': metadataAvatar,
        }, onConflict: 'auth_user_id')
        .select('user_id, google_id, name, avatar_url')
        .single();

    _currentUser = AppUser.fromJson(created);
    return _currentUser;
  }

  static String? _extractAvatarUrl(Map<String, dynamic> metadata) {
    final raw = metadata['avatar_url'] ?? metadata['picture'];
    if (raw is String && raw.trim().isNotEmpty) {
      return raw.trim();
    }
    return null;
  }

  @override
  Future<AppUser?> signInWithGoogle() async {
    if (!SupabaseConfig.isGoogleConfigured) {
      throw Exception(
        'Google Web Client ID is not configured in lib/config/supabase_config.dart.',
      );
    }

    await _ensureGoogleInitialized();

    final GoogleSignInAccount googleUser;
    try {
      googleUser = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      rethrow;
    }

    final idToken = googleUser.authentication.idToken;
    if (idToken == null) {
      throw Exception('Failed to retrieve Google ID Token.');
    }

    const scopes = ['email', 'profile'];
    final authorization =
        await googleUser.authorizationClient.authorizationForScopes(scopes) ??
        await googleUser.authorizationClient.authorizeScopes(scopes);

    final response = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: authorization.accessToken,
    );

    final authUser = response.user;
    if (authUser == null) {
      throw Exception('Supabase sign-in failed.');
    }

    final displayName = (googleUser.displayName?.trim().isNotEmpty ?? false)
        ? googleUser.displayName!.trim()
        : googleUser.email.split('@').first;
    final avatarUrl = (googleUser.photoUrl?.trim().isNotEmpty ?? false)
        ? googleUser.photoUrl!.trim()
        : _extractAvatarUrl(authUser.userMetadata ?? const <String, dynamic>{});

    final userRow = await _client
        .from('users')
        .upsert({
          'auth_user_id': authUser.id,
          'google_id': googleUser.id,
          'name': displayName,
          'avatar_url': avatarUrl,
        }, onConflict: 'auth_user_id')
        .select('user_id, google_id, name, avatar_url')
        .single();

    _currentUser = AppUser.fromJson(userRow);
    return _currentUser;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    try {
      if (_googleInitFuture != null) {
        await GoogleSignIn.instance.signOut();
      }
    } finally {
      await _client.auth.signOut();
    }
  }

  AppUser _requireUser() {
    final user = _currentUser;
    if (user == null) {
      throw StateError('User is not signed in.');
    }
    return user;
  }

  Future<int> _upsertAnime(Anime anime) async {
    final row = await _client
        .from('anime')
        .upsert(anime.toSupabaseMap(), onConflict: 'external_id')
        .select('anime_id')
        .single();
    return (row['anime_id'] as num).toInt();
  }

  Future<int?> _findAnimeId(int externalAnimeId) async {
    final row = await _client
        .from('anime')
        .select('anime_id')
        .eq('external_id', externalAnimeId.toString())
        .maybeSingle();
    if (row == null) return null;
    return (row['anime_id'] as num).toInt();
  }

  @override
  Future<List<Anime>> getFavorites() async {
    final user = _requireUser();
    final rows = await _client
        .from('favorites')
        .select('anime(*)')
        .eq('user_id', user.userId)
        .order('created_at', ascending: false);

    return rows
        .map((row) => row['anime'])
        .whereType<Map<String, dynamic>>()
        .map(Anime.fromSupabase)
        .toList();
  }

  @override
  Future<bool> isFavorite(int externalAnimeId) async {
    final user = _requireUser();
    final animeId = await _findAnimeId(externalAnimeId);
    if (animeId == null) return false;

    final row = await _client
        .from('favorites')
        .select('fav_id')
        .eq('user_id', user.userId)
        .eq('anime_id', animeId)
        .maybeSingle();
    return row != null;
  }

  @override
  Future<void> addFavorite(Anime anime) async {
    final user = _requireUser();
    final animeId = await _upsertAnime(anime);
    await _client.from('favorites').upsert({
      'user_id': user.userId,
      'anime_id': animeId,
    }, onConflict: 'user_id,anime_id');
  }

  @override
  Future<void> removeFavorite(int externalAnimeId) async {
    final user = _requireUser();
    final animeId = await _findAnimeId(externalAnimeId);
    if (animeId == null) return;

    await _client
        .from('favorites')
        .delete()
        .eq('user_id', user.userId)
        .eq('anime_id', animeId);
  }

  @override
  Future<List<AnimeComment>> getComments(int externalAnimeId) async {
    final animeId = await _findAnimeId(externalAnimeId);
    if (animeId == null) return [];

    final rows = await _client
        .from('comments')
        .select(
          'comment_id, user_id, content, created_at, users(name, avatar_url)',
        )
        .eq('anime_id', animeId)
        .order('created_at', ascending: false);

    return rows.map(AnimeComment.fromJson).toList();
  }

  @override
  Future<AnimeComment> addComment(Anime anime, String content) async {
    final user = _requireUser();
    final animeId = await _upsertAnime(anime);
    final row = await _client
        .from('comments')
        .insert({
          'user_id': user.userId,
          'anime_id': animeId,
          'content': content.trim(),
        })
        .select(
          'comment_id, user_id, content, created_at, users(name, avatar_url)',
        )
        .single();

    return AnimeComment.fromJson(row);
  }

  @override
  Future<void> deleteComment(int commentId) async {
    await _client.from('comments').delete().eq('comment_id', commentId);
  }
}
