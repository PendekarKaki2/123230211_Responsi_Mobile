class Game {
  const Game({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.shortDescription,
    required this.gameUrl,
    required this.genre,
    required this.platform,
    required this.publisher,
    required this.developer,
    required this.releaseDate,
    this.description,
    this.status,
    this.profileUrl,
    this.screenshots = const [],
  });

  final int id;
  final String title;
  final String thumbnail;
  final String shortDescription;
  final String? description;
  final String gameUrl;
  final String genre;
  final String platform;
  final String publisher;
  final String developer;
  final String releaseDate;
  final String? status;
  final String? profileUrl;
  final List<String> screenshots;

  String get name => title;

  String? get posterUrl => thumbnail.isEmpty ? null : thumbnail;

  String get genreLabel => genre.isEmpty ? 'Tidak ada genre' : genre;

  String get platformLabel =>
      platform.isEmpty ? 'Platform tidak diketahui' : platform;

  String get descriptionLabel {
    final detail = description?.trim();
    if (detail != null && detail.isNotEmpty) {
      return detail;
    }
    if (shortDescription.trim().isNotEmpty) {
      return shortDescription;
    }
    return 'Belum ada deskripsi.';
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    final screenshotsData = json['screenshots'];

    return Game(
      id: _parseInt(json['id']),
      title: _readString(json['title'], fallback: 'Tanpa Judul'),
      thumbnail: _readString(json['thumbnail']),
      shortDescription: _readString(
        json['short_description'],
        fallback: 'Belum ada ringkasan.',
      ),
      description: _cleanText(json['description']),
      gameUrl: _readString(json['game_url']),
      genre: _readString(json['genre'], fallback: 'Tidak ada genre'),
      platform: _readString(
        json['platform'],
        fallback: 'Platform tidak diketahui',
      ),
      publisher: _readString(json['publisher'], fallback: 'Tidak diketahui'),
      developer: _readString(json['developer'], fallback: 'Tidak diketahui'),
      releaseDate: _readString(
        json['release_date'],
        fallback: 'Tidak diketahui',
      ),
      status: _cleanText(json['status']),
      profileUrl: _cleanText(json['freetogame_profile_url']),
      screenshots: screenshotsData is List<dynamic>
          ? screenshotsData
                .whereType<Map<String, dynamic>>()
                .map((item) => item['image']?.toString() ?? '')
                .where((url) => url.trim().isNotEmpty)
                .toList()
          : const [],
    );
  }

  factory Game.fromStorage(Map<dynamic, dynamic> data) {
    return Game(
      id: _parseInt(data['id']),
      title: _readString(data['title'], fallback: 'Tanpa Judul'),
      thumbnail: _readString(data['thumbnail']),
      shortDescription: _readString(
        data['shortDescription'],
        fallback: 'Belum ada ringkasan.',
      ),
      description: _cleanText(data['description']),
      gameUrl: _readString(data['gameUrl']),
      genre: _readString(data['genre'], fallback: 'Tidak ada genre'),
      platform: _readString(
        data['platform'],
        fallback: 'Platform tidak diketahui',
      ),
      publisher: _readString(data['publisher'], fallback: 'Tidak diketahui'),
      developer: _readString(data['developer'], fallback: 'Tidak diketahui'),
      releaseDate: _readString(
        data['releaseDate'],
        fallback: 'Tidak diketahui',
      ),
      status: _cleanText(data['status']),
      profileUrl: _cleanText(data['profileUrl']),
      screenshots: (data['screenshots'] as List<dynamic>? ?? const [])
          .map((url) => url.toString())
          .where((url) => url.trim().isNotEmpty)
          .toList(),
    );
  }

  Map<String, dynamic> toStorage() {
    return {
      'id': id,
      'title': title,
      'thumbnail': thumbnail,
      'shortDescription': shortDescription,
      'description': description,
      'gameUrl': gameUrl,
      'genre': genre,
      'platform': platform,
      'publisher': publisher,
      'developer': developer,
      'releaseDate': releaseDate,
      'status': status,
      'profileUrl': profileUrl,
      'screenshots': screenshots,
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _readString(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  static String? _cleanText(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return null;
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
}
