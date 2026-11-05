class Anime {
  final int id;
  final String title;
  final double? score;
  final String status;
  final String? imageUrl;
  final String? synopsis;

  const Anime({
    required this.id,
    required this.title,
    this.score,
    required this.status,
    this.imageUrl,
    this.synopsis,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    final id = json['mal_id'];
    final title = json['title'];
    final score = json['score'];

    if (id is! int || id <= 0 || title is! String || title.trim().isEmpty) {
      throw const FormatException('Identitas anime tidak valid.');
    }
    if (score != null && score is! num) {
      throw const FormatException('Skor anime tidak valid.');
    }

    final images = json['images'];
    final jpg = images is Map<String, dynamic> ? images['jpg'] : null;
    final imageUrl = jpg is Map<String, dynamic> ? jpg['image_url'] : null;

    return Anime(
      id: id,
      title: title,
      score: (score as num?)?.toDouble(),
      status: _optionalText(json['status']) ?? 'Status belum tersedia',
      imageUrl: _optionalText(imageUrl),
      synopsis: _optionalText(json['synopsis']),
    );
  }

  String get scoreText => score?.toString() ?? 'N/A';

  static String? _optionalText(Object? value) {
    if (value is! String || value.trim().isEmpty) {
      return null;
    }
    return value.trim();
  }
}
