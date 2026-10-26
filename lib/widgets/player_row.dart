import 'package:flutter/material.dart';
import '../models/player.dart';
import '../theme/app_colors.dart';

class PlayerRowItem extends StatelessWidget {
  const PlayerRowItem({
    super.key,
    required this.player,
    required this.onRemove,
    this.onEdit,
    this.canRemove = true,
  });

  final Player player;
  final VoidCallback onRemove;
  final VoidCallback? onEdit;
  final bool canRemove;

  @override
  Widget build(BuildContext context) {
    final isTeamA = player.team == TeamSide.teamA;
    final badgeColor = isTeamA ? AppColors.teamA : AppColors.teamB;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              player.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: badgeColor,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              player.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onEdit != null)
            IconButton(
              onPressed: onEdit,
              tooltip: 'Edit ${player.label}',
              icon: const Icon(Icons.edit_outlined,
                  size: 16, color: AppColors.textMutedDark),
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
          if (canRemove) ...[
            const SizedBox(width: 4),
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.cancel_outlined,
                  size: 16,
                  color: AppColors.textMutedDark,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
