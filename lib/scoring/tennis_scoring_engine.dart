import '../models/match.dart';
import '../models/player.dart';
import 'scoring_engine.dart';

class TennisScoringEngine implements ScoringEngine {
  const TennisScoringEngine();

  @override
  Match rallyWonBy(Match match, TeamSide winner) {
    if (match.completed) return match;
    final history = [...match.history, match.toSnapshot()];
    if (match.inTiebreak) return _tiebreakPoint(match, winner, history);

    final pointsA = match.tennisGamePointsA + (winner == TeamSide.teamA ? 1 : 0);
    final pointsB = match.tennisGamePointsB + (winner == TeamSide.teamB ? 1 : 0);
    final wonPoints = winner == TeamSide.teamA ? pointsA : pointsB;
    final lostPoints = winner == TeamSide.teamA ? pointsB : pointsA;
    final gameWon = match.rule.useAdvantage
        ? wonPoints >= 4 && wonPoints - lostPoints >= 2
        : wonPoints >= 4;
    if (!gameWon) {
      final total = pointsA + pointsB;
      var playersA = match.teamAPlayers;
      var playersB = match.teamBPlayers;
      if (match.format.playersPerTeam == 1) {
        final positions = _positionSingles(
            playersA, playersB, match.servingTeam,
            total.isEven ? CourtSide.right : CourtSide.left);
        playersA = positions.$1;
        playersB = positions.$2;
      }
      return match.copyWith(
        tennisGamePointsA: pointsA,
        tennisGamePointsB: pointsB,
        serviceCourtSide: total.isEven ? CourtSide.right : CourtSide.left,
        teamAPlayers: playersA,
        teamBPlayers: playersB,
        history: history,
      );
    }

    final gamesA = match.teamAGames + (winner == TeamSide.teamA ? 1 : 0);
    final gamesB = match.teamBGames + (winner == TeamSide.teamB ? 1 : 0);
    final target = match.rule.pointsPerGame;
    final atTiebreak = gamesA == match.rule.tiebreakAt &&
        gamesB == match.rule.tiebreakAt;
    if (atTiebreak) {
      final next = _nextServer(match);
      final positions = _positionSingles(next.teamAPlayers, next.teamBPlayers,
          next.team, CourtSide.right);
      return match.copyWith(
        teamAGames: gamesA,
        teamBGames: gamesB,
        tennisGamePointsA: 0,
        tennisGamePointsB: 0,
        inTiebreak: true,
        servingTeam: next.team,
        currentServerId: next.serverId,
        currentReceiverId: next.receiverId,
        serviceRotationIndex: next.index,
        serviceCourtSide: CourtSide.right,
        teamAPlayers: positions.$1,
        teamBPlayers: positions.$2,
        history: history,
      );
    }

    final setWon = gamesA >= target && gamesA - gamesB >= 2;
    if (setWon) {
      return _finishSet(match, winner, gamesA, gamesB, history);
    }

    final next = _nextServer(match);
    final positions = _positionSingles(
        next.teamAPlayers, next.teamBPlayers, next.team, CourtSide.right);
    return match.copyWith(
      teamAGames: gamesA,
      teamBGames: gamesB,
      tennisGamePointsA: 0,
      tennisGamePointsB: 0,
      servingTeam: next.team,
      currentServerId: next.serverId,
      currentReceiverId: next.receiverId,
      serviceRotationIndex: next.index,
      serviceCourtSide: CourtSide.right,
      teamAPlayers: positions.$1,
      teamBPlayers: positions.$2,
      history: history,
    );
  }

  Match _tiebreakPoint(Match match, TeamSide winner, List<MatchSnapshot> history) {
    final pointsA = match.tennisGamePointsA + (winner == TeamSide.teamA ? 1 : 0);
    final pointsB = match.tennisGamePointsB + (winner == TeamSide.teamB ? 1 : 0);
    final won = winner == TeamSide.teamA ? pointsA : pointsB;
    final lost = winner == TeamSide.teamA ? pointsB : pointsA;
    if (won >= 7 && won - lost >= 2) {
      final gamesA = winner == TeamSide.teamA ? 7 : 6;
      final gamesB = winner == TeamSide.teamB ? 7 : 6;
      return _finishSet(match, winner, gamesA, gamesB, history,
          tiebreakScore: '$pointsA-$pointsB');
    }
    final total = pointsA + pointsB;
    var index = match.serviceRotationIndex;
    if (total.isOdd) index = _nextIndex(match, index);
    final next = _serverAt(match, index);
    final serviceCourt = total.isEven ? CourtSide.right : CourtSide.left;
    final positions = _positionSingles(
        next.teamAPlayers, next.teamBPlayers, next.team, serviceCourt);
    return match.copyWith(
      tennisGamePointsA: pointsA,
      tennisGamePointsB: pointsB,
      servingTeam: next.team,
      currentServerId: next.serverId,
      currentReceiverId: next.receiverId,
      serviceRotationIndex: index,
      serviceCourtSide: serviceCourt,
      teamAPlayers: positions.$1,
      teamBPlayers: positions.$2,
      history: history,
    );
  }

  Match _finishSet(Match match, TeamSide winner, int gamesA, int gamesB,
      List<MatchSnapshot> history, {String? tiebreakScore}) {
    final summary = tiebreakScore == null
        ? '$gamesA-$gamesB'
        : '$gamesA-$gamesB ($tiebreakScore)';
    final setHistory = [...match.setHistory, summary];
    final setsA = match.teamAScore + (winner == TeamSide.teamA ? 1 : 0);
    final setsB = match.teamBScore + (winner == TeamSide.teamB ? 1 : 0);
    final needed = (match.rule.gamesPerMatch / 2).ceil();
    if (setsA >= needed || setsB >= needed) {
      return match.copyWith(
        teamAScore: setsA,
        teamBScore: setsB,
        teamAGames: gamesA,
        teamBGames: gamesB,
        tennisGamePointsA: 0,
        tennisGamePointsB: 0,
        inTiebreak: false,
        completed: true,
        winner: winner,
        finishedAt: DateTime.now(),
        setHistory: setHistory,
        history: history,
      );
    }
    final next = _nextServer(match);
    final positions = _positionSingles(
        next.teamAPlayers, next.teamBPlayers, next.team, CourtSide.right);
    return match.copyWith(
      teamAScore: setsA,
      teamBScore: setsB,
      teamAGames: 0,
      teamBGames: 0,
      currentGame: match.currentGame + 1,
      tennisGamePointsA: 0,
      tennisGamePointsB: 0,
      inTiebreak: false,
      setHistory: setHistory,
      servingTeam: next.team,
      currentServerId: next.serverId,
      currentReceiverId: next.receiverId,
      serviceRotationIndex: next.index,
      serviceCourtSide: CourtSide.right,
      teamAPlayers: positions.$1,
      teamBPlayers: positions.$2,
      clearWinner: true,
      clearFinishedAt: true,
      history: history,
    );
  }

  _ServerData _nextServer(Match match) =>
      _serverAt(match, _nextIndex(match, match.serviceRotationIndex));

  int _nextIndex(Match match, int current) {
    final players = _activePlayers(match);
    if (players.isEmpty) return 0;
    if (match.format.playersPerTeam == 1) {
      return (current + 1) % players.length;
    }
    return (current + 1) % players.length;
  }

  _ServerData _serverAt(Match match, int index) {
    final players = _activePlayers(match);
    final server = players[index % players.length];
    final receiving = server.team == TeamSide.teamA
        ? match.teamBPlayers
        : match.teamAPlayers;
    final receiver = receiving.first;
    final a = match.teamAPlayers
        .map((p) => p.copyWith(isServer: p.id == server.id))
        .toList();
    final b = match.teamBPlayers
        .map((p) => p.copyWith(isServer: p.id == server.id))
        .toList();
    return _ServerData(server.team, server.id, receiver.id, index, a, b);
  }

  (List<Player>, List<Player>) _positionSingles(
      List<Player> playersA,
      List<Player> playersB,
      TeamSide servingTeam,
      CourtSide serviceCourt) {
    if (playersA.length != 1 || playersB.length != 1) {
      return (playersA, playersB);
    }
    final receiverCourt = serviceCourt == CourtSide.right
        ? CourtSide.left
        : CourtSide.right;
    return servingTeam == TeamSide.teamA
        ? (
            playersA.map((p) => p.copyWith(currentCourtSide: serviceCourt)).toList(),
            playersB.map((p) => p.copyWith(currentCourtSide: receiverCourt)).toList(),
          )
        : (
            playersA.map((p) => p.copyWith(currentCourtSide: receiverCourt)).toList(),
            playersB.map((p) => p.copyWith(currentCourtSide: serviceCourt)).toList(),
          );
  }

  List<Player> _activePlayers(Match match) => [
        ...match.teamAPlayers.take(match.format.playersPerTeam),
        ...match.teamBPlayers.take(match.format.playersPerTeam),
      ];

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
}

class _ServerData {
  const _ServerData(this.team, this.serverId, this.receiverId, this.index,
      this.teamAPlayers, this.teamBPlayers);
  final TeamSide team;
  final String serverId;
  final String receiverId;
  final int index;
  final List<Player> teamAPlayers;
  final List<Player> teamBPlayers;
}
