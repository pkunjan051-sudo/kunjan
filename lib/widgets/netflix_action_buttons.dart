import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/favorites_service.dart';
import '../theme/app_colors.dart';

/// Reusable action buttons row for Netflix-style hover cards:
/// - Play Button (White filled circle, black play icon)
/// - Add to List / Watchlist Button (Toggle plus / check icon)
/// - Like Button (Toggle thumbs-up icon)
/// - More Info Button (Chevron down details button)
class NetflixActionButtons extends StatefulWidget {
  final Movie movie;
  final VoidCallback onPlayTap;
  final VoidCallback onMoreInfoTap;
  final double iconSize;

  const NetflixActionButtons({
    super.key,
    required this.movie,
    required this.onPlayTap,
    required this.onMoreInfoTap,
    this.iconSize = 16.0,
  });

  @override
  State<NetflixActionButtons> createState() => _NetflixActionButtonsState();
}

class _NetflixActionButtonsState extends State<NetflixActionButtons> {
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Movie>>(
      valueListenable: FavoritesService().favoritesNotifier,
      builder: (context, favorites, _) {
        final isFav = FavoritesService().isFavorite(widget.movie.id);

        return Row(
          children: [
            // Play Button
            _buildIconButton(
              icon: Icons.play_arrow_rounded,
              iconColor: Colors.black,
              backgroundColor: Colors.white,
              tooltip: 'Play',
              onTap: widget.onPlayTap,
            ),
            const SizedBox(width: 8),

            // Add to List (Watchlist) Button
            _buildIconButton(
              icon: isFav ? Icons.check_rounded : Icons.add_rounded,
              iconColor: isFav ? Colors.white : Colors.white,
              backgroundColor: isFav ? AppColors.primary : Colors.white12,
              borderColor: isFav ? AppColors.primary : Colors.white38,
              tooltip: isFav ? 'In My List' : 'Add to My List',
              onTap: () {
                FavoritesService().toggleFavorite(widget.movie);
              },
            ),
            const SizedBox(width: 8),

            // Like Button
            _buildIconButton(
              icon: _isLiked ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
              iconColor: _isLiked ? Colors.white : Colors.white70,
              backgroundColor: _isLiked ? const Color(0xFFE50914) : Colors.white12,
              borderColor: _isLiked ? const Color(0xFFE50914) : Colors.white38,
              tooltip: _isLiked ? 'Liked' : 'I like this',
              onTap: () {
                setState(() {
                  _isLiked = !_isLiked;
                });
              },
            ),
            const Spacer(),

            // More Info / Details Button
            _buildIconButton(
              icon: Icons.keyboard_arrow_down_rounded,
              iconColor: Colors.white,
              backgroundColor: Colors.white12,
              borderColor: Colors.white38,
              tooltip: 'More Info',
              onTap: widget.onMoreInfoTap,
            ),
          ],
        );
      },
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    Color? borderColor,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border: borderColor != null ? Border.all(color: borderColor, width: 1.2) : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: widget.iconSize,
            ),
          ),
        ),
      ),
    );
  }
}
