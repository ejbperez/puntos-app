import '../models/match.dart';
import '../models/player.dart';
import 'scoring_engine.dart';

class BadmintonScoringEngine implements ScoringEngine {
  const BadmintonScoringEngine();

  @override
  Match rallyWonBy(Match match, TeamSide winner) {
    if (match.completed) return match;
    final history = [...match.history, match.toSnapshot()];
    final scoreA = match.teamAScore + (winner == TeamSide.teamA ? 1 : 0);
    final scoreB = match.teamBScore + (winner == TeamSide.teamB ? 1 : 0);
    final winning = winner == TeamSide.teamA ? scoreA : scoreB;
    final losing = winner == TeamSide.teamA ? scoreB : scoreA;
    final gameWon = winning >= match.rule.maxPoints ||
        (winning >= match.rule.pointsPerGame &&
            (!match.rule.winByTwo || winning - losing >= 2));

    if (gameWon) {
      final gamesA = match.teamAGames + (winner == TeamSide.teamA ? 1 : 0);
      final gamesB = match.teamBGames + (winner == TeamSide.teamB ? 1 : 0);
      final needed = (match.rule.gamesPerMatch / 2).ceil();
      if (gamesA >= needed || gamesB >= needed) {
        return match.copyWith(
          teamAScore: scoreA,
          teamBScore: scoreB,
          teamAGames: gamesA,
          teamBGames: gamesB,
          completed: true,
          winner: winner,
          finishedAt: DateTime.now(),
          history: history,
        );
      }
      final serving = winner == TeamSide.teamA
          ? match.teamAPlayers
          : match.teamBPlayers;
      final receiving = winner == TeamSide.teamA
          ? match.teamBPlayers
          : match.teamAPlayers;
      final serverId = serving.first.id;
      final receiverId = receiving.first.id;
      var nextPlayersA = winner == TeamSide.teamA
          ? _markServer(serving, serverId)
          : match.teamAPlayers;
      var nextPlayersB = winner == TeamSide.teamB
          ? _markServer(serving, serverId)
          : match.teamBPlayers;
      if (match.format.playersPerTeam == 1) {
        nextPlayersA = _setSingleSide(
            nextPlayersA, winner == TeamSide.teamA ? CourtSide.right : CourtSide.left);
        nextPlayersB = _setSingleSide(
            nextPlayersB, winner == TeamSide.teamB ? CourtSide.right : CourtSide.left);
      }
      return match.copyWith(
        teamAScore: 0,
        teamBScore: 0,
        currentGame: match.currentGame + 1,
        teamAGames: gamesA,
        teamBGames: gamesB,
        servingTeam: winner,
        currentServerId: serverId,
        currentReceiverId: receiverId,
        serviceCourtSide: CourtSide.right,
        teamAPlayers: nextPlayersA,
        teamBPlayers: nextPlayersB,
        completed: false,
        clearWinner: true,
        clearFinishedAt: true,
        history: history,
      );
    }

    var playersA = [...match.teamAPlayers];
    var playersB = [...match.teamBPlayers];
    final court = winning.isEven ? CourtSide.right : CourtSide.left;
    final servingTeamWon = match.servingTeam == winner;
    if (servingTeamWon && match.format.playersPerTeam == 2) {
      if (winner == TeamSide.teamA) {
        playersA = _swapCourtSides(playersA);
      } else {
        playersB = _swapCourtSides(playersB);
      }
    }

    final servingPlayers = winner == TeamSide.teamA ? playersA : playersB;
    final receivingPlayers = winner == TeamSide.teamA ? playersB : playersA;
    final server = match.format.playersPerTeam == 1
        ? servingPlayers.first
        : servingPlayers.firstWhere(
            (p) => p.currentCourtSide == court,
            orElse: () => servingPlayers.first,
          );
    final receiver = match.format.playersPerTeam == 1
        ? receivingPlayers.first
        : receivingPlayers.firstWhere(
            (p) => p.currentCourtSide == court,
            orElse: () => receivingPlayers.first,
          );
    if (match.format.playersPerTeam == 1) {
      final receiverCourt = court == CourtSide.right
          ? CourtSide.left
          : CourtSide.right;
      if (winner == TeamSide.teamA) {
        playersA = _setSingleSide(playersA, court);
        playersB = _setSingleSide(playersB, receiverCourt);
      } else {
        playersA = _setSingleSide(playersA, receiverCourt);
        playersB = _setSingleSide(playersB, court);
      }
    }
    playersA = _markServer(playersA, server.id);
    playersB = _markServer(playersB, server.id);
    return match.copyWith(
      teamAScore: scoreA,
      teamBScore: scoreB,
      servingTeam: winner,
      currentServerId: server.id,
      currentReceiverId: receiver.id,
      serviceCourtSide: court,
      teamAPlayers: playersA,
      teamBPlayers: playersB,
      history: history,
    );
  }

  @override
  Match decrementPoint(Match match, TeamSide team) => undo(match);

  @override
  Match undo(Match match) {
    if (match.history.isEmpty) return match;
    final previous = match.history.last;
    return match.copyWith(
      teamAPlayers: previous.teamAPlayers,
      teamBPlayers: previous.teamBPlayers,
      teamAName: previous.teamAName,
      teamBName: previous.teamBName,
      teamAScore: previous.teamAScore,
      teamBScore: previous.teamBScore,
      currentGame: previous.currentGame,
      teamAGames: previous.teamAGames,
      teamBGames: previous.teamBGames,
      servingTeam: previous.servingTeam,
      currentServerId: previous.currentServerId,
      currentReceiverId: previous.currentReceiverId,
      serviceCourtSide: previous.serviceCourtSide,
      completed: previous.completed,
      finishedAt: previous.finishedAt,
      clearFinishedAt: previous.finishedAt == null,
      winner: previous.winner,
      clearWinner: previous.winner == null,
      isManuallyEnded: previous.isManuallyEnded,
      serverNumber: previous.serverNumber,
      serviceRotationIndex: previous.serviceRotationIndex,
      tennisGamePointsA: previous.tennisGamePointsA,
      tennisGamePointsB: previous.tennisGamePointsB,
      inTiebreak: previous.inTiebreak,
      setHistory: previous.setHistory,
      history: match.history.sublist(0, match.history.length - 1),
    );
  }

  static List<Player> _swapCourtSides(List<Player> players) => players
      .map((p) => p.copyWith(
          currentCourtSide: p.currentCourtSide == CourtSide.right
              ? CourtSide.left
              : CourtSide.right))
      .toList();

  static List<Player> _markServer(List<Player> players, String id) => players
      .map((p) => p.copyWith(isServer: p.id == id))
      .toList();

  static List<Player> _setSingleSide(List<Player> players, CourtSide side) =>
      players.map((p) => p.copyWith(currentCourtSide: side)).toList();
}
