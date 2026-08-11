import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'safe_network_image.dart';

/// Fallback stub for VM / Windows desktop platforms.
class InlineTrailerPreview extends StatelessWidget {
  final String videoKey;
  final String fallbackImageUrl;
  final String title;
  final double width;
  final double height;
  final bool autoPlay;
  final bool muted;

  const InlineTrailerPreview({
    super.key,
    required this.videoKey,
    required this.fallbackImageUrl,
    required this.title,
    required this.width,
    required this.height,
    this.autoPlay = true,
    this.muted = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          SafeNetworkImage(
            imageUrl: videoKey.isNotEmpty
                ? 'https://img.youtube.com/vi/$videoKey/hqdefault.jpg'
                : fallbackImageUrl,
            fallbackUrl: fallbackImageUrl,
            width: width,
            height: height,
            fit: BoxFit.cover,
            title: title,
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xAA0B1326)],
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
