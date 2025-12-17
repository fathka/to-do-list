// lib/screens/all_tasks_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_planner_app/models/task_model.dart';
import 'edit_task_screen.dart';
import 'new_task_screen.dart';

Future<void> _toggleTaskStatus(Task task) async {
  await FirebaseFirestore.instance
      .collection(taskCollectionName)
      .doc(task.id)
      .update({'isDone': !task.isDone});
}

Future<void> _deleteTask(BuildContext context, Task task) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Hapus Tugas'),
      content: Text('Apakah Anda yakin ingin menghapus "${task.title}"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );

  if (confirm == true) {
    try {
      await FirebaseFirestore.instance
          .collection(taskCollectionName)
          .doc(task.id)
          .delete();

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tugas berhasil dihapus')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menghapus tugas: $e')));
      }
    }
  }
}

class AllTasksScreen extends StatelessWidget {
  const AllTasksScreen({super.key});

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red.shade600;
      case 'Medium':
        return Colors.amber.shade700;
      case 'Low':
        return Colors.green.shade600;
      default:
        return Colors.grey;
    }
  }

  Map<String, List<Task>> _categorizeTasks(List<Task> allTasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endOfWeek = today.add(Duration(days: 7 - today.weekday));
    final endOfNextWeek = endOfWeek.add(const Duration(days: 7));

    final Map<String, List<Task>> categorized = {
      'today': [],
      'thisWeek': [],
      'nextWeek': [],
      'upcoming': [],
      'completed': [],
    };

    for (var task in allTasks) {
      if (task.isDone) {
        categorized['completed']!.add(task);
      } else {
        final taskDate = DateTime(
          task.dueDate.year,
          task.dueDate.month,
          task.dueDate.day,
        );

        if (taskDate.isAtSameMomentAs(today)) {
          categorized['today']!.add(task);
        } else if (taskDate.isAfter(today) &&
            taskDate.isBefore(endOfWeek.add(const Duration(days: 1)))) {
          categorized['thisWeek']!.add(task);
        } else if (taskDate.isAfter(endOfWeek) &&
            taskDate.isBefore(endOfNextWeek.add(const Duration(days: 1)))) {
          categorized['nextWeek']!.add(task);
        } else if (taskDate.isAfter(endOfNextWeek)) {
          categorized['upcoming']!.add(task);
        }
      }
    }

    return categorized;
  }

  Widget _buildTaskCard(BuildContext context, Task task) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: ListTile(
        leading: IconButton(
          icon: Icon(
            task.isDone ? Icons.check_box : Icons.check_box_outline_blank,
            color: task.isDone ? theme.colorScheme.primary : Colors.grey,
          ),
          onPressed: () => _toggleTaskStatus(task),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isDone
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          task.description.isEmpty ? 'Tidak ada deskripsi' : task.description,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getPriorityColor(task.priority).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                task.priority,
                style: TextStyle(
                  color: _getPriorityColor(task.priority),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: theme.colorScheme.primary),
              onSelected: (value) {
                if (value == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditTaskScreen(task: task),
                    ),
                  );
                } else if (value == 'delete') {
                  _deleteTask(context, task);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      const Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Hapus', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    String title,
    List<Task> tasks,
    IconData icon,
    Color iconColor,
  ) {
    if (tasks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${tasks.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...tasks.map((task) => _buildTaskCard(context, task)),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(taskCollectionName)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('Tidak ada data tugas.'));
        }

        final allTasks = snapshot.data!.docs.map((doc) {
          return Task.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();

        // Sort tasks by due date
        allTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));

        final categorized = _categorizeTasks(allTasks);

        final totalTasks = allTasks.length;
        final completedTasks = categorized['completed']!.length;
        final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

        return Column(
          children: [
            // Progress Indicator
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Kemajuan Semua Tugas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$completedTasks/$totalTasks',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}% Selesai',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Categorized Tasks List
            Expanded(
              child: allTasks.isEmpty
                  ? const Center(child: Text('Tidak ada tugas!'))
                  : ListView(
                      children: [
                        _buildCategorySection(
                          context,
                          'Hari Ini',
                          categorized['today']!,
                          Icons.today,
                          Colors.red.shade600,
                        ),
                        _buildCategorySection(
                          context,
                          'Minggu Ini',
                          categorized['thisWeek']!,
                          Icons.date_range,
                          Colors.orange.shade600,
                        ),
                        _buildCategorySection(
                          context,
                          'Minggu Depan',
                          categorized['nextWeek']!,
                          Icons.calendar_month,
                          Colors.blue.shade600,
                        ),
                        _buildCategorySection(
                          context,
                          'Tugas Yang Akan Datang',
                          categorized['upcoming']!,
                          Icons.upcoming,
                          Colors.purple.shade600,
                        ),
                        _buildCategorySection(
                          context,
                          'Tugas Selesai',
                          categorized['completed']!,
                          Icons.check_circle,
                          Colors.green.shade600,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}
