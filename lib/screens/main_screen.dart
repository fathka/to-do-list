import 'package:daily_planner_app/screens/all_tasks_screen.dart';
import 'package:daily_planner_app/theme/theme_config.dart';
import 'package:flutter/material.dart';
import 'today_tasks_screen.dart';
import 'new_task_screen.dart';

class MainScreen extends StatefulWidget {
  final Function(AppTheme) onChangeTheme;

  const MainScreen({super.key, required this.onChangeTheme});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    const TodayTasksScreen(),
    const AllTasksScreen(),
    const NewTaskScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('🎨 Pilih Tema'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildThemeSection('💙 Blue', [
                  _ThemeOption(
                    'Light',
                    AppTheme.blueLight,
                    const Color(0xFF2563EB),
                  ),
                  _ThemeOption(
                    'Dark',
                    AppTheme.blueDark,
                    const Color(0xFF1E293B),
                  ),
                ]),
                const Divider(height: 24),
                _buildThemeSection('💗 Pink', [
                  _ThemeOption(
                    'Light',
                    AppTheme.pinkLight,
                    const Color(0xFFEC4899),
                  ),
                  _ThemeOption(
                    'Dark',
                    AppTheme.pinkDark,
                    const Color(0xFF2D1B27),
                  ),
                ]),
                const Divider(height: 24),
                _buildThemeSection('💜 Purple', [
                  _ThemeOption(
                    'Light',
                    AppTheme.purpleLight,
                    const Color(0xFF9333EA),
                  ),
                  _ThemeOption(
                    'Dark',
                    AppTheme.purpleDark,
                    const Color(0xFF312E81),
                  ),
                ]),
                const Divider(height: 24),
                _buildThemeSection('🌅 Sunset', [
                  _ThemeOption(
                    'Light',
                    AppTheme.sunsetLight,
                    const Color(0xFFF97316),
                  ),
                  _ThemeOption(
                    'Dark',
                    AppTheme.sunsetDark,
                    const Color(0xFF292524),
                  ),
                ]),
                const Divider(height: 24),
                _buildThemeSection('🌊 Ocean', [
                  _ThemeOption(
                    'Light',
                    AppTheme.oceanLight,
                    const Color(0xFF06B6D4),
                  ),
                  _ThemeOption(
                    'Dark',
                    AppTheme.oceanDark,
                    const Color(0xFF164E63),
                  ),
                ]),
                const Divider(height: 24),
                _buildThemeSection('🌲 Forest', [
                  _ThemeOption(
                    'Light',
                    AppTheme.forestLight,
                    const Color(0xFF16A34A),
                  ),
                  _ThemeOption(
                    'Dark',
                    AppTheme.forestDark,
                    const Color(0xFF166534),
                  ),
                ]),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildThemeSection(String title, List<_ThemeOption> themes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Row(
          children: themes.map((theme) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildThemeCard(theme),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildThemeCard(_ThemeOption option) {
    return InkWell(
      onTap: () {
        widget.onChangeTheme(option.theme);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: option.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: option.color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: option.color,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              option.name,
              style: TextStyle(
                fontSize: 12,
                color: option.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: _showThemeDialog,
            tooltip: 'Ganti Tema',
          ),
        ],
      ),

      body: _widgetOptions.elementAt(_selectedIndex),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.secondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Hari Ini',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Semua Tugas',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Tambah'),
        ],
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
