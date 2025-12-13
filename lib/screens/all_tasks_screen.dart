import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_planner_app/models/task_model.dart';
import 'package:intl/intl.dart';
import 'new_task_screen.dart';
import 'edit_task_screen.dart';

// =====================
// HELPER FUNCTION
// =====================
bool isSameWeek(DateTime a, DateTime b) {
  final aWeek = a.difference(DateTime(a.year, 1, 1)).inDays ~/ 7;
  final bWeek = b.difference(DateTime(b.year, 1, 1)).inDays ~/ 7;
  return a.year == b.year && aWeek == bWeek;
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

  // =====================
  // FIRESTORE ACTIONS
  // =====================
  Future<void> _toggleTaskStatus(Task task) async {
    await FirebaseFirestore.instance
        .collection(taskCollectionName)
        .doc(task.id)
        .update({'isDone': !task.isDone});
  }

  Future<void> _deleteTask(String taskId, BuildContext context) async {
    await FirebaseFirestore.instance
        .collection(taskCollectionName)
        .doc(taskId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tugas berhasil dihapus')),
    );
  }

  // =====================
  // GROUPING LOGIC
  // =====================
  Map<String, List<Task>> _groupTasks(List<Task> tasks) {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));

    return {
      'Minggu Ini': tasks.where((t) =>
          !t.isDone && isSameWeek(t.dueDate, now)).toList(),

      'Minggu Depan': tasks.where((t) =>
          !t.isDone &&
          t.dueDate.isAfter(now) &&
          isSameWeek(t.dueDate, nextWeek)).toList(),

      'Nanti': tasks.where((t) =>
          !t.isDone && t.dueDate.isAfter(nextWeek)).toList(),

      'Sudah Selesai': tasks.where((t) => t.isDone).toList(),
    };
  }

  // =====================
  // TASK TILE
  // =====================
  Widget _taskTile(Task task, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
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
            fontWeight: FontWeight.bold,
            decoration:
                task.isDone ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty)
              Text(task.description),
            const SizedBox(height: 4),
            Text(
              'Jatuh tempo: ${DateFormat('dd MMM yyyy').format(task.dueDate)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.orange),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditTaskScreen(task: task),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteTask(task.id!, context),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  // =====================
  // BUILD UI
  // =====================
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(taskCollectionName)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Belum ada tugas'));
        }

        final tasks = snapshot.data!.docs
            .map((doc) => Task.fromMap(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        final groupedTasks = _groupTasks(tasks);

        return ListView(
          children: groupedTasks.entries.map((entry) {
            if (entry.value.isEmpty) return const SizedBox();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...entry.value.map((task) => _taskTile(task, context)),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}
