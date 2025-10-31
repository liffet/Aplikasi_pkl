import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/room_service.dart';
import '../services/floor_service.dart';
import '../models/room_model.dart';
import '../models/floor_model.dart';
import '../models/user_model.dart';
import '../layout/navbar_layout.dart';
import 'perangkat_page.dart';

class HomePage extends StatefulWidget {
  final UserModel user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RoomService _roomService = RoomService();
  final FloorService _floorService = FloorService();

  List<RoomModel> _rooms = [];
  List<FloorModel> _floors = [];
  bool _isLoading = true;
  String _errorMessage = '';
  DateTime _selectedDate = DateTime.now();
  int? _selectedFloorId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data setiap kali halaman muncul
    if (mounted) {
      fetchData();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await fetchFloors();
      await fetchRooms();
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

  Future<void> fetchRooms() async {
    try {
      final data = await _roomService.getRooms();
      setState(() {
        _rooms = data;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data ruangan: $e';
      });
    }
  }

  Future<void> fetchFloors() async {
    try {
      final data = await _floorService.getFloors();
      setState(() {
        _floors = data;
        if (_floors.isNotEmpty && _selectedFloorId == null) {
          _selectedFloorId = _floors.first.id;
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data lantai: $e';
      });
    }
  }

  Widget _buildHomeContent() {
    final formattedDate = DateFormat(
      'd MMMM yyyy',
      'id_ID',
    ).format(_selectedDate);

    final filteredRooms = _rooms
        .where(
          (room) =>
              (_selectedFloorId == null || room.floorId == _selectedFloorId) &&
              (room.name.toLowerCase().contains(_searchQuery.toLowerCase())),
        )
        .toList();

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchData,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text(
                'Selamat Datang, ${widget.user.name}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              // Tanggal
              Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Horizontal Floor Selector
              SizedBox(
                height: 90,
                child: _floors.isEmpty
                    ? const Center(child: Text('Belum ada data lantai'))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _floors.length,
                        itemBuilder: (context, index) {
                          final floor = _floors[index];
                          final isSelected = floor.id == _selectedFloorId;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedFloorId = floor.id;
                              });
                            },
                            child: Container(
                              width: 80,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.indigo.shade50
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.indigo
                                      : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    floor.name.replaceAll('Lantai ', ''),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.indigo
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Lantai',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isSelected
                                          ? Colors.indigo
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 20),

              // Search Bar
              TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Pencarian...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade400,
                    size: 24,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: Colors.grey.withOpacity(
                        0.5,
                      ), // border transparan sedikit
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: Colors.grey.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: Colors.indigo,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 24),

              // Daftar Ruangan Title
              const Text(
                'Daftar Ruangan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Room List
              filteredRooms.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('Tidak ada ruangan yang ditemukan'),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredRooms.length,
                      itemBuilder: (context, index) {
                        final room = filteredRooms[index];
                        // Ambil inisial untuk avatar
                        final initial = room.name.isNotEmpty
                            ? room.name[0].toUpperCase()
                            : '?';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Container(
                              width: 48, // lebar kotak
                              height:
                                  48, // tinggi kotak, sesuai radius sebelumnya
                              decoration: BoxDecoration(
                                color: Colors.indigo,
                                borderRadius: BorderRadius.circular(
                                  12,
                                ), // sudut membulat
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            title: Text(
                              room.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: room.floor != null
                                ? Text(
                                    '${room.floor!.name}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  )
                                : null,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PerangkatPage(room: room),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavbarLayout(user: widget.user, homeContent: _buildHomeContent());
  }
}

// Extension untuk capitalize
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
