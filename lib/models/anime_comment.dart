class AnimeComment {
  final int id;
  final int userId;
  final String userName;
  final String? userAvatarUrl;
  final String content;
  final DateTime createdAt;

  const AnimeComment({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.content,
    required this.createdAt,
  });

  factory AnimeComment.fromJson(Map<String, dynamic> json) {
    final userMap = json['users'];
    final userName = userMap is Map<String, dynamic>
        ? (userMap['name'] as String? ?? 'NimeList User')
        : 'NimeList User';
    final rawAvatar = userMap is Map<String, dynamic>
        ? userMap['avatar_url']
        : null;
    final userAvatarUrl = rawAvatar is String && rawAvatar.trim().isNotEmpty
        ? rawAvatar.trim()
        : null;

    return AnimeComment(
      id: (json['comment_id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      userName: userName,
      userAvatarUrl: userAvatarUrl,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
