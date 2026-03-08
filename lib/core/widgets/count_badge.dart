import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// A badge widget to display count overlays (e.g., cart items, notifications).
class CountBadge extends StatelessWidget {
  final int count;
  final Widget child;
  final Color badgeColor;

  const CountBadge({
    super.key,
    required this.count,
    required this.child,
    this.badgeColor = AppColors.error,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (count > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
