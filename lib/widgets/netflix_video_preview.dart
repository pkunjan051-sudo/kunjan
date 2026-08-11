import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../theme/app_colors.dart';
import 'inline_trailer_preview.dart';
import 'safe_network_image.dart';

/// Auto-playing trailer preview supporting YouTube movie trailers (web/mobile) and MP4 video_player streams.
/// Includes mute/unmute audio control toggle, buffering loader, and backdrop fallback.
class NetflixVideoPreview extends StatefulWidget {
  final String videoKey;
  final String videoUrl;
  final String fallbackImageUrl;
  final String title;
  final double width;
  final double height;
  final bool isHovered;

  const NetflixVideoPreview({
    super.key,
    required this.videoKey,
    required this.videoUrl,
    required this.fallbackImageUrl,
    required this.title,
    required this.width,
    required this.height,
    required this.isHovered,
  });

  @override
  State<NetflixVideoPreview> createState() => _NetflixVideoPreviewState();
}

class _NetflixVideoPreviewState extends State<NetflixVideoPreview> {
  VideoPlayerController? _controller;
  bool _isInitializing = false;
  bool _isInitialized = false;
  bool _isMuted = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && widget.isHovered) {
      _initMp4Player();
    }
  }

  @override
  void didUpdateWidget(NetflixVideoPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!kIsWeb) {
      if (widget.isHovered && !oldWidget.isHovered) {
        _initMp4Player();
      } else if (!widget.isHovered && oldWidget.isHovered) {
        _stopAndDisposePlayer();
      }
    }
  }

  Future<void> _initMp4Player() async {
    if (_controller != null || _isInitializing) return;

    setState(() {
      _isInitializing = true;
      _hasError = false;
    });

    try {
      final uri = Uri.parse(widget.videoUrl);
      final controller = VideoPlayerController.networkUrl(uri);
      _controller = controller;

      await controller.initialize();
      if (!mounted || !widget.isHovered) {
        await controller.pause();
        await controller.dispose();
        _controller = null;
        return;
      }

      controller.setVolume(_isMuted ? 0.0 : 1.0);
      controller.setLooping(true);
      await controller.play();

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _isInitialized = false;
          _hasError = true;
        });
      }
    }
  }

  void _stopAndDisposePlayer() {
    final controller = _controller;
    _controller = null;

    if (mounted) {
      setState(() {
        _isInitialized = false;
        _isInitializing = false;
      });
    }

    if (controller != null) {
      controller.pause();
      controller.dispose();
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      if (!kIsWeb && _controller != null && _isInitialized) {
        _controller?.setVolume(_isMuted ? 0.0 : 1.0);
      }
    });
  }

  @override
  void dispose() {
    _stopAndDisposePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final hasYtTrailer = widget.videoKey.trim().isNotEmpty;

    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Fallback Backdrop Image
          SafeNetworkImage(
            imageUrl: widget.fallbackImageUrl,
            width: widget.width,
            height: widget.height,
            fit: BoxFit.cover,
            title: widget.title,
          ),

          // YouTube Embedded Trailer (Web / Preferred Movie Trailer)
          if (hasYtTrailer && widget.isHovered)
            Positioned.fill(
              child: InlineTrailerPreview(
                videoKey: widget.videoKey,
                fallbackImageUrl: widget.fallbackImageUrl,
                title: widget.title,
                width: widget.width,
                height: widget.height,
                autoPlay: true,
                muted: _isMuted,
              ),
            ),

          // Video Player MP4 Container (Native Platforms Fallback)
          if (!kIsWeb && controller != null && _isInitialized && controller.value.isInitialized && !_hasError)
            AnimatedOpacity(
              opacity: _isInitialized ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeIn,
              child: FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: controller.value.size.width > 0 ? controller.value.size.width : widget.width,
                  height: controller.value.size.height > 0 ? controller.value.size.height : widget.height,
                  child: VideoPlayer(controller),
                ),
              ),
            ),

          // Dark Overlay Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.4, 1.0],
                colors: [
                  Colors.black26,
                  Colors.transparent,
                  Color(0xFF141414),
                ],
              ),
            ),
          ),

          // Buffering Indicator for MP4
          if (!kIsWeb && (_isInitializing || (controller != null && controller.value.isBuffering && !_hasError)))
            Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
            ),

          // Netflix N Brand Badge
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE50914), // Netflix Red
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'N FILM',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),

          // Interactive Mute / Unmute Button
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _toggleMute,
                customBorder: const CircleBorder(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _isMuted ? Colors.white38 : AppColors.primary,
                      width: 1.2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                        color: _isMuted ? Colors.white70 : AppColors.primary,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
