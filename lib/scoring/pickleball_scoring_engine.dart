import '../models/match.dart';
import '../models/player.dart';
import 'scoring_engine.dart';

class PickleballScoringEngine implements ScoringEngine {
  const PickleballScoringEngine();

  @override
  Match rallyWonBy(Match match, TeamSide winner) {
    if (match.completed ||
        match.teamAPlayers.isEmpty ||
        match.teamBPlayers.isEmpty) {
      return match;
    }
    final history = [...match.history, match.toSnapshot()];
    final sideOut = match.rule.isSideOutScoring;
    final doubles = match.format.playersPerTeam == 2;
    final servingWon = match.servingTeam == winner;
    final scores = [match.teamAScore, match.teamBScore];
    final earnsPoint = !sideOut || servingWon;
    if (earnsPoint) scores[winner == TeamSide.teamA ? 0 : 1]++;

    final winnerScore = winner == TeamSide.teamA ? scores[0] : scores[1];
    final loserScore = winner == TeamSide.teamA ? scores[1] : scores[0];
    final gameWon = winnerScore >= match.rule.pointsPerGame &&
        (!match.rule.winByTwo || winnerScore - loserScore >= 2) &&
        (sideOut || servingWon);
    if (gameWon) {
      final gamesA = match.teamAGames + (winner == TeamSide.teamA ? 1 : 0);
      final gamesB = match.teamBGames + (winner == TeamSide.teamB ? 1 : 0);
      final needed = (match.rule.gamesPerMatch / 2).ceil();
      if (gamesA >= needed || gamesB >= needed) {
        return match.copyWith(
          teamAScore: scores[0],
          teamBScore: scores[1],
          teamAGames: gamesA,
          teamBGames: gamesB,
          completed: true,
          winner: winner,
          finishedAt: DateTime.now(),
          history: history,
        );
      }
      return _startGame(match, winner, gamesA, gamesB, history);
    }

    var playersA = [...match.teamAPlayers];
    var playersB = [...match.teamBPlayers];
    var servingTeam = match.servingTeam;
    var serverNumber = match.serverNumber;
    var serviceCourt = match.serviceCourtSide;
    var serverId = match.currentServerId;
    var receiverId = match.currentReceiverId;

    if (servingWon) {
      // A serving win keeps service. In doubles, the partners exchange
      // courts while the same player remains the server.
      if (doubles) {
        if (servingTeam == TeamSide.teamA) {
          playersA = _swap(playersA);
        } else {
          playersB = _swap(playersB);
        }
      }
      final servingScore = servingTeam == TeamSide.teamA ? scores[0] : scores[1];
      serviceCourt = servingScore.isEven
          ? CourtSide.right
          : CourtSide.left;
      final serving = servingTeam == TeamSide.teamA ? playersA : playersB;
      final receiving = servingTeam == TeamSide.teamA ? playersB : playersA;
      final server = serving.firstWhere((p) => p.id == serverId,
          orElse: () => serving.firstWhere(
              (p) => p.currentCourtSide == serviceCourt,
              orElse: () => serving.first));
      final receiver = _receiverFor(receiving, serviceCourt.opposite);
      serverId = server.id;
      receiverId = receiver.id;
    } else if (sideOut && doubles && serverNumber == 1) {
      // Traditional doubles gives the partner the second service opportunity.
      serverNumber = 2;
      final serving = servingTeam == TeamSide.teamA ? playersA : playersB;
      final receiving = servingTeam == TeamSide.teamA ? playersB : playersA;
      final server = serving.firstWhere((p) => p.id != serverId,
          orElse: () => serving.first);
      serverId = server.id;
      receiverId = receiving.firstWhere(
          (p) => p.currentCourtSide == server.currentCourtSide.opposite,
          orElse: () => receiving.first).id;
      serviceCourt = server.currentCourtSide;
    } else {
      // A side-out transfers service. Rally-scoring doubles has no second
      // server, while traditional doubles reaches this branch after server 2.
      servingTeam = winner;
      serverNumber = 1;

      if (doubles && !sideOut) {
        // In rally-scoring doubles, the new serving team changes positions
        // after every side-out, then serves from the right court.
        if (servingTeam == TeamSide.teamA) {
          playersA = _swap(playersA);
        } else {
          playersB = _swap(playersB);
        }
        serviceCourt = CourtSide.right;
      } else if (doubles) {
        // Traditional doubles always starts a new service turn from right.
        serviceCourt = CourtSide.right;
      } else {
        // Singles uses the new server's score to select the service court.
        final servingScore = servingTeam == TeamSide.teamA ? scores[0] : scores[1];
        serviceCourt = servingScore.isEven ? CourtSide.right : CourtSide.left;
      }

      final serving = servingTeam == TeamSide.teamA ? playersA : playersB;
      final receiving = servingTeam == TeamSide.teamA ? playersB : playersA;
      final server = serving.firstWhere(
        (p) => p.currentCourtSide == serviceCourt,
        orElse: () => serving.first);
      final receiver = _receiverFor(receiving, serviceCourt.opposite);
      serverId = server.id;
      receiverId = receiver.id;
    }

    if (match.format.playersPerTeam == 1) {
      final receiverCourt = serviceCourt == CourtSide.right
          ? CourtSide.left
          : CourtSide.right;
      if (servingTeam == TeamSide.teamA) {
        playersA = _setSingleSide(playersA, serviceCourt);
        playersB = _setSingleSide(playersB, receiverCourt);
      } else {
        playersA = _setSingleSide(playersA, receiverCourt);
        playersB = _setSingleSide(playersB, serviceCourt);
      }
    }
    playersA = _markServer(playersA, serverId);
    playersB = _markServer(playersB, serverId);
    return match.copyWith(
      teamAScore: scores[0],
      teamBScore: scores[1],
      servingTeam: servingTeam,
      serverNumber: serverNumber,
      currentServerId: serverId,
      currentReceiverId: receiverId,
      serviceCourtSide: serviceCourt,
      teamAPlayers: playersA,
      teamBPlayers: playersB,
      history: history,
    );
  }

  Match _startGame(Match match, TeamSide winner, int gamesA, int gamesB,
      List<MatchSnapshot> history) {
    var nextPlayersA = [...match.teamAPlayers];
    var nextPlayersB = [...match.teamBPlayers];
    final doubles = match.format.playersPerTeam == 2;
    final serviceCourt = CourtSide.right;

    if (doubles) {
      final serving = winner == TeamSide.teamA ? nextPlayersA : nextPlayersB;
      final receiverPlayers =
          winner == TeamSide.teamA ? nextPlayersB : nextPlayersA;
      final server = serving.firstWhere(
        (p) => p.currentCourtSide == serviceCourt,
        orElse: () => serving.first);
      final receiver = _receiverFor(receiverPlayers, serviceCourt.opposite);

      return match.copyWith(
        teamAScore: 0,
        teamBScore: 0,
        currentGame: match.currentGame + 1,
        teamAGames: gamesA,
        teamBGames: gamesB,
        servingTeam: winner,
        serverNumber: match.rule.isSideOutScoring ? 2 : 1,
        currentServerId: server.id,
        currentReceiverId: receiver.id,
        serviceCourtSide: serviceCourt,
        teamAPlayers: _markServer(nextPlayersA, server.id),
        teamBPlayers: _markServer(nextPlayersB, server.id),
        history: history,
      );
    }

    nextPlayersA = _setSingleSide(nextPlayersA, winner == TeamSide.teamA
        ? CourtSide.right
        : CourtSide.left);
    nextPlayersB = _setSingleSide(nextPlayersB, winner == TeamSide.teamB
        ? CourtSide.right
        : CourtSide.left);
    final serving = winner == TeamSide.teamA ? nextPlayersA : nextPlayersB;
    final receiving = winner == TeamSide.teamA ? nextPlayersB : nextPlayersA;
    final server = serving.first;
    final receiver = receiving.first;
    return match.copyWith(
      teamAScore: 0,
      teamBScore: 0,
      currentGame: match.currentGame + 1,
      teamAGames: gamesA,
      teamBGames: gamesB,
      servingTeam: winner,
      serverNumber: 1,
      currentServerId: server.id,
      currentReceiverId: receiver.id,
      serviceCourtSide: serviceCourt,
      teamAPlayers: _markServer(nextPlayersA, server.id),
      teamBPlayers: _markServer(nextPlayersB, server.id),
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

  static List<Player> _swap(List<Player> players) => players
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

  static Player _receiverFor(List<Player> players, CourtSide side) =>
      players.firstWhere(
        (p) => p.currentCourtSide == side,
        orElse: () => players.first,
      );

}
