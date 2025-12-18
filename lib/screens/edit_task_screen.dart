import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore untuk update data
import 'package:intl/intl.dart'; // Format tanggal
import 'package:daily_planner_app/models/task_model.dart'; // Model Task
import 'new_task_screen.dart'; // Import untuk konstanta taskCollectionName

// Screen untuk mengedit task yang sudah ada
class EditTaskScreen extends StatefulWidget {
  final Task task; // Menerima task yang akan diedit dari screen sebelumnya

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>(); // Key untuk validasi form

  // Controller untuk text field
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  // State untuk data yang bisa diubah
  late DateTime _selectedDate; // Tanggal jatuh tempo
  late String _selectedPriority; // Prioritas

  final List<String> _priorities = ['High', 'Medium', 'Low']; // Opsi prioritas

  @override
  void initState() {
    super.initState();
    
    // 1. INISIALISASI: Isi form dengan data task yang diterima
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    
    // Ambil data dari task yang sedang diedit
    _selectedDate = widget.task.dueDate; // Tanggal jatuh tempo
    _selectedPriority = widget.task.priority; // Prioritas
  }

  @override
  void dispose() {
    // 2. CLEANUP: Bebaskan resource controller saat widget dihancurkan
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Fungsi untuk memilih tanggal dari date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate, // Tanggal yang sedang dipilih
      firstDate: DateTime(2020), // Rentang tanggal minimum
      lastDate: DateTime(2035), // Rentang tanggal maksimum
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked; // Update tanggal yang dipilih
      });
    }
  }

  // 3. LOGIKA UPDATE: Fungsi untuk menyimpan perubahan ke Firestore
  Future<void> _updateTask() async {
    // Validasi form sebelum menyimpan
    if (!_formKey.currentState!.validate()) return;

    try {
      // Update dokumen di Firestore berdasarkan ID task
      await FirebaseFirestore.instance
          .collection(taskCollectionName) // 'daily_plan'
          .doc(widget.task.id) // ID dokumen yang akan diupdate
          .update({
            'title': _titleController.text,
            'description': _descriptionController.text,
            'dueDate': Timestamp.fromDate(_selectedDate), // Konversi DateTime ke Timestamp
            'priority': _selectedPriority,
            // Catatan: tidak mengubah 'isDone' dan 'createdAt' karena hanya edit info dasar
          });

      // Pastikan widget masih ada (mounted) sebelum update UI
      if (!mounted) return;

      // Tampilkan feedback sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tugas berhasil diperbarui')),
      );

      // Kembali ke screen sebelumnya setelah berhasil
      Navigator.pop(context);
    } catch (e) {
      // Tangani error dan tampilkan feedback
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui tugas: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Tugas')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Input: Judul Tugas (wajib)
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

              // Input: Deskripsi (opsional)
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Input: Tanggal Jatuh Tempo
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Jatuh Tempo: ${DateFormat('EEE, dd MMM yyyy').format(_selectedDate)}',
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

              // Input: Prioritas (dropdown)
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Prioritas',
                  border: OutlineInputBorder(),
                ),
                items: _priorities
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPriority = value!; // Update state saat dipilih
                  });
                },
              ),
              const SizedBox(height: 32),

              // Tombol Aksi: Simpan Perubahan
              ElevatedButton(
                onPressed: _updateTask, // Panggil fungsi update
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Simpan Perubahan',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
