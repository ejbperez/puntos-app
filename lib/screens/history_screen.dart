import 'package:flutter/material.dart';
import '../models/match.dart';
import '../state/match_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/recent_match_card.dart';
import 'live_scoreboard_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({
    super.key,
    required this.controller,
  });

  final MatchController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Match History'),
        actions: [
          if (controller.completedMatches.isNotEmpty)
            IconButton(
              tooltip: 'Clear history',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () => _confirmClearAll(context),
            ),
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final completed = controller.completedMatches;

            if (completed.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history_rounded,
                        size: 48, color: AppColors.textMutedDark),
                    SizedBox(height: 12),
                    Text(
                      'No completed matches yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Completed games will automatically appear here.',
                      style: TextStyle(
                          color: AppColors.textSecondaryDark, fontSize: 13),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: completed.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final match = completed[index];
                return RecentMatchCard(
                  match: match,
                  statusOverride: 'Completed',
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
        content: const Text(
            'This completed match will be removed from history.'),
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
        title: const Text('Clear match history?'),
        content: const Text(
            'All completed matches will be permanently removed.'),
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
    if (confirmed == true) await controller.clearCompletedMatches();
  }
}
