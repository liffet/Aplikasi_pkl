import 'package:flutter/material.dart';
import '../models/item_model.dart';
import 'damage_report_page.dart';

class DetailItemPage extends StatelessWidget {
  final ItemModel item;

  const DetailItemPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Perangkat'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📷 Gambar perangkat
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: item.photo != null && item.photo!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(item.photo!, fit: BoxFit.cover),
                    )
                  : const Center(
                      child: Icon(
                        Icons.devices_other,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
            ),
            const SizedBox(height: 20),

            // 🧾 Informasi perangkat
            _buildInfoRow('KODE', item.code),
            _buildInfoRow('NAMA', item.name),
            _buildInfoRow('KATEGORI', item.category ?? '-'),
            _buildInfoRow('RUANGAN', item.room?.name ?? '-'),
            _buildInfoRow('LANTAI', item.floor?.name ?? '-'),
            _buildInfoRow('TGL PASANG', item.installDate),
            _buildInfoRow('TGL MAINTENANCE', item.replacementDate),

            const SizedBox(height: 30),

            // 🔘 Tombol Kembali & Laporkan
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Kembali'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.indigo),
                      foregroundColor: Colors.indigo,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DamageReportPage(item: item),
                        ),
                      );

                      // ✅ Tampilkan snackbar jika laporan berhasil
                      if (result == true && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Laporan berhasil dikirim!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.warning_amber_rounded),
                    label: const Text('Laporkan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🧱 Widget pembantu untuk baris info
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(value, style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }
}
