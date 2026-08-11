import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';
import '../theme/app_colors.dart';
import '../widgets/inline_trailer_preview.dart';
import '../widgets/safe_network_image.dart';
import '../widgets/trailer_player_modal.dart';
import 'movie_details_screen.dart';

/// Full-screen Instagram Reels style vertical feed for movie trailers & clips.
class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final PageController _pageController = PageController();
  final ApiService _apiService = ApiService();
  final FavoritesService _favoritesService = FavoritesService();

  List<Movie> _movies = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  bool _isMuted = true;

  // Double tap heart animation state
  final Map<int, List<Offset>> _heartBursts = {};

  @override
  void initState() {
    super.initState();
    _loadReelsFeed();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadReelsFeed() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        _apiService.fetchTrendingMovies(pages: 2),
        _apiService.fetchPopularMovies(pages: 2),
        _apiService.fetchBollywoodMovies(pages: 2),
        _apiService.fetchGujaratiMovies(pages: 2),
        _apiService.fetchMarvelMovies(pages: 2),
      ]);

      final Set<int> seenIds = {};
      final List<Movie> feed = [];

      for (final list in results) {
        for (final movie in list) {
          if (!seenIds.contains(movie.id) && movie.backdropPath != null) {
            seenIds.add(movie.id);
            feed.add(movie);
          }
        }
      }

      feed.shuffle();

      if (mounted) {
        setState(() {
          _movies = feed;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleDoubleTap(int pageIndex, TapDownDetails details) {
    final position = details.localPosition;
    setState(() {
      _heartBursts.putIfAbsent(pageIndex, () => []).add(position);
    });

    // Auto favorite on double tap
    final movie = _movies[pageIndex];
    if (!_favoritesService.isFavorite(movie.id)) {
      _favoritesService.toggleFavorite(movie);
    }

    Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _heartBursts[pageIndex]?.remove(position);
        });
      }
    });
  }

  Future<void> _shareMovie(Movie movie) async {
    final url = movie.youtubeTrailerUrl;
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sharing "${movie.title}" trailer...'),
          backgroundColor: AppColors.surfaceHighest,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text(
                'Loading Movie Reels...',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    if (_movies.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.movie_creation_outlined, color: AppColors.textMuted, size: 64),
              const SizedBox(height: 16),
              const Text(
                'No reels available',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _loadReelsFeed,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Feed'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Vertical Full-Screen Swipeable Reel PageView
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _movies.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final movie = _movies[index];
              final isActive = index == _currentIndex;

              return _buildReelPage(movie, index, isActive);
            },
          ),

          // Top Header Overlay (Instagram Reels Style)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black87,
                    Colors.black38,
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.movie_creation_rounded, color: AppColors.primary, size: 26),
                      SizedBox(width: 8),
                      Text(
                        'Reels',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),

                  // Reel Index Badge & Mute Toggle
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(
                          '${_currentIndex + 1} / ${_movies.length}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isMuted = !_isMuted;
                          });
                        },
                        icon: Icon(
                          _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReelPage(Movie movie, int index, bool isActive) {
    final effectiveKey = movie.effectiveVideoKey;

    return GestureDetector(
      onTapDown: (details) => _handleDoubleTap(index, details),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Video / Media Preview
          Positioned.fill(
            child: isActive
                ? InlineTrailerPreview(
                    videoKey: effectiveKey,
                    fallbackImageUrl: movie.fullBackdropUrl,
                    title: movie.title,
                    width: double.infinity,
                    height: double.infinity,
                    autoPlay: true,
                    muted: _isMuted,
                  )
                : SafeNetworkImage(
                    imageUrl: movie.fullBackdropUrl,
                    fallbackUrl: movie.fullPosterUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    title: movie.title,
                  ),
          ),

          // Dark Gradient Overlays for readable text
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [0.0, 0.25, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // Double Tap Heart Burst Animations
          if (_heartBursts.containsKey(index))
            ..._heartBursts[index]!.map((pos) {
              return Positioned(
                left: pos.dx - 40,
                top: pos.dy - 40,
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 600),
                  tween: Tween(begin: 0.5, end: 1.4),
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: (2.0 - scale).clamp(0.0, 1.0),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: AppColors.primary,
                          size: 80,
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 16),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),

          // Right Sidebar Actions (Instagram Reels Style)
          Positioned(
            right: 14,
            bottom: 30,
            child: ValueListenableBuilder<List<Movie>>(
              valueListenable: _favoritesService.favoritesNotifier,
              builder: (context, favorites, _) {
                final isFav = _favoritesService.isFavorite(movie.id);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Favorite / Like Button
                    _buildActionButton(
                      icon: isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      iconColor: isFav ? AppColors.primary : Colors.white,
                      label: isFav ? 'Liked' : 'Like',
                      onTap: () => _favoritesService.toggleFavorite(movie),
                    ),
                    const SizedBox(height: 18),

                    // Play Full Trailer
                    _buildActionButton(
                      icon: Icons.play_circle_fill_rounded,
                      iconColor: AppColors.secondary,
                      label: 'Trailer',
                      onTap: () => TrailerPlayerModal.show(context, movie),
                    ),
                    const SizedBox(height: 18),

                    // Share Button
                    _buildActionButton(
                      icon: Icons.send_rounded,
                      iconColor: Colors.white,
                      label: 'Share',
                      onTap: () => _shareMovie(movie),
                    ),
                    const SizedBox(height: 18),

                    // Movie Info Details
                    _buildActionButton(
                      icon: Icons.info_outline_rounded,
                      iconColor: Colors.white,
                      label: 'Details',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MovieDetailsScreen(movie: movie),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),

          // Bottom Left Movie Overlay Info
          Positioned(
            left: 16,
            right: 80,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Movie Poster Badge & Title
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SafeNetworkImage(
                        imageUrl: movie.fullPosterUrl,
                        width: 44,
                        height: 60,
                        fit: BoxFit.cover,
                        title: movie.title,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(color: Colors.black87, blurRadius: 8),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Rating & Release Year Row
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star_rounded, color: Colors.black, size: 12),
                                    const SizedBox(width: 2),
                                    Text(
                                      movie.formattedRating,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${movie.releaseYear} • ${movie.genres.take(2).join(', ')}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Overview Caption
                Text(
                  movie.overview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white90,
                    fontSize: 13,
                    height: 1.4,
                    shadows: [
                      Shadow(color: Colors.black87, blurRadius: 6),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Action Callout Button
                GestureDetector(
                  onTap: () => TrailerPlayerModal.show(context, movie),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white38),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.movie_rounded, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Watch Official Trailer',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.chevron_right_rounded, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 1.5),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 26,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(color: Colors.black, blurRadius: 4),
            ],
          ),
        ),
      ],
    );
  }
}
