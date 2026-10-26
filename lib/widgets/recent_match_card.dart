import 'package:flutter/material.dart';
import '../models/match.dart';
import '../theme/app_colors.dart';
import 'sports_icons.dart';

class RecentMatchCard extends StatelessWidget {
  const RecentMatchCard({
    super.key,
    required this.match,
    required this.onTap,
    this.statusOverride,
    this.onDelete,
  });

  final Match match;
  final VoidCallback onTap;
  final String? statusOverride;
  final VoidCallback? onDelete;

  Widget _buildSportIcon(String sportId) {
    switch (sportId) {
      case 'badminton':
        return const ShuttlecockIcon(size: 20, color: Colors.white);
      case 'pickleball':
        return const PickleballPaddleIcon(size: 20, color: Colors.white);
      case 'tennis':
        return const TennisBallIcon(size: 20, color: Colors.white);
      default:
        return const ShuttlecockIcon(size: 20, color: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = statusOverride ?? (match.completed ? 'Completed' : 'Live');
    final isLive = status == 'Live';
    final isPaused = status == 'Paused';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardLightBorder),
        ),
        child: Row(
          children: [
            // Sport Icon Circle
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: match.sport.cardColor,
                shape: BoxShape.circle,
              ),
              child: Center(child: _buildSportIcon(match.sport.id)),
            ),
            const SizedBox(width: 12),

            // Match description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${match.sport.name} · ${match.format.label}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${match.court} · ${isLive ? "Ongoing" : (isPaused ? "Paused" : "Completed")}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ),

            // Score and Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  match.scoreSummary,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryDark,
                  ),
                ),
                const SizedBox(height: 3),
                if (isLive)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.liveGreenBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.liveGreen.withValues(alpha: 0.5)),
                    ),
                    child: const Text(
                      'Live',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.liveGreen,
                      ),
                    ),
                  )
                else if (isPaused)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Paused',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  )
                else
                  const Text(
                    'Completed',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMutedDark,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            if (onDelete != null)
              IconButton(
                onPressed: onDelete,
                tooltip: 'Delete match',
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.textMutedDark, size: 19),
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 30, minHeight: 30),
              ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textMutedDark,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
