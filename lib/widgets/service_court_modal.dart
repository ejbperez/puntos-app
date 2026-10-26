import 'package:flutter/material.dart';
import '../models/match.dart';
import '../models/player.dart';
import '../theme/app_colors.dart';
import 'court_diagram.dart';

class ServiceCourtModal extends StatelessWidget {
  const ServiceCourtModal({
    super.key,
    required this.match,
  });

  final Match match;

  static Future<void> show(BuildContext context, Match match) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ServiceCourtModal(match: match),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRight = match.serviceCourtSide == CourtSide.right;
    final serverName = match.currentServer?.name ?? 'Server';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.cardDarkBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Service Court',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Where to serve?',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMutedDark,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon:
                    const Icon(Icons.close, color: AppColors.textPrimaryLight),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Court diagram preview
          CourtDiagram(
            match: match,
            height: 150,
          ),
          const SizedBox(height: 16),

          // Serving status banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.courtSurface.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.servingGreen.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.servingGreen,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Serve from the ${isRight ? "RIGHT" : "LEFT"} service court\n(${isRight ? "Even score" : "Odd score"}) • $serverName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick Rules
          const Text(
            'Quick Rules',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '• Even score → Right service court\n• Odd score → Left service court\n• After each rally, the serving side and service court will change based on badminton rules.',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 20),

          // Got it button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.servingGreen,
                foregroundColor: AppColors.darkBackground,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Got it',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
