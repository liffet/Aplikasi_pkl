import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/room_service.dart';
import '../services/floor_service.dart';
import '../models/room_model.dart';
import '../models/floor_model.dart';
import '../models/user_model.dart';
import 'perangkat_page.dart';
import 'kalender_page.dart';
import 'login_page.dart';
import 'profile_page.dart'; // ✅ Tambahkan import ini

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

  int _selectedIndex = 0; // 🔹 Index untuk bottom navbar

  @override
  void initState() {
    super.initState();
    fetchData();
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

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah kamu yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  // 🔹 Isi halaman Home
  Widget _buildHomeContent() {
    final formattedDate = DateFormat('d MMMM yyyy', 'id_ID').format(_selectedDate);

    final filteredRooms = _rooms
        .where((room) =>
            (_selectedFloorId == null || room.floorId == _selectedFloorId) &&
            (room.name.toLowerCase().contains(_searchQuery.toLowerCase())))
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.calendar_today, color: Colors.indigo),
                ],
              ),
              const SizedBox(height: 12),

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
                              width: 90,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.indigo : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.indigo
                                      : Colors.grey.shade300,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Colors.yellow.shade600,
                                          offset: const Offset(3, 3),
                                          blurRadius: 0,
                                        )
                                      ]
                                    : [],
                              ),
                              child: Center(
                                child: Text(
                                  floor.name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),

              TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Pencarian ruangan...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Daftar Ruangan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),

              filteredRooms.isEmpty
                  ? const Center(child: Text('Tidak ada ruangan yang ditemukan'))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredRooms.length,
                      itemBuilder: (context, index) {
                        final room = filteredRooms[index];
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: const Icon(Icons.meeting_room, size: 40),
                            title: Text(
                              room.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Lantai: ${room.floor?.name ?? "-"}',
                            ),
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

  // 🔹 Build dengan BottomNavigationBar
  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomeContent(),
      KalenderPage(user: widget.user),
      ProfilePage(user: widget.user), // ✅ Tambahkan halaman Profile
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? 'Selamat Datang, ${widget.user.name}'
              : _selectedIndex == 1
                  ? 'Kalender Maintenance'
                  : 'Profil',
        ),
        centerTitle: true,
        actions: [
          if (_selectedIndex == 0)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: fetchData,
            ),
          if (_selectedIndex != 2)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              tooltip: 'Logout',
              onPressed: _logout,
            ),
        ],
      ),
      body: (_selectedIndex >= 0 && _selectedIndex < pages.length)
          ? pages[_selectedIndex]
          : const Center(child: Text('Halaman tidak ditemukan')),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex:
            (_selectedIndex >= 0 && _selectedIndex < pages.length) ? _selectedIndex : 0,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Kalender',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
