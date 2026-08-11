import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../models/cast_member.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';
import '../theme/app_colors.dart';
import '../widgets/actor_card.dart';
import '../widgets/horizontal_movie_list.dart';
import '../widgets/inline_trailer_preview.dart';
import '../widgets/rating_badge.dart';
import '../widgets/trailer_player_modal.dart';
import 'actor_details_screen.dart';

class MovieDetailsScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailsScreen({super.key, required this.movie});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  late Movie _movie;
  List<CastMember> _cast = [];
  List<Movie> _similarMovies = [];
  bool _isLoadingCast = true;
  bool _isLoadingSimilar = true;
  bool _isHeaderMuted = true;

  @override
  void initState() {
    super.initState();
    _movie = widget.movie;
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final results = await Future.wait([
        ApiService().fetchMovieDetails(_movie.id),
        ApiService().fetchMovieCast(_movie.id),
        ApiService().fetchSimilarMovies(_movie.id),
      ]);

      if (mounted) {
        setState(() {
          _movie = results[0] as Movie;
          _cast = results[1] as List<CastMember>;
          _similarMovies = results[2] as List<Movie>;
          _isLoadingCast = false;
          _isLoadingSimilar = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCast = false;
          _isLoadingSimilar = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ValueListenableBuilder<List<Movie>>(
        valueListenable: FavoritesService().favoritesNotifier,
        builder: (context, favorites, _) {
          final isFav = FavoritesService().isFavorite(_movie.id);

          return CustomScrollView(
            slivers: [
              // Sliver AppBar with Backdrop and Trailer Action
              SliverAppBar(
                expandedHeight: 320.0,
                pinned: true,
                backgroundColor: AppColors.background,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: isFav ? AppColors.primary : Colors.white,
                      ),
                      onPressed: () {
                        FavoritesService().toggleFavorite(_movie);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isFav
                                  ? 'Removed "${_movie.title}" from Watchlist'
                                  : 'Added "${_movie.title}" to Watchlist',
                            ),
                            duration: const Duration(seconds: 2),
                            backgroundColor: AppColors.surfaceHighest,
                          ),
                        );
                      },
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      InlineTrailerPreview(
                        videoKey: _movie.effectiveVideoKey,
                        fallbackImageUrl: _movie.youtubeThumbnailUrl.isNotEmpty
                            ? _movie.youtubeThumbnailUrl
                            : _movie.fullBackdropUrl,
                        title: _movie.title,
                        width: double.infinity,
                        height: 320,
                        autoPlay: true,
                        muted: _isHeaderMuted,
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0.2, 0.7, 1.0],
                            colors: [
                              Colors.transparent,
                              Color(0xAA0B1326),
                              Color(0xFF0B1326),
                            ],
                          ),
                        ),
                      ),
                      // Interactive Mute / Unmute Button Overlay
                      Positioned(
                        bottom: 12,
                        left: 16,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isHeaderMuted = !_isHeaderMuted;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.primary, width: 1.5),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black45,
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isHeaderMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isHeaderMuted ? 'UNMUTE TRAILER' : 'MUTE TRAILER',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.play_circle_fill_rounded, color: AppColors.secondary, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'OFFICIAL TRAILER',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Movie Details Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Rating Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _movie.title,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                if (_movie.tagline != null && _movie.tagline!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '"${_movie.tagline!}"',
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontStyle: FontStyle.italic,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          RatingBadge(rating: _movie.voteAverage, fontSize: 14),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Meta info pill (Year, Runtime, Votes)
                      Row(
                        children: [
                          _buildMetaChip(Icons.calendar_today_rounded, _movie.releaseYear),
                          const SizedBox(width: 10),
                          if (_movie.runtime != null)
                            _buildMetaChip(Icons.timer_rounded, '${_movie.runtime} min'),
                          const SizedBox(width: 10),
                          _buildMetaChip(Icons.how_to_vote_rounded, '${_movie.voteCount} votes'),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Watch Official Trailer Action Banner Button
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton.icon(
                          onPressed: () => TrailerPlayerModal.show(context, _movie),
                          icon: const Icon(Icons.play_circle_fill_rounded, size: 22),
                          label: const Text(
                            'Watch Official Trailer',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Genre Chips
                      if (_movie.genres.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _movie.genres.map((genre) {
                            return Chip(
                              label: Text(genre),
                              backgroundColor: AppColors.surfaceContainer,
                              side: const BorderSide(color: AppColors.glassBorder),
                            );
                          }).toList(),
                        ),

                      const SizedBox(height: 20),

                      // Storyline / Plot Overview
                      const Text(
                        'Storyline',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onBackground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _movie.overview,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.onSurface,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Top Cast
                      const Text(
                        'Top Cast',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onBackground,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 140,
                        child: _isLoadingCast
                            ? const Center(
                                child: CircularProgressIndicator(color: AppColors.primary),
                              )
                            : _cast.isEmpty
                                ? const Text(
                                    'No cast info available.',
                                    style: TextStyle(color: AppColors.textMuted),
                                  )
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _cast.length,
                                    itemBuilder: (context, index) {
                                      final castMember = _cast[index];
                                      return ActorCard.fromCastMember(
                                        castMember,
                                        onTap: () async {
                                          final actor = await ApiService()
                                              .fetchActorDetails(castMember.id);
                                          if (context.mounted) {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ActorDetailsScreen(actor: actor),
                                              ),
                                            );
                                          }
                                        },
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
              ),

              // Similar Recommendations (Placed flush without line overflow)
              if (!_isLoadingSimilar && _similarMovies.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0, bottom: 40.0),
                    child: HorizontalMovieList(
                      title: 'More Like This',
                      movies: _similarMovies,
                      onMovieTap: (similarMovie) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MovieDetailsScreen(movie: similarMovie),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetaChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.secondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
