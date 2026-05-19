import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/game.dart';

class FavoriteService extends GetxService {
  static const _boxName = 'favorite_shows';

  late final Box<dynamic> _box = Hive.box<dynamic>(_boxName);

  static Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<dynamic>(_boxName);
    }
  }

  List<Game> getFavorites() {
    return _box.values
        .whereType<Map<dynamic, dynamic>>()
        .map(Game.fromStorage)
        .toList()
      ..sort((first, second) => first.name.compareTo(second.name));
  }

  Future<void> addFavorite(Game show) async {
    await _box.put(show.id.toString(), show.toStorage());
  }

  Future<void> removeFavorite(int id) async {
    await _box.delete(id.toString());
  }

  bool isFavorite(int id) {
    return _box.containsKey(id.toString());
  }
}
