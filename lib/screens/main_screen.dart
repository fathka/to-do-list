// lib/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'today_tasks_screen.dart'; 
import 'all_tasks_screen.dart'; 
import 'new_task_screen.dart'; 

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

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
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Hari Ini',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Semua Tugas',
          ),
          // Halaman Tambah
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'Tambah',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
      ),
    );
  }
}