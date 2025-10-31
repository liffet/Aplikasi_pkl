import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/item_service.dart';
import '../services/auth_service.dart'; // ✅ Tambahkan ini
import '../models/item_model.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart'; // <-- tambahkan ini

class KalenderPage extends StatefulWidget {
  final UserModel? user;
  const KalenderPage({super.key, this.user});

  @override
  State<KalenderPage> createState() => _KalenderPageState();
}

class _KalenderPageState extends State<KalenderPage> {
  final ItemService _itemService = ItemService();
  final AuthService _authService = AuthService(); // ✅ Tambahkan ini

  List<ItemModel> _allItems = [];
  List<ItemModel> _selectedDateItems = [];
  bool _isLoading = true;
  String _errorMessage = '';

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<ItemModel>> _maintenanceEvents = {};

  UserModel? _currentUser; // ✅ Tambahkan ini

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadUserData(); // ✅ Load user data dulu
    fetchItems();
  }

  // ✅ Method untuk load user data dari SharedPreferences
  Future<void> _loadUserData() async {
    final freshUser = await _authService.getUserData();
    if (freshUser != null) {
      setState(() {
        _currentUser = freshUser;
      });
    } else {
      setState(() {
        _currentUser = widget.user;
      });
    }
  }

  Future<void> fetchItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await _itemService.getItems();
      setState(() {
        _allItems = data;
        _maintenanceEvents = _groupItemsByDate(data);
        _updateSelectedDateItems();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<DateTime, List<ItemModel>> _groupItemsByDate(List<ItemModel> items) {
    Map<DateTime, List<ItemModel>> events = {};
    for (var item in items) {
      try {
        DateTime date = DateTime.parse(item.replacementDate);
        DateTime normalized = DateTime(date.year, date.month, date.day);
        events.putIfAbsent(normalized, () => []);
        events[normalized]!.add(item);
      } catch (e) {
        debugPrint('Error parsing date: ${item.name}');
      }
    }
    return events;
  }

  List<ItemModel> _getEventsForDay(DateTime day) {
    DateTime normalized = DateTime(day.year, day.month, day.day);
    return _maintenanceEvents[normalized] ?? [];
  }

  void _updateSelectedDateItems() {
    if (_selectedDay != null) {
      setState(() {
        _selectedDateItems = _getEventsForDay(_selectedDay!);
      });
    }
  }

  // Panggil ini setelah update profil berhasil
  Future<void> _notifyProviderUserUpdated() async {
    try {
      await Provider.of<UserProvider>(
        context,
        listen: false,
      ).forceRefreshUser();
      setState(() {
        _currentUser = Provider.of<UserProvider>(context, listen: false).user;
      });
      debugPrint(
        '✅ KalenderPage: Provider di-refresh, nama sekarang: ${_currentUser?.name}',
      );
    } catch (e) {
      debugPrint('❌ KalenderPage: gagal refresh provider: $e');
    }
  }

  // Contoh: setelah Anda memanggil _authService.updateProfile(...) dan mendapat sukses:
  Future<void> _onSaveProfileSuccess() async {
    await _notifyProviderUserUpdated();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profil diperbarui')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            const Text(
              "Selamat Pagi,",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(179, 0, 0, 0),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _currentUser?.name ?? widget.user?.name ?? "User", // ✅ Ubah ini
              style: const TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        toolbarHeight: 80,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? _buildErrorState()
          : SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildCalendarCard(),
                    const SizedBox(height: 20),
                    _buildSectionTitle(),
                    const SizedBox(height: 8),
                    _buildMaintenanceList(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  // ---------------- UI SECTIONS ----------------

  Widget _buildCalendarCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
            _updateSelectedDateItems();
          });
        },
        locale: 'id_ID',
        calendarFormat: CalendarFormat.month,
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left_rounded,
            color: Colors.grey[700],
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey[700],
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
          weekendStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          defaultTextStyle: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
          weekendTextStyle: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
          todayDecoration: BoxDecoration(
            color: Colors.blue[100],
            shape: BoxShape.circle,
          ),
          todayTextStyle: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
          selectedDecoration: const BoxDecoration(
            color: Color(0xFF3949AB),
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          markerDecoration: BoxDecoration(
            color: Colors.orange[600],
            shape: BoxShape.circle,
          ),
          markerSize: 5,
          markersMaxCount: 1,
        ),
        eventLoader: _getEventsForDay,
      ),
    );
  }

  Widget _buildSectionTitle() {
    final dateText = _selectedDay != null
        ? DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDay!)
        : '';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        'Jadwal Maintenance • $dateText',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildMaintenanceList() {
    if (_selectedDateItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.event_available,
                size: 64,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 12),
              Text(
                'Tidak ada maintenance di tanggal ini',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _selectedDateItems.length,
      itemBuilder: (context, index) {
        final item = _selectedDateItems[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF3949AB), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF3949AB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.code ?? 'ITM-XXXXX',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.room?.name ?? 'Ruangan tidak diketahui',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_errorMessage, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: fetchItems, child: const Text('Coba Lagi')),
        ],
      ),
    );
  }
}
