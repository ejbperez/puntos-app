enum TeamSide { teamA, teamB }

enum CourtSide { left, right }

extension CourtSidePosition on CourtSide {
  CourtSide get opposite => this == CourtSide.right
      ? CourtSide.left
      : CourtSide.right;
}

class Player {
  const Player({
    required this.id,
    required this.name,
    required this.team,
    required this.slot,
    this.currentCourtSide = CourtSide.right,
    this.isServer = false,
  });

  final String id;
  final String name;
  final TeamSide team;
  final int slot; // 1, 2, 3, etc.
  final CourtSide currentCourtSide;
  final bool isServer;

  String get label => '${team == TeamSide.teamA ? "A" : "B"}$slot';

  Player copyWith({
    String? id,
    String? name,
    TeamSide? team,
    int? slot,
    CourtSide? currentCourtSide,
    bool? isServer,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      team: team ?? this.team,
      slot: slot ?? this.slot,
      currentCourtSide: currentCourtSide ?? this.currentCourtSide,
      isServer: isServer ?? this.isServer,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'team': team.name,
        'slot': slot,
        'currentCourtSide': currentCourtSide.name,
        'isServer': isServer,
      };

  factory Player.fromMap(Map<String, dynamic> map) => Player(
        id: map['id'] as String,
        name: map['name'] as String,
        team: TeamSide.values.byName(map['team'] as String),
        slot: map['slot'] as int,
        currentCourtSide: CourtSide.values
            .byName(map['currentCourtSide'] as String? ?? 'right'),
        isServer: map['isServer'] as bool? ?? false,
      );
}
