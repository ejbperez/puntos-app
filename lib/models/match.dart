import 'dart:convert';
import 'match_format.dart';
import 'match_rule.dart';
import 'player.dart';
import 'sport.dart';

class Match {
  const Match({
    required this.id,
    required this.sport,
    required this.format,
    required this.court,
    required this.teamAPlayers,
    required this.teamBPlayers,
    this.teamAName = 'Team A',
    this.teamBName = 'Team B',
    required this.teamAScore,
    required this.teamBScore,
    required this.currentGame,
    required this.teamAGames,
    required this.teamBGames,
    required this.servingTeam,
    required this.currentServerId,
    required this.currentReceiverId,
    required this.serviceCourtSide,
    required this.rule,
    required this.startedAt,
    required this.completed,
    this.finishedAt,
    this.winner,
    this.isManuallyEnded = false,
    this.serverNumber = 1, // 1 or 2 for Pickleball doubles
    this.serviceRotationIndex = 0,
    this.tennisGamePointsA = 0,
    this.tennisGamePointsB = 0,
    this.inTiebreak = false,
    this.setHistory = const [],
    this.history = const [],
  });

  final String id;
  final SportDefinition sport;
  final MatchFormat format;
  final String court;
  final List<Player> teamAPlayers;
  final List<Player> teamBPlayers;
  final String teamAName;
  final String teamBName;
  final int teamAScore;
  final int teamBScore;
  final int currentGame;
  final int teamAGames;
  final int teamBGames;
  final TeamSide servingTeam;
  final String currentServerId;
  final String currentReceiverId;
  final CourtSide serviceCourtSide;
  final MatchRule rule;
  final DateTime startedAt;
  final bool completed;
  final DateTime? finishedAt;
  final TeamSide? winner;
  final bool isManuallyEnded;
  final int serverNumber;
  final int serviceRotationIndex;
  final int tennisGamePointsA;
  final int tennisGamePointsB;
  final bool inTiebreak;
  final List<String> setHistory;
  final List<MatchSnapshot> history;

  // Compatibility helpers
  List<String> get participants => [
        ...teamAPlayers.map((p) => p.name),
        ...teamBPlayers.map((p) => p.name),
      ];

  List<int> get scores => [teamAScore, teamBScore];

  String? get server => currentServer?.name;

  Player? get currentServer {
    final all = [...teamAPlayers, ...teamBPlayers];
    for (final player in all) {
      if (player.id == currentServerId) return player;
    }
    return all.isEmpty ? null : all.first;
  }

  Player? get currentReceiver {
    final all = [...teamAPlayers, ...teamBPlayers];
    for (final player in all) {
      if (player.id == currentReceiverId) return player;
    }
    return all.isEmpty ? null : all.first;
  }

  bool get isTeamAServing => servingTeam == TeamSide.teamA;
  bool get isTeamBServing => servingTeam == TeamSide.teamB;

  String get winnerTitle {
    if (winner == TeamSide.teamA) return teamAName;
    if (winner == TeamSide.teamB) return teamBName;
    return 'None';
  }

  String get serviceCourtDescription {
    final side = serviceCourtSide == CourtSide.right ? 'RIGHT' : 'LEFT';
    return 'Serving from the $side service court';
  }

  /// Formatted main score display for Team A
  String get displayScoreA {
    if (sport.id == 'tennis') {
      if (inTiebreak) return '$tennisGamePointsA';
      return _formatTennisPoint(tennisGamePointsA, tennisGamePointsB);
    }
    return '$teamAScore';
  }

  /// Formatted main score display for Team B
  String get displayScoreB {
    if (sport.id == 'tennis') {
      if (inTiebreak) return '$tennisGamePointsB';
      return _formatTennisPoint(tennisGamePointsB, tennisGamePointsA);
    }
    return '$teamBScore';
  }

  String _formatTennisPoint(int myPoints, int oppPoints) {
    if (myPoints >= 3 && oppPoints >= 3) {
      if (myPoints == oppPoints) return 'Deuce';
      if (myPoints > oppPoints) return 'AD';
      return '40';
    }
    switch (myPoints) {
      case 0:
        return 'Love';
      case 1:
        return '15';
      case 2:
        return '30';
      case 3:
        return '40';
      default:
        return '$myPoints';
    }
  }

  /// Summary for cards (e.g. "18 - 16" or "6-4, 3-2")
  String get scoreSummary {
    if (sport.id == 'tennis') {
      final currentGameStr = inTiebreak
          ? 'TB ($tennisGamePointsA-$tennisGamePointsB)'
          : '${_formatTennisPoint(tennisGamePointsA, tennisGamePointsB)} - ${_formatTennisPoint(tennisGamePointsB, tennisGamePointsA)}';
      final setStr = '$teamAGames - $teamBGames';
      if (setHistory.isEmpty) return '$setStr ($currentGameStr)';
      return '${setHistory.join(", ")}, $setStr';
    } else if (sport.id == 'pickleball' && format.playersPerTeam == 2) {
      return '$teamAScore - $teamBScore (S$serverNumber)';
    }
    return '$teamAScore - $teamBScore';
  }

  String get gamesSummary => '$teamAGames - $teamBGames';

  Match copyWith({
    String? id,
    SportDefinition? sport,
    MatchFormat? format,
    String? court,
    List<Player>? teamAPlayers,
    List<Player>? teamBPlayers,
    String? teamAName,
    String? teamBName,
    int? teamAScore,
    int? teamBScore,
    int? currentGame,
    int? teamAGames,
    int? teamBGames,
    TeamSide? servingTeam,
    String? currentServerId,
    String? currentReceiverId,
    CourtSide? serviceCourtSide,
    MatchRule? rule,
    DateTime? startedAt,
    bool? completed,
    DateTime? finishedAt,
    TeamSide? winner,
    bool clearFinishedAt = false,
    bool clearWinner = false,
    bool? isManuallyEnded,
    int? serverNumber,
    int? serviceRotationIndex,
    int? tennisGamePointsA,
    int? tennisGamePointsB,
    bool? inTiebreak,
    List<String>? setHistory,
    List<MatchSnapshot>? history,
  }) {
    return Match(
      id: id ?? this.id,
      sport: sport ?? this.sport,
      format: format ?? this.format,
      court: court ?? this.court,
      teamAPlayers: teamAPlayers ?? this.teamAPlayers,
      teamBPlayers: teamBPlayers ?? this.teamBPlayers,
      teamAName: teamAName ?? this.teamAName,
      teamBName: teamBName ?? this.teamBName,
      teamAScore: teamAScore ?? this.teamAScore,
      teamBScore: teamBScore ?? this.teamBScore,
      currentGame: currentGame ?? this.currentGame,
      teamAGames: teamAGames ?? this.teamAGames,
      teamBGames: teamBGames ?? this.teamBGames,
      servingTeam: servingTeam ?? this.servingTeam,
      currentServerId: currentServerId ?? this.currentServerId,
      currentReceiverId: currentReceiverId ?? this.currentReceiverId,
      serviceCourtSide: serviceCourtSide ?? this.serviceCourtSide,
      rule: rule ?? this.rule,
      startedAt: startedAt ?? this.startedAt,
      completed: completed ?? this.completed,
      finishedAt: clearFinishedAt ? null : (finishedAt ?? this.finishedAt),
      winner: clearWinner ? null : (winner ?? this.winner),
      isManuallyEnded: isManuallyEnded ?? this.isManuallyEnded,
      serverNumber: serverNumber ?? this.serverNumber,
      serviceRotationIndex: serviceRotationIndex ?? this.serviceRotationIndex,
      tennisGamePointsA: tennisGamePointsA ?? this.tennisGamePointsA,
      tennisGamePointsB: tennisGamePointsB ?? this.tennisGamePointsB,
      inTiebreak: inTiebreak ?? this.inTiebreak,
      setHistory: setHistory ?? this.setHistory,
      history: history ?? this.history,
    );
  }

  MatchSnapshot toSnapshot() => MatchSnapshot(
        teamAPlayers: teamAPlayers,
        teamBPlayers: teamBPlayers,
        teamAName: teamAName,
        teamBName: teamBName,
        teamAScore: teamAScore,
        teamBScore: teamBScore,
        currentGame: currentGame,
        teamAGames: teamAGames,
        teamBGames: teamBGames,
        servingTeam: servingTeam,
        currentServerId: currentServerId,
        currentReceiverId: currentReceiverId,
        serviceCourtSide: serviceCourtSide,
        completed: completed,
        winner: winner,
        isManuallyEnded: isManuallyEnded,
        serverNumber: serverNumber,
        serviceRotationIndex: serviceRotationIndex,
        tennisGamePointsA: tennisGamePointsA,
        tennisGamePointsB: tennisGamePointsB,
        inTiebreak: inTiebreak,
        setHistory: setHistory,
        finishedAt: finishedAt,
      );

  factory Match.createDefault() {
    const a1 = Player(
      id: 'a1',
      name: 'James Lee',
      team: TeamSide.teamA,
      slot: 1,
      currentCourtSide: CourtSide.right,
      isServer: true,
    );
    const a2 = Player(
      id: 'a2',
      name: 'Daniel Kim',
      team: TeamSide.teamA,
      slot: 2,
      currentCourtSide: CourtSide.left,
      isServer: false,
    );
    const b1 = Player(
      id: 'b1',
      name: 'Chris Tan',
      team: TeamSide.teamB,
      slot: 1,
      currentCourtSide: CourtSide.left,
      isServer: false,
    );
    const b2 = Player(
      id: 'b2',
      name: 'Alex Cruz',
      team: TeamSide.teamB,
      slot: 2,
      currentCourtSide: CourtSide.right,
      isServer: false,
    );

    return Match(
      id: 'match_1',
      sport: SportCatalog.badminton,
      format: MatchFormat.doubles,
      court: 'Court 1',
      teamAName: 'Team A',
      teamBName: 'Team B',
      teamAPlayers: const [a1, a2],
      teamBPlayers: const [b1, b2],
      teamAScore: 18,
      teamBScore: 16,
      currentGame: 2,
      teamAGames: 1,
      teamBGames: 0,
      servingTeam: TeamSide.teamA,
      currentServerId: a1.id,
      currentReceiverId: b1.id,
      serviceCourtSide: CourtSide.right,
      rule: const MatchRule(
          pointsPerGame: 21, gamesPerMatch: 3, winByTwo: true, maxPoints: 30),
      startedAt: DateTime.now().subtract(const Duration(minutes: 25)),
      completed: false,
    );
  }

  String encode() => jsonEncode({
        'id': id,
        'sportId': sport.id,
        'format': format.type.name,
        'court': court,
        'teamAName': teamAName,
        'teamBName': teamBName,
        'teamAPlayers': teamAPlayers.map((p) => p.toMap()).toList(),
        'teamBPlayers': teamBPlayers.map((p) => p.toMap()).toList(),
        'teamAScore': teamAScore,
        'teamBScore': teamBScore,
        'currentGame': currentGame,
        'teamAGames': teamAGames,
        'teamBGames': teamBGames,
        'servingTeam': servingTeam.name,
        'currentServerId': currentServerId,
        'currentReceiverId': currentReceiverId,
        'serviceCourtSide': serviceCourtSide.name,
        'rule': rule.toMap(),
        'startedAt': startedAt.toIso8601String(),
        'completed': completed,
        'finishedAt': finishedAt?.toIso8601String(),
        'winner': winner?.name,
        'isManuallyEnded': isManuallyEnded,
        'serverNumber': serverNumber,
        'serviceRotationIndex': serviceRotationIndex,
        'tennisGamePointsA': tennisGamePointsA,
        'tennisGamePointsB': tennisGamePointsB,
        'inTiebreak': inTiebreak,
        'setHistory': setHistory,
        'history': history.map((snapshot) => snapshot.toMap()).toList(),
      });

  factory Match.decode(String value) {
    final data = jsonDecode(value) as Map<String, dynamic>;
    final formatType =
        MatchFormatType.values.byName(data['format'] as String? ?? 'doubles');
    final format = MatchFormat.standardFormats.firstWhere(
      (f) => f.type == formatType,
      orElse: () => MatchFormat.doubles,
    );

    return Match(
      id: data['id'] as String,
      sport: SportCatalog.byId(data['sportId'] as String? ?? 'badminton'),
      format: format,
      court: data['court'] as String? ?? 'Court 1',
      teamAName: data['teamAName'] as String? ?? 'Team A',
      teamBName: data['teamBName'] as String? ?? 'Team B',
      teamAPlayers: ((data['teamAPlayers'] ?? []) as List)
          .map((item) => Player.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList(),
      teamBPlayers: ((data['teamBPlayers'] ?? []) as List)
          .map((item) => Player.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList(),
      teamAScore: data['teamAScore'] as int? ?? 0,
      teamBScore: data['teamBScore'] as int? ?? 0,
      currentGame: data['currentGame'] as int? ?? 1,
      teamAGames: data['teamAGames'] as int? ?? 0,
      teamBGames: data['teamBGames'] as int? ?? 0,
      servingTeam:
          TeamSide.values.byName(data['servingTeam'] as String? ?? 'teamA'),
      currentServerId: data['currentServerId'] as String? ?? '',
      currentReceiverId: data['currentReceiverId'] as String? ?? '',
      serviceCourtSide: CourtSide.values
          .byName(data['serviceCourtSide'] as String? ?? 'right'),
      rule: MatchRule.fromMap(data['rule'] as Map<String, dynamic>? ?? {}),
      startedAt: DateTime.parse(
          data['startedAt'] as String? ?? DateTime.now().toIso8601String()),
      completed: data['completed'] as bool? ?? false,
      finishedAt: data['finishedAt'] == null
          ? null
          : DateTime.tryParse(data['finishedAt'] as String),
      winner: data['winner'] != null
          ? TeamSide.values.byName(data['winner'] as String)
          : null,
      isManuallyEnded: data['isManuallyEnded'] as bool? ?? false,
      serverNumber: data['serverNumber'] as int? ?? 1,
      serviceRotationIndex: data['serviceRotationIndex'] as int? ?? 0,
      tennisGamePointsA: data['tennisGamePointsA'] as int? ?? 0,
      tennisGamePointsB: data['tennisGamePointsB'] as int? ?? 0,
      inTiebreak: data['inTiebreak'] as bool? ?? false,
      setHistory: List<String>.from(data['setHistory'] as List? ?? []),
      history: ((data['history'] ?? []) as List)
          .map((item) =>
              MatchSnapshot.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }
}

class MatchSnapshot {
  const MatchSnapshot({
    required this.teamAPlayers,
    required this.teamBPlayers,
    required this.teamAName,
    required this.teamBName,
    required this.teamAScore,
    required this.teamBScore,
    required this.currentGame,
    required this.teamAGames,
    required this.teamBGames,
    required this.servingTeam,
    required this.currentServerId,
    required this.currentReceiverId,
    required this.serviceCourtSide,
    required this.completed,
    this.finishedAt,
    this.winner,
    this.isManuallyEnded = false,
    this.serverNumber = 1,
    this.serviceRotationIndex = 0,
    this.tennisGamePointsA = 0,
    this.tennisGamePointsB = 0,
    this.inTiebreak = false,
    this.setHistory = const [],
  });

  final List<Player> teamAPlayers;
  final List<Player> teamBPlayers;
  final String teamAName;
  final String teamBName;
  final int teamAScore;
  final int teamBScore;
  final int currentGame;
  final int teamAGames;
  final int teamBGames;
  final TeamSide servingTeam;
  final String currentServerId;
  final String currentReceiverId;
  final CourtSide serviceCourtSide;
  final bool completed;
  final DateTime? finishedAt;
  final TeamSide? winner;
  final bool isManuallyEnded;
  final int serverNumber;
  final int serviceRotationIndex;
  final int tennisGamePointsA;
  final int tennisGamePointsB;
  final bool inTiebreak;
  final List<String> setHistory;

  Map<String, dynamic> toMap() => {
        'teamAPlayers': teamAPlayers.map((p) => p.toMap()).toList(),
        'teamBPlayers': teamBPlayers.map((p) => p.toMap()).toList(),
        'teamAName': teamAName,
        'teamBName': teamBName,
        'teamAScore': teamAScore,
        'teamBScore': teamBScore,
        'currentGame': currentGame,
        'teamAGames': teamAGames,
        'teamBGames': teamBGames,
        'servingTeam': servingTeam.name,
        'currentServerId': currentServerId,
        'currentReceiverId': currentReceiverId,
        'serviceCourtSide': serviceCourtSide.name,
        'completed': completed,
        'finishedAt': finishedAt?.toIso8601String(),
        'winner': winner?.name,
        'isManuallyEnded': isManuallyEnded,
        'serverNumber': serverNumber,
        'serviceRotationIndex': serviceRotationIndex,
        'tennisGamePointsA': tennisGamePointsA,
        'tennisGamePointsB': tennisGamePointsB,
        'inTiebreak': inTiebreak,
        'setHistory': setHistory,
      };

  factory MatchSnapshot.fromMap(Map<String, dynamic> map) => MatchSnapshot(
        teamAPlayers: ((map['teamAPlayers'] ?? []) as List)
            .map((item) =>
                Player.fromMap(Map<String, dynamic>.from(item as Map)))
            .toList(),
        teamBPlayers: ((map['teamBPlayers'] ?? []) as List)
            .map((item) =>
                Player.fromMap(Map<String, dynamic>.from(item as Map)))
            .toList(),
        teamAName: map['teamAName'] as String? ?? 'Team A',
        teamBName: map['teamBName'] as String? ?? 'Team B',
        teamAScore: map['teamAScore'] as int? ?? 0,
        teamBScore: map['teamBScore'] as int? ?? 0,
        currentGame: map['currentGame'] as int? ?? 1,
        teamAGames: map['teamAGames'] as int? ?? 0,
        teamBGames: map['teamBGames'] as int? ?? 0,
        servingTeam:
            TeamSide.values.byName(map['servingTeam'] as String? ?? 'teamA'),
        currentServerId: map['currentServerId'] as String? ?? '',
        currentReceiverId: map['currentReceiverId'] as String? ?? '',
        serviceCourtSide: CourtSide.values
            .byName(map['serviceCourtSide'] as String? ?? 'right'),
        completed: map['completed'] as bool? ?? false,
        finishedAt: map['finishedAt'] == null
            ? null
            : DateTime.tryParse(map['finishedAt'] as String),
        winner: map['winner'] == null
            ? null
            : TeamSide.values.byName(map['winner'] as String),
        isManuallyEnded: map['isManuallyEnded'] as bool? ?? false,
        serverNumber: map['serverNumber'] as int? ?? 1,
        serviceRotationIndex: map['serviceRotationIndex'] as int? ?? 0,
        tennisGamePointsA: map['tennisGamePointsA'] as int? ?? 0,
        tennisGamePointsB: map['tennisGamePointsB'] as int? ?? 0,
        inTiebreak: map['inTiebreak'] as bool? ?? false,
        setHistory: List<String>.from(map['setHistory'] as List? ?? []),
      );
}
