import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/item_model.dart';
import 'damage_report_page.dart';

// Import ini untuk digunakan dari KalenderPage

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
            const SizedBox(height: 24),

            // Info Container dengan Card Style
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildInfoRow('KODE', item.code, Icons.qr_code_rounded),
                  _buildDivider(),
                  _buildInfoRow('NAMA', item.name, Icons.label_outline),
                  _buildDivider(),
                  _buildInfoRow('KATEGORI', item.category?.name ?? '-', Icons.category_outlined),
                  _buildDivider(),
                  _buildInfoRow('GEDUNG', item.building?.name ?? '-', Icons.apartment_rounded),
                  _buildDivider(),
                  _buildInfoRow('RUANGAN', item.room?.name ?? '-', Icons.meeting_room_outlined),
                  _buildDivider(),
                  _buildInfoRow('LANTAI', item.floor?.name ?? '-', Icons.layers_outlined),
                  _buildDivider(),
                  _buildInfoRowWithColor('TGL PASANG', formatDate(item.installDate), 
                    Icons.calendar_today_rounded, Colors.blue),
                  _buildDivider(),
                  _buildInfoRowWithColor('TGL MAINTENANCE', formatDate(item.replacementDate), 
                    Icons.build_circle_outlined, Colors.red),
                ],
              ),
            ),

            const SizedBox(height: 30),

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

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: Colors.grey[700]),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowWithColor(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
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
      indent: 16,
      endIndent: 16,
    );
  }
}