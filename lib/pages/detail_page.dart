import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/favorite_controller.dart';
import '../models/game.dart';
import '../services/tvmaze_api_service.dart';
import '../widgets/rating_chip.dart';
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
  Game? _initialShow;
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
      _initialShow = argument;
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
              _initialShow == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError && _initialShow == null) {
            return StateMessage(
              icon: Icons.error_outline_rounded,
              title: 'Detail gagal dimuat',
              message: snapshot.error.toString(),
              actionLabel: 'Coba lagi',
              onAction: _retry,
            );
          }

          final show = snapshot.data ?? _initialShow!;
          return _DetailContent(
            show: show,
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
    required this.show,
    required this.isRefreshing,
    this.warningMessage,
  });

  final Game show;
  final bool isRefreshing;
  final String? warningMessage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Stack(
            children: [
              SizedBox(
                height: 360,
                width: double.infinity,
                child: ShowPoster(imageUrl: show.posterUrl),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.72),
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
                      show.name,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                    ),
                    const SizedBox(height: 10),
                    RatingChip(ratingLabel: show.ratingLabel),
                  ],
                ),
              ),
            ],
          ),
        ),
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
                _FavoriteAction(show: show),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: show.genres.isEmpty
                      ? [const Chip(label: Text('Tidak ada genre'))]
                      : show.genres
                            .map((genre) => Chip(label: Text(genre)))
                            .toList(),
                ),
                const SizedBox(height: 18),
                _InfoPanel(show: show),
                const SizedBox(height: 20),
                Text(
                  'Overview',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  show.summary,
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

class _FavoriteAction extends StatelessWidget {
  const _FavoriteAction({required this.show});

  final Game show;

  @override
  Widget build(BuildContext context) {
    final favoriteController = Get.find<FavoriteController>();

    return Obx(() {
      final isFavorite = favoriteController.isFavorite(show.id);
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: FilledButton.icon(
          onPressed: () => favoriteController.toggleFavorite(show),
          icon: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          ),
          label: Text(isFavorite ? 'Hapus dari Favorit' : 'Tambah ke Favorit'),
        ),
      );
    });
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.show});

  final Game show;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InfoRow(
          icon: Icons.translate_rounded,
          label: 'Bahasa',
          value: show.language ?? 'Tidak diketahui',
        ),
        _InfoRow(
          icon: Icons.flag_outlined,
          label: 'Status',
          value: show.status ?? 'Tidak diketahui',
        ),
        _InfoRow(
          icon: Icons.event_available_rounded,
          label: 'Premier',
          value: show.premiered ?? 'Tidak diketahui',
        ),
        _InfoRow(
          icon: Icons.schedule_rounded,
          label: 'Jadwal',
          value: show.schedule ?? 'Tidak diketahui',
          isLast: true,
        ),
      ],
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
      padding: const EdgeInsets.symmetric(vertical: 10),
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
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
