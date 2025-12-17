import 'package:flutter/material.dart';
import '../theme/theme_config.dart';

class ThemeSelector extends StatelessWidget {
  final AppTheme currentTheme;
  final Function(AppTheme) onThemeChanged;

  const ThemeSelector({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Tema'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              '🎨 Pilih Tema Favorit Anda',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          _buildThemeCategory('Blue Themes', Icons.water_drop, Colors.blue, [
            _ThemeOption(
              'Blue Light',
              AppTheme.blueLight,
              const Color(0xFF2563EB),
            ),
            _ThemeOption(
              'Blue Dark',
              AppTheme.blueDark,
              const Color(0xFF3B82F6),
            ),
          ]),
          const SizedBox(height: 16),
          _buildThemeCategory('Pink Themes', Icons.favorite, Colors.pink, [
            _ThemeOption(
              'Pink Light',
              AppTheme.pinkLight,
              const Color(0xFFEC4899),
            ),
            _ThemeOption(
              'Pink Dark',
              AppTheme.pinkDark,
              const Color(0xFFF472B6),
            ),
          ]),
          const SizedBox(height: 16),
          _buildThemeCategory(
            'Purple Themes',
            Icons.auto_awesome,
            Colors.purple,
            [
              _ThemeOption(
                'Purple Light',
                AppTheme.purpleLight,
                const Color(0xFF9333EA),
              ),
              _ThemeOption(
                'Purple Dark',
                AppTheme.purpleDark,
                const Color(0xFFA855F7),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildThemeCategory(
            'Sunset Themes',
            Icons.wb_twilight,
            Colors.orange,
            [
              _ThemeOption(
                'Sunset Light',
                AppTheme.sunsetLight,
                const Color(0xFFF97316),
              ),
              _ThemeOption(
                'Sunset Dark',
                AppTheme.sunsetDark,
                const Color(0xFFFB923C),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildThemeCategory('Ocean Themes', Icons.waves, Colors.cyan, [
            _ThemeOption(
              'Ocean Light',
              AppTheme.oceanLight,
              const Color(0xFF06B6D4),
            ),
            _ThemeOption(
              'Ocean Dark',
              AppTheme.oceanDark,
              const Color(0xFF22D3EE),
            ),
          ]),
          const SizedBox(height: 16),
          _buildThemeCategory('Forest Themes', Icons.forest, Colors.green, [
            _ThemeOption(
              'Forest Light',
              AppTheme.forestLight,
              const Color(0xFF16A34A),
            ),
            _ThemeOption(
              'Forest Dark',
              AppTheme.forestDark,
              const Color(0xFF22C55E),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildThemeCategory(
    String title,
    IconData icon,
    Color iconColor,
    List<_ThemeOption> themes,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: themes.map((theme) {
                final isSelected = currentTheme == theme.theme;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildThemeCard(theme, isSelected),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard(_ThemeOption option, bool isSelected) {
    return InkWell(
      onTap: () => onThemeChanged(option.theme),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: option.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? option.color : Colors.transparent,
            width: 3,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: option.color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: option.color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 30)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              option.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: option.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption {
  final String name;
  final AppTheme theme;
  final Color color;

  _ThemeOption(this.name, this.theme, this.color);
}
