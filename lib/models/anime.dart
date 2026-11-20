class Anime {
  final int id;
  final String title;
  final double? score;
  final String status;
  final String? rating;
  final String? genre;
  final String? imageUrl;
  final String? synopsis;

  const Anime({
    required this.id,
    required this.title,
    this.score,
    required this.status,
    this.rating,
    this.genre,
    this.imageUrl,
    this.synopsis,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    final id = json['mal_id'];
    final title = json['title'];
    final score = json['score'];

    if (id is! int || id <= 0 || title is! String || title.trim().isEmpty) {
      throw const FormatException('Invalid anime ID or title.');
    }
    if (score != null && score is! num) {
      throw const FormatException('Invalid anime score.');
    }

    final images = json['images'];
    final jpg = images is Map<String, dynamic> ? images['jpg'] : null;
    final imageUrl = jpg is Map<String, dynamic> ? jpg['image_url'] : null;

    return Anime(
      id: id,
      title: title,
      score: (score as num?)?.toDouble(),
      status: _optionalText(json['status']) ?? 'Status unavailable',
      rating: _optionalText(json['rating']),
      genre: _parseGenres(json['genres']),
      imageUrl: _optionalText(imageUrl),
      synopsis: _optionalText(json['synopsis']),
    );
  }

  factory Anime.fromSupabase(Map<String, dynamic> row) {
    final externalId = int.tryParse('${row['external_id']}') ?? 0;
    return Anime(
      id: externalId,
      title: row['title'] as String,
      score: (row['score'] as num?)?.toDouble(),
      status: _optionalText(row['status']) ?? 'Status unavailable',
      genre: _optionalText(row['genre']),
      imageUrl: _optionalText(row['image_url']),
      synopsis: _optionalText(row['synopsis']),
    );
  }

  Map<String, dynamic> toSupabaseMap() => {
    'external_id': id.toString(),
    'title': title,
    'score': score,
    'status': status,
    'genre': genre,
    'image_url': imageUrl,
    'synopsis': synopsis,
  };

  String get scoreText => score?.toString() ?? 'N/A';

  static final _synopsisAttributionPattern = RegExp(
    r'\s*(?:\[Written by ([^\]]+)\]|\(Source:\s*([^)]+)\))\s*$',
    caseSensitive: false,
  );

  String? get synopsisBody {
    final raw = synopsis?.trim();
    if (raw == null || raw.isEmpty) return null;
    final cleaned = raw.replaceFirst(_synopsisAttributionPattern, '').trim();
    return cleaned.isEmpty ? null : cleaned;
  }

  String? get synopsisSource {
    final raw = synopsis?.trim();
    if (raw == null || raw.isEmpty) return null;
    final match = _synopsisAttributionPattern.firstMatch(raw);
    if (match == null) return null;
    final value = (match.group(1) ?? match.group(2))?.trim();
    return (value == null || value.isEmpty) ? null : value;
  }

  bool get isSfw {
    final normalized = rating?.toLowerCase();
    if (normalized == null) return true;
    return !normalized.startsWith('rx') && !normalized.startsWith('r+');
  }

  static String? _parseGenres(Object? value) {
    if (value is! List) return null;
    final names = value
        .whereType<Map<String, dynamic>>()
        .map((item) => _optionalText(item['name']))
        .whereType<String>()
        .toList();
    return names.isEmpty ? null : names.join(', ');
  }

  static String? _optionalText(Object? value) {
    if (value is! String || value.trim().isEmpty) {
      return null;
    }
    return value.trim();
  }
}
