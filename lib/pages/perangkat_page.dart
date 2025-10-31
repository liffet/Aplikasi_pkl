import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/item_model.dart';
import '../models/room_model.dart';
import '../services/item_service.dart';
import 'detail_item_page.dart';

class PerangkatPage extends StatefulWidget {
  final RoomModel room;
  const PerangkatPage({super.key, required this.room});

  @override
  State<PerangkatPage> createState() => _PerangkatPageState();
}

class _PerangkatPageState extends State<PerangkatPage> {
  final ItemService _itemService = ItemService();

  List<ItemModel> _items = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    try {
      final data = await _itemService.getItems();

      // Filter item berdasarkan ID ruangan
      setState(() {
        _items = data.where((item) => item.roomId == widget.room.id).toList();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat perangkat: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String formatDate(String date) {
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(date));
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat(
      'd MMMM yyyy',
      'id_ID',
    ).format(DateTime.now());

    final filteredItems = _items
        .where(
          (item) =>
              item.name.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SafeArea(
            child: Container(
              height: 80, // tinggi AppBar custom
              color: Colors.white,
              child: Stack(
                children: [
                  // Back button di kiri dengan padding sama seperti konten
                  Positioned(
                    left: 5, // sama dengan padding konten
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.chevron_left,
                        color: Colors.black,
                        size: 33,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  // Nama ruangan di tengah
                  Center(
                    child: Text(
                      widget.room.name,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Konten halaman
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(
                20,
              ), // sama dengan left: 20 tombol back
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daftar Perangkat',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 20),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent, // background transparan
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.grey.withOpacity(
                          0.5,
                        ), // border tipis dan transparan
                        width: 1.5,
                      ),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Pencarian...',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // List Items
                  Expanded(
                    child: filteredItems.isEmpty
                        ? const Center(
                            child: Text('Tidak ada perangkat ditemukan'),
                          )
                        : ListView.builder(
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
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
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3949AB),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        item.name.isNotEmpty
                                            ? item.name[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    item.code,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      item.category ?? 'Tanpa Kategori',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  trailing: Text(
                                    formatDate(item.replacementDate),
                                    style: TextStyle(
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                      fontSize: 13,
                                      fontWeight:
                                          FontWeight.bold, // buat teks bold
                                    ),
                                  ),

                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DetailItemPage(item: item),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
