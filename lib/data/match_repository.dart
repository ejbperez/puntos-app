import 'package:hive_ce/hive_ce.dart';

import '../models/match.dart';

class MatchRepository {
  const MatchRepository(this._box);

  final Box<String> _box;

  Future<void> save(Match match) => _box.put(match.id, match.encode());

  Future<void> delete(String matchId) => _box.delete(matchId);

  Future<void> deleteAll(Iterable<String> matchIds) =>
      _box.deleteAll(matchIds);

  Future<List<Match>> readActive() async {
    return _box.values
        .map(Match.decode)
        .where((match) => !match.completed)
        .toList();
  }

  Future<List<Match>> readHistory() async {
    return _box.values
        .map(Match.decode)
        .where((match) => match.completed)
        .toList();
  }
}
