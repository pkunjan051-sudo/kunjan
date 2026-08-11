import 'dart:async';
import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../screens/movie_details_screen.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';
import '../theme/app_colors.dart';
import 'netflix_action_buttons.dart';
import 'netflix_meta_info.dart';
import 'netflix_video_preview.dart';
import 'safe_network_image.dart';

/// Central Hover Manager to ensure strictly ONLY ONE Netflix hover card overlay can be open at any time across the app.
class NetflixHoverManager {
  static final NetflixHoverManager _instance = NetflixHoverManager._internal();
  factory NetflixHoverManager() => _instance;
  NetflixHoverManager._internal();

  NetflixHoverCardState? _activeState;

  void setActive(NetflixHoverCardState state) {
    if (_activeState != null && _activeState != state) {
      _activeState?._dismissOverlayDirectly();
    }
    _activeState = state;
  }

  void clearActive(NetflixHoverCardState state) {
    if (_activeState == state) {
      _activeState = null;
    }
  }

  void dismissAll() {
    _activeState?._dismissOverlayDirectly();
    _activeState = null;
  }
}

/// Premium Netflix-Style Hover Card with Floating Overlay (z-index popout above surrounding cards).
/// 
/// Key Features & Performance Enhancements:
/// - Generous expanded card dimensions (290x350 px) displaying ALL 4 action buttons & metadata.
/// - 350ms Hover Activation Debounce: Prevents accidental video loads during rapid mouse movement over cards.
/// - Single Global Overlay Controller: Guarantees ONLY 1 hover preview opens at any time, eliminating lag.
/// - Increased Card Spacing: Provides ample room between adjacent movie cards.
class NetflixHoverCard extends StatefulWidget {
  final Movie movie;
  final VoidCallback onTap;
  final double width;
  final double height;
  final Duration animationDuration;
  final EdgeInsetsGeometry? margin;

  const NetflixHoverCard({
    super.key,
    required this.movie,
    required this.onTap,
    this.width = 145,
    this.height = 215,
    this.animationDuration = const Duration(milliseconds: 300),
    this.margin,
  });

  @override
  State<NetflixHoverCard> createState() => NetflixHoverCardState();
}

class NetflixHoverCardState extends State<NetflixHoverCard> {
  OverlayEntry? _overlayEntry;
  bool _isHovered = false;
  bool _isPointerInsideBaseCard = false;
  Timer? _hoverTimer;

  @override
  void dispose() {
    _hoverTimer?.cancel();
    _removeOverlay();
    NetflixHoverManager().clearActive(this);
    super.dispose();
  }

  void _onPointerEnter(PointerEvent event) {
    _isPointerInsideBaseCard = true;
    _hoverTimer?.cancel();
    // 300ms hover delay so fast mouse scrubbing never triggers unwanted video previews or lag
    _hoverTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted || !_isPointerInsideBaseCard) return;
      NetflixHoverManager().setActive(this);
      setState(() {
        _isHovered = true;
      });
      _showOverlay();
    });
  }

  void _onPointerExit(PointerEvent event) {
    _isPointerInsideBaseCard = false;
    _hoverTimer?.cancel();
    // Only dismiss if overlay entry is NOT showing.
    // When overlay is showing, the overlay's own MouseRegion handles exit when mouse leaves expanded overlay.
    if (_overlayEntry == null && _isHovered) {
      _dismissOverlayDirectly();
    }
  }

  void _dismissOverlayDirectly() {
    _hoverTimer?.cancel();
    _isPointerInsideBaseCard = false;
    if (_isHovered) {
      if (mounted) {
        setState(() {
          _isHovered = false;
        });
      } else {
        _isHovered = false;
      }
    }
    _removeOverlay();
    NetflixHoverManager().clearActive(this);
  }

  void _showOverlay() {
    _removeOverlay();

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached) return;

    final cardOffset = renderBox.localToGlobal(Offset.zero);
    final cardSize = renderBox.size;
    final screenSize = MediaQuery.of(context).size;

    // Generous expanded card size ensuring all 4 action buttons & details fit with zero overflow
    const expandedWidth = 290.0;
    const expandedHeight = 350.0;

    // Calculate center-aligned floating overlay position
    final centerX = cardOffset.dx + (cardSize.width / 2);
    final centerY = cardOffset.dy + (cardSize.height / 2);

    double left = centerX - (expandedWidth / 2);
    double top = centerY - (expandedHeight / 2);

    // Screen bounds safety checking so card never clips or overflows screen edges
    left = left.clamp(12.0, (screenSize.width - expandedWidth - 12.0).clamp(12.0, double.infinity));
    top = top.clamp(12.0, (screenSize.height - expandedHeight - 12.0).clamp(12.0, double.infinity));

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: left,
          top: top,
          width: expandedWidth,
          height: expandedHeight,
          child: MouseRegion(
            onExit: (event) {
              _dismissOverlayDirectly();
            },
            child: _FloatingNetflixHoverCard(
              movie: widget.movie,
              expandedWidth: expandedWidth,
              expandedHeight: expandedHeight,
              animationDuration: widget.animationDuration,
              onPlayTap: () {
                _dismissOverlayDirectly();
                widget.onTap();
              },
              onMoreInfoTap: () {
                _dismissOverlayDirectly();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MovieDetailsScreen(movie: widget.movie),
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _onPointerEnter,
      onExit: _onPointerExit,
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          _dismissOverlayDirectly();
          widget.onTap();
        },
        child: AnimatedOpacity(
          opacity: _isHovered ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: _buildStandardPosterCard(context),
          ),
        ),
      ),
    );
  }

  /// Standard Unhovered Poster Artwork with Hero animation tag
  Widget _buildStandardPosterCard(BuildContext context) {
    return Container(
      margin: widget.margin ?? const EdgeInsets.only(right: 20.0), // Generous 20px card spacing
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16.0), // 16px rounded corners
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 16,
            spreadRadius: -2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: ValueListenableBuilder<List<Movie>>(
          valueListenable: FavoritesService().favoritesNotifier,
          builder: (context, favorites, _) {
            final isFav = FavoritesService().isFavorite(widget.movie.id);

            return Stack(
              fit: StackFit.expand,
              children: [
                // Hero Poster Image
                Hero(
                  tag: 'movie-poster-${widget.movie.id}',
                  child: SafeNetworkImage(
                    imageUrl: widget.movie.fullPosterUrl,
                    fit: BoxFit.cover,
                    title: widget.movie.title,
                  ),
                ),

                // Dark Gradient Overlay
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.3, 1.0],
                      colors: [
                        Colors.transparent,
                        Color(0xEE141414),
                      ],
                    ),
                  ),
                ),

                // Top Rating Badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.secondary, size: 12),
                        const SizedBox(width: 3),
                        Text(
                          widget.movie.formattedRating,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Top Bookmark / Watchlist Button
                Positioned(
                  top: 4,
                  right: 4,
                  child: IconButton(
                    icon: Icon(
                      isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: isFav ? AppColors.primary : Colors.white70,
                      size: 22,
                    ),
                    onPressed: () {
                      FavoritesService().toggleFavorite(widget.movie);
                    },
                  ),
                ),

                // Bottom Title & Release Year
                Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.movie.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.movie.releaseYear,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Floating Hover Card rendered inside OverlayEntry above all surrounding cards.
class _FloatingNetflixHoverCard extends StatefulWidget {
  final Movie movie;
  final double expandedWidth;
  final double expandedHeight;
  final Duration animationDuration;
  final VoidCallback onPlayTap;
  final VoidCallback onMoreInfoTap;

  const _FloatingNetflixHoverCard({
    required this.movie,
    required this.expandedWidth,
    required this.expandedHeight,
    required this.animationDuration,
    required this.onPlayTap,
    required this.onMoreInfoTap,
  });

  @override
  State<_FloatingNetflixHoverCard> createState() => _FloatingNetflixHoverCardState();
}

class _FloatingNetflixHoverCardState extends State<_FloatingNetflixHoverCard> {
  bool _isScaled = false;
  String? _videoKey;

  @override
  void initState() {
    super.initState();
    _videoKey = widget.movie.videoKey;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isScaled = true;
        });
      }
    });
    _fetchTrailerKey();
  }

  Future<void> _fetchTrailerKey() async {
    final key = await ApiService().getOrFetchTrailerKey(
      widget.movie.id,
      widget.movie.title,
      initialKey: widget.movie.videoKey,
    );
    if (mounted && key != null && key != _videoKey) {
      setState(() {
        _videoKey = key;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: AnimatedScale(
        scale: _isScaled ? 1.05 : 0.95, // Smooth 1.05-1.1x scale transition
        duration: widget.animationDuration,
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: _isScaled ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 250),
          child: Container(
            width: widget.expandedWidth,
            height: widget.expandedHeight,
            decoration: BoxDecoration(
              color: const Color(0xFF141414), // Netflix dark surface
              borderRadius: BorderRadius.circular(16.0), // 16px rounded corners
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.7),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.85),
                  blurRadius: 28,
                  spreadRadius: 6,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 18,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Half: Auto-playing Exact Movie Trailer Video Preview (160px)
                  GestureDetector(
                    onTap: widget.onPlayTap,
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      height: 160,
                      width: double.infinity,
                      child: NetflixVideoPreview(
                        videoKey: _videoKey ?? widget.movie.effectiveVideoKey,
                        videoUrl: widget.movie.trailerMp4Url,
                        fallbackImageUrl: widget.movie.fullBackdropUrl.isNotEmpty
                            ? widget.movie.fullBackdropUrl
                            : widget.movie.fullPosterUrl,
                        title: widget.movie.title,
                        width: double.infinity,
                        height: 160,
                        isHovered: true,
                      ),
                    ),
                  ),

                  // Bottom Half: Action Buttons Row & Metadata Info
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Action Buttons Row (Play, Add to List, Like, More Info)
                          NetflixActionButtons(
                            movie: widget.movie,
                            onPlayTap: widget.onPlayTap,
                            onMoreInfoTap: widget.onMoreInfoTap,
                          ),

                          const SizedBox(height: 8),

                          // Scrollable Metadata (Title, Release Year, Rating, Duration, Description)
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: NetflixMetaInfo(
                                movie: widget.movie,
                                showDescription: true,
                              ),
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
        ),
      ),
    );
  }
}
