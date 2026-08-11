import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import 'inline_trailer_preview.dart';

/// Modal dialog for launching and previewing official movie trailers.
class TrailerPlayerModal extends StatefulWidget {
  final Movie movie;

  const TrailerPlayerModal({super.key, required this.movie});

  static Future<void> show(BuildContext context, Movie movie) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TrailerPlayerModal(movie: movie),
    );
  }

  @override
  State<TrailerPlayerModal> createState() => _TrailerPlayerModalState();
}

class _TrailerPlayerModalState extends State<TrailerPlayerModal> {
  String? _videoKey;

  @override
  void initState() {
    super.initState();
    _videoKey = widget.movie.videoKey;
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

  Future<void> _launchTrailer(BuildContext context) async {
    final effectiveKey = _videoKey ?? widget.movie.effectiveVideoKey;
    final url = effectiveKey.isNotEmpty
        ? 'https://www.youtube.com/watch?v=$effectiveKey'
        : widget.movie.youtubeTrailerUrl;
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening trailer for "${widget.movie.title}"...'),
            backgroundColor: AppColors.surfaceHighest,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveKey = _videoKey ?? widget.movie.effectiveVideoKey;
    final thumbnailUrl = effectiveKey.isNotEmpty
        ? 'https://img.youtube.com/vi/$effectiveKey/hqdefault.jpg'
        : widget.movie.fullBackdropUrl;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle indicator
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceHighest,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Trailer Header Card
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: InlineTrailerPreview(
                      videoKey: effectiveKey,
                      fallbackImageUrl: thumbnailUrl.isNotEmpty
                          ? thumbnailUrl
                          : widget.movie.fullBackdropUrl,
                      title: widget.movie.title,
                      width: double.infinity,
                      height: 200,
                      autoPlay: true,
                      muted: false,
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Color(0xCC0B1326),
                            Color(0xFF0B1326),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: () => _launchTrailer(context),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.5),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 14,
                    right: 14,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.movie_creation_rounded, color: AppColors.secondary, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'OFFICIAL TRAILER',
                              style: TextStyle(
                                color: AppColors.secondary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded, color: AppColors.secondary, size: 12),
                              const SizedBox(width: 4),
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Title & Details
          Text(
            widget.movie.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.movie.releaseYear} • ${widget.movie.genres.join(' • ')}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.movie.overview,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.onSurface,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _launchTrailer(context),
              icon: const Icon(Icons.play_circle_fill_rounded, size: 22),
              label: const Text(
                'Play Trailer on YouTube',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
