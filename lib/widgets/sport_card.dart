import 'package:flutter/material.dart';
import '../models/sport.dart';
import '../theme/app_colors.dart';
import 'sports_icons.dart';

class SportCard extends StatelessWidget {
  const SportCard({
    super.key,
    required this.sport,
    required this.isSelected,
    required this.onTap,
    this.compact = false,
  });

  final SportDefinition sport;
  final bool isSelected;
  final VoidCallback onTap;
  final bool compact;

  Widget _buildIcon(double size, Color color) {
    switch (sport.id) {
      case 'badminton':
        return ShuttlecockIcon(size: size, color: color);
      case 'pickleball':
        return PickleballPaddleIcon(size: size, color: color);
      case 'tennis':
        return TennisBallIcon(size: size, color: color);
      default:
        return ShuttlecockIcon(size: size, color: color);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      // Setup screen style
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryBrown.withValues(alpha: 0.08)
                : AppColors.cardLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryBrown
                  : AppColors.cardLightBorder,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildIcon(
                26,
                isSelected
                    ? AppColors.primaryBrown
                    : AppColors.textSecondaryDark,
              ),
              const SizedBox(height: 8),
              Text(
                sport.name,
                textAlign: TextAlign.center,
                softWrap: true,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? AppColors.primaryBrown
                      : AppColors.textPrimaryDark,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Home screen style: vibrant sport-colored rounded cards
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: sport.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: sport.cardColor.withValues(alpha: 0.35),
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildIcon(30, Colors.white),
            const SizedBox(height: 8),
            Text(
              sport.name,
              textAlign: TextAlign.center,
              softWrap: true,
              maxLines: 2,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
