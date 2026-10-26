class MatchRule {
  const MatchRule({
    this.pointsPerGame = 21,
    this.gamesPerMatch = 3, // Best of 3
    this.winByTwo = true,
    this.maxPoints = 30,
    this.trackServiceCourt = true,
    this.showPlayerPositions = true,
    this.isSideOutScoring = false,
    this.useAdvantage = true,
    this.tiebreakAt = 6,
  });

  final int pointsPerGame;
  final int gamesPerMatch;
  final bool winByTwo;
  final int maxPoints;
  final bool trackServiceCourt;
  final bool showPlayerPositions;
  final bool isSideOutScoring; // Used by Pickleball
  final bool useAdvantage; // Used by Tennis
  final int tiebreakAt; // Used by Tennis

  String get gamesDescription => 'Best of $gamesPerMatch';
  String get pointsDescription =>
      '$pointsPerGame${winByTwo ? " (win by 2)" : ""}';

  MatchRule copyWith({
    int? pointsPerGame,
    int? gamesPerMatch,
    bool? winByTwo,
    int? maxPoints,
    bool? trackServiceCourt,
    bool? showPlayerPositions,
    bool? isSideOutScoring,
    bool? useAdvantage,
    int? tiebreakAt,
  }) {
    return MatchRule(
      pointsPerGame: pointsPerGame ?? this.pointsPerGame,
      gamesPerMatch: gamesPerMatch ?? this.gamesPerMatch,
      winByTwo: winByTwo ?? this.winByTwo,
      maxPoints: maxPoints ?? this.maxPoints,
      trackServiceCourt: trackServiceCourt ?? this.trackServiceCourt,
      showPlayerPositions: showPlayerPositions ?? this.showPlayerPositions,
      isSideOutScoring: isSideOutScoring ?? this.isSideOutScoring,
      useAdvantage: useAdvantage ?? this.useAdvantage,
      tiebreakAt: tiebreakAt ?? this.tiebreakAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'pointsPerGame': pointsPerGame,
        'gamesPerMatch': gamesPerMatch,
        'winByTwo': winByTwo,
        'maxPoints': maxPoints,
        'trackServiceCourt': trackServiceCourt,
        'showPlayerPositions': showPlayerPositions,
        'isSideOutScoring': isSideOutScoring,
        'useAdvantage': useAdvantage,
        'tiebreakAt': tiebreakAt,
      };

  factory MatchRule.fromMap(Map<String, dynamic> map) => MatchRule(
        pointsPerGame: map['pointsPerGame'] as int? ?? 21,
        gamesPerMatch: map['gamesPerMatch'] as int? ?? 3,
        winByTwo: map['winByTwo'] as bool? ?? true,
        maxPoints: map['maxPoints'] as int? ?? 30,
        trackServiceCourt: map['trackServiceCourt'] as bool? ?? true,
        showPlayerPositions: map['showPlayerPositions'] as bool? ?? true,
        isSideOutScoring: map['isSideOutScoring'] as bool? ?? false,
        useAdvantage: map['useAdvantage'] as bool? ?? true,
        tiebreakAt: map['tiebreakAt'] as int? ?? 6,
      );
}
