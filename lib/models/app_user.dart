class AppUser {
  final int userId;
  final String googleId;
  final String name;
  final String? avatarUrl;

  const AppUser({
    required this.userId,
    required this.googleId,
    required this.name,
    this.avatarUrl,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final rawAvatar = json['avatar_url'];
    final avatarUrl = rawAvatar is String && rawAvatar.trim().isNotEmpty
        ? rawAvatar.trim()
        : null;

    return AppUser(
      userId: (json['user_id'] as num).toInt(),
      googleId: json['google_id'] as String,
      name: json['name'] as String,
      avatarUrl: avatarUrl,
    );
  }
}
