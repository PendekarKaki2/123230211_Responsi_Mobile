import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/favorite_controller.dart';
import '../models/game.dart';
import '../services/tvmaze_api_service.dart';
import '../widgets/game_poster.dart';
import '../widgets/state_message.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final _apiService = Get.find<TvMazeApiService>();

  late final int _gameId;
  Game? _initialGame;
  late Future<Game> _detailFuture;

  @override
  void initState() {
    super.initState();
    _readArguments();
    _detailFuture = _fetchDetail();
  }

  void _readArguments() {
    final argument = Get.arguments;
    if (argument is Game) {
      _initialGame = argument;
      _gameId = argument.id;
      return;
    }
    if (argument is int) {
      _gameId = argument;
      return;
    }
    _gameId = int.tryParse(argument?.toString() ?? '') ?? 0;
  }

  Future<Game> _fetchDetail() {
    if (_gameId == 0) {
      return Future.error(ApiException('ID game tidak valid.'));
    }
    return _apiService.fetchGameDetail(_gameId);
  }

  void _retry() {
    setState(() {
      _detailFuture = _fetchDetail();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Game')),
      body: FutureBuilder<Game>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _initialGame == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError && _initialGame == null) {
            return StateMessage(
              icon: Icons.error_outline_rounded,
              title: 'Detail gagal dimuat',
              message: snapshot.error.toString(),
              actionLabel: 'Coba lagi',
              onAction: _retry,
            );
          }

          final game = snapshot.data ?? _initialGame!;
          return _DetailContent(
            game: game,
            isRefreshing: snapshot.connectionState == ConnectionState.waiting,
            warningMessage: snapshot.hasError
                ? snapshot.error.toString()
                : null,
          );
        },
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({
    required this.game,
    required this.isRefreshing,
    this.warningMessage,
  });

  final Game game;
  final bool isRefreshing;
  final String? warningMessage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _HeroHeader(game: game)),
        if (isRefreshing)
          const SliverToBoxAdapter(child: LinearProgressIndicator()),
        if (warningMessage != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  warningMessage!,
                  style: TextStyle(color: colorScheme.onErrorContainer),
                ),
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LibraryAction(game: game),
                const SizedBox(height: 18),
                _InfoPanel(game: game),
                const SizedBox(height: 22),
                _SectionTitle(title: 'Screenshots'),
                const SizedBox(height: 10),
                _ScreenshotList(images: game.screenshots),
                const SizedBox(height: 22),
                _SectionTitle(title: 'Deskripsi'),
                const SizedBox(height: 8),
                Text(
                  game.descriptionLabel,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.45,
                    color: colorScheme.onSurface.withValues(alpha: 0.78),
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 300,
          width: double.infinity,
          child: ShowPoster(imageUrl: game.posterUrl),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.78),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 18,
          right: 18,
          bottom: 18,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                game.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  height: 1.12,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _HeroChip(icon: Icons.category_outlined, label: game.genre),
                  _HeroChip(icon: Icons.devices_rounded, label: game.platform),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black87),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryAction extends StatelessWidget {
  const _LibraryAction({required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    final favoriteController = Get.find<FavoriteController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      final isOwned = favoriteController.isFavorite(game.id);
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: isOwned
            ? OutlinedButton.icon(
                onPressed: () => favoriteController.toggleFavorite(game),
                icon: const Icon(Icons.check_circle_rounded),
                label: const Text('Sudah di Library'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  side: BorderSide(color: colorScheme.primary, width: 1.4),
                ),
              )
            : FilledButton.icon(
                onPressed: () => favoriteController.toggleFavorite(game),
                icon: const Icon(Icons.add_task_rounded),
                label: const Text('Dapatkan Game'),
              ),
      );
    });
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.event_available_rounded,
            label: 'Tanggal Rilis',
            value: game.releaseDate,
          ),
          _InfoRow(
            icon: Icons.business_rounded,
            label: 'Publisher',
            value: game.publisher,
          ),
          _InfoRow(
            icon: Icons.code_rounded,
            label: 'Developer',
            value: game.developer,
          ),
          _InfoRow(
            icon: Icons.verified_outlined,
            label: 'Status',
            value: game.status ?? 'Tidak diketahui',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : BorderSide(color: Colors.black.withValues(alpha: 0.07)),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.62),
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScreenshotList extends StatelessWidget {
  const _ScreenshotList({required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.primaryContainer.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('Belum ada screenshot untuk game ini.'),
      );
    }

    return SizedBox(
      height: 166,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: ShowPoster(imageUrl: images[index]),
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
    );
  }
}
