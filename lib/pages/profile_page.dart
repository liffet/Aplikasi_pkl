import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/damage_report_model.dart';
import '../services/damage_report_service.dart';
import 'edit_password_page.dart';
import 'edit_profile_page.dart';
import 'login_page.dart';
import 'histori_page.dart'; // pastikan path sesuai file HistoriPage kamu

class ProfilePage extends StatelessWidget {
  final UserModel user;

  const ProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ======== USER CARD ========
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.indigo,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  user.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(user.email),
              ),
            ),
            const SizedBox(height: 24),

            // ======== SECTION: UMUM ========
            _sectionTitle('Umum'),
            _menuItem(
              context,
              icon: Icons.person_outline,
              title: 'Edit Profil',
              subtitle: 'Mengubah nama, dan E-mail',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfilePage(user: user),
                  ),
                );
              },
            ),

            _menuItem(
              context,
              icon: Icons.lock_outline,
              title: 'Mengubah Kata Sandi',
              subtitle: 'Memperbarui dan memperkuat keamanan akun anda',
              onTap: () {
               Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ChangePasswordPage(user: user),
  ),
);

              },
            ),

            const SizedBox(height: 24),

            // ======== SECTION: PENGATURAN LAINNYA ========
            _sectionTitle('Pengaturan Lainnya'),
            _menuItem(
              context,
              icon: Icons.history,
              title: 'Histori',
              subtitle: 'Melihat histori laporan anda',
              onTap: () async {
                // Ambil data laporan user dari API
                final service = DamageReportService();
                final token =
                    user.token; // pastikan token tersimpan di UserModel

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) =>
                      const Center(child: CircularProgressIndicator()),
                );

                try {
                  final reports = await service.getReports(token);
                  Navigator.pop(context); // tutup loading

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HistoriPage(reports: reports),
                    ),
                  );
                } catch (e) {
                  Navigator.pop(context); // tutup loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gagal mengambil histori laporan'),
                    ),
                  );
                }
              },
            ),
            _menuItem(
              context,
              icon: Icons.logout,
              title: 'Keluar',
              subtitle: 'Keluar dari akun anda',
              textColor: Colors.red,
              iconColor: Colors.red,
              onTap: () {
                _showLogoutConfirmation(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ======== DIALOG: KONFIRMASI LOGOUT ========
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout, color: Colors.red, size: 32),
              ),
              const SizedBox(height: 16),
              // Title
              const Text(
                'Konfirmasi Logout',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Message
              const Text(
                'Apakah anda yakin ingin log out? Sesi anda saat ini akan berakhir',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              // Buttons
              Row(
                children: [
                  // Batal Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Log out Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // tutup dialog
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Log out',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ======== COMPONENT: SECTION TITLE ========
  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  // ======== COMPONENT: MENU ITEM ========
  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = Colors.grey,
    Color textColor = Colors.black,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
