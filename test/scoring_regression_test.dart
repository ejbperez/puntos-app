import 'package:flutter_test/flutter_test.dart';
import 'package:puntos_app/models/match.dart';
import 'package:puntos_app/models/match_format.dart';
import 'package:puntos_app/models/match_rule.dart';
import 'package:puntos_app/models/sport.dart';
import 'package:puntos_app/models/player.dart';
import 'package:puntos_app/scoring/pickleball_scoring_engine.dart';
import 'package:puntos_app/scoring/badminton_scoring_engine.dart';
import 'package:puntos_app/scoring/tennis_scoring_engine.dart';
import 'package:puntos_app/state/setup_controller.dart';
import 'package:puntos_app/state/match_controller.dart';

void main() {
  test('new setup uses generic player names and stable identifiers', () {
    final setup = SetupController();
    expect(setup.teamAName, 'Team A');
    expect(setup.teamBName, 'Team B');
    expect(setup.teamAPlayers.map((p) => p.name), ['Player 1', 'Player 2']);
    expect(setup.teamBPlayers.map((p) => p.name), ['Player 1', 'Player 2']);
    setup.editPlayerName(TeamSide.teamA, 'a1', 'Miguel Santos');
    expect(setup.teamAPlayers.first.id, 'a1');
    expect(setup.teamAPlayers.first.name, 'Miguel Santos');
  });

  test('traditional pickleball side-out does not award receiving points', () {
    final match = Match.createDefault().copyWith(
      sport: SportCatalog.pickleball,
      rule: const MatchRule(
          pointsPerGame: 11, gamesPerMatch: 1, isSideOutScoring: true),
      teamAScore: 0,
      teamBScore: 0,
      serverNumber: 2,
    );
    final result = const PickleballScoringEngine()
        .rallyWonBy(match, TeamSide.teamB);
    expect(result.teamAScore, 0);
    expect(result.teamBScore, 0);
    expect(result.servingTeam, TeamSide.teamB);
  });

  test('tennis uses terminology and handles deuce/advantage', () {
    var match = Match.createDefault().copyWith(
      sport: SportCatalog.tennis,
      format: MatchFormat.singles,
      rule: const MatchRule(
          pointsPerGame: 6, gamesPerMatch: 1, useAdvantage: true),
      teamAScore: 0,
      teamBScore: 0,
      teamAGames: 0,
      teamBGames: 0,
      tennisGamePointsA: 0,
      tennisGamePointsB: 0,
    );
    final engine = const TennisScoringEngine();
    expect(match.displayScoreA, 'Love');
    for (var i = 0; i < 3; i++) {
      match = engine.rallyWonBy(match, TeamSide.teamA);
      match = engine.rallyWonBy(match, TeamSide.teamB);
    }
    expect(match.displayScoreA, 'Deuce');
    match = engine.rallyWonBy(match, TeamSide.teamA);
    expect(match.displayScoreA, 'AD');
    match = engine.rallyWonBy(match, TeamSide.teamB);
    expect(match.displayScoreA, 'Deuce');
  });

  test('pickleball undo restores service and player positions', () {
    final initial = Match.createDefault().copyWith(
      sport: SportCatalog.pickleball,
      rule: const MatchRule(
          pointsPerGame: 11, gamesPerMatch: 3, isSideOutScoring: true),
    );
    final engine = const PickleballScoringEngine();
    final changed = engine.rallyWonBy(initial, TeamSide.teamA);
    final restored = engine.undo(changed);
    expect(restored.currentServerId, initial.currentServerId);
    expect(restored.currentReceiverId, initial.currentReceiverId);
    expect(restored.serviceCourtSide, initial.serviceCourtSide);
    expect(restored.teamAPlayers.first.currentCourtSide,
        initial.teamAPlayers.first.currentCourtSide);
  });

  for (final target in [11, 15, 21]) {
    test('badminton honors a $target point target', () {
      final match = Match.createDefault().copyWith(
        teamAScore: target - 1,
        teamBScore: target - 2,
        rule: MatchRule(
          pointsPerGame: target,
          gamesPerMatch: 3,
          winByTwo: true,
          maxPoints: 30,
        ),
      );
      final result = const BadmintonScoringEngine()
          .rallyWonBy(match, TeamSide.teamA);
      expect(result.teamAScore, 0);
      expect(result.teamBScore, 0);
      expect(result.teamAGames, 1);
      expect(result.rule.pointsPerGame, target);
    });
  }

  test('badminton retains the 30-point absolute cap', () {
    final match = Match.createDefault().copyWith(
      teamAScore: 29,
      teamBScore: 28,
      rule: const MatchRule(
        pointsPerGame: 11,
        gamesPerMatch: 3,
        winByTwo: true,
        maxPoints: 30,
      ),
    );
    final result = const BadmintonScoringEngine()
        .rallyWonBy(match, TeamSide.teamA);
    expect(result.teamAGames, 1);
    expect(result.teamAScore, 0);
  });

  test('pickleball honors a configured 15-point target', () {
    final match = Match.createDefault().copyWith(
      sport: SportCatalog.pickleball,
      teamAScore: 14,
      teamBScore: 13,
      rule: const MatchRule(
        pointsPerGame: 15,
        gamesPerMatch: 3,
        winByTwo: true,
        isSideOutScoring: true,
      ),
    );
    final result = const PickleballScoringEngine()
        .rallyWonBy(match, TeamSide.teamA);
    expect(result.teamAScore, 0);
    expect(result.teamAGames, 1);
    expect(result.rule.pointsPerGame, 15);
  });

  test('starting a new match remains safe after list lifecycle updates', () {
    final controller = MatchController();
    final newMatch = Match.createDefault().copyWith(
      id: 'new-match-for-controller-test',
      teamAScore: 0,
      teamBScore: 0,
    );
    controller.createAndStartMatch(newMatch);
    expect(controller.currentMatch.id, newMatch.id);
    expect(controller.activeMatches.first.id, newMatch.id);
  });

  test('matches with no players do not crash server or receiver lookup', () {
    final match = Match.createDefault().copyWith(
      teamAPlayers: const [],
      teamBPlayers: const [],
      currentServerId: '',
      currentReceiverId: '',
    );
    expect(match.currentServer, isNull);
    expect(match.currentReceiver, isNull);
  });

  test('controller can delete individual matches and clear each collection', () async {
    final controller = MatchController();
    final activeId = controller.activeMatches.first.id;
    final historyId = controller.completedMatches.first.id;

    await controller.deleteMatch(activeId);
    expect(controller.activeMatches.any((match) => match.id == activeId), isFalse);
    expect(controller.completedMatches.any((match) => match.id == historyId), isTrue);

    await controller.deleteMatch(historyId);
    expect(controller.completedMatches.any((match) => match.id == historyId), isFalse);

    await controller.clearActiveMatches();
    expect(controller.activeMatches, isEmpty);
    await controller.clearCompletedMatches();
    expect(controller.completedMatches, isEmpty);
  });

  test('singles badminton moves server and receiver markers together', () {
    final initial = Match.createDefault();
    final match = initial.copyWith(
      format: MatchFormat.singles,
      teamAPlayers: [initial.teamAPlayers.first],
      teamBPlayers: [initial.teamBPlayers.first],
      teamAScore: 0,
      teamBScore: 0,
      currentServerId: 'a1',
      currentReceiverId: 'b1',
    );
    final engine = const BadmintonScoringEngine();
    final afterA = engine.rallyWonBy(match, TeamSide.teamA);
    expect(afterA.currentServer!.currentCourtSide, CourtSide.left);
    expect(afterA.currentReceiver!.currentCourtSide, CourtSide.right);

    final afterB = engine.rallyWonBy(afterA, TeamSide.teamB);
    expect(afterB.currentServer!.currentCourtSide, CourtSide.left);
    expect(afterB.currentReceiver!.currentCourtSide, CourtSide.right);
  });

  test('singles pickleball and tennis update receiver positions', () {
    final initial = Match.createDefault();
    final pickleball = initial.copyWith(
      sport: SportCatalog.pickleball,
      format: MatchFormat.singles,
      teamAPlayers: [initial.teamAPlayers.first],
      teamBPlayers: [initial.teamBPlayers.first],
      teamAScore: 0,
      teamBScore: 0,
      rule: const MatchRule(
          pointsPerGame: 11, gamesPerMatch: 3, isSideOutScoring: true),
    );
    final afterPickleball = const PickleballScoringEngine()
        .rallyWonBy(pickleball, TeamSide.teamA);
    expect(afterPickleball.currentServer!.currentCourtSide, CourtSide.left);
    expect(afterPickleball.currentReceiver!.currentCourtSide, CourtSide.right);

    final tennis = pickleball.copyWith(
      sport: SportCatalog.tennis,
      rule: const MatchRule(pointsPerGame: 6, gamesPerMatch: 3),
      tennisGamePointsA: 0,
      tennisGamePointsB: 0,
    );
    final afterTennis = const TennisScoringEngine()
        .rallyWonBy(tennis, TeamSide.teamA);
    expect(afterTennis.currentServer!.currentCourtSide, CourtSide.left);
    expect(afterTennis.currentReceiver!.currentCourtSide, CourtSide.right);
  });

  test('badminton doubles receiver follows the opposite service court', () {
    final initial = Match.createDefault().copyWith(
      teamAScore: 18,
      teamBScore: 16,
      currentServerId: 'a1',
      currentReceiverId: 'b1',
    );

    final result = const BadmintonScoringEngine()
        .rallyWonBy(initial, TeamSide.teamA);

    expect(result.currentServerId, 'a1');
    expect(result.currentReceiverId, 'b2');
    expect(result.currentReceiver!.currentCourtSide, CourtSide.right);
  });

  test('pickleball doubles receiver follows the opposite service court', () {
    final initial = Match.createDefault().copyWith(
      sport: SportCatalog.pickleball,
      teamAScore: 0,
      teamBScore: 0,
      currentServerId: 'a1',
      currentReceiverId: 'b1',
      rule: const MatchRule(
        pointsPerGame: 11,
        gamesPerMatch: 3,
        winByTwo: true,
        isSideOutScoring: true,
      ),
    );

    final result = const PickleballScoringEngine()
        .rallyWonBy(initial, TeamSide.teamA);

    expect(result.currentServerId, 'a1');
    expect(result.currentReceiverId, 'b2');
    expect(result.currentReceiver!.currentCourtSide, CourtSide.right);
  });
}
