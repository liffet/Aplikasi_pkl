import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/item_model.dart';
import 'damage_report_page.dart';

class DetailItemPage extends StatelessWidget {
  final ItemModel item;

  const DetailItemPage({super.key, required this.item});

  String formatDate(String date) {
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(date));
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Detail Perangkat',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            // Image Container
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: item.photo != null && item.photo!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        item.photo!,
                        fit: BoxFit.contain,
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.devices_other,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
            ),
            const SizedBox(height: 50),

            // Info Rows
            _buildInfoRow('KODE', item.code, false),
            _buildDivider(),
            _buildInfoRow('NAMA', item.name, false),
            _buildDivider(),
            _buildInfoRow('KATEGORI', item.category ?? '-', false),
            _buildDivider(),
            _buildInfoRow('RUANGAN', item.room?.name ?? '-', false),
            _buildDivider(),
            _buildInfoRow('LANTAI', item.floor?.name ?? '-', false),
            _buildDivider(),
            _buildInfoRow('TGL PASANG', formatDate(item.installDate), true, Colors.blue),
            _buildDivider(),
            _buildInfoRow('TGL MAINTENANCE', formatDate(item.replacementDate), true, Colors.red),

            const SizedBox(height: 100),

            // Buttons
            Row(
              children: [
                // Back Button
                Container(
                  width: 80,
                  height: 56,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF3949AB), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF3949AB)),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Report Button
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DamageReportPage(item: item),
                          ),
                        );

                        if (result == true && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Laporan berhasil dikirim!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Laporkan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildInfoRow(String label, String value, bool isDate, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey.shade200,
      thickness: 1,
      height: 1,
    );
  }
}