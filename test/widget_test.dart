import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puntos_app/app.dart';
import 'package:puntos_app/models/match.dart';
import 'package:puntos_app/models/player.dart';
import 'package:puntos_app/scoring/badminton_scoring_engine.dart';

void main() {
  group('ScoringEngine Unit Tests', () {
    test('Badminton server continues and swaps courts on point won', () {
      final initial = Match.createDefault();
      expect(initial.teamAScore, 18);
      expect(initial.isTeamAServing, true);

      // Team A scores point 19 (odd score)
      final engine = const BadmintonScoringEngine();
      final afterPoint = engine.rallyWonBy(initial, TeamSide.teamA);
      expect(afterPoint.teamAScore, 19);
      expect(afterPoint.isTeamAServing, true);
      expect(afterPoint.currentServerId, initial.currentServerId);
      expect(afterPoint.serviceCourtSide, CourtSide.left);

      // Test undo
      final undone = engine.undo(afterPoint);
      expect(undone.teamAScore, 18);
      expect(undone.serviceCourtSide, CourtSide.right);
    });

    test('Badminton side-out transfers serve to receiving team', () {
      final initial = Match.createDefault();
      expect(initial.isTeamAServing, true);

      // Team B wins rally -> side-out, Team B score becomes 17
      final afterSideOut =
          const BadmintonScoringEngine().rallyWonBy(initial, TeamSide.teamB);
      expect(afterSideOut.teamBScore, 17);
      expect(afterSideOut.isTeamBServing, true);
      // 17 is odd -> serve from left court
      expect(afterSideOut.serviceCourtSide, CourtSide.left);
    });

    test('Match persistence preserves scoring history and player positions',
        () {
      final initial = Match.createDefault();
      final scored =
          const BadmintonScoringEngine().rallyWonBy(initial, TeamSide.teamA);
      final restored = Match.decode(scored.encode());

      expect(restored.teamAScore, scored.teamAScore);
      expect(restored.currentServerId, scored.currentServerId);
      expect(restored.serviceCourtSide, scored.serviceCourtSide);
      expect(restored.history, hasLength(1));
      expect(restored.history.single.teamAPlayers.first.currentCourtSide,
          initial.teamAPlayers.first.currentCourtSide);
    });

    test('Completed matches reject further scoring', () {
      var match = Match.createDefault().copyWith(
        teamAScore: 20,
        teamBScore: 18,
        teamAGames: 1,
      );
      final engine = const BadmintonScoringEngine();
      match = engine.rallyWonBy(match, TeamSide.teamA);
      match = engine.rallyWonBy(match, TeamSide.teamA);
      match = engine.rallyWonBy(match, TeamSide.teamA);

      expect(match.completed, isTrue);
      expect(engine.rallyWonBy(match, TeamSide.teamB), same(match));
    });
  });

  group('Puntos App Widget Tests', () {
    testWidgets(
        'App smoke test: loads Home Screen and navigates to Match Setup',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const PuntosApp());
      await tester.pumpAndSettle();

      // Verify Home Screen elements
      expect(find.text('Puntos App'), findsOneWidget);
      expect(find.text('Score • Play • Enjoy'), findsOneWidget);
      expect(find.text('Select Sport'), findsOneWidget);
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('New Match'), findsOneWidget);

      // Tap "New Match" to navigate to Match Setup
      await tester.tap(find.text('New Match'));
      await tester.pumpAndSettle();

      // Verify Match Setup screen elements
      expect(find.text('Match Setup'), findsOneWidget);
      expect(find.text('Sport & Format'), findsOneWidget);
      expect(find.text('Start Match'), findsOneWidget);

      // Scroll to "Start Match" button and tap
      await tester.ensureVisible(find.text('Start Match'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start Match'));
      await tester.pumpAndSettle();

      // Verify Live Scoreboard screen loaded
      expect(find.text('Live Scoreboard'), findsOneWidget);
      expect(find.text('Team A'), findsWidgets);
      expect(find.text('Team B'), findsWidgets);
      expect(find.text('Current Server'), findsOneWidget);
      expect(find.text('End Match'), findsOneWidget);

      // Verify scoring interaction: tap Team A '+' button
      final addButtons = find.byIcon(Icons.add);
      expect(addButtons, findsWidgets);
      await tester.tap(addButtons.first);
      await tester.pumpAndSettle();

      // Tap Undo button
      final undoButton = find.byIcon(Icons.undo_rounded);
      expect(undoButton, findsOneWidget);
      await tester.tap(undoButton);
      await tester.pumpAndSettle();

      // Go back to Home
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      // Verify bottom nav tab switching
      expect(find.text('Courts'), findsWidgets);
      await tester.tap(find.text('Courts').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Settings').first);
      await tester.pumpAndSettle();
      expect(find.text('Game Settings'), findsOneWidget);
    });
  });
}
