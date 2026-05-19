import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/show_controller.dart';
import '../models/game.dart';
import '../routes/app_routes.dart';
import '../widgets/game_card.dart';
import '../widgets/state_message.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _showController = Get.find<ShowController>();
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_showController.isLoading.value && _showController.shows.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_showController.errorMessage.value.isNotEmpty &&
          _showController.shows.isEmpty) {
        return StateMessage(
          icon: Icons.wifi_off_rounded,
          title: 'Data belum berhasil dimuat',
          message: _showController.errorMessage.value,
          actionLabel: 'Coba lagi',
          onAction: _showController.refreshShows,
        );
      }

      final filteredShows = _showController.filteredShows;

      return RefreshIndicator(
        onRefresh: _showController.refreshShows,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _HomeControls(
                searchController: _searchController,
                resultCount: filteredShows.length,
                totalCount: _showController.shows.length,
              ),
            ),
            if (_showController.isLoading.value)
              const SliverToBoxAdapter(
                child: LinearProgressIndicator(minHeight: 2),
              ),
            if (_showController.errorMessage.value.isNotEmpty)
              SliverToBoxAdapter(
                child: _ErrorBanner(
                  message: _showController.errorMessage.value,
                ),
              ),
            if (filteredShows.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: StateMessage(
                  icon: Icons.search_off_rounded,
                  title: 'Show tidak ditemukan',
                  message: 'Coba ubah kata kunci atau filter genre.',
                ),
              )
            else if (_showController.isGridView.value)
              _ShowGrid(shows: filteredShows)
            else
              _ShowList(shows: filteredShows),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
          ],
        ),
      );
    });
  }
}

class _HomeControls extends StatelessWidget {
  const _HomeControls({
    required this.searchController,
    required this.resultCount,
    required this.totalCount,
  });

  final TextEditingController searchController;
  final int resultCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final showController = Get.find<ShowController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: searchController,
            onChanged: showController.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'Cari judul show',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: Obx(
                () => showController.searchQuery.value.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(
                        tooltip: 'Hapus pencarian',
                        onPressed: () {
                          searchController.clear();
                          showController.setSearchQuery('');
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: Obx(() {
              final genres = showController.genres;
              final selectedGenre = showController.selectedGenre.value;

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: genres.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final genre = genres[index];
                  return ChoiceChip(
                    label: Text(genre),
                    selected: selectedGenre == genre,
                    onSelected: (_) => showController.setGenre(genre),
                  );
                },
              );
            }),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.movie_filter_outlined,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Menampilkan $resultCount dari $totalCount show',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.64),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShowGrid extends StatelessWidget {
  const _ShowGrid({required this.shows});

  final List<Game> shows;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.crossAxisExtent;
        final crossAxisCount = width >= 980
            ? 5
            : width >= 720
            ? 4
            : width >= 480
            ? 3
            : 2;

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.61,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final show = shows[index];
              return ShowCard(
                show: show,
                isGrid: true,
                onTap: () => Get.toNamed(AppRoutes.detail, arguments: show),
              );
            }, childCount: shows.length),
          ),
        );
      },
    );
  }
}

class _ShowList extends StatelessWidget {
  const _ShowList({required this.shows});

  final List<Game> shows;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      sliver: SliverList.separated(
        itemCount: shows.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final show = shows[index];
          return ShowCard(
            show: show,
            onTap: () => Get.toNamed(AppRoutes.detail, arguments: show),
          );
        },
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colorScheme.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
