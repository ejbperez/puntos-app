import 'package:flutter/material.dart';
import '../models/sport.dart';
import '../state/match_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/recent_match_card.dart';
import '../widgets/sport_card.dart';
import '../widgets/sports_icons.dart';
import 'live_scoreboard_screen.dart';
import 'match_setup_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.controller,
    required this.onNavigateToCourts,
    required this.onNavigateToHistory,
    required this.onNavigateToSettings,
  });

  final MatchController controller;
  final VoidCallback onNavigateToCourts;
  final VoidCallback onNavigateToHistory;
  final VoidCallback onNavigateToSettings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final activeMatches = controller.activeMatches;
            final completedMatches = controller.completedMatches;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(context),
                  const SizedBox(height: 16),

                  // Hero Banner Card
                  _buildHeroCard(),
                  const SizedBox(height: 20),

                  // Select Sport
                  _buildSectionHeader('Select Sport'),
                  const SizedBox(height: 10),
                  _buildSportGrid(context),
                  const SizedBox(height: 22),

                  // Quick Actions
                  _buildSectionHeader('Quick Actions'),
                  const SizedBox(height: 10),
                  _buildQuickActions(context),
                  const SizedBox(height: 22),

                  // Recent Matches
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionHeader('Recent Matches'),
                      InkWell(
                        onTap: onNavigateToHistory,
                        child: const Text(
                          'View All',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBrown,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildRecentMatches(context, activeMatches, completedMatches),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.textPrimaryDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: ShuttlecockIcon(size: 22, color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Puntos App',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: AppColors.textPrimaryDark,
                  ),
                ),
                Text(
                  'Score • Play • Enjoy',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ],
        ),
        IconButton(
          onPressed: onNavigateToSettings,
          icon: const Icon(Icons.settings_outlined,
              color: AppColors.textPrimaryDark),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      height: 156,
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image with fallback
            Image.asset(
              'assets/images/badminton_hero.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.darkBackground,
              ),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.darkBackground.withValues(alpha: 0.94),
                    AppColors.darkBackground.withValues(alpha: 0.82),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.58, 1.0],
                ),
              ),
            ),
            // Content
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Your game.\nOur scoreboard.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: 220,
                    child: Text(
                      'Easily score, manage and track your matches — anytime, anywhere.',
                      style: TextStyle(
                        color: AppColors.textSecondaryLight,
                        fontSize: 11.5,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: AppColors.textPrimaryDark,
      ),
    );
  }

  Widget _buildSportGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = SportCatalog.supported.length;
        final cardWidth = (constraints.maxWidth - ((count - 1) * 10)) / count;
        return Row(
          children: SportCatalog.supported.map((sport) {
            return Container(
              width: cardWidth,
              margin: EdgeInsets.only(
                right: sport.id == SportCatalog.supported.last.id ? 0 : 10,
              ),
              child: SportCard(
                sport: sport,
                isSelected: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MatchSetupScreen(
                        controller: controller,
                        initialSport: sport,
                      ),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                title: 'New Match',
                subtitle:
                    'Start a new game and set up players, format and rules.',
                icon: const Icon(Icons.add,
                    color: AppColors.primaryBrown, size: 22),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MatchSetupScreen(controller: controller),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionCard(
                title: 'Courts',
                subtitle: 'View active matches and manage courts.',
                icon: const Icon(Icons.grid_view_rounded,
                    color: AppColors.primaryBrown, size: 22),
                onTap: onNavigateToCourts,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        QuickActionCard(
          isFullWidth: true,
          title: 'Match History',
          subtitle: 'See your past matches and results.',
          icon: const Icon(Icons.history_rounded,
              color: AppColors.primaryBrown, size: 22),
          onTap: onNavigateToHistory,
        ),
      ],
    );
  }

  Widget _buildRecentMatches(
    BuildContext context,
    List activeMatches,
    List completedMatches,
  ) {
    final liveMatch = activeMatches.isNotEmpty
        ? activeMatches.first
        : controller.currentMatch;
    final completedMatch =
        completedMatches.isNotEmpty ? completedMatches.first : null;

    return Column(
      children: [
        RecentMatchCard(
          match: liveMatch,
          statusOverride: 'Live',
          onTap: () {
            controller.setCurrentMatch(liveMatch);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    LiveScoreboardScreen(controller: controller),
              ),
            );
          },
        ),
        if (completedMatch != null) ...[
          const SizedBox(height: 10),
          RecentMatchCard(
            match: completedMatch,
            statusOverride: 'Completed',
            onTap: () {
              controller.setCurrentMatch(completedMatch);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      LiveScoreboardScreen(controller: controller),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
