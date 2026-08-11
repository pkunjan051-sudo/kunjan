import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../theme/app_colors.dart';
import 'movie_card.dart';
import 'netflix_hover_card.dart';
import 'shimmer_loading.dart';

class HorizontalMovieList extends StatelessWidget {
  final String title;
  final List<Movie> movies;
  final bool isLoading;
  final Function(Movie) onMovieTap;
  final VoidCallback? onSeeAllTap;

  const HorizontalMovieList({
    super.key,
    required this.title,
    required this.movies,
    this.isLoading = false,
    required this.onMovieTap,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading && movies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Red Vertical Accent Indicator
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.6),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    if (!isLoading && movies.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
                        ),
                        child: Text(
                          '${movies.length}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (onSeeAllTap != null)
                InkWell(
                  onTap: onSeeAllTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'See All',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 235,
          child: isLoading
              ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 5,
                  itemBuilder: (context, index) => const MovieCardSkeleton(),
                )
              : NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollStartNotification) {
                      NetflixHoverManager().dismissAll();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      final movie = movies[index];
                      return MovieCard(
                        movie: movie,
                        margin: const EdgeInsets.only(right: 20), // 20px card spacing
                        onTap: () => onMovieTap(movie),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

