// lib/screens/all_tasks_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_planner_app/models/task_model.dart';

import 'new_task_screen.dart'; // Untuk mendapatkan nama koleksi

Future<void> _toggleTaskStatus(Task task) async {
  await FirebaseFirestore.instance
      .collection(taskCollectionName)
      .doc(task.id)
      .update({'isDone': !task.isDone});
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

  @override
  Widget build(BuildContext context) {
    // Baca data dari koleksi 'daily_plan'
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

        final totalTasks = allTasks.length;
        final completedTasks = allTasks.where((task) => task.isDone).length;
        final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

        return Column(
          children: [
            // Indikator Kemajuan
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kemajuan Semua Tugas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}% Selesai ($completedTasks/$totalTasks)',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Daftar Semua Tugas
            Expanded(
              child: allTasks.isEmpty
                  ? const Center(child: Text('Tidak ada tugas!'))
                  : ListView.builder(
                      itemCount: allTasks.length,
                      itemBuilder: (context, index) {
                        final task = allTasks[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 16,
                          ),
                          child: ListTile(
                            leading: IconButton(
                              icon: Icon(
                                task.isDone
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: task.isDone
                                    ? Colors.blueAccent
                                    : Colors.grey,
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
                              task.description.isEmpty
                                  ? 'Tidak ada deskripsi'
                                  : task.description,
                            ),
                            trailing: Text(
                              task.priority,
                              style: TextStyle(
                                color: _getPriorityColor(task.priority),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
