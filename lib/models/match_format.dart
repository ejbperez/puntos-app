enum MatchFormatType {
  singles,
  doubles,
  mixedDoubles,
  custom,
}

class MatchFormat {
  const MatchFormat({
    required this.type,
    required this.label,
    required this.subtitle,
    required this.playersPerTeam,
  });

  final MatchFormatType type;
  final String label;
  final String subtitle;
  final int playersPerTeam;

  static const singles = MatchFormat(
    type: MatchFormatType.singles,
    label: 'Singles',
    subtitle: '1 vs 1',
    playersPerTeam: 1,
  );

  static const doubles = MatchFormat(
    type: MatchFormatType.doubles,
    label: 'Doubles',
    subtitle: '2 vs 2',
    playersPerTeam: 2,
  );

  static const mixedDoubles = MatchFormat(
    type: MatchFormatType.mixedDoubles,
    label: 'Mixed Doubles',
    subtitle: '2 vs 2',
    playersPerTeam: 2,
  );

  static const custom = MatchFormat(
    type: MatchFormatType.custom,
    label: 'Custom',
    subtitle: 'Configurable',
    playersPerTeam: 2,
  );

  static const standardFormats = [singles, doubles, mixedDoubles, custom];
}
