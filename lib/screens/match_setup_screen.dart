import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/sport.dart';
import '../state/match_controller.dart';
import '../state/setup_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/match_setting_tile.dart';
import '../widgets/player_row.dart';
import '../widgets/sport_card.dart';
import 'live_scoreboard_screen.dart';

class MatchSetupScreen extends StatefulWidget {
  const MatchSetupScreen({
    super.key,
    required this.controller,
    this.initialSport,
  });

  final MatchController controller;
  final SportDefinition? initialSport;

  @override
  State<MatchSetupScreen> createState() => _MatchSetupScreenState();
}

class _MatchSetupScreenState extends State<MatchSetupScreen> {
  late final SetupController _setup;
  bool _isStarting = false;

  @override
  void initState() {
    super.initState();
    _setup = SetupController();
    if (widget.initialSport != null) {
      _setup.setSport(widget.initialSport!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _setup,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.lightBackground,
          appBar: _buildAppBar(context),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress step indicator (1 Sport & Format, 2 Players, 3 Rules, 4 Review)
                  _buildProgressIndicator(),
                  const SizedBox(height: 20),

                  // Sport Selection
                  _buildSectionLabel('Sport'),
                  const SizedBox(height: 10),
                  _buildSportSelector(),
                  const SizedBox(height: 20),

                  // Match Format
                  _buildSectionLabel('Match Format'),
                  const SizedBox(height: 10),
                  _buildFormatSelector(),
                  const SizedBox(height: 22),

                  // Players & Teams
                  _buildSectionLabel('Players & Teams'),
                  const SizedBox(height: 10),
                  _buildPlayersSection(context),
                  const SizedBox(height: 22),

                  // Match Settings
                  _buildSectionLabel('Match Settings'),
                  const SizedBox(height: 10),
                  _buildMatchSettings(context),
                  const SizedBox(height: 24),

                  // Start Match CTA Button
                  _buildStartMatchButton(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.lightBackground,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new,
            color: AppColors.textPrimaryDark, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Match Setup',
        style: TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon:
              const Icon(Icons.save_outlined, color: AppColors.textPrimaryDark),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Setup template saved.')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    final steps = ['Sport & Format', 'Players', 'Rules', 'Review'];

    return Row(
      children: List.generate(steps.length, (index) {
        final stepNumber = index + 1;
        final isActive = _setup.currentStep == stepNumber;
        final isCompleted = _setup.currentStep > stepNumber;

        return Expanded(
          child: InkWell(
            onTap: () => _setup.setStep(stepNumber),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primaryBrown
                              : (isCompleted
                                  ? AppColors.pickleballGreen
                                  : Colors.transparent),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isActive || isCompleted
                                ? Colors.transparent
                                : AppColors.cardLightBorder,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(Icons.check,
                                  size: 13, color: Colors.white)
                              : Text(
                                  '$stepNumber',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isActive
                                        ? Colors.white
                                        : AppColors.textSecondaryDark,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        steps[index],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w500,
                          color: isActive
                              ? AppColors.textPrimaryDark
                              : AppColors.textMutedDark,
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < steps.length - 1)
                  Container(
                    width: 12,
                    height: 1,
                    color: isCompleted
                        ? AppColors.primaryBrown
                        : AppColors.cardLightBorder,
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimaryDark,
      ),
    );
  }

  Widget _buildSportSelector() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - (3 * 8)) / 4;
        return Row(
          children: SportCatalog.supported.map((sport) {
            final isSelected = _setup.sport.id == sport.id;
            return Container(
              width: cardWidth,
              margin: EdgeInsets.only(
                right: sport.id == SportCatalog.supported.last.id ? 0 : 8,
              ),
              child: SportCard(
                sport: sport,
                isSelected: isSelected,
                compact: true,
                onTap: () => _setup.setSport(sport),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildFormatSelector() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final formats = _setup.sport.supportedFormats;
        final itemWidth = (constraints.maxWidth - ((formats.length - 1) * 8)) /
            formats.length;
        return Row(
          children: formats.asMap().entries.map((entry) {
            final format = entry.value;
            final isSelected = _setup.format.type == format.type;

            return Container(
              width: itemWidth,
              margin: EdgeInsets.only(
                right: entry.key == formats.length - 1 ? 0 : 8,
              ),
              child: InkWell(
                onTap: () => _setup.setFormat(format),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryBrown.withValues(alpha: 0.08)
                        : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryBrown
                          : AppColors.cardLightBorder,
                      width: isSelected ? 1.8 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        format.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected
                              ? AppColors.primaryBrown
                              : AppColors.textPrimaryDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        format.subtitle,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildPlayersSection(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Two narrow cards leave too little room for the team name, count,
        // edit action, and player controls on common phone widths.
        final isNarrow = constraints.maxWidth < 520;

        final teamAPanel = _buildTeamPanel(
          context: context,
          team: TeamSide.teamA,
          title: _setup.teamAName,
          accentColor: AppColors.teamA,
          players: _setup.teamAPlayers,
        );

        final teamBPanel = _buildTeamPanel(
          context: context,
          team: TeamSide.teamB,
          title: _setup.teamBName,
          accentColor: AppColors.teamB,
          players: _setup.teamBPlayers,
        );

        if (isNarrow) {
          return Column(
            children: [
              teamAPanel,
              const SizedBox(height: 10),
              teamBPanel,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: teamAPanel),
            const SizedBox(width: 10),
            Expanded(child: teamBPanel),
          ],
        );
      },
    );
  }

  Widget _buildTeamPanel({
    required BuildContext context,
    required TeamSide team,
    required String title,
    required Color accentColor,
    required List<Player> players,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardLightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: accentColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  ),
                ),
              IconButton(
                onPressed: () => _showEditTeamDialog(context, team),
                tooltip: 'Edit team name',
                icon: const Icon(Icons.edit_outlined,
                    size: 17, color: AppColors.textMutedDark),
                padding: const EdgeInsets.all(4),
                constraints:
                    const BoxConstraints(minWidth: 30, minHeight: 30),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.cardLightMuted,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${players.length} ${players.length == 1 ? "player" : "players"}',
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                    fontSize: 8.5,
                    color: AppColors.textSecondaryDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...players.map(
            (p) => PlayerRowItem(
              player: p,
              onRemove: () => _setup.removePlayer(team, p.id),
              onEdit: () => _showEditPlayerDialog(context, team, p),
              canRemove: players.length > _setup.format.playersPerTeam,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: players.length >= _setup.format.playersPerTeam
                ? () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              '${_setup.format.label} supports ${_setup.format.playersPerTeam} player(s) per team.')),
                    )
                : () => _showAddPlayerDialog(context, team),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 7),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.cardLightBorder,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add,
                        size: 14, color: AppColors.textSecondaryDark),
                    SizedBox(width: 4),
                    Text(
                      'Add Player',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchSettings(BuildContext context) {
    return Column(
      children: [
        MatchSettingTile(
          title: 'Games per match',
          value: _setup.gamesDescription,
          onTap: () => _pickGamesPerMatch(context),
        ),
        const SizedBox(height: 8),
        MatchSettingTile(
          title: 'Points per game',
          value: _setup.pointsDescription,
          onTap: () => _pickPointsPerGame(context),
        ),
        if (_setup.sport.id == 'pickleball') ...[
          const SizedBox(height: 8),
          MatchSettingTile(
            title: 'Pickleball scoring',
            value: _setup.isSideOutScoring ? 'Side-out (traditional)' : 'Rally scoring',
            onTap: () => _pickPickleballScoring(context),
          ),
        ],
        const SizedBox(height: 8),
        MatchSettingTile(
          title: 'Starting server',
          value: _setup.startingServerDescription,
          onTap: () => _pickStartingServer(context),
        ),
        const SizedBox(height: 8),
        MatchSettingTile(
          title: 'Court',
          value: _setup.court,
          onTap: () => _pickCourt(context),
        ),
      ],
    );
  }

  Widget _buildStartMatchButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isStarting ? null : () {
          if (_isStarting) return;
          setState(() => _isStarting = true);
          final validationError = _setup.validate();
          if (validationError != null) {
            setState(() => _isStarting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(validationError)),
            );
            return;
          }
          try {
            final newMatch = _setup.buildMatch();
            widget.controller.createAndStartMatch(newMatch);
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      LiveScoreboardScreen(controller: widget.controller),
                ),
              );
            }
          } catch (error) {
            if (mounted) {
              setState(() => _isStarting = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Unable to start match: $error')),
              );
            }
          }
        },
        icon: _isStarting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.play_arrow_rounded, size: 20),
        label: const Text(
          'Start Match',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBrown,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  void _showEditTeamDialog(BuildContext context, TeamSide team) {
    final textController = TextEditingController(
      text: team == TeamSide.teamA ? _setup.teamAName : _setup.teamBName,
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit ${team == TeamSide.teamA ? "Team A" : "Team B"}'),
        content: TextField(
          controller: textController,
          autofocus: true,
          maxLength: 40,
          decoration: const InputDecoration(labelText: 'Team name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final value = textController.text.trim();
              if (value.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Team name cannot be empty.')));
                return;
              }
              if (team == TeamSide.teamA) {
                _setup.setTeamAName(value);
              } else {
                _setup.setTeamBName(value);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddPlayerDialog(BuildContext context, TeamSide team) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
            'Add Player to ${team == TeamSide.teamA ? "Team A" : "Team B"}'),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Player Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _setup.addPlayer(team, textController.text.trim());
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditPlayerDialog(
      BuildContext context, TeamSide team, Player player) {
    final textController = TextEditingController(text: player.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit ${player.label}'),
        content: TextField(
          controller: textController,
          autofocus: true,
          maxLength: 40,
          decoration: const InputDecoration(labelText: 'Player name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final value = textController.text.trim();
              if (value.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Player name cannot be empty.')));
                return;
              }
              _setup.editPlayerName(team, player.id, value);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _pickGamesPerMatch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [1, 3, 5].map((g) {
          return ListTile(
            title: Text('Best of $g'),
            trailing:
                _setup.gamesPerMatch == g ? const Icon(Icons.check) : null,
            onTap: () {
              Navigator.pop(ctx);
              _setup.setGamesPerMatch(g);
            },
          );
        }).toList(),
      ),
    );
  }

  void _pickPointsPerGame(BuildContext context) {
    final options = _setup.sport.id == 'tennis' ? [4, 6, 8] : [11, 15, 21];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((pts) {
          return ListTile(
            title: Text('$pts points (win by 2)'),
            trailing:
                _setup.pointsPerGame == pts ? const Icon(Icons.check) : null,
            onTap: () {
              Navigator.pop(ctx);
              _setup.setPointsPerGame(pts);
            },
          );
        }).toList(),
      ),
    );
  }

  void _pickPickleballScoring(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ('Side-out (traditional)', true),
          ('Rally scoring', false),
        ].map((option) => ListTile(
          title: Text(option.$1),
          trailing: _setup.isSideOutScoring == option.$2
              ? const Icon(Icons.check)
              : null,
          onTap: () {
            _setup.setSideOutScoring(option.$2);
            Navigator.pop(ctx);
          },
        )).toList(),
      ),
    );
  }

  void _pickStartingServer(BuildContext context) {
    final players = [..._setup.teamAPlayers, ..._setup.teamBPlayers];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: players
            .map((player) => ListTile(
                  title: Text('${player.label} (${player.name})'),
                  trailing: player.id == _setup.startingServerId
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () {
                    _setup.setStartingServer(player.id);
                    Navigator.pop(ctx);
                  },
                ))
            .toList(),
      ),
    );
  }

  void _pickCourt(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: ['Court 1', 'Court 2', 'Court 3', 'Court 4'].map((court) {
          return ListTile(
            title: Text(court),
            trailing: _setup.court == court ? const Icon(Icons.check) : null,
            onTap: () {
              Navigator.pop(ctx);
              _setup.setCourt(court);
            },
          );
        }).toList(),
      ),
    );
  }
}
