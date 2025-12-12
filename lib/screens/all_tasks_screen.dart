// lib/screens/all_tasks_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_planner_app/models/task_model.dart';
import 'package:intl/intl.dart';
import 'new_task_screen.dart'; // Untuk mendapatkan nama koleksi

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

  // Fungsi UPDATE status tugas
  Future<void> _toggleTaskStatus(Task task) async {
    DocumentReference taskRef = FirebaseFirestore.instance.collection(taskCollectionName).doc(task.id);
    await taskRef.update({'isDone': !task.isDone});
  }

  // Fungsi DELETE tugas
  Future<void> _deleteTask(String taskId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection(taskCollectionName).doc(taskId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tugas berhasil dihapus!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus tugas.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // StreamBuilder untuk real-time READ data dari koleksi 'daily_plan'
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(taskCollectionName)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('Belum ada tugas. Silakan tambahkan tugas baru!'),
          );
        }

        final List<Task> tasks = snapshot.data!.docs.map((doc) {
          return Task.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              elevation: 3,
              child: ListTile(
                leading: IconButton(
                  icon: Icon(
                    task.isDone ? Icons.check_circle : Icons.circle_outlined,
                    color: task.isDone ? Colors.blueAccent : Colors.grey,
                  ),
                  onPressed: () => _toggleTaskStatus(task),
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.isDone ? TextDecoration.lineThrough : TextDecoration.none,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.description.isEmpty ? 'Tidak ada deskripsi' : task.description),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(task.priority),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            task.priority,
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Jatuh Tempo: ${DateFormat('MMM d').format(task.dueDate)}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteTask(task.id!, context), 
                ),
              ),
            );
          },
        );
      },
    );
  }
}