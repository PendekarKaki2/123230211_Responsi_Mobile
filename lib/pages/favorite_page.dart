import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/favorite_controller.dart';
import '../models/game.dart';
import '../routes/app_routes.dart';
import '../widgets/game_card.dart';
import '../widgets/state_message.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteController = Get.find<FavoriteController>();

    return Obx(() {
      final favorites = favoriteController.favorites;

      if (favorites.isEmpty) {
        return const StateMessage(
          icon: Icons.collections_bookmark_outlined,
          title: 'Library masih kosong',
          message: 'Dapatkan game dari halaman Home atau Detail.',
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
        itemCount: favorites.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final show = favorites[index];

          return Dismissible(
            key: ValueKey(show.id),
            direction: DismissDirection.endToStart,
            background: _DeleteBackground(),
            confirmDismiss: (_) => _confirmDelete(context, show),
            onDismissed: (_) {
              favoriteController.removeFavorite(
                show.id,
                showName: show.name,
                showMessage: true,
              );
            },
            child: ShowCard(
              show: show,
              showFavoriteButton: false,
              trailing: IconButton(
                tooltip: 'Hapus dari Library',
                onPressed: () async {
                  final shouldDelete = await _confirmDelete(context, show);
                  if (shouldDelete == true) {
                    await favoriteController.removeFavorite(
                      show.id,
                      showName: show.name,
                      showMessage: true,
                    );
                  }
                },
                icon: const Icon(Icons.delete_outline_rounded),
              ),
              onTap: () => Get.toNamed(AppRoutes.detail, arguments: show),
            ),
          );
        },
      );
    });
  }

  Future<bool> _confirmDelete(BuildContext context, Game show) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Hapus dari Library?'),
              content: Text('${show.name} akan dihapus dari daftar game.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Hapus'),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}

class _DeleteBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 22),
      decoration: BoxDecoration(
        color: colorScheme.error,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.delete_rounded, color: colorScheme.onError),
    );
  }
}
