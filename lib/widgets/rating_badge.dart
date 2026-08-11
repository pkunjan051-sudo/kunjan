import 'package:flutter/material.dart';

class RatingBadge extends StatelessWidget {
  final double rating;
  final double fontSize;

  const RatingBadge({
    super.key,
    required this.rating,
    this.fontSize = 12.0,
  });

  @override
  Widget build(BuildContext me) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFFFB95F).withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            color: Color(0xFFFFB95F),
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
