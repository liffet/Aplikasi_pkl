import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/item_service.dart';
import '../models/item_model.dart';
import '../models/user_model.dart';

class KalenderPage extends StatefulWidget {
  final UserModel? user;
  const KalenderPage({super.key, this.user});

  @override
  State<KalenderPage> createState() => _KalenderPageState();
}

class _KalenderPageState extends State<KalenderPage> {
  final ItemService _itemService = ItemService();
  
  List<ItemModel> _allItems = [];
  List<ItemModel> _selectedDateItems = [];
  bool _isLoading = true;
  String _errorMessage = '';
  
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  // Map untuk menyimpan item berdasarkan tanggal
  Map<DateTime, List<ItemModel>> _maintenanceEvents = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    fetchItems();
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

  // Mengelompokkan item berdasarkan replacement_date
  Map<DateTime, List<ItemModel>> _groupItemsByDate(List<ItemModel> items) {
    Map<DateTime, List<ItemModel>> events = {};
    
    for (var item in items) {
      try {
        // Parse replacement_date
        DateTime date = DateTime.parse(item.replacementDate);
        // Normalisasi ke tanggal saja (tanpa waktu)
        DateTime normalizedDate = DateTime(date.year, date.month, date.day);
        
        if (events[normalizedDate] == null) {
          events[normalizedDate] = [];
        }
        events[normalizedDate]!.add(item);
      } catch (e) {
        print('Error parsing date for item ${item.name}: $e');
      }
    }
    
    return events;
  }

  // Mendapatkan item untuk tanggal tertentu
  List<ItemModel> _getEventsForDay(DateTime day) {
    DateTime normalizedDay = DateTime(day.year, day.month, day.day);
    return _maintenanceEvents[normalizedDay] ?? [];
  }

  void _updateSelectedDateItems() {
    if (_selectedDay != null) {
      setState(() {
        _selectedDateItems = _getEventsForDay(_selectedDay!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender Maintenance'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchItems,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: fetchItems,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Kalender
                    Card(
                      margin: const EdgeInsets.all(8.0),
                      child: TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) {
                          return isSameDay(_selectedDay, day);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                            _updateSelectedDateItems();
                          });
                        },
                        calendarFormat: CalendarFormat.month,
                        locale: 'id_ID',
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Colors.indigo.shade200,
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Colors.indigo,
                            shape: BoxShape.circle,
                          ),
                          markerDecoration: BoxDecoration(
                            color: Colors.yellow.shade700,
                            shape: BoxShape.circle,
                          ),
                        ),
                        eventLoader: _getEventsForDay,
                      ),
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // Header untuk daftar maintenance
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Maintenance Hari Ini',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_selectedDay != null)
                            Text(
                              DateFormat('d MMM yyyy', 'id_ID')
                                  .format(_selectedDay!),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // Daftar item maintenance
                    Expanded(
                      child: _selectedDateItems.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.event_available,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Tidak ada maintenance di tanggal ini',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: _selectedDateItems.length,
                              itemBuilder: (context, index) {
                                final item = _selectedDateItems[index];
                                return Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    leading: item.photo != null
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.network(
                                              item.photo!,
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  width: 60,
                                                  height: 60,
                                                  color: Colors.grey.shade300,
                                                  child: const Icon(
                                                    Icons.inventory_2,
                                                    size: 30,
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                        : Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: Colors.indigo.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.inventory_2,
                                              size: 30,
                                              color: Colors.indigo,
                                            ),
                                          ),
                                    title: Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Kode: ${item.code}'),
                                        Text(
                                            'Ruangan: ${item.room?.name ?? "-"}'),
                                        Text('Kategori: ${item.category ?? "-"}'),
                                      ],
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.yellow.shade700,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'Maintenance',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    isThreeLine: true,
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}