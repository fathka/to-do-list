import 'package:daily_planner_app/screens/all_tasks_screen.dart';
import 'package:daily_planner_app/theme/theme_config.dart';
import 'package:flutter/material.dart';
import 'today_tasks_screen.dart';
import 'new_task_screen.dart';

class MainScreen extends StatefulWidget {
  // Menerima callback function untuk mengubah tema dari parent (MyApp)
  final Function(AppTheme) onChangeTheme;

  const MainScreen({super.key, required this.onChangeTheme});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Indeks untuk navigasi bottom bar (0 = hari ini, 1 = semua, 2 = tambah)

  // Daftar widget/screen yang sesuai dengan setiap tab navigasi
  final List<Widget> _widgetOptions = <Widget>[
    const TodayTasksScreen(), // Tab 0: Tugas hari ini
    const AllTasksScreen(),   // Tab 1: Semua tugas
    const NewTaskScreen(),    // Tab 2: Form tambah tugas baru
  ];

  // Fungsi dipanggil ketika user men-tap item di bottom navigation bar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update state untuk ganti screen
    });
  }

  // Menampilkan dialog pemilihan tema dengan berbagai pilihan
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
                // Membuat section untuk setiap grup tema (Blue, Pink, dll)
                _buildThemeSection('💙 Blue', [
                  _ThemeOption('Light', AppTheme.blueLight, const Color(0xFF2563EB)),
                  _ThemeOption('Dark', AppTheme.blueDark, const Color(0xFF1E293B)),
                ]),
                const Divider(height: 24),
                _buildThemeSection('💗 Pink', [
                  _ThemeOption('Light', AppTheme.pinkLight, const Color(0xFFEC4899)),
                  _ThemeOption('Dark', AppTheme.pinkDark, const Color(0xFF2D1B27)),
                ]),
                const Divider(height: 24),
                // ... (section untuk tema lainnya: Purple, Sunset, Ocean, Forest)
                // Setiap section berisi 2 pilihan: Light dan Dark mode
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

  // Helper method untuk membuat satu section tema (judul + 2 kartu pilihan)
  Widget _buildThemeSection(String title, List<_ThemeOption> themes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Row(
          // Menampilkan semua pilihan tema dalam section secara horizontal
          children: themes.map((theme) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildThemeCard(theme), // Membuat kartu untuk setiap pilihan tema
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Membuat kartu individual untuk setiap pilihan tema
  Widget _buildThemeCard(_ThemeOption option) {
    return InkWell(
      onTap: () {
        // Ketika kartu di-tap: ubah tema & tutup dialog
        widget.onChangeTheme(option.theme); // Panggil callback ke parent
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: option.color.withAlpha(40), // Background dengan warna tema transparan
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: option.color.withAlpha(76), width: 1),
        ),
        child: Column(
          children: [
            // Kotak warna untuk preview tema
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: option.color,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 4),
            // Nama tema (Light/Dark)
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
          // Tombol di app bar untuk membuka dialog tema
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: _showThemeDialog,
            tooltip: 'Ganti Tema',
          ),
        ],
      ),

      // Tampilkan screen sesuai tab yang dipilih
      body: _widgetOptions.elementAt(_selectedIndex),

      // Bottom Navigation Bar dengan 3 tab utama
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // Panggil fungsi saat tab di-tap
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
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box), 
            label: 'Tambah',
          ),
        ],
      ),
    );
  }
}

// Helper class untuk menyimpan data pilihan tema dalam dialog
class _ThemeOption {
  final String name;    // 'Light' atau 'Dark'
  final AppTheme theme; // Enum tema dari theme_config.dart
  final Color color;    // Warna utama untuk preview

  _ThemeOption(this.name, this.theme, this.color);
}
