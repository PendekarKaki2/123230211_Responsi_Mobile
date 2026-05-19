class Game {
  const Game({
    required this.id,
    required this.name,
    required this.genres,
    required this.summary,
    this.rating,
    this.mediumImage,
    this.originalImage,
    this.language,
    this.status,
    this.premiered,
    this.schedule,
  });

  final int id;
  final String name;
  final double? rating;
  final String? mediumImage;
  final String? originalImage;
  final List<String> genres;
  final String summary;
  final String? language;
  final String? status;
  final String? premiered;
  final String? schedule;

  String? get posterUrl => originalImage ?? mediumImage;

  String get ratingLabel => rating == null ? 'N/A' : rating!.toStringAsFixed(1);

  String get genreLabel =>
      genres.isEmpty ? 'Tidak ada genre' : genres.join(', ');

  factory Game.fromJson(Map<String, dynamic> json) {
    final image = json['image'];
    final ratingData = json['rating'];

    return Game(
      id: _parseInt(json['id']),
      name: (json['name'] ?? 'Tanpa Judul').toString(),
      rating: _parseDouble(
        ratingData is Map<String, dynamic> ? ratingData['average'] : null,
      ),
      mediumImage: image is Map<String, dynamic>
          ? image['medium']?.toString()
          : null,
      originalImage: image is Map<String, dynamic>
          ? image['original']?.toString()
          : null,
      genres: (json['genres'] as List<dynamic>? ?? const [])
          .map((genre) => genre.toString())
          .where((genre) => genre.trim().isNotEmpty)
          .toList(),
      summary: _cleanSummary(json['summary']),
      language: json['language']?.toString(),
      status: json['status']?.toString(),
      premiered: json['premiered']?.toString(),
      schedule: _parseSchedule(json['schedule']),
    );
  }

  factory Game.fromStorage(Map<dynamic, dynamic> data) {
    return Game(
      id: _parseInt(data['id']),
      name: (data['name'] ?? 'Tanpa Judul').toString(),
      rating: _parseDouble(data['rating']),
      mediumImage: data['mediumImage']?.toString(),
      originalImage: data['originalImage']?.toString(),
      genres: (data['genres'] as List<dynamic>? ?? const [])
          .map((genre) => genre.toString())
          .where((genre) => genre.trim().isNotEmpty)
          .toList(),
      summary: (data['summary'] ?? 'Belum ada ringkasan.').toString(),
      language: data['language']?.toString(),
      status: data['status']?.toString(),
      premiered: data['premiered']?.toString(),
      schedule: data['schedule']?.toString(),
    );
  }

  Map<String, dynamic> toStorage() {
    return {
      'id': id,
      'name': name,
      'rating': rating,
      'mediumImage': mediumImage,
      'originalImage': originalImage,
      'genres': genres,
      'summary': summary,
      'language': language,
      'status': status,
      'premiered': premiered,
      'schedule': schedule,
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString());
  }

  static String _cleanSummary(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return 'Belum ada ringkasan.';
    }

    final raw = value
        .toString()
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&rsquo;', "'")
        .replaceAll('&lsquo;', "'")
        .replaceAll('&ldquo;', '"')
        .replaceAll('&rdquo;', '"');

    return raw.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
  }

  static String? _parseSchedule(dynamic value) {
    if (value is! Map<String, dynamic>) {
      return null;
    }

    final time = value['time']?.toString();
    final days = (value['days'] as List<dynamic>? ?? const [])
        .map((day) => day.toString())
        .where((day) => day.isNotEmpty)
        .join(', ');

    if ((time == null || time.isEmpty) && days.isEmpty) {
      return null;
    }
    if (time == null || time.isEmpty) {
      return days;
    }
    if (days.isEmpty) {
      return time;
    }
    return '$days, $time';
  }
}
