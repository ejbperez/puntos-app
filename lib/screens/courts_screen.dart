import 'package:flutter/material.dart';
import '../models/match.dart';
import '../state/match_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/sports_icons.dart';
import 'live_scoreboard_screen.dart';

class CourtsScreen extends StatelessWidget {
  const CourtsScreen({
    super.key,
    required this.controller,
  });

  final MatchController controller;

  Widget _buildSportIcon(String sportId) {
    switch (sportId) {
      case 'badminton':
        return const ShuttlecockIcon(size: 22, color: Colors.white);
      case 'pickleball':
        return const PickleballPaddleIcon(size: 22, color: Colors.white);
      case 'tennis':
        return const TennisBallIcon(size: 22, color: Colors.white);
      default:
        return const ShuttlecockIcon(size: 22, color: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        title: const Text(
          'Courts',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          if (controller.activeMatches.isNotEmpty)
            IconButton(
              tooltip: 'Clear all courts',
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.white),
              onPressed: () => _confirmClearAll(context),
            ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Use New Match to assign a game to a court.')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final matches = controller.activeMatches;

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: matches.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final match = matches[index];
                return _CourtOverviewCard(
                  match: match,
                  icon: _buildSportIcon(match.sport.id),
                  onDelete: () => _confirmDelete(context, match),
                  onTap: () {
                    controller.setCurrentMatch(match);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            LiveScoreboardScreen(controller: controller),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Match match) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete match?'),
        content: Text('Remove ${match.court} from active courts?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) await controller.deleteMatch(match.id);
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear all courts?'),
        content: const Text('All active matches will be removed from Courts.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
    if (confirmed == true) await controller.clearActiveMatches();
  }
}

class _CourtOverviewCard extends StatelessWidget {
  const _CourtOverviewCard({
    required this.match,
    required this.icon,
    required this.onTap,
    required this.onDelete,
  });

  final Match match;
  final Widget icon;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final serverName = match.currentServer?.label ?? 'Server';
    final sideDesc =
        match.serviceCourtSide.name == 'right' ? 'Right court' : 'Left court';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardDarkBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: match.sport.cardColor,
                shape: BoxShape.circle,
              ),
              child: Center(child: icon),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    match.court,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${match.sport.name} · ${match.format.label}',
                    style: const TextStyle(
                      color: AppColors.textMutedDark,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    match.scoreSummary,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$serverName serving · $sideDesc',
                    style: const TextStyle(
                      color: AppColors.textSecondaryLight,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onDelete,
              tooltip: 'Delete match',
              icon: const Icon(Icons.delete_outline,
                  color: AppColors.textMutedDark, size: 20),
              padding: EdgeInsets.zero,
              constraints:
                  const BoxConstraints(minWidth: 30, minHeight: 30),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.liveGreenBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.liveGreen.withValues(alpha: 0.6)),
              ),
              child: const Text(
                'LIVE',
                style: TextStyle(
                  color: AppColors.liveGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
