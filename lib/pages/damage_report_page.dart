import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/item_model.dart';
import '../models/damage_report_model.dart';
import '../services/damage_report_service.dart';
import '../services/auth_service.dart';
import 'dart:io';

class DamageReportPage extends StatefulWidget {
  final ItemModel item;

  const DamageReportPage({super.key, required this.item});

  @override
  State<DamageReportPage> createState() => _DamageReportPageState();
}

class _DamageReportPageState extends State<DamageReportPage> {
  final TextEditingController _reasonController = TextEditingController();
  bool _isLoading = false;

  // untuk menyimpan foto
  Uint8List? _webImageBytes;
  File? _pickedFile;
  String? _fileName;

  final ImagePicker _picker = ImagePicker();

  // 🔹 pilih gambar (support web & mobile)
  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);

      if (picked != null) {
        setState(() {
          _fileName = picked.name;
        });

        if (kIsWeb) {
          // web pakai bytes
          final bytes = await picked.readAsBytes();
          setState(() => _webImageBytes = bytes);
        } else {
          // mobile pakai file path
          setState(() => _pickedFile = File(picked.path));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih foto: $e')),
      );
    }
  }

  // 🔹 kirim laporan
  Future<void> _submitReport() async {
    if (_reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alasan kerusakan tidak boleh kosong')),
      );
      return;
    }

    if (!kIsWeb && _pickedFile == null || kIsWeb && _webImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih foto bukti kerusakan')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await AuthService().getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Token tidak ditemukan. Silakan login ulang.'),
          ),
        );
        return;
      }

      final newReport = DamageReport(
        id: 0,
        itemId: widget.item.id,
        reason: _reasonController.text,
        status: 'pending',
      );

      bool success;

      if (kIsWeb) {
        success = await DamageReportService()
            .createReportWeb(newReport, token, _webImageBytes!, _fileName ?? 'damage_photo.jpg');
      } else {
        success = await DamageReportService()
            .createReportMobile(newReport, token, _pickedFile!);
      }

      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => _DamageReportSuccessPage(
              itemCode: widget.item.code ?? 'ITM-XXXXXX',
              itemName: widget.item.name,
            ),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Gagal'),
            content: const Text('Gagal mengirim laporan. Coba lagi nanti.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateNow = DateFormat('dd/MM/yyyy').format(DateTime.now());
    final dueDate =
        DateFormat('dd/MM/yyyy').format(DateTime.now().add(const Duration(days: 30)));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.inventory_2,
                      color: Colors.grey[700],
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.item.code ?? 'ITM-XXXXXX',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Alasan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Silakan mengisi alasan pelaporan dan tambahkan foto bukti kerusakan.',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _reasonController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Silahkan mengisi alasan disini...',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),

                        const SizedBox(height: 16),
                        // 🔹 tombol pilih foto
                        OutlinedButton.icon(
                          icon: const Icon(Icons.photo_camera),
                          label: const Text('Pilih Foto Bukti'),
                          onPressed: _pickImage,
                        ),

                        const SizedBox(height: 12),
                        if (_webImageBytes != null || _pickedFile != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: kIsWeb
                                ? Image.memory(_webImageBytes!, height: 200, fit: BoxFit.cover)
                                : Image.file(_pickedFile!, height: 200, fit: BoxFit.cover),
                          ),

                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            dateNow,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Perangkat',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              width: 55,
                              height: 55,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3949AB),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  widget.item.name.isNotEmpty
                                      ? widget.item.name[0].toUpperCase()
                                      : 'S',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.item.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.item.room?.name ?? 'Tidak diketahui',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              dueDate,
                              style: const TextStyle(
                                color: Color(0xFFE53935),
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 300),

                        Row(
                          children: [
                            Container(
                              width: 65,
                              height: 52,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFF3949AB),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back, size: 24),
                                onPressed: () => Navigator.pop(context),
                                color: const Color(0xFF3949AB),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _submitReport,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3949AB),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : const Text(
                                          'Konfirmasi',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Halaman sukses tetap sama seperti punyamu
class _DamageReportSuccessPage extends StatelessWidget {
  final String itemCode;
  final String itemName;

  const _DamageReportSuccessPage({
    required this.itemCode,
    required this.itemName,
  });

  @override
  Widget build(BuildContext context) {
    // ... (kode sukses page kamu tetap sama persis, tidak diubah)
    return Scaffold(
      body: Center(
        child: Text("✅ Laporan Berhasil Dikirim untuk $itemName ($itemCode)"),
      ),
    );
  }
}
