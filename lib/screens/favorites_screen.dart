import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/favorites_service.dart';
import '../theme/app_colors.dart';
import '../widgets/movie_card.dart';
import '../widgets/netflix_hover_card.dart';
import 'movie_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final VoidCallback onExploreTap;

  const FavoritesScreen({super.key, required this.onExploreTap});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 4 : 2;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Watchlist & Favorites'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: ValueListenableBuilder<List<Movie>>(
        valueListenable: FavoritesService().favoritesNotifier,
        builder: (context, favorites, _) {
          if (favorites.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bookmark_border_rounded,
                        size: 56,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Your Watchlist is Empty',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onBackground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap the bookmark icon on any movie poster or details page to save it for later.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: onExploreTap,
                      icon: const Icon(Icons.explore_rounded),
                      label: const Text('Explore Movies'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification) {
                NetflixHoverManager().dismissAll();
              }
              return false;
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Saved Titles (${favorites.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onBackground,
                          ),
                        ),
                        Text(
                          'Tap poster to view',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.66,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final movie = favorites[index];
                        return MovieCard(
                          movie: movie,
                          width: double.infinity,
                          height: double.infinity,
                          margin: EdgeInsets.zero,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => MovieDetailsScreen(movie: movie),
                              ),
                            );
                          },
                        );
                      },
                      childCount: favorites.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          );
        },
      ),
    );
  }
}

