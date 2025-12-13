
import 'package:daily_planner_app/theme/theme_config.dart';
import 'package:flutter/material.dart';
import 'today_tasks_screen.dart'; 
import 'all_tasks_screen.dart'; 
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Planner'),
        actions: [
          PopupMenuButton<AppTheme>(
            icon: const Icon(Icons.color_lens),
            onSelected: widget.onChangeTheme,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: AppTheme.blue,
                child: Text('Tema Biru'),
              ),
              PopupMenuItem(
                value: AppTheme.pink,
                child: Text('Tema Pink'),
              ),
              PopupMenuItem(
                value: AppTheme.purple,
                child: Text('Tema Ungu'),
              ),
            ],
          ),
        ],
      ),

      // 🔥 INI YANG KEMARIN HILANG
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
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'Tambah',
          ),
        ],
      ),
    );
  }

}