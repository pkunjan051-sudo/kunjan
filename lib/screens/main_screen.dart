import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/favorites_service.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'reels_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(onSearchTap: () => _onTabTapped(1)),
      const SearchScreen(),
      const ReelsScreen(),
      FavoritesScreen(onExploreTap: () => _onTabTapped(0)),
      const ProfileScreen(),
    ];
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: ValueListenableBuilder<List<Movie>>(
        valueListenable: FavoritesService().favoritesNotifier,
        builder: (context, favorites, _) {
          return NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _onTabTapped,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              const NavigationDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search_rounded),
                label: 'Search',
              ),
              const NavigationDestination(
                icon: Icon(Icons.movie_creation_outlined),
                selectedIcon: Icon(Icons.movie_creation_rounded),
                label: 'Reels',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: favorites.isNotEmpty,
                  label: Text('${favorites.length}'),
                  child: const Icon(Icons.bookmark_border_rounded),
                ),
                selectedIcon: Badge(
                  isLabelVisible: favorites.isNotEmpty,
                  label: Text('${favorites.length}'),
                  child: const Icon(Icons.bookmark_rounded),
                ),
                label: 'Watchlist',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          );
        },
      ),
    );
  }
}
