import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/game.dart';
import '../services/favorite_service.dart';

class FavoriteController extends GetxController {
  final FavoriteService _favoriteService = Get.find<FavoriteService>();

  final favorites = <Game>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  void loadFavorites() {
    favorites.assignAll(_favoriteService.getFavorites());
  }

  bool isFavorite(int id) {
    return favorites.any((game) => game.id == id);
  }

  Future<void> toggleFavorite(Game game) async {
    if (isFavorite(game.id)) {
      await removeFavorite(game.id, showName: game.name, showMessage: true);
      return;
    }

    await _favoriteService.addFavorite(game);
    loadFavorites();
    _showSnackBar(
      title: 'Berhasil didapatkan',
      message: '${game.name} masuk ke Library.',
      color: Colors.green,
    );
  }

  Future<void> removeFavorite(
    int id, {
    String? showName,
    bool showMessage = false,
  }) async {
    final removedShow = favorites.firstWhereOrNull((game) => game.id == id);
    await _favoriteService.removeFavorite(id);
    loadFavorites();

    if (showMessage) {
      _showSnackBar(
        title: 'Dihapus',
        message:
            '${showName ?? removedShow?.name ?? 'Game'} dihapus dari Library.',
        color: Colors.red,
      );
    }
  }

  void _showSnackBar({
    required String title,
    required String message,
    required MaterialColor color,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color.shade50,
      colorText: color.shade900,
      margin: const EdgeInsets.all(16),
    );
  }
}
