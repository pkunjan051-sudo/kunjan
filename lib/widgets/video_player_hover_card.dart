import 'package:flutter/material.dart';
import '../models/movie.dart';
import 'netflix_hover_card.dart';

/// Backward-compatible VideoPlayerHoverCard wrapper that delegates to NetflixHoverCard.
class VideoPlayerHoverCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;
  final double width;
  final double height;

  const VideoPlayerHoverCard({
    super.key,
    required this.movie,
    required this.onTap,
    this.width = 145,
    this.height = 215,
  });

  @override
  Widget build(BuildContext context) {
    return NetflixHoverCard(
      movie: movie,
      onTap: onTap,
      width: width,
      height: height,
    );
  }
}
