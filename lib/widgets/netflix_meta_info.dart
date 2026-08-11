import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../theme/app_colors.dart';

/// Metadata display widget for Netflix-style hover cards:
/// - Title & Tagline
/// - Rating Score, Match Percentage, Age Rating & HD badges
/// - Release Year & Runtime Duration
/// - Movie Overview Description text
/// - Genre tags
class NetflixMetaInfo extends StatelessWidget {
  final Movie movie;
  final bool showDescription;

  const NetflixMetaInfo({
    super.key,
    required this.movie,
    this.showDescription = true,
  });

  String _formatDuration(int? runtime) {
    if (runtime == null || runtime <= 0) return '2h 10m';
    final hours = runtime ~/ 60;
    final mins = runtime % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    final matchPercentage = ((movie.voteAverage * 10).clamp(70, 99)).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          movie.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 5),

        // Metadata badges row (Wrap handles small screen wrap automatically without overflow!)
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 4,
          children: [
            // Netflix Green Match % Tag
            Text(
              '$matchPercentage% Match',
              style: const TextStyle(
                color: Color(0xFF46D369), // Netflix Match Green
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),

            // Age Rating Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: Colors.white38, width: 0.8),
              ),
              child: const Text(
                'U/A 13+',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Release Year
            Text(
              movie.releaseYear,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),

            // Duration
            Text(
              _formatDuration(movie.runtime),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),

            // HD Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: Colors.white54, width: 0.8),
              ),
              child: const Text(
                'HD',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Rating Stars
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: AppColors.secondary, size: 12),
                const SizedBox(width: 2),
                Text(
                  movie.formattedRating,
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 5),

        // Genre Tags
        Text(
          movie.genres.isNotEmpty
              ? movie.genres.take(3).join(' • ')
              : 'Cinema • Action • Drama',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),

        // Description / Overview Synopsis
        if (showDescription && movie.overview.isNotEmpty) ...[
          const SizedBox(height: 5),
          Text(
            movie.overview,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              height: 1.3,
            ),
          ),
        ],
      ],
    );
  }
}
