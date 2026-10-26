import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _trackServiceCourt = true;
  bool _showPlayerPositions = true;
  bool _showCourtDiagram = true;
  bool _showPlayerNames = true;
  String _selectedRuleFormat = 'Doubles';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        title: const Text(
          'Game Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          children: [
            // Badminton Rules Section
            const Text(
              'Badminton Rules',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),

            // Format Dropdown Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardDarkBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedRuleFormat,
                  dropdownColor: AppColors.cardDark,
                  icon: const Icon(Icons.keyboard_arrow_down,
                      color: Colors.white),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'Doubles', child: Text('Doubles')),
                    DropdownMenuItem(value: 'Singles', child: Text('Singles')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedRuleFormat = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Toggles
            _buildSwitchTile(
              title: 'Track service court & server',
              value: _trackServiceCourt,
              onChanged: (val) => setState(() => _trackServiceCourt = val),
            ),
            const SizedBox(height: 8),
            _buildSwitchTile(
              title: 'Show player positions',
              value: _showPlayerPositions,
              onChanged: (val) => setState(() => _showPlayerPositions = val),
            ),
            const SizedBox(height: 16),

            // Service Court Rules Info Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardDarkBorder),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 16, color: AppColors.textMutedDark),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Service Court Rules (Doubles)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Even score → Right service court\n• Odd score → Left service court\n• Follow doubles serving order',
                    style: TextStyle(
                      color: AppColors.textSecondaryLight,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Display Options Section
            const Text(
              'Display Options',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),

            _buildSwitchTile(
              title: 'Show court diagram',
              value: _showCourtDiagram,
              onChanged: (val) => setState(() => _showCourtDiagram = val),
            ),
            const SizedBox(height: 8),
            _buildSwitchTile(
              title: 'Show player names',
              value: _showPlayerNames,
              onChanged: (val) => setState(() => _showPlayerNames = val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardDarkBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            activeThumbColor: AppColors.servingGreen,
            activeTrackColor: AppColors.courtSurface,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
