import 'package:flutter/material.dart';
import '../models/movie.dart';
import 'netflix_hover_card.dart';

/// MovieCard widget that uses NetflixHoverCard with InlineTrailerPreview for YouTube database trailer playback.
class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;
  final double width;
  final double height;
  final EdgeInsetsGeometry? margin;

  const MovieCard({
    super.key,
    required this.movie,
    required this.onTap,
    this.width = 140,
    this.height = 210,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return NetflixHoverCard(
      movie: movie,
      onTap: onTap,
      width: width,
      height: height,
      margin: margin,
    );
  }
}

