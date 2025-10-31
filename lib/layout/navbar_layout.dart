import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../pages/kalender_page.dart';
import '../pages/profile_page.dart';
import '../providers/user_provider.dart';

class NavbarLayout extends StatefulWidget {
  final UserModel user;
  final Widget homeContent;

  const NavbarLayout({
    super.key,
    required this.user,
    required this.homeContent,
  });

  @override
  State<NavbarLayout> createState() => _NavbarLayoutState();
}

class _NavbarLayoutState extends State<NavbarLayout> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.user ?? widget.user;

    final pages = [
      widget.homeContent,
      KalenderPage(user: currentUser),
      ProfilePage(user: currentUser),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: (_selectedIndex >= 0 && _selectedIndex < pages.length)
          ? pages[_selectedIndex]
          : const Center(child: Text('Halaman tidak ditemukan')),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50), // bentuk oval
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: false, // hilangkan label
            showUnselectedLabels: false, // hilangkan label
            selectedItemColor: Colors.blue.shade900, // biru tua saat dipilih
            unselectedItemColor: Colors.grey.shade400,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.access_time_outlined),
                activeIcon: Icon(Icons.access_time),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: '',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
