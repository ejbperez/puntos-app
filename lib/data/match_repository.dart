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
    return (await _readMatches())
        .where((match) => !match.completed)
        .toList();
  }

  Future<List<Match>> readHistory() async {
    return (await _readMatches()).where((match) => match.completed).toList();
  }

  Future<List<Match>> _readMatches() async {
    final matches = <Match>[];
    for (final encoded in _box.values) {
      try {
        matches.add(Match.decode(encoded));
      } on Object {
        // A single corrupt record must not hide all other saved matches.
      }
    }
    return matches;
  }
}
