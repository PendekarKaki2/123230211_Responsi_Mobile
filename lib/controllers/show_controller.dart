import 'package:get/get.dart';

import '../models/game.dart';
import '../services/tvmaze_api_service.dart';

class ShowController extends GetxController {
  final TvMazeApiService _apiService = Get.find<TvMazeApiService>();

  final shows = <Game>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final searchQuery = ''.obs;
  final selectedGenre = 'Semua'.obs;
  final isGridView = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadShows();
  }

  Future<void> loadShows({bool forceRefresh = false}) async {
    if (shows.isNotEmpty && !forceRefresh) {
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _apiService.fetchGames();
      shows.assignAll(result);
    } on ApiException catch (error) {
      errorMessage.value = error.message;
    } catch (_) {
      errorMessage.value = 'Terjadi kesalahan saat mengambil data.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshShows() async {
    await loadShows(forceRefresh: true);
  }

  List<Game> get filteredShows {
    final query = searchQuery.value.toLowerCase();
    final genre = selectedGenre.value;

    return shows.where((show) {
      final matchesSearch = show.name.toLowerCase().contains(query);
      final matchesGenre = genre == 'Semua' || show.genres.contains(genre);
      return matchesSearch && matchesGenre;
    }).toList();
  }

  List<String> get genres {
    final genreSet = <String>{};
    for (final show in shows) {
      genreSet.addAll(show.genres);
    }
    final sortedGenres = genreSet.toList()..sort();
    return ['Semua', ...sortedGenres];
  }

  void setSearchQuery(String value) {
    searchQuery.value = value;
  }

  void setGenre(String value) {
    selectedGenre.value = value;
  }

  void toggleViewMode() {
    isGridView.value = !isGridView.value;
  }
}
