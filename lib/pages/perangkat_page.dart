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

      // 🔹 Filter item berdasarkan ID ruangan
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
      return DateFormat('d MMMM yyyy', 'id_ID').format(DateTime.parse(date));
    } catch (e) {
      return date; // fallback jika format tanggal salah
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('d MMMM yyyy', 'id_ID').format(DateTime.now());

    final filteredItems = _items
        .where((item) =>
            item.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Perangkat - ${widget.room.name}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daftar Perangkat di ${widget.room.name}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),

                      // 🔹 Pencarian
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Cari perangkat...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 🔹 Daftar perangkat
                      Expanded(
                        child: filteredItems.isEmpty
                            ? const Center(
                                child: Text('Tidak ada perangkat ditemukan'),
                              )
                            : ListView.builder(
                                itemCount: filteredItems.length,
                                itemBuilder: (context, index) {
                                  final item = filteredItems[index];
                                  return Card(
                                    elevation: 2,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 6),
                                    child: ListTile(
  leading: item.photo != null
      ? ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            item.photo!,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        )
      : CircleAvatar(
          backgroundColor: Colors.indigo,
          child: Text(
            item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
  title: Text(
    item.name,
    style: const TextStyle(fontWeight: FontWeight.bold),
  ),
  subtitle: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Kode: ${item.code}'),
      Text('Kategori: ${item.category ?? 'Tanpa Kategori'}'),
      Text(
        'Dipasang: ${formatDate(item.installDate)}',
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
    ],
  ),
  trailing: Text(
    formatDate(item.replacementDate),
    style: const TextStyle(color: Colors.grey, fontSize: 12),
  ),

  // ✅ Tambahkan ini
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailItemPage(item: item),
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
    );
  }
}
