import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'match_format.dart';
import 'match_rule.dart';

class SportDefinition {
  const SportDefinition({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.cardColor,
    required this.defaultParticipantCount,
    required this.supportsService,
    required this.defaultRule,
    this.supportedFormats = MatchFormat.standardFormats,
  });

  final String id;
  final String name;
  final String subtitle;
  final Color cardColor;
  final int defaultParticipantCount;
  final bool supportsService;
  final MatchRule defaultRule;
  final List<MatchFormat> supportedFormats;
}

abstract final class SportCatalog {
  static const badminton = SportDefinition(
    id: 'badminton',
    name: 'Badminton',
    subtitle: 'Singles & Doubles',
    cardColor: AppColors.badmintonBrown,
    defaultParticipantCount: 4,
    supportsService: true,
    defaultRule: MatchRule(
      pointsPerGame: 21,
      gamesPerMatch: 3,
      winByTwo: true,
      maxPoints: 30,
    ),
    supportedFormats: [
      MatchFormat.singles,
      MatchFormat.doubles,
      MatchFormat.mixedDoubles,
    ],
  );

  static const pickleball = SportDefinition(
    id: 'pickleball',
    name: 'Pickleball',
    subtitle: 'Singles & Doubles',
    cardColor: AppColors.pickleballGreen,
    defaultParticipantCount: 4,
    supportsService: true,
    defaultRule: MatchRule(
      pointsPerGame: 11,
      gamesPerMatch: 3,
      winByTwo: true,
      isSideOutScoring: true,
    ),
    supportedFormats: [
      MatchFormat.singles,
      MatchFormat.doubles,
      MatchFormat.mixedDoubles,
    ],
  );

  static const tennis = SportDefinition(
    id: 'tennis',
    name: 'Tennis',
    subtitle: 'Singles & Doubles',
    cardColor: AppColors.tennisSlate,
    defaultParticipantCount: 2,
    supportsService: true,
    defaultRule: MatchRule(
      pointsPerGame: 6,
      gamesPerMatch: 3,
      winByTwo: true,
      useAdvantage: true,
      tiebreakAt: 6,
    ),
    supportedFormats: [
      MatchFormat.singles,
      MatchFormat.doubles,
      MatchFormat.mixedDoubles,
    ],
  );

  /// Exactly three supported sports per project requirements.
  static const supported = <SportDefinition>[
    badminton,
    pickleball,
    tennis,
  ];

  static const all = supported;

  static SportDefinition byId(String id) => all.firstWhere(
        (sport) => sport.id == id,
        orElse: () => badminton,
      );
}
