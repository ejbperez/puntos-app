import '../models/match.dart';
import '../models/player.dart';

abstract class ScoringEngine {
  const ScoringEngine();

  /// Calculates the new match state when [winner] wins the rally.
  Match rallyWonBy(Match match, TeamSide winner);

  /// Decrements one point or reverts the latest score increment if possible.
  Match decrementPoint(Match match, TeamSide team);

  /// Reverts the match to the previous state snapshot.
  Match undo(Match match);
}
