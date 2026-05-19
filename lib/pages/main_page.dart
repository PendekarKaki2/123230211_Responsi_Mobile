import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/favorite_controller.dart';
import '../controllers/show_controller.dart';
import 'favorite_page.dart';
import 'home_page.dart';
import 'profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _showController = Get.find<ShowController>();
  final _favoriteController = Get.find<FavoriteController>();

  int _selectedIndex = 0;

  final _pages = const [HomePage(), FavoritePage(), ProfilePage()];

  final _titles = const ['Daftar Shows', 'Favorit', 'Profil'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: _buildActions(),
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Obx(
              () => Badge.count(
                count: _favoriteController.favorites.length,
                isLabelVisible: _favoriteController.favorites.isNotEmpty,
                child: const Icon(Icons.favorite_border_rounded),
              ),
            ),
            activeIcon: Obx(
              () => Badge.count(
                count: _favoriteController.favorites.length,
                isLabelVisible: _favoriteController.favorites.isNotEmpty,
                child: const Icon(Icons.favorite_rounded),
              ),
            ),
            label: 'Favorit',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions() {
    if (_selectedIndex != 0) {
      return const [];
    }

    return [
      Obx(() {
        final isGrid = _showController.isGridView.value;
        return IconButton(
          tooltip: isGrid ? 'Tampilan list' : 'Tampilan grid',
          onPressed: _showController.toggleViewMode,
          icon: Icon(
            isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
          ),
        );
      }),
      IconButton(
        tooltip: 'Refresh data',
        onPressed: _showController.refreshShows,
        icon: const Icon(Icons.refresh_rounded),
      ),
    ];
  }
}
