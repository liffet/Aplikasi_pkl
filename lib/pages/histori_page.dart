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
      appBar: AppBar(
        title: const Text(
          'Histori Laporan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            tooltip: 'Pilih tanggal laporan',
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(2024),
                lastDate: DateTime(2030),
                locale: const Locale('id', 'ID'),
              );
              if (picked != null && picked != selectedDate) {
                setState(() {
                  selectedDate = picked;
                });
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔹 Jika user sudah memilih tanggal, tampilkan info & tombol hapus filter
          if (selectedDate != null)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tanggal dipilih: ${DateFormat('dd MMMM yyyy', 'id_ID').format(selectedDate!)}',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        selectedDate = null;
                      });
                    },
                    icon: const Icon(Icons.close, size: 16, color: Colors.red),
                    label: const Text(
                      'Hapus Filter',
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                    style: TextButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      backgroundColor: Colors.red.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: filteredReports.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada laporan untuk tanggal ini',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredReports.length,
                    itemBuilder: (context, index) {
                      final report = filteredReports[index];
                      return _reportCard(context, report);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _reportCard(BuildContext context, DamageReport report) {
    Color statusColor;
    Color borderColor;
    String statusText;

    switch (report.status.toLowerCase()) {
      case 'accepted':
        statusColor = Colors.green.shade100;
        borderColor = Colors.green;
        statusText = 'Disetujui';
        break;
      case 'rejected':
        statusColor = Colors.red.shade100;
        borderColor = Colors.red;
        statusText = 'Ditolak';
        break;
      case 'pending':
      default:
        statusColor = Colors.blue.shade100;
        borderColor = Colors.blue;
        statusText = 'Menunggu';
    }

    return InkWell(
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
        decoration: BoxDecoration(
          color: statusColor,
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: borderColor, width: 6)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.description_outlined, color: borderColor, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ITM-${report.itemId.toString().padLeft(8, '0')}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Switch', // nanti bisa ubah ke nama barang
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: borderColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    report.createdAt != null
                        ? DateFormat('dd/MM/yyyy').format(report.createdAt!)
                        : '-',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
