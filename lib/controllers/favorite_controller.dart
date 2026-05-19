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
    return favorites.any((show) => show.id == id);
  }

  Future<void> toggleFavorite(Game show) async {
    if (isFavorite(show.id)) {
      await removeFavorite(show.id, showName: show.name, showMessage: true);
      return;
    }

    await _favoriteService.addFavorite(show);
    loadFavorites();
    _showSnackBar(
      title: 'Ditambahkan',
      message: '${show.name} masuk ke favorit.',
      color: Colors.green,
    );
  }

  Future<void> removeFavorite(
    int id, {
    String? showName,
    bool showMessage = false,
  }) async {
    final removedShow = favorites.firstWhereOrNull((show) => show.id == id);
    await _favoriteService.removeFavorite(id);
    loadFavorites();

    if (showMessage) {
      _showSnackBar(
        title: 'Dihapus',
        message:
            '${showName ?? removedShow?.name ?? 'Show'} dihapus dari favorit.',
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
