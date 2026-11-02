import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:puntos_app/data/match_repository.dart';
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

  test('setup player collections cannot be mutated externally', () {
    final setup = SetupController();

    expect(() => setup.teamAPlayers.add(setup.teamAPlayers.first),
        throwsUnsupportedError);
    expect(() => setup.teamBPlayers.clear(), throwsUnsupportedError);
  });

  test('switching formats preserves edited player names', () {
    final setup = SetupController();
    setup.editPlayerName(TeamSide.teamA, 'a2', 'Edited Player');

    setup.setFormat(MatchFormat.singles);
    setup.setFormat(MatchFormat.doubles);

    expect(setup.teamAPlayers[1].name, 'Edited Player');
  });

  test('setup rejects non-positive point targets', () {
    final setup = SetupController();
    setup.setPointsPerGame(0);

    expect(setup.validate(), contains('Points per game'));
  });

  test('scoring ignores a match with missing players', () {
    final match = Match.createDefault().copyWith(
      teamAPlayers: const [],
      teamBPlayers: const [],
    );

    expect(const BadmintonScoringEngine().rallyWonBy(match, TeamSide.teamA),
        same(match));
    expect(const PickleballScoringEngine().rallyWonBy(match, TeamSide.teamA),
        same(match));
    expect(const TennisScoringEngine().rallyWonBy(match, TeamSide.teamA),
        same(match));
  });

  test('repository skips malformed records and keeps valid matches', () async {
    final directory = await Directory.systemTemp.createTemp('puntos-hive-');
    final boxName = 'matches_${DateTime.now().microsecondsSinceEpoch}';
    Box<String>? box;

    try {
      Hive.init(directory.path);
      final openedBox = await Hive.openBox<String>(boxName);
      box = openedBox;
      final valid = Match.createDefault();
      await openedBox.put(valid.id, valid.encode());
      await openedBox.put('corrupt', '{not valid json');

      final repository = MatchRepository(openedBox);
      final active = await repository.readActive();

      expect(active.map((match) => match.id), contains(valid.id));
      expect(active, hasLength(1));
    } finally {
      if (box?.isOpen ?? false) await box!.close();
      await directory.delete(recursive: true);
    }
  });

  test('new doubles setup keeps receiver and partner on opposite court sides', () {
    final match = SetupController().buildMatch();
    final receiver = match.currentReceiver!;
    final receivingPlayers = receiver.team == TeamSide.teamA
        ? match.teamAPlayers
        : match.teamBPlayers;
    final partner = receivingPlayers.firstWhere((p) => p.id != receiver.id);

    expect(receiver.currentCourtSide, match.serviceCourtSide.opposite);
    expect(partner.currentCourtSide, match.serviceCourtSide);
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

  test('side-out singles uses the new server score for court position', () {
    final match = Match.createDefault().copyWith(
      sport: SportCatalog.pickleball,
      format: MatchFormat.singles,
      teamAPlayers: [
        Match.createDefault().teamAPlayers.first
            .copyWith(currentCourtSide: CourtSide.right),
      ],
      teamBPlayers: [
        Match.createDefault().teamBPlayers.first
            .copyWith(currentCourtSide: CourtSide.left),
      ],
      teamAScore: 0,
      teamBScore: 1,
      servingTeam: TeamSide.teamA,
      currentServerId: 'a1',
      currentReceiverId: 'b1',
      serviceCourtSide: CourtSide.right,
      rule: const MatchRule(
        pointsPerGame: 11,
        gamesPerMatch: 1,
        isSideOutScoring: true,
      ),
    );

    final result = const PickleballScoringEngine()
        .rallyWonBy(match, TeamSide.teamB);

    expect(result.teamBScore, 1);
    expect(result.servingTeam, TeamSide.teamB);
    expect(result.serviceCourtSide, CourtSide.left);
    expect(result.currentServerId, 'b1');
  });

  test('rally singles awards the point and transfers service', () {
    final initial = Match.createDefault();
    final match = initial.copyWith(
      sport: SportCatalog.pickleball,
      format: MatchFormat.singles,
      teamAPlayers: [initial.teamAPlayers.first],
      teamBPlayers: [initial.teamBPlayers.first],
      teamAScore: 0,
      teamBScore: 0,
      servingTeam: TeamSide.teamA,
      currentServerId: 'a1',
      currentReceiverId: 'b1',
      rule: const MatchRule(
        pointsPerGame: 11,
        gamesPerMatch: 1,
        isSideOutScoring: false,
      ),
    );

    final result = const PickleballScoringEngine()
        .rallyWonBy(match, TeamSide.teamB);

    expect(result.teamBScore, 1);
    expect(result.servingTeam, TeamSide.teamB);
    expect(result.serviceCourtSide, CourtSide.left);
    expect(result.currentServerId, 'b1');
    expect(result.currentReceiverId, 'a1');
  });

  test('rally doubles has no second server after a side-out', () {
    final initial = Match.createDefault();
    final match = initial.copyWith(
      sport: SportCatalog.pickleball,
      teamAPlayers: initial.teamAPlayers,
      teamBPlayers: initial.teamBPlayers,
      teamAScore: 0,
      teamBScore: 0,
      servingTeam: TeamSide.teamA,
      serverNumber: 1,
      currentServerId: 'a1',
      currentReceiverId: 'b1',
      serviceCourtSide: CourtSide.right,
      rule: const MatchRule(
        pointsPerGame: 11,
        gamesPerMatch: 1,
        isSideOutScoring: false,
      ),
    );

    final result = const PickleballScoringEngine()
        .rallyWonBy(match, TeamSide.teamB);

    expect(result.teamBScore, 1);
    expect(result.servingTeam, TeamSide.teamB);
    expect(result.serverNumber, 1);
    expect(result.serviceCourtSide, CourtSide.right);
    expect(result.currentServerId, 'b2');
  });

  test('new rally-scoring doubles setup starts with one server', () {
    final setup = SetupController();
    setup.setSport(SportCatalog.pickleball);
    setup.setSideOutScoring(false);

    final match = setup.buildMatch();

    expect(match.serverNumber, 1);
    expect(match.rule.isSideOutScoring, isFalse);
  });

  test('rally scoring cannot win a game while receiving', () {
    final initial = Match.createDefault();
    final match = initial.copyWith(
      sport: SportCatalog.pickleball,
      format: MatchFormat.singles,
      teamAPlayers: [initial.teamAPlayers.first],
      teamBPlayers: [initial.teamBPlayers.first],
      teamAScore: 10,
      teamBScore: 10,
      servingTeam: TeamSide.teamA,
      currentServerId: 'a1',
      currentReceiverId: 'b1',
      rule: const MatchRule(
        pointsPerGame: 11,
        gamesPerMatch: 1,
        isSideOutScoring: false,
      ),
    );

    final result = const PickleballScoringEngine()
        .rallyWonBy(match, TeamSide.teamB);

    expect(result.teamBScore, 11);
    expect(result.completed, isFalse);
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

  test('tennis service court follows the serving side score', () {
    final initial = Match.createDefault();
    final match = initial.copyWith(
      sport: SportCatalog.tennis,
      format: MatchFormat.singles,
      teamAPlayers: [initial.teamAPlayers.first],
      teamBPlayers: [initial.teamBPlayers.first],
      servingTeam: TeamSide.teamA,
      tennisGamePointsA: 0,
      tennisGamePointsB: 1,
      currentServerId: 'a1',
      currentReceiverId: 'b1',
      serviceCourtSide: CourtSide.left,
      rule: const MatchRule(pointsPerGame: 6, gamesPerMatch: 3),
    );

    final result = const TennisScoringEngine()
        .rallyWonBy(match, TeamSide.teamA);

    expect(result.tennisGamePointsA, 1);
    expect(result.tennisGamePointsB, 1);
    expect(result.serviceCourtSide, CourtSide.left);
  });

  test('tennis doubles rotates service through alternating teams', () {
    var match = Match.createDefault().copyWith(
      sport: SportCatalog.tennis,
      format: MatchFormat.doubles,
      rule: const MatchRule(
        pointsPerGame: 6,
        gamesPerMatch: 3,
        useAdvantage: false,
      ),
      currentServerId: 'a1',
      currentReceiverId: 'b1',
      servingTeam: TeamSide.teamA,
    );
    const engine = TennisScoringEngine();

    for (var i = 0; i < 4; i++) {
      match = engine.rallyWonBy(match, TeamSide.teamA);
    }
    expect(match.currentServerId, 'b1');

    for (var i = 0; i < 4; i++) {
      match = engine.rallyWonBy(match, TeamSide.teamB);
    }
    expect(match.currentServerId, 'a2');
  });

  test('badminton applies the standard 20-all and 29-all endings', () {
    final engine = const BadmintonScoringEngine();
    final base = Match.createDefault().copyWith(
      rule: const MatchRule(
        pointsPerGame: 21,
        gamesPerMatch: 3,
        winByTwo: true,
        maxPoints: 30,
      ),
    );

    final atTwentyAll = engine.rallyWonBy(
      base.copyWith(teamAScore: 20, teamBScore: 20), TeamSide.teamA);
    expect(atTwentyAll.teamAGames, 0);
    expect(atTwentyAll.teamAScore, 21);

    final atTwentyTwo = engine.rallyWonBy(
      atTwentyAll.copyWith(teamAScore: 21, teamBScore: 21), TeamSide.teamA);
    expect(atTwentyTwo.teamAGames, 0);
    expect(atTwentyTwo.teamAScore, 22);

    final atThirty = engine.rallyWonBy(
      base.copyWith(teamAScore: 29, teamBScore: 29), TeamSide.teamB);
    expect(atThirty.teamBGames, 1);
    expect(atThirty.teamBScore, 0);
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

  test('single-match workflow seeds only one active match', () {
    final controller = MatchController();

    expect(controller.activeMatches, hasLength(1));
  });

  test('ending a match removes it from live matches and keeps it in history', () {
    final controller = MatchController();
    final activeId = controller.activeMatches.first.id;

    controller.endMatch();

    expect(controller.activeMatches.any((match) => match.id == activeId),
        isFalse);
    expect(
        controller.completedMatches
            .where((match) => match.id == activeId)
            .single
            .completed,
        isTrue);
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
