import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// A star rating display widget.
class StarRating extends StatelessWidget {
  final double rating;
  final int maxStars;
  final double size;
  final bool showLabel;

  const StarRating({
    super.key,
    required this.rating,
    this.maxStars = 5,
    this.size = 18,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(maxStars, (index) {
          if (index < rating.floor()) {
            return Icon(Icons.star, size: size, color: AppColors.starFilled);
          } else if (index < rating) {
            return Icon(Icons.star_half, size: size, color: AppColors.starFilled);
          }
          return Icon(Icons.star_border, size: size, color: AppColors.starEmpty);
        }),
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.75,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
