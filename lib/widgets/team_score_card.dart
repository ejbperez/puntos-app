import 'package:flutter/material.dart';
import '../models/match.dart';
import '../models/player.dart';
import '../theme/app_colors.dart';

class TeamScoreBoard extends StatelessWidget {
  const TeamScoreBoard({
    super.key,
    required this.match,
  });

  final Match match;

  @override
  Widget build(BuildContext context) {
    String centerSubText;
    if (match.sport.id == 'tennis') {
      centerSubText = 'Games: ${match.teamAGames}-${match.teamBGames}';
    } else {
      centerSubText = '(${match.rule.gamesDescription})';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Team A Card
        Expanded(
          child: _TeamCard(
            match: match,
            teamSide: TeamSide.teamA,
            teamName: match.teamAName,
            players: match.teamAPlayers,
            displayScore: match.displayScoreA,
            isServing: match.isTeamAServing,
            accentColor: AppColors.teamA,
          ),
        ),

        // Center Indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.cardDarkSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardDarkBorder),
                ),
                child: Text(
                  match.sport.id == 'tennis'
                      ? 'Set ${match.currentGame}'
                      : 'Set ${match.currentGame}',
                  style: const TextStyle(
                    color: AppColors.textPrimaryLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                centerSubText,
                style: const TextStyle(
                  color: AppColors.textMutedDark,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // Team B Card
        Expanded(
          child: _TeamCard(
            match: match,
            teamSide: TeamSide.teamB,
            teamName: match.teamBName,
            players: match.teamBPlayers,
            displayScore: match.displayScoreB,
            isServing: match.isTeamBServing,
            accentColor: AppColors.teamB,
          ),
        ),
      ],
    );
  }
}

class _TeamCard extends StatelessWidget {
  const _TeamCard({
    required this.match,
    required this.teamSide,
    required this.teamName,
    required this.players,
    required this.displayScore,
    required this.isServing,
    required this.accentColor,
  });

  final Match match;
  final TeamSide teamSide;
  final String teamName;
  final List<Player> players;
  final String displayScore;
  final bool isServing;
  final Color accentColor;

  String _buildStatusLabel() {
    if (!isServing) return 'RECEIVING';
    if (match.sport.id == 'pickleball' && match.format.playersPerTeam >= 2) {
      return 'SERVING (S${match.serverNumber})';
    }
    return 'SERVING';
  }

  String _buildHint() {
    if (match.sport.id == 'tennis') {
      if (isServing) {
        final court = match.serviceCourtSide == CourtSide.right
            ? 'Deuce (Right)'
            : 'Ad (Left)';
        return 'Serve from $court';
      } else {
        final court = match.serviceCourtSide == CourtSide.right
            ? 'Deuce (Right)'
            : 'Ad (Left)';
        return 'Receive from $court';
      }
    } else if (match.sport.id == 'pickleball') {
      if (isServing) {
        if (match.format.playersPerTeam == 1) {
          final isEven = (teamSide == TeamSide.teamA
                      ? match.teamAScore
                      : match.teamBScore) %
                  2 ==
              0;
          return '${isEven ? "Even" : "Odd"} score\n→ ${isEven ? "Right" : "Left"} court';
        }
        return 'Server ${match.serverNumber}\n${match.serviceCourtSide == CourtSide.right ? "Right" : "Left"} court';
      } else {
        return 'Receiving\n(${match.serviceCourtSide == CourtSide.right ? "Right" : "Left"} court)';
      }
    } else {
      // Badminton
      final score =
          teamSide == TeamSide.teamA ? match.teamAScore : match.teamBScore;
      final evenScore = score % 2 == 0;
      return isServing
          ? '${evenScore ? "Even score" : "Odd score"}\n→ ${evenScore ? "Right" : "Left"} service court'
          : 'Opposite service court\n(${match.serviceCourtSide == CourtSide.right ? "Right" : "Left"})';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isServing
              ? AppColors.servingGreen.withValues(alpha: 0.6)
              : AppColors.cardDarkBorder,
          width: isServing ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  teamName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimaryLight,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Player lines
          ...players.take(2).map(
                (p) => Text(
                  '${p.label}  ${p.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          const SizedBox(height: 10),

          // Big Score
          Center(
            child: Text(
              displayScore,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 44,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Status Badge
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
              decoration: BoxDecoration(
                color: isServing
                    ? AppColors.servingGreen
                    : AppColors.receivingSlate,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _buildStatusLabel(),
                maxLines: 1,
                style: TextStyle(
                  color: isServing ? AppColors.darkBackground : Colors.white,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Helper hint
          Center(
            child: Text(
              _buildHint(),
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                color: AppColors.textMutedDark,
                fontSize: 9.5,
                height: 1.2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
