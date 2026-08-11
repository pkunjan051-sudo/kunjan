import 'dart:async';
import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../theme/app_colors.dart';
import 'rating_badge.dart';
import 'safe_network_image.dart';

import 'trailer_player_modal.dart';

class HeroCarousel extends StatefulWidget {
  final List<Movie> movies;
  final Function(Movie) onMovieTap;

  const HeroCarousel({
    super.key,
    required this.movies,
    required this.onMovieTap,
  });

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (widget.movies.isNotEmpty && _pageController.hasClients) {
        final nextPage = (_currentPage + 1) % widget.movies.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 280,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.movies.length,
            itemBuilder: (context, index) {
              final movie = widget.movies[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Backdrop Image
                      Positioned.fill(
                        child: SafeNetworkImage(
                          imageUrl: movie.fullBackdropUrl,
                          fallbackUrl: movie.fullPosterUrl,
                          fit: BoxFit.cover,
                          title: movie.title,
                        ),
                      ),

                      // Gradient Veil with Obsidian Blur Fade
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0.0, 0.4, 0.85, 1.0],
                              colors: [
                                Colors.transparent,
                                Color(0x33090D16),
                                Color(0xDD090D16),
                                Color(0xFF090D16),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Rating & N Featured Badge (Top Left)
                      Positioned(
                        top: 14,
                        left: 14,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'FEATURED',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            RatingBadge(rating: movie.voteAverage),
                          ],
                        ),
                      ),

                      // Content details
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (movie.genres.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                ),
                                child: Text(
                                  movie.genres.take(3).join(' • ').toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                            ],
                            Text(
                              movie.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.2,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black,
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            if (movie.tagline != null && movie.tagline!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                '"${movie.tagline!}"',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.onBackground,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.55),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: () => TrailerPlayerModal.show(context, movie),
                                    icon: const Icon(Icons.play_arrow_rounded, size: 22, color: Colors.white),
                                    label: const Text(
                                      'Watch Trailer',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                OutlinedButton.icon(
                                  onPressed: () => widget.onMovieTap(movie),
                                  icon: const Icon(Icons.info_outline_rounded, size: 18, color: Colors.white),
                                  label: const Text(
                                    'Details',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(color: AppColors.glassBorder, width: 1.2),
                                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black45,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.white12),
                                  ),
                                  child: Text(
                                    movie.releaseYear,
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),

        // Indicator dots with primary red glow
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.movies.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == index ? 24 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: _currentPage == index ? AppColors.primary : AppColors.surfaceHighest,
                borderRadius: BorderRadius.circular(4),
                boxShadow: _currentPage == index
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.6),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
