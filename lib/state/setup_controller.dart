import 'package:flutter/material.dart';
import '../models/match.dart';
import '../models/match_format.dart';
import '../models/match_rule.dart';
import '../models/player.dart';
import '../models/sport.dart';

class SetupController extends ChangeNotifier {
  SportDefinition _sport = SportCatalog.badminton;
  MatchFormat _format = MatchFormat.doubles;
  int _currentStep = 1;

  String _teamAName = 'Team A';
  String _teamBName = 'Team B';

  List<Player> _teamAPlayers = [
    const Player(
      id: 'a1',
      name: 'Player 1',
      team: TeamSide.teamA,
      slot: 1,
      currentCourtSide: CourtSide.right,
    ),
    const Player(
      id: 'a2',
      name: 'Player 2',
      team: TeamSide.teamA,
      slot: 2,
      currentCourtSide: CourtSide.left,
    ),
  ];

  List<Player> _teamBPlayers = [
    const Player(
      id: 'b1',
      name: 'Player 1',
      team: TeamSide.teamB,
      slot: 1,
      currentCourtSide: CourtSide.right,
    ),
    const Player(
      id: 'b2',
      name: 'Player 2',
      team: TeamSide.teamB,
      slot: 2,
      currentCourtSide: CourtSide.left,
    ),
  ];

  late int _gamesPerMatch;
  late int _pointsPerGame;
  late bool _winByTwo;
  late bool _isSideOutScoring;
  late bool _useAdvantage;
  String _startingServerId = 'a1';
  String _court = 'Court 1';

  SetupController() {
    _syncRulesFromSport(_sport);
  }

  void _syncRulesFromSport(SportDefinition sport) {
    _pointsPerGame = sport.defaultRule.pointsPerGame;
    _gamesPerMatch = sport.defaultRule.gamesPerMatch;
    _winByTwo = sport.defaultRule.winByTwo;
    _isSideOutScoring = sport.defaultRule.isSideOutScoring;
    _useAdvantage = sport.defaultRule.useAdvantage;
  }

  // Getters
  SportDefinition get sport => _sport;
  MatchFormat get format => _format;
  int get currentStep => _currentStep;
  String get teamAName => _teamAName;
  String get teamBName => _teamBName;
  List<Player> get teamAPlayers => _teamAPlayers;
  List<Player> get teamBPlayers => _teamBPlayers;
  int get gamesPerMatch => _gamesPerMatch;
  int get pointsPerGame => _pointsPerGame;
  bool get winByTwo => _winByTwo;
  bool get isSideOutScoring => _isSideOutScoring;
  bool get useAdvantage => _useAdvantage;
  bool get isRallyScoring => !_isSideOutScoring;
  String get startingServerId => _startingServerId;
  String get court => _court;

  String get gamesDescription => 'Best of $_gamesPerMatch';
  String get pointsDescription {
    if (_sport.id == 'tennis') {
      return '$_pointsPerGame games${_useAdvantage ? " (Advantage)" : " (No-Ad)"}';
    }
    return '$_pointsPerGame${_winByTwo ? " (win by 2)" : ""}';
  }

  String get startingServerDescription {
    final all = [..._teamAPlayers, ..._teamBPlayers];
    final server = all.firstWhere((p) => p.id == _startingServerId,
        orElse: () => _teamAPlayers.first);
    final teamLabel = server.team == TeamSide.teamA ? _teamAName : _teamBName;
    return '$teamLabel · ${server.label} (${server.name})';
  }

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void setTeamAName(String name) {
    _teamAName = name.trim();
    notifyListeners();
  }

  void setTeamBName(String name) {
    _teamBName = name.trim();
    notifyListeners();
  }

  void setSport(SportDefinition sport) {
    _sport = sport;
    _syncRulesFromSport(sport);
    // Ensure format is valid for selected sport
    if (!sport.supportedFormats.any((f) => f.type == _format.type)) {
      setFormat(sport.supportedFormats.first);
    } else {
      notifyListeners();
    }
  }

  void setFormat(MatchFormat format) {
    _format = format;
    if (format.playersPerTeam == 1) {
      // Singles: exactly 1 player per team
      _teamAPlayers = [
        _teamAPlayers.first.copyWith(slot: 1, currentCourtSide: CourtSide.right)
      ];
      _teamBPlayers = [
        _teamBPlayers.first.copyWith(slot: 1, currentCourtSide: CourtSide.right)
      ];
      _startingServerId = _teamAPlayers.first.id;
    } else if (format.playersPerTeam == 2) {
      // Doubles: exactly 2 players per team
      if (_teamAPlayers.length < 2) {
        _teamAPlayers.add(
            const Player(
              id: 'a2',
              name: 'Player 2',
            team: TeamSide.teamA,
            slot: 2,
            currentCourtSide: CourtSide.left,
          ),
        );
      }
      if (_teamBPlayers.length < 2) {
        _teamBPlayers.add(
            const Player(
              id: 'b2',
              name: 'Player 2',
            team: TeamSide.teamB,
            slot: 2,
            currentCourtSide: CourtSide.left,
          ),
        );
      }
    }
    if (_teamAPlayers.length > format.playersPerTeam) {
      _teamAPlayers = _teamAPlayers.take(format.playersPerTeam).toList();
    }
    if (_teamBPlayers.length > format.playersPerTeam) {
      _teamBPlayers = _teamBPlayers.take(format.playersPerTeam).toList();
    }
    final configuredPlayers = [..._teamAPlayers, ..._teamBPlayers];
    if (!configuredPlayers.any((player) => player.id == _startingServerId)) {
      _startingServerId = _teamAPlayers.first.id;
    }
    notifyListeners();
  }

  void editPlayerName(TeamSide team, String playerId, String newName) {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;

    if (team == TeamSide.teamA) {
      _teamAPlayers = _teamAPlayers
          .map((p) => p.id == playerId ? p.copyWith(name: trimmed) : p)
          .toList();
    } else {
      _teamBPlayers = _teamBPlayers
          .map((p) => p.copyWith(name: p.id == playerId ? trimmed : p.name))
          .toList();
    }
    notifyListeners();
  }

  void addPlayer(TeamSide team, String name) {
    final trimmed = name.trim();
    final playerName = trimmed.isEmpty
        ? 'Player ${(team == TeamSide.teamA ? _teamAPlayers : _teamBPlayers).length + 1}'
        : trimmed;

    if (team == TeamSide.teamA) {
      final slot = _teamAPlayers.length + 1;
      _teamAPlayers = [
        ..._teamAPlayers,
        Player(
          id: 'a$slot',
          name: playerName,
          team: TeamSide.teamA,
          slot: slot,
          currentCourtSide: slot.isEven ? CourtSide.left : CourtSide.right,
        ),
      ];
    } else {
      final slot = _teamBPlayers.length + 1;
      _teamBPlayers = [
        ..._teamBPlayers,
        Player(
          id: 'b$slot',
          name: playerName,
          team: TeamSide.teamB,
          slot: slot,
          currentCourtSide: slot.isEven ? CourtSide.left : CourtSide.right,
        ),
      ];
    }
    notifyListeners();
  }

  void removePlayer(TeamSide team, String playerId) {
    final minPlayers = _format.playersPerTeam;
    if (team == TeamSide.teamA) {
      if (_teamAPlayers.length <= minPlayers) return;
      _teamAPlayers = _teamAPlayers.where((p) => p.id != playerId).toList();
      // Renumber slots
      _teamAPlayers = [
        for (int i = 0; i < _teamAPlayers.length; i++)
          _teamAPlayers[i].copyWith(
            slot: i + 1,
            id: 'a${i + 1}',
            currentCourtSide: (i + 1).isEven ? CourtSide.left : CourtSide.right,
          ),
      ];
      if (!_teamAPlayers.any((p) => p.id == _startingServerId)) {
        _startingServerId = _teamAPlayers.first.id;
      }
    } else {
      if (_teamBPlayers.length <= minPlayers) return;
      _teamBPlayers = _teamBPlayers.where((p) => p.id != playerId).toList();
      _teamBPlayers = [
        for (int i = 0; i < _teamBPlayers.length; i++)
          _teamBPlayers[i].copyWith(
            slot: i + 1,
            id: 'b${i + 1}',
            currentCourtSide: (i + 1).isEven ? CourtSide.left : CourtSide.right,
          ),
      ];
      if (!_teamBPlayers.any((p) => p.id == _startingServerId) &&
          _teamAPlayers.isEmpty) {
        _startingServerId = _teamBPlayers.first.id;
      }
    }
    notifyListeners();
  }

  void updatePlayerSide(TeamSide team, String playerId, CourtSide side) {
    if (team == TeamSide.teamA) {
      _teamAPlayers = _teamAPlayers
          .map((p) => p.id == playerId ? p.copyWith(currentCourtSide: side) : p)
          .toList();
    } else {
      _teamBPlayers = _teamBPlayers
          .map((p) => p.id == playerId ? p.copyWith(currentCourtSide: side) : p)
          .toList();
    }
    notifyListeners();
  }

  void setGamesPerMatch(int count) {
    _gamesPerMatch = count;
    notifyListeners();
  }

  void setPointsPerGame(int points) {
    _pointsPerGame = points;
    notifyListeners();
  }

  void setSideOutScoring(bool value) {
    _isSideOutScoring = value;
    notifyListeners();
  }

  void setCourt(String court) {
    _court = court;
    notifyListeners();
  }

  void setStartingServer(String serverId) {
    _startingServerId = serverId;
    notifyListeners();
  }

  /// Validation checking that players match the format and names are non-empty
  String? validate() {
    if (!_sport.supportedFormats.any((f) => f.type == _format.type)) {
      return '${_sport.name} does not support ${_format.label}.';
    }
    if (_court.trim().isEmpty) return 'Select a court.';
    if (_gamesPerMatch < 1 || _gamesPerMatch.isEven) {
      return 'Games per match must be an odd positive number.';
    }
    if (_teamAName.trim().isEmpty) return 'Team A name cannot be empty.';
    if (_teamBName.trim().isEmpty) return 'Team B name cannot be empty.';

    final requiredPlayers = _format.playersPerTeam;
    if (_teamAPlayers.length != requiredPlayers) {
      return '$_teamAName requires exactly $requiredPlayers player(s) for ${_format.label}.';
    }
    if (_teamBPlayers.length != requiredPlayers) {
      return '$_teamBName requires exactly $requiredPlayers player(s) for ${_format.label}.';
    }

    for (final p in _teamAPlayers) {
      if (p.name.trim().isEmpty) {
        return 'All players in $_teamAName must have a name.';
      }
    }
    for (final p in _teamBPlayers) {
      if (p.name.trim().isEmpty) {
        return 'All players in $_teamBName must have a name.';
      }
    }
    final ids = [..._teamAPlayers, ..._teamBPlayers].map((p) => p.id).toSet();
    if (ids.length != _teamAPlayers.length + _teamBPlayers.length) {
      return 'Each player must have a unique identifier.';
    }
    if (!_teamAPlayers.any((p) => p.id == _startingServerId) &&
        !_teamBPlayers.any((p) => p.id == _startingServerId)) {
      return 'Select a valid starting server.';
    }
    return null;
  }

  Match buildMatch() {
    final allPlayers = [..._teamAPlayers, ..._teamBPlayers];
    final server = allPlayers.firstWhere((p) => p.id == _startingServerId);

    final servingTeam = server.team;
    final receiverPlayers =
        servingTeam == TeamSide.teamA ? _teamBPlayers : _teamAPlayers;
    final receiverSide = _format.playersPerTeam == 1
        ? CourtSide.left
        : server.currentCourtSide.opposite;

    // Initialize isServer flags
    final updatedAPlayers = _teamAPlayers
        .map((p) => p.copyWith(
              isServer: p.id == _startingServerId,
              currentCourtSide: p.id == receiverPlayers.first.id
                  ? receiverSide
                  : p.currentCourtSide,
            ))
        .toList();
    final updatedBPlayers = _teamBPlayers
        .map((p) => p.copyWith(
              isServer: p.id == _startingServerId,
              currentCourtSide: p.id == receiverPlayers.first.id
                  ? receiverSide
                  : p.currentCourtSide,
            ))
        .toList();

    return Match(
      id: 'match_${DateTime.now().millisecondsSinceEpoch}',
      sport: _sport,
      format: _format,
      court: _court,
      teamAName: _teamAName,
      teamBName: _teamBName,
      teamAPlayers: updatedAPlayers,
      teamBPlayers: updatedBPlayers,
      teamAScore: 0,
      teamBScore: 0,
      currentGame: 1,
      teamAGames: 0,
      teamBGames: 0,
      servingTeam: servingTeam,
      serverNumber:
          _sport.id == 'pickleball' && _format.playersPerTeam == 2 ? 2 : 1,
      serviceRotationIndex: allPlayers.indexOf(server),
      currentServerId: _startingServerId,
      currentReceiverId: receiverPlayers.first.id,
      serviceCourtSide: CourtSide.right,
      rule: MatchRule(
        pointsPerGame: _pointsPerGame,
        gamesPerMatch: _gamesPerMatch,
        winByTwo: _winByTwo,
        isSideOutScoring: _isSideOutScoring,
        useAdvantage: _useAdvantage,
        maxPoints: _sport.id == 'badminton' ? 30 : 99,
      ),
      startedAt: DateTime.now(),
      completed: false,
    );
  }
}
