class SupabaseConfig {
  static const url = 'https://zkypxsuqmogpbndlygfy.supabase.co';
  static const publishableKey =
      'sb_publishable_ReL9yGGeXH5D9cRzhLWo8g_sMIKpJX6';

  /// Ganti dengan Web Client ID dari Google Cloud Console
  /// (format: xxxxx.apps.googleusercontent.com), atau kirim via
  /// `--dart-define=GOOGLE_WEB_CLIENT_ID=...` saat build.
  static const googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '727216640776-e5jp302ogkfsds76g25nmnsq7e7ucpt0.apps.googleusercontent.com',
  );

  static bool get isGoogleConfigured =>
      googleWebClientId.endsWith('.apps.googleusercontent.com');
}
