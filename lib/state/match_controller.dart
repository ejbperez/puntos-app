import 'package:flutter/material.dart';
import '../data/match_repository.dart';
import '../models/match.dart';
import '../models/match_format.dart';
import '../models/match_rule.dart';
import '../models/player.dart';
import '../models/sport.dart';
import '../scoring/badminton_scoring_engine.dart';
import '../scoring/pickleball_scoring_engine.dart';
import '../scoring/scoring_engine.dart';
import '../scoring/tennis_scoring_engine.dart';

class MatchController extends ChangeNotifier {
  MatchController({this.repository}) {
    _initializeData();
    if (repository != null) {
      _loadPersistedData();
    }
  }

  final MatchRepository? repository;

  late Match _currentMatch;
  List<Match> _activeMatches = [];
  List<Match> _completedMatches = [];

  Match get currentMatch => _currentMatch;
  List<Match> get activeMatches => _activeMatches;
  List<Match> get completedMatches => _completedMatches;

  ScoringEngine _engineFor(SportDefinition sport) {
    switch (sport.id) {
      case 'badminton':
        return const BadmintonScoringEngine();
      case 'pickleball':
        return const PickleballScoringEngine();
      case 'tennis':
        return const TennisScoringEngine();
      default:
        return const BadmintonScoringEngine();
    }
  }

  void _initializeData() {
    // Seed default match matching Phone 2 mockup (Badminton Doubles 18 - 16)
    _currentMatch = Match.createDefault();

    // Court 2: Pickleball Doubles
    final court2 = Match(
      id: 'match_pickleball_1',
      sport: SportCatalog.pickleball,
      format: MatchFormat.doubles,
      court: 'Court 2',
      teamAName: 'Team A',
      teamBName: 'Team B',
      teamAPlayers: const [
        Player(id: 'pa1', name: 'John Miller', team: TeamSide.teamA, slot: 1),
        Player(id: 'pa2', name: 'Dave Wilson', team: TeamSide.teamA, slot: 2),
      ],
      teamBPlayers: const [
        Player(id: 'pb1', name: 'Sam Taylor', team: TeamSide.teamB, slot: 1),
        Player(id: 'pb2', name: 'Mike Brown', team: TeamSide.teamB, slot: 2),
      ],
      teamAScore: 7,
      teamBScore: 5,
      currentGame: 1,
      teamAGames: 0,
      teamBGames: 0,
      servingTeam: TeamSide.teamB,
      serverNumber: 1,
      currentServerId: 'pb1',
      currentReceiverId: 'pa1',
      serviceCourtSide: CourtSide.right,
      rule: const MatchRule(
          pointsPerGame: 11, gamesPerMatch: 3, isSideOutScoring: true),
      startedAt: DateTime.now().subtract(const Duration(minutes: 15)),
      completed: false,
    );

    // Court 3: Tennis Singles
    final court3 = Match(
      id: 'match_tennis_1',
      sport: SportCatalog.tennis,
      format: MatchFormat.singles,
      court: 'Court 3',
      teamAName: 'Roger F.',
      teamBName: 'Rafael N.',
      teamAPlayers: const [
        Player(id: 'ta1', name: 'Roger F.', team: TeamSide.teamA, slot: 1),
      ],
      teamBPlayers: const [
        Player(id: 'tb1', name: 'Rafael N.', team: TeamSide.teamB, slot: 1),
      ],
      teamAScore: 0,
      teamBScore: 0,
      teamAGames: 4,
      teamBGames: 3,
      tennisGamePointsA: 2, // 30
      tennisGamePointsB: 1, // 15
      currentGame: 1,
      servingTeam: TeamSide.teamB,
      currentServerId: 'tb1',
      currentReceiverId: 'ta1',
      serviceCourtSide: CourtSide.left,
      rule: const MatchRule(
          pointsPerGame: 6, gamesPerMatch: 3, useAdvantage: true),
      startedAt: DateTime.now().subtract(const Duration(minutes: 40)),
      completed: false,
    );

    // Completed Match Archive (Pickleball)
    final completedCourt3 = Match(
      id: 'match_completed_1',
      sport: SportCatalog.pickleball,
      format: MatchFormat.singles,
      court: 'Court 3',
      teamAName: 'John Doe',
      teamBName: 'Sarah Lee',
      teamAPlayers: const [
        Player(id: 'pca1', name: 'John Doe', team: TeamSide.teamA, slot: 1),
      ],
      teamBPlayers: const [
        Player(id: 'pcb1', name: 'Sarah Lee', team: TeamSide.teamB, slot: 1),
      ],
      teamAScore: 11,
      teamBScore: 7,
      currentGame: 1,
      teamAGames: 1,
      teamBGames: 0,
      servingTeam: TeamSide.teamA,
      currentServerId: 'pca1',
      currentReceiverId: 'pcb1',
      serviceCourtSide: CourtSide.right,
      rule: const MatchRule(
          pointsPerGame: 11, gamesPerMatch: 1, isSideOutScoring: true),
      startedAt: DateTime.now().subtract(const Duration(hours: 2)),
      completed: true,
      winner: TeamSide.teamA,
    );

    _activeMatches = [_currentMatch, court2, court3];
    _completedMatches = [completedCourt3];
  }

  Future<void> _loadPersistedData() async {
    try {
      final active = await repository!.readActive();
      final completed = await repository!.readHistory();
      if (active.isEmpty && completed.isEmpty) return;

      // Repository queries may return fixed-length lists. The controller owns
      // mutable collections because scoring and match lifecycle operations
      // insert, replace, and remove entries.
      _activeMatches = List<Match>.from(active);
      _completedMatches = List<Match>.from(completed);
      _currentMatch = active.isNotEmpty
          ? active.first
          : (completed.isNotEmpty ? completed.first : _currentMatch);
      notifyListeners();
    } catch (_) {
      // Keep the seeded in-memory state if a corrupt or unavailable record is found.
    }
  }

  void setCurrentMatch(Match match) {
    _currentMatch = match;
    notifyListeners();
  }

  void rallyWon(TeamSide winner) {
    if (_currentMatch.completed) return;
    final engine = _engineFor(_currentMatch.sport);
    _currentMatch = engine.rallyWonBy(_currentMatch, winner);
    _syncCurrentMatchInLists();
    _persistMatch(_currentMatch);
    notifyListeners();
  }

  void decrementPoint(TeamSide team) {
    if (_currentMatch.completed) return;
    final engine = _engineFor(_currentMatch.sport);
    _currentMatch = engine.decrementPoint(_currentMatch, team);
    _syncCurrentMatchInLists();
    _persistMatch(_currentMatch);
    notifyListeners();
  }

  void undo() {
    final engine = _engineFor(_currentMatch.sport);
    _currentMatch = engine.undo(_currentMatch);
    _syncCurrentMatchInLists();
    _persistMatch(_currentMatch);
    notifyListeners();
  }

  void endMatch({bool isManual = true}) {
    if (_currentMatch.completed) return;
    _currentMatch = _currentMatch.copyWith(
      completed: true,
      isManuallyEnded: isManual,
      winner: isManual ? null : _currentMatch.winner,
      clearWinner: isManual,
      finishedAt: DateTime.now(),
    );
    _syncCurrentMatchInLists();
    _persistMatch(_currentMatch);
    notifyListeners();
  }

  void createAndStartMatch(Match newMatch) {
    // Defensively copy in case this controller was populated by an external
    // repository implementation that returned an unmodifiable list.
    _activeMatches = List<Match>.from(_activeMatches);
    _completedMatches = List<Match>.from(_completedMatches);
    _currentMatch = newMatch;
    _activeMatches.removeWhere((match) => match.id == newMatch.id);
    _completedMatches.removeWhere((match) => match.id == newMatch.id);
    _activeMatches.insert(0, newMatch);
    _persistMatch(newMatch);
    notifyListeners();
  }

  Future<void> deleteMatch(String matchId) async {
    _activeMatches = List<Match>.from(_activeMatches)
      ..removeWhere((match) => match.id == matchId);
    _completedMatches = List<Match>.from(_completedMatches)
      ..removeWhere((match) => match.id == matchId);
    await repository?.delete(matchId);
    if (_currentMatch.id == matchId) {
      _currentMatch = _activeMatches.isNotEmpty
          ? _activeMatches.first
          : Match.createDefault();
    }
    notifyListeners();
  }

  Future<void> clearActiveMatches() async {
    final ids = _activeMatches.map((match) => match.id).toList();
    _activeMatches = [];
    await repository?.deleteAll(ids);
    if (ids.contains(_currentMatch.id)) {
      _currentMatch = Match.createDefault();
    }
    notifyListeners();
  }

  Future<void> clearCompletedMatches() async {
    final ids = _completedMatches.map((match) => match.id).toList();
    _completedMatches = [];
    await repository?.deleteAll(ids);
    notifyListeners();
  }

  void _syncCurrentMatchInLists() {
    final idx = _activeMatches.indexWhere((m) => m.id == _currentMatch.id);
    if (_currentMatch.completed) {
      if (idx != -1) _activeMatches.removeAt(idx);
      if (!_completedMatches.any((m) => m.id == _currentMatch.id)) {
        _completedMatches.insert(0, _currentMatch);
      }
    } else {
      if (idx != -1) {
        _activeMatches[idx] = _currentMatch;
      } else {
        _activeMatches.insert(0, _currentMatch);
      }
    }
  }

  void _persistMatch(Match match) {
    repository?.save(match);
  }
}
