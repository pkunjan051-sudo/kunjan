import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';
import '../services/api_constants.dart';

/// A robust network image widget with graceful fallback handling and custom poster rendering on error.
class SafeNetworkImage extends StatelessWidget {
  final String imageUrl;
  final String? fallbackUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final String? title;
  final IconData icon;

  const SafeNetworkImage({
    super.key,
    required this.imageUrl,
    this.fallbackUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.title,
    this.icon = Icons.movie_filter_rounded,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.trim().isEmpty) {
      return _buildFallbackPoster();
    }

    if (kIsWeb) {
      // Use native Image.network on web to bypass CORS/XMLHttpRequest constraints in Chrome
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: AppColors.surfaceContainer,
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          final secUrl = fallbackUrl ?? ApiConstants.fallbackPosterUrl;
          if (secUrl.isNotEmpty && secUrl != imageUrl) {
            return Image.network(
              secUrl,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (context, error, stackTrace) => _buildFallbackPoster(),
            );
          }
          return _buildFallbackPoster();
        },
      );
    }

    final targetMemWidth = width != null && width! > 0 ? (width! * 2.0).toInt() : 400;
    final targetMemHeight = height != null && height! > 0 ? (height! * 2.0).toInt() : null;

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: targetMemWidth,
      memCacheHeight: targetMemHeight,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: AppColors.surfaceContainer,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) {
        // If secondary fallback URL exists and differs from primary, try loading fallback URL
        final secUrl = fallbackUrl ?? ApiConstants.fallbackPosterUrl;
        if (secUrl.isNotEmpty && secUrl != imageUrl) {
          return CachedNetworkImage(
            imageUrl: secUrl,
            width: width,
            height: height,
            fit: fit,
            memCacheWidth: targetMemWidth,
            memCacheHeight: targetMemHeight,
            placeholder: (context, url) => Container(
              color: AppColors.surfaceContainer,
            ),
            errorWidget: (context, url, error) => _buildFallbackPoster(),
          );
        }
        return _buildFallbackPoster();
      },
    );
  }

  Widget _buildFallbackPoster() {
    final displayTitle = title != null && title!.trim().isNotEmpty
        ? title!.trim()
        : 'Cinema Central';

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceHighest,
            AppColors.surfaceContainer,
            AppColors.surfaceHigh,
          ],
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            displayTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
