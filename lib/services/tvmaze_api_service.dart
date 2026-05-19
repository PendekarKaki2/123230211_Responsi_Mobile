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

  static const _baseUrl = 'https://www.freetogame.com/api';

  final http.Client _client;

  Future<List<Game>> fetchGames() async {
    final uri = Uri.parse('$_baseUrl/games');
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
    final uri = Uri.parse('$_baseUrl/game?id=$id');
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
    if (decoded['status'] == 0) {
      throw ApiException(
        decoded['status_message']?.toString() ?? 'Game tidak ditemukan.',
      );
    }

    return Game.fromJson(decoded);
  }

  Future<List<Game>> searchGames(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return fetchGames();
    }

    final games = await fetchGames();
    final loweredQuery = trimmedQuery.toLowerCase();
    return games
        .where((game) => game.title.toLowerCase().contains(loweredQuery))
        .toList();
  }
}
