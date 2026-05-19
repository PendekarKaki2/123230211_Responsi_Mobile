import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/favorite_controller.dart';
import '../models/game.dart';
import 'game_poster.dart';

class ShowCard extends StatelessWidget {
  const ShowCard({
    super.key,
    required this.show,
    required this.onTap,
    this.isGrid = false,
    this.showFavoriteButton = true,
    this.trailing,
  });

  final Game show;
  final VoidCallback onTap;
  final bool isGrid;
  final bool showFavoriteButton;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: isGrid ? _buildGridContent(context) : _buildListContent(context),
      ),
    );
  }

  Widget _buildGridContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              ShowPoster(imageUrl: show.posterUrl),
              if (showFavoriteButton)
                Positioned(
                  top: 4,
                  right: 4,
                  child: _FavoriteButton(show: show, compact: true),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                show.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                show.genreLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.62),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                show.platformLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.56),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListContent(BuildContext context) {
    return SizedBox(
      height: 128,
      child: Row(
        children: [
          ShowPoster(imageUrl: show.posterUrl, width: 124, height: 128),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    show.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _MetaLine(
                    icon: Icons.category_outlined,
                    text: show.genreLabel,
                  ),
                  const SizedBox(height: 6),
                  _MetaLine(
                    icon: Icons.devices_rounded,
                    text: show.platformLabel,
                  ),
                ],
              ),
            ),
          ),
          if (trailing != null)
            Padding(padding: const EdgeInsets.only(right: 4), child: trailing)
          else if (showFavoriteButton)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: _FavoriteButton(show: show),
            ),
        ],
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.primary),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.66),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.show, this.compact = false});

  final Game show;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final favoriteController = Get.find<FavoriteController>();

    return Obx(() {
      final isFavorite = favoriteController.isFavorite(show.id);
      return IconButton.filledTonal(
        tooltip: isFavorite ? 'Hapus dari Library' : 'Dapatkan game',
        iconSize: compact ? 18 : 22,
        constraints: BoxConstraints.tightFor(
          width: compact ? 36 : 42,
          height: compact ? 36 : 42,
        ),
        visualDensity: VisualDensity.compact,
        onPressed: () => favoriteController.toggleFavorite(show),
        icon: Icon(
          isFavorite
              ? Icons.collections_bookmark_rounded
              : Icons.add_task_rounded,
        ),
      );
    });
  }
}
