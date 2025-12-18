// lib/screens/new_task_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Untuk Firebase Firestore
import 'package:daily_planner_app/models/task_model.dart'; // Model data Task
import 'package:intl/intl.dart'; // Untuk memformat tanggal (DateFormat)

// Nama collection di Firestore (harus konsisten dengan screen lain)
const String taskCollectionName = 'daily_plan';

class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({super.key});

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  // 1. STATE MANAGEMENT: Kontrol form dan data input
  final _formKey = GlobalKey<FormState>(); // Key untuk validasi form
  final TextEditingController _titleController = TextEditingController(); // Input judul
  final TextEditingController _descriptionController = TextEditingController(); // Input deskripsi

  DateTime _selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  ); // Tanggal default = hari ini (dengan waktu 00:00:00)
  String _selectedPriority = 'Medium'; // Prioritas default
  final List<String> _priorities = ['High', 'Medium', 'Low']; // Opsi prioritas

  // 2. HELPER: Fungsi untuk memilih tanggal dari date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate, // Tanggal yang sedang dipilih
      firstDate: DateTime.now(), // Tidak boleh pilih tanggal sebelum hari ini
      lastDate: DateTime(2030), // Batas maksimal pilih tanggal
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked; // Update state dengan tanggal baru
      });
    }
  }

  // 3. LOGIKA INTI: CREATE - Menambahkan task baru ke Firestore
  Future<void> _addTask() async {
    // Validasi form terlebih dahulu
    if (_formKey.currentState!.validate()) {
      // Buat objek Task baru dari data input user
      Task newTask = Task(
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _selectedDate, // Tanggal jatuh tempo yang dipilih
        priority: _selectedPriority,
        isDone: false, // Task baru default belum selesai
        createdAt: DateTime.now(), // Waktu pembuatan task
      );

      try {
        // Dapatkan reference ke collection 'daily_plan'
        CollectionReference tasks = FirebaseFirestore.instance.collection(taskCollectionName);
        
        // Tambahkan dokumen baru ke Firestore dengan mengkonversi Task ke Map
        await tasks.add(newTask.toMap());

        // Tampilkan feedback sukses ke user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tugas berhasil ditambahkan!')),
          );
        }

        // 4. RESET FORM: Kosongkan form setelah berhasil menyimpan
        _titleController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedDate = DateTime( // Reset tanggal ke hari ini
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          );
          _selectedPriority = 'Medium'; // Reset prioritas ke default
        });
      } catch (e) {
        // Tangani error dan tampilkan feedback
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menambahkan tugas: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dapatkan warna dari tema untuk konsistensi UI
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color onPrimaryColor = Theme.of(context).colorScheme.onPrimary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey, // Hubungkan GlobalKey dengan Form
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // INPUT: Judul Tugas (wajib diisi)
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul Tugas',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Judul tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // INPUT: Deskripsi Tugas (opsional)
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(),
              ),
              maxLines: 3, // Textarea dengan 3 baris
            ),
            const SizedBox(height: 16),
            
            // INPUT: Tanggal Jatuh Tempo
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    // Format tanggal menjadi lebih mudah dibaca
                    'Jatuh Tempo: ${DateFormat('EEE, MMM d, yyyy').format(_selectedDate)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                TextButton(
                  onPressed: () => _selectDate(context), // Buka date picker
                  child: const Text('Pilih Tanggal'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // INPUT: Prioritas (dropdown)
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Prioritas',
                border: OutlineInputBorder(),
              ),
              items: _priorities.map((String priority) {
                return DropdownMenuItem<String>(
                  value: priority,
                  child: Text(priority),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPriority = newValue!; // Update state saat dipilih
                });
              },
            ),
            const SizedBox(height: 32),
            
            // TOMBOL AKSI: Simpan Task
            ElevatedButton(
              onPressed: _addTask, // Panggil fungsi untuk menyimpan
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: primaryColor, // Warna dari tema
                foregroundColor: onPrimaryColor,
              ),
              child: const Text('Simpan Tugas', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
