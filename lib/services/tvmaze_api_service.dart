import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/game.dart';

class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class TvMazeApiService extends GetxService {
  TvMazeApiService({http.Client? client}) : _client = client ?? http.Client();

  static const _baseUrl = 'https://www.freetogame.com/api/games';

  final http.Client _client;

  Future<List<Game>> fetchGames() async {
    final uri = Uri.parse('$_baseUrl');
    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw ApiException(
        'Gagal mengambil daftar game (${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List<dynamic>) {
      throw ApiException('Format data daftar game tidak sesuai.');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(Game.fromJson)
        .where((game) => game.id != 0)
        .toList();
  }

  Future<Game> fetchGameDetail(int id) async {
    final uri = Uri.parse('_baseUrl/games/$id');
    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 404) {
      throw ApiException('Game tidak ditemukan.');
    }
    if (response.statusCode != 200) {
      throw ApiException(
        'Gagal mengambil detail game (${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw ApiException('Format data detail game tidak sesuai.');
    }

    return Game.fromJson(decoded);
  }

  Future<List<Game>> searchGames(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return fetchGames();
    }

    final uri = Uri.parse(
      '$_baseUrl/search/games?q=${Uri.encodeQueryComponent(trimmedQuery)}',
    );
    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw ApiException('Gagal mencari game (${response.statusCode}).');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List<dynamic>) {
      throw ApiException('Format data pencarian tidak sesuai.');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map((item) => item['game'])
        .whereType<Map<String, dynamic>>()
        .map(Game.fromJson)
        .where((game) => game.id != 0)
        .toList();
  }
}
