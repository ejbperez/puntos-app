import 'package:flutter/material.dart';
import '../models/match.dart';
import '../models/player.dart';
import '../state/match_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/court_diagram.dart';
import '../widgets/service_court_modal.dart';
import '../widgets/sports_icons.dart';
import '../widgets/team_score_card.dart';

class LiveScoreboardScreen extends StatelessWidget {
  const LiveScoreboardScreen({
    super.key,
    required this.controller,
  });

  final MatchController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final match = controller.currentMatch;

        return Scaffold(
          backgroundColor: AppColors.darkBackground,
          appBar: _buildAppBar(context),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  // Match Info Header Pill
                  _buildMatchInfoCard(match),
                  const SizedBox(height: 14),

                  // Opposing Team Score Cards
                  TeamScoreBoard(match: match),
                  const SizedBox(height: 14),

                  // Current Server Info Bar
                  _buildCurrentServerBar(context, match),
                  const SizedBox(height: 14),

                  // Court Diagram
                  CourtDiagram(
                    match: match,
                    height: 195,
                    onTap: () => ServiceCourtModal.show(context, match),
                  ),
                  const SizedBox(height: 14),

                  // Match Statistics (Current Game, Games, Total Points)
                  _buildMatchStatistics(match),
                  const SizedBox(height: 16),

                  // Scoring Controls (Team A, Undo, Team B)
                  _buildScoringControls(context, match),
                  const SizedBox(height: 16),

                  // End Match Button
                  _buildEndMatchButton(context, match),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.darkBackground,
      elevation: 0,
      leading: IconButton(
        icon:
            const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Live Scoreboard',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.more_horiz, color: Colors.white, size: 24),
          onPressed: () => _showMatchOptions(context),
        ),
      ],
    );
  }

  Widget _buildMatchInfoCard(Match match) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardDarkBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: match.sport.cardColor,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: ShuttlecockIcon(size: 16, color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                Text(
                  '${match.sport.name} · ${match.format.label}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  match.court,
                  style: const TextStyle(
                    color: AppColors.textMutedDark,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.liveGreenBg,
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: AppColors.liveGreen.withValues(alpha: 0.6)),
            ),
            child: Text(
              match.completed ? 'Completed' : 'Live',
              style: TextStyle(
                color: match.completed
                    ? AppColors.textMutedDark
                    : AppColors.liveGreen,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentServerBar(BuildContext context, Match match) {
    final server = match.currentServer;
    final serverName = server?.name ?? 'Server';
    final serverLabel = server?.label ?? 'A1';

    return InkWell(
      onTap: () => ServiceCourtModal.show(context, match),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardDarkBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFF1E3A5F),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Server',
                    style: TextStyle(
                      color: AppColors.textMutedDark,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '$serverLabel ($serverName)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Receiver: ${match.currentReceiver?.label ?? "—"} '
                    '(${match.currentReceiver?.name ?? "—"})',
                    style: const TextStyle(
                      color: AppColors.textSecondaryLight,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    match.serviceCourtDescription,
                    style: const TextStyle(
                      color: AppColors.servingGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const ShuttlecockIcon(size: 20, color: AppColors.textMutedDark),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchStatistics(Match match) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Current Game',
            value: '${match.currentGame}',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: 'Games',
            value: match.gamesSummary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: 'Total Points',
            value: match.scoreSummary,
          ),
        ),
      ],
    );
  }

  Widget _buildScoringControls(BuildContext context, Match match) {
    return IgnorePointer(
      ignoring: match.completed,
      child: Opacity(
        opacity: match.completed ? 0.45 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardDarkBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Team A Controls
              Column(
                children: [
                  Row(
                    children: [
                      _ScoreButton(
                        icon: Icons.remove,
                        borderColor: AppColors.teamA.withValues(alpha: 0.6),
                        onTap: () => controller.decrementPoint(TeamSide.teamA),
                      ),
                      const SizedBox(width: 8),
                      _ScoreButton(
                        icon: Icons.add,
                        borderColor: AppColors.teamA,
                        isProminent: true,
                        onTap: () => controller.rallyWon(TeamSide.teamA),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    match.teamAName,
                    style: const TextStyle(
                      color: AppColors.textSecondaryLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              // Center Undo Button
              Column(
                children: [
                  InkWell(
                    onTap: controller.undo,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.cardDarkSurface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.cardDarkBorder),
                      ),
                      child: const Center(
                        child: Icon(Icons.undo_rounded,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Undo',
                    style: TextStyle(
                      color: AppColors.textMutedDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // Team B Controls
              Column(
                children: [
                  Row(
                    children: [
                      _ScoreButton(
                        icon: Icons.remove,
                        borderColor: AppColors.teamB.withValues(alpha: 0.6),
                        onTap: () => controller.decrementPoint(TeamSide.teamB),
                      ),
                      const SizedBox(width: 8),
                      _ScoreButton(
                        icon: Icons.add,
                        borderColor: AppColors.teamB,
                        isProminent: true,
                        onTap: () => controller.rallyWon(TeamSide.teamB),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    match.teamBName,
                    style: const TextStyle(
                      color: AppColors.textSecondaryLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEndMatchButton(BuildContext context, Match match) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: match.completed ? null : () => _confirmEndMatch(context),
        icon: Icon(
          match.completed ? Icons.check_circle_outline : Icons.outlined_flag,
          color: Colors.white,
          size: 18,
        ),
        label: Text(
          match.completed ? 'Completed' : 'End Match',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.cardDarkBorder),
          backgroundColor: AppColors.cardDark,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  void _confirmEndMatch(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: const Text('End Match?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to finish this match and save the results?',
          style: TextStyle(color: AppColors.textSecondaryLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMutedDark)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.endMatch();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Match marked as completed.')),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBrown),
            child: const Text('End Match'),
          ),
        ],
      ),
    );
  }

  void _showMatchOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.white),
              title: const Text('Service Court Rules',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                ServiceCourtModal.show(context, controller.currentMatch);
              },
            ),
            ListTile(
              leading: const Icon(Icons.restart_alt, color: Colors.white),
              title: const Text('Reset Score',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                controller.setCurrentMatch(Match.createDefault());
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardDarkBorder),
      ),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: const TextStyle(
              color: AppColors.textMutedDark,
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreButton extends StatelessWidget {
  const _ScoreButton({
    required this.icon,
    required this.borderColor,
    required this.onTap,
    this.isProminent = false,
  });

  final IconData icon;
  final Color borderColor;
  final VoidCallback onTap;
  final bool isProminent;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isProminent
              ? borderColor.withValues(alpha: 0.15)
              : AppColors.cardDarkSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.4),
        ),
        child: Center(
          child: Icon(
            icon,
            color: Colors.white,
            size: isProminent ? 22 : 18,
          ),
        ),
      ),
    );
  }
}
