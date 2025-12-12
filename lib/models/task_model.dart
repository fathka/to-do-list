// lib/models/task_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  String? id;
  String title;
  String description;
  DateTime dueDate;
  String priority;
  bool isDone;
  DateTime createdAt;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    this.isDone = false,
    required this.createdAt,
  });

  // ----------------------------------------------------
  // Metode untuk mengirim ke Firestore (Dart DateTime -> Firestore Timestamp)
  // ----------------------------------------------------
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate), 
      'priority': priority,
      'isDone': isDone,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // ----------------------------------------------------
  // Konstruktor untuk membaca dari Firestore (Firestore Timestamp -> Dart DateTime)
  // ----------------------------------------------------
  factory Task.fromMap(Map<String, dynamic> map, String id) {
    
    // Ambil data tanggal sebagai 'dynamic' lalu pastikan casting ke 'Timestamp'
    // Menggunakan safe access untuk memastikan tipe data benar, mengatasi error
    final dynamic dueData = map['dueDate'];
    final dynamic createdData = map['createdAt'];

    DateTime resolvedDueDate;
    DateTime resolvedCreatedAt;
    
    // Pastikan konversi hanya jika datanya benar-benar Timestamp
    if (dueData is Timestamp) {
      resolvedDueDate = dueData.toDate();
    } else {
      // Jika ternyata masih string atau null (error data lama), gunakan DateTime.now() sebagai fallback.
      // Anda bisa menggantinya dengan penanganan error yang lebih spesifik jika diperlukan.
      resolvedDueDate = DateTime.now(); 
    }

    if (createdData is Timestamp) {
      resolvedCreatedAt = createdData.toDate();
    } else {
      resolvedCreatedAt = DateTime.now();
    }

    return Task(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: resolvedDueDate,
      priority: map['priority'] ?? 'Medium',
      isDone: map['isDone'] ?? false,
      createdAt: resolvedCreatedAt,
    );
  }
}