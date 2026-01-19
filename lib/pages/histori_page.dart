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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      locale: const Locale('id', 'ID'),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredReports = selectedDate == null
        ? widget.reports
        : widget.reports.where((r) {
            if (r.createdAt == null) return false;
            return r.createdAt!.year == selectedDate!.year &&
                r.createdAt!.month == selectedDate!.month &&
                r.createdAt!.day == selectedDate!.day;
          }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(color: Colors.black87),
        title: const Text(
          'Histori Laporan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.calendar_today_rounded,
              color: selectedDate != null
                  ? const Color(0xFF3949AB)
                  : Colors.grey,
            ),
            onPressed: _selectDate,
          ),
        ],
      ),
      body: filteredReports.isEmpty
          ? _emptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredReports.length,
              itemBuilder: (_, i) => _reportCard(filteredReports[i]),
            ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            selectedDate != null
                ? 'Tidak ada laporan di tanggal ini'
                : 'Belum ada histori laporan',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportCard(DamageReport report) {
    final statusUI = _statusUI(report.status);

    final avatarLetter =
        (report.itemName?.isNotEmpty ?? false) ? report.itemName![0] : 'I';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DamageReportDetailPage(report: report),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF3949AB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  avatarLetter.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.itemName ?? 'Nama barang tidak tersedia',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${report.roomName ?? '-'} • ${report.buildingName ?? '-'}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report.createdAt != null
                        ? DateFormat('dd MMM yyyy', 'id_ID')
                            .format(report.createdAt!)
                        : '-',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Status Badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusUI.bg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(statusUI.icon, size: 18, color: statusUI.color),
                  const SizedBox(height: 2),
                  Text(
                    statusUI.text,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: statusUI.color,
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

  /// ==========================
  /// STATUS UI MAPPER
  /// ==========================
  _StatusUI _statusUI(String status) {
    switch (status) {
      case 'accepted':
        return _StatusUI(
          text: 'Disetujui',
          color: Colors.green,
          bg: Colors.green.withOpacity(0.1),
          icon: Icons.check_circle_rounded,
        );
      case 'rejected':
        return _StatusUI(
          text: 'Ditolak',
          color: Colors.red,
          bg: Colors.red.withOpacity(0.1),
          icon: Icons.cancel_rounded,
        );
      case 'in_progress':
        return _StatusUI(
          text: 'Diproses',
          color: Colors.blue,
          bg: Colors.blue.withOpacity(0.1),
          icon: Icons.autorenew_rounded,
        );
      case 'completed':
        return _StatusUI(
          text: 'Selesai',
          color: Colors.teal,
          bg: Colors.teal.withOpacity(0.1),
          icon: Icons.task_alt_rounded,
        );
      case 'pending':
      default:
        return _StatusUI(
          text: 'Menunggu',
          color: Colors.orange,
          bg: Colors.orange.withOpacity(0.1),
          icon: Icons.schedule_rounded,
        );
    }
  }
}

/// ==========================
/// STATUS UI MODEL
/// ==========================
class _StatusUI {
  final String text;
  final Color color;
  final Color bg;
  final IconData icon;

  _StatusUI({
    required this.text,
    required this.color,
    required this.bg,
    required this.icon,
  });
}
