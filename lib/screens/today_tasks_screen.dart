// lib/screens/today_tasks_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Akses Firestore
import 'package:daily_planner_app/models/task_model.dart'; // Model data Task
import 'edit_task_screen.dart'; // Screen untuk edit task
import 'new_task_screen.dart'; // Screen untuk buat task baru (mungkin untuk import konstanta)

// 1. FUNGSI UTILITAS: Toggle status selesai/tidak pada suatu Task (sama seperti di all_tasks_screen)
Future<void> _toggleTaskStatus(Task task) async {
  await FirebaseFirestore.instance
      .collection(taskCollectionName)
      .doc(task.id)
      .update({'isDone': !task.isDone});
}

// 2. FUNGSI UTILITAS: Hapus task dengan konfirmasi dialog (sama seperti di all_tasks_screen)
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
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tugas berhasil dihapus')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal menghapus tugas: $e')));
      }
    }
  }
}

class TodayTasksScreen extends StatelessWidget {
  const TodayTasksScreen({super.key});

  // 3. HELPER: Tentukan warna berdasarkan prioritas task (sama seperti di all_tasks_screen)
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

  // 4. WIDGET: Membangun UI kartu untuk satu task (sama seperti di all_tasks_screen)
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
            decoration:
                task.isDone ? TextDecoration.lineThrough : TextDecoration.none,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
            task.description.isEmpty ? 'Tidak ada deskripsi' : task.description),
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

  // 5. WIDGET BUILD: Method utama yang membangun seluruh UI screen
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Gunakan StreamBuilder untuk real-time updates dari Firestore
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection(taskCollectionName).snapshots(),
      builder: (context, snapshot) {
        // STATE 1: Loading data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // STATE 2: Error
        if (snapshot.hasError) {
          return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
        }
        // STATE 3: Data tidak ada atau kosong
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Tidak ada data tugas.'));
        }

        // STATE 4: Data berhasil didapatkan
        // Filter tugas untuk hari ini (filtering di sisi klien/Flutter)
        final now = DateTime.now();
        final nowDay = DateTime(now.year, now.month, now.day); // Normalisasi tanggal ke 00:00:00

        final todayTasks = snapshot.data!.docs
            .map((doc) {
              // Konversi dokumen Firestore ke objek Task
              return Task.fromMap(doc.data() as Map<String, dynamic>, doc.id);
            })
            .where((task) {
              // Filter hanya task dengan dueDate hari ini
              final taskDueDateOnly = DateTime(
                task.dueDate.year,
                task.dueDate.month,
                task.dueDate.day,
              );
              return taskDueDateOnly.isAtSameMomentAs(nowDay);
            })
            .toList();

        // Urutkan task berdasarkan prioritas (High -> Medium -> Low)
        todayTasks.sort((a, b) {
          const priorityOrder = {'High': 0, 'Medium': 1, 'Low': 2};
          return priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
        });

        // Hitung statistik untuk progress indicator
        final totalTasks = todayTasks.length;
        final completedTasks = todayTasks.where((task) => task.isDone).length;
        final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

        // Bangun UI utama yang terdiri dari Progress Card dan List Task
        return Column(
          children: [
            // PROGRESS INDICATOR CARD untuk tugas hari ini
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
                            'Kemajuan Tugas Hari Ini',
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
                          valueColor:
                              AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
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

            // LIST TASK UNTUK HARI INI
            Expanded(
              child: todayTasks.isEmpty
                  ? // Tampilan jika tidak ada tugas hari ini
                  Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 80,
                            color: theme.colorScheme.primary.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada tugas jatuh tempo hari ini!',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    )
                  : // Tampilan jika ada tugas hari ini
                  ListView.builder(
                      itemCount: todayTasks.length,
                      itemBuilder: (context, index) {
                        final task = todayTasks[index];
                        return _buildTaskCard(context, task);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
