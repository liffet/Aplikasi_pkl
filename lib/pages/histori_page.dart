import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/damage_report_model.dart';
import 'damage_report_detail_page.dart';

class HistoriPage extends StatefulWidget {
  final List<DamageReport> reports;

  const HistoriPage({super.key, required this.reports});

  @override
  State<HistoriPage> createState() => _HistoriPageState();
}

class _HistoriPageState extends State<HistoriPage> {
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final filteredReports = selectedDate == null
        ? widget.reports
        : widget.reports.where((report) {
            if (report.createdAt == null) return false;
            return report.createdAt!.year == selectedDate!.year &&
                report.createdAt!.month == selectedDate!.month &&
                report.createdAt!.day == selectedDate!.day;
          }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan tombol filter
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Row(
                children: [
                  // Tombol Back
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.grey[700],
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Histori Laporan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  // Tombol Filter Tanggal
                  GestureDetector(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2030),
                        locale: const Locale('id', 'ID'),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Color(0xFF3949AB),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null && picked != selectedDate) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: selectedDate != null
                            ? const Color(0xFF3949AB)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.calendar_today,
                        color: selectedDate != null
                            ? Colors.white
                            : Colors.grey[700],
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info filter tanggal
            if (selectedDate != null)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EAF6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF3949AB),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.filter_list,
                      size: 20,
                      color: Color(0xFF3949AB),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Filter: ${DateFormat('dd MMMM yyyy', 'id_ID').format(selectedDate!)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDate = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF3949AB),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            // List Laporan
            Expanded(
              child: filteredReports.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            selectedDate != null
                                ? 'Tidak ada laporan untuk tanggal ini'
                                : 'Belum ada histori laporan',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredReports.length,
                      itemBuilder: (context, index) {
                        final report = filteredReports[index];
                        return _reportCard(context, report);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reportCard(BuildContext context, DamageReport report) {
    Color statusColor;
    Color bgColor;
    String statusText;
    IconData statusIcon;

    switch (report.status.toLowerCase()) {
      case 'accepted':
        statusColor = Colors.green;
        bgColor = const Color(0xFFE8F5E9);
        statusText = 'Disetujui';
        statusIcon = Icons.check_circle_outline;
        break;
      case 'rejected':
        statusColor = Colors.red;
        bgColor = const Color(0xFFFFEBEE);
        statusText = 'Ditolak';
        statusIcon = Icons.cancel_outlined;
        break;
      case 'pending':
      default:
        statusColor = Colors.orange;
        bgColor = const Color(0xFFFFF3E0);
        statusText = 'Menunggu';
        statusIcon = Icons.hourglass_bottom;
    }

    // Ambil huruf pertama dari nama item untuk avatar
    String avatarLetter = 'S'; // default
    if (report.itemName != null && report.itemName!.isNotEmpty) {
      avatarLetter = report.itemName![0].toUpperCase();
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DamageReportDetailPage(report: report),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar dengan huruf pertama dari nama item
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF3949AB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  avatarLetter,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info Laporan
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kode Item - gunakan itemCode kalau ada, fallback ke itemId
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      report.itemCode != null && report.itemCode!.isNotEmpty
                          ? report.itemCode!
                          : 'ITM-${report.itemId.toString().padLeft(5, '0')}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Nama Item - gunakan itemName kalau ada
                  Text(
                    report.itemName ?? 'Nama barang tidak tersedia',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Tanggal
                  Text(
                    report.createdAt != null
                        ? DateFormat('dd MMM yyyy', 'id_ID')
                            .format(report.createdAt!)
                        : '-',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: statusColor,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    statusIcon,
                    size: 16,
                    color: statusColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}