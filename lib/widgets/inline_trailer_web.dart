// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'safe_network_image.dart';

/// Netflix-style embedded YouTube trailer player for Web platform.
class InlineTrailerPreview extends StatefulWidget {
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
  State<InlineTrailerPreview> createState() => _InlineTrailerPreviewState();
}

class _InlineTrailerPreviewState extends State<InlineTrailerPreview> {
  late String _viewTypeId;
  bool _isRegistered = false;

  @override
  void initState() {
    super.initState();
    _viewTypeId = 'web-yt-${widget.videoKey}-${widget.muted ? 'muted' : 'unmuted'}';
    if (widget.videoKey.isNotEmpty) {
      _registerIframe();
    }
  }

  @override
  void didUpdateWidget(InlineTrailerPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.videoKey != widget.videoKey || oldWidget.muted != widget.muted) && widget.videoKey.isNotEmpty) {
      _viewTypeId = 'web-yt-${widget.videoKey}-${widget.muted ? 'muted' : 'unmuted'}';
      _registerIframe();
    }
  }

  void _registerIframe() {
    final muteParam = widget.muted ? '1' : '0';
    final autoParam = widget.autoPlay ? '1' : '0';
    final embedUrl =
        'https://www.youtube.com/embed/${widget.videoKey}?autoplay=$autoParam&mute=$muteParam&controls=0&rel=0&modestbranding=1&enablejsapi=1&playsinline=1';

    try {
      ui_web.platformViewRegistry.registerViewFactory(_viewTypeId, (int viewId) {
        final iframe = html.IFrameElement()
          ..src = embedUrl
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.border = 'none'
          ..style.pointerEvents = 'none'
          ..allow = 'autoplay; encrypted-media; picture-in-picture; accelerometer; gyroscope'
          ..allowFullscreen = true;
        return iframe;
      });
    } catch (_) {
      // Factory already registered for this videoKey
    }

    if (mounted) {
      setState(() {
        _isRegistered = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videoKey.isEmpty) {
      return SafeNetworkImage(
        imageUrl: widget.fallbackImageUrl,
        width: widget.width,
        height: widget.height,
        fit: BoxFit.cover,
        title: widget.title,
      );
    }

    if (_isRegistered) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: HtmlElementView(viewType: _viewTypeId),
      );
    }

    return Container(
      width: widget.width,
      height: widget.height,
      color: AppColors.surfaceContainer,
    );
  }
}
