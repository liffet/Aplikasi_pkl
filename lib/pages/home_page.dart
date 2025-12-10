import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/room_service.dart';
import '../services/floor_service.dart';
import '../services/building_service.dart';

import '../models/room_model.dart';
import '../models/floor_model.dart';
import '../models/building_model.dart';

import '../layout/navbar_layout.dart';
import '../providers/user_provider.dart';
import 'perangkat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RoomService _roomService = RoomService();
  final FloorService _floorService = FloorService();
  final BuildingService _buildingService = BuildingService();

  List<RoomModel> _rooms = [];
  List<FloorModel> _floors = [];
  List<Building> _buildings = [];

  bool _isLoading = true;
  String _errorMessage = '';

  DateTime _selectedDate = DateTime.now();
  int? _selectedBuildingId;
  int? _selectedFloorId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    setState(() => _isLoading = true);

    try {
      await fetchBuildings();

      if (_selectedBuildingId != null) {
        await fetchFloors(_selectedBuildingId!);
      }

      await fetchRooms();
    } catch (e) {
      setState(() => _errorMessage = 'Gagal memuat data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> fetchBuildings() async {
    try {
      final data = await _buildingService.getBuildings();
      setState(() {
        _buildings = data;
        if (_buildings.isNotEmpty && _selectedBuildingId == null) {
          _selectedBuildingId = _buildings.first.id;
        }
      });
    } catch (e) {
      setState(() => _errorMessage = 'Gagal memuat gedung: $e');
    }
  }

  Future<void> fetchFloors(int buildingId) async {
    try {
      final data = await _floorService.getFloors(buildingId);
      setState(() {
        _floors = data;
        if (_floors.isNotEmpty) {
          _selectedFloorId = _floors.first.id;
        }
      });
    } catch (e) {
      setState(() => _errorMessage = 'Gagal memuat lantai: $e');
    }
  }

  Future<void> fetchRooms() async {
    try {
      final data = await _roomService.getRooms();
      setState(() => _rooms = data);
    } catch (e) {
      setState(() => _errorMessage = 'Gagal memuat ruangan: $e');
    }
  }

  Widget _buildHomeContent() {
    final user = Provider.of<UserProvider>(context).user;

    final formattedDate = DateFormat('d MMMM yyyy', 'id_ID').format(_selectedDate);

    final filteredRooms = _rooms.where((room) {
      final matchBuilding = _selectedBuildingId == null || room.buildingId == _selectedBuildingId;
      final matchFloor = _selectedFloorId == null || room.floor?.id == _selectedFloorId;
      final matchSearch = room.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchBuilding && matchFloor && matchSearch;
    }).toList();

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          children: [
            Text(_errorMessage),
            ElevatedButton(
              onPressed: fetchInitialData,
              child: const Text("Coba Lagi"),
            )
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchInitialData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Selamat Datang, ${user?.name ?? "User"}",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    formattedDate,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Text(
                "Pilih Gedung",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),

              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _buildings.length,
                  itemBuilder: (context, index) {
                    final building = _buildings[index];
                    final isSelected = building.id == _selectedBuildingId;

                    return GestureDetector(
                      onTap: () async {
                        setState(() {
                          _selectedBuildingId = building.id;
                          _floors = [];
                          _selectedFloorId = null;
                          _isLoading = true;
                        });

                        await fetchFloors(_selectedBuildingId!);

                        setState(() => _isLoading = false);
                      },
                      child: Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.indigo.shade50 : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.indigo : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            building.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.indigo : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 90,
                child: _floors.isEmpty
                    ? const Center(child: Text("Belum ada data lantai"))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _floors.length,
                        itemBuilder: (context, index) {
                          final floor = _floors[index];
                          final isSelected = floor.id == _selectedFloorId;

                          return GestureDetector(
                            onTap: () {
                              setState(() => _selectedFloorId = floor.id);
                            },
                            child: Container(
                              width: 80,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.indigo.shade50 : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? Colors.indigo : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    floor.name.replaceAll("Lantai ", ""),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.indigo : Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    "Lantai",
                                    style: TextStyle(
                                      color: isSelected ? Colors.indigo : Colors.grey.shade600,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 20),

              TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: "Pencarian...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "Daftar Ruangan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              filteredRooms.isEmpty
                  ? const Center(child: Text("Tidak ada ruangan"))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredRooms.length,
                      itemBuilder: (context, index) {
                        final room = filteredRooms[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            tileColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            leading: CircleAvatar(
                              backgroundColor: Colors.indigo,
                              child: Text(
                                room.name[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(room.name),
                            subtitle: Text(room.floor?.name ?? '-'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PerangkatPage(room: room),
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
    final user = Provider.of<UserProvider>(context).user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return NavbarLayout(
      homeContentBuilder: (_) => _buildHomeContent(),
      user: user,
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
