// lib/models/task_model.dart

import 'package:cloud_firestore/cloud_firestore.dart'; // Untuk Timestamp Firebase

class Task {
  // PROPERTIES: Data yang disimpan untuk satu tugas
  String? id;           // ID dokumen Firestore (nullable saat membuat baru)
  String title;         // Judul tugas
  String description;   // Deskripsi detail
  DateTime dueDate;     // Tenggat waktu
  String priority;      // Prioritas (High/Medium/Low)
  bool isDone;          // Status selesai
  DateTime createdAt;   // Waktu pembuatan

  // Constructor utama untuk membuat instance Task di aplikasi
  Task({
    this.id,                       // ID bisa null untuk task baru
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    this.isDone = false,           // Default: belum selesai
    required this.createdAt,
  });

  // ====================================================
  // SERIALIZATION: Konversi Dart object → Map untuk Firestore
  // ====================================================
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),     // Konversi DateTime → Timestamp Firestore
      'priority': priority,
      'isDone': isDone,
      'createdAt': Timestamp.fromDate(createdAt), // Konversi DateTime → Timestamp Firestore
    };
  }

  // ====================================================
  // DESERIALIZATION: Konversi Map dari Firestore → Dart object
  // ====================================================
  factory Task.fromMap(Map<String, dynamic> map, String id) {
    // Data mentah dari Firestore bisa dalam berbagai format, perlu safety check
    final dynamic dueData = map['dueDate'];       // Bisa Timestamp, atau tipe lain jika data korup
    final dynamic createdData = map['createdAt'];

    DateTime resolvedDueDate;
    DateTime resolvedCreatedAt;

    // SAFETY CHECK 1: Validasi dan konversi dueDate
    if (dueData is Timestamp) {
      // Format normal: konversi Timestamp Firebase ke DateTime Dart
      resolvedDueDate = dueData.toDate();
    } else {
      // Fallback jika data tidak valid (misal: string, null, atau tipe lain)
      // Gunakan DateTime.now() sebagai default untuk mencegah crash
      resolvedDueDate = DateTime.now();
    }

    // SAFETY CHECK 2: Validasi dan konversi createdAt
    if (createdData is Timestamp) {
      resolvedCreatedAt = createdData.toDate();
    } else {
      resolvedCreatedAt = DateTime.now();
    }

    // Kembalikan instance Task dengan data yang sudah divalidasi
    return Task(
      id: id, // ID dokumen dari Firestore (wajib saat membaca)
      title: map['title'] ?? '',              // Default: string kosong jika null
      description: map['description'] ?? '',
      dueDate: resolvedDueDate,
      priority: map['priority'] ?? 'Medium',  // Default: 'Medium' jika null
      isDone: map['isDone'] ?? false,         // Default: false jika null
      createdAt: resolvedCreatedAt,
    );
  }
}
