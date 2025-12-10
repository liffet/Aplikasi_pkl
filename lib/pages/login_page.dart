import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isLoginSelected = true;
  bool _obscurePassword = true;

  // Variabel untuk tracking error
  String? _emailError;
  String? _passwordError;

  // Fungsi untuk menampilkan custom snackbar yang cantik
  void _showCustomSnackBar({
    required String message,
    required bool isSuccess,
  }) {
    final snackBar = SnackBar(
      content: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSuccess
                    ? const Color(0xFF4CAF50).withOpacity(0.2)
                    : const Color(0xFFE53935).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
                color: isSuccess
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFE53935),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isSuccess ? 'Berhasil!' : 'Gagal!',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: isSuccess
          ? const Color(0xFF2E7D32)
          : const Color(0xFFC62828),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      elevation: 8,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Fungsi untuk menampilkan loading overlay
  void _showLoadingOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xff1E3A8A),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Memuat...',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _login() async {
    // Reset error messages
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    bool hasError = false;

    if (_emailController.text.trim().isEmpty) {
      setState(() => _emailError = 'Email tidak boleh kosong');
      hasError = true;
    }

    if (_passwordController.text.trim().isEmpty) {
      setState(() => _passwordError = 'Password tidak boleh kosong');
      hasError = true;
    }

    if (hasError) {
      _showCustomSnackBar(
        message: 'Mohon lengkapi semua field yang diperlukan',
        isSuccess: false,
      );
      return;
    }

    // Tampilkan loading overlay
    _showLoadingOverlay();

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    // Tutup loading overlay
    if (mounted) Navigator.pop(context);

    if (success && userProvider.user != null) {
      // Tampilkan pesan sukses
      _showCustomSnackBar(
        message: 'Selamat datang, ${userProvider.user!.name}!',
        isSuccess: true,
      );

      // Delay sedikit biar snackbar tampil dulu
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home', arguments: userProvider.user);
      }
    } else {
      setState(() {
        _emailError = 'Email atau password salah';
        _passwordError = 'Email atau password salah';
      });

      _showCustomSnackBar(
        message: 'Email atau password salah. Silakan coba lagi.',
        isSuccess: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 🟨 Lapisan Kuning
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 120),
              painter: YellowTrianglePainter(),
            ),
          ),

          // 🟦 Lapisan Biru
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 90),
              painter: BlueTrianglePainter(),
            ),
          ),

          // 🔝 Konten utama
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 80),
              child: Center(
                child: Transform.scale(
                  scale: 0.88,
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50),

                        // 🖼️ Logo
                        Image.asset(
                          'assets/images/logo.png',
                          height: 100,
                          fit: BoxFit.contain,
                        ),

                        const SizedBox(height: 25),

                        // 📝 Judul
                        const Text(
                          'Selamat Datang',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Masuk untuk mengelola perangkat jaringan kantor\nAnda secara efisien dan terpusat.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14.5,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 45),

                        // 🔘 Tab Masuk / Daftar
                        Container(
                          width: double.infinity,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _isLoginSelected = true),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _isLoginSelected
                                          ? const Color(0xff1E3A8A)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Masuk',
                                      style: TextStyle(
                                        color: _isLoginSelected
                                            ? Colors.white
                                            : const Color(0xff1E3A8A),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() => _isLoginSelected = false);
                                    Navigator.pushNamed(context, '/register');
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: !_isLoginSelected
                                          ? const Color(0xff1E3A8A)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Daftar',
                                      style: TextStyle(
                                        color: !_isLoginSelected
                                            ? Colors.white
                                            : const Color(0xff1E3A8A),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 60),

                        // 🧾 Form Input
                        Column(
                          children: [
                            // Email Field
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: _emailController,
                                  onChanged: (value) {
                                    // Clear error saat user mulai mengetik
                                    if (_emailError != null) {
                                      setState(() => _emailError = null);
                                    }
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Masukkan Alamat Email Anda',
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      color: _emailError != null
                                          ? const Color(0xFFE53935)
                                          : Colors.black54,
                                    ),
                                    prefixIconConstraints: const BoxConstraints(
                                      minWidth: 50,
                                      minHeight: 50,
                                    ),
                                    filled: true,
                                    fillColor: _emailError != null
                                        ? const Color(0xFFFFEBEE)
                                        : Colors.white,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(50),
                                      borderSide: BorderSide(
                                        color: _emailError != null
                                            ? const Color(0xFFE53935)
                                            : Colors.black26.withOpacity(0.3),
                                        width: _emailError != null ? 2 : 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(50),
                                      borderSide: BorderSide(
                                        color: _emailError != null
                                            ? const Color(0xFFE53935)
                                            : const Color(0xff1E3A8A).withOpacity(0.6),
                                        width: 1.3,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 22,
                                    ),
                                  ),
                                ),
                                // Error message
                                if (_emailError != null)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 22,
                                      top: 6,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.error_outline,
                                          size: 16,
                                          color: Color(0xFFE53935),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _emailError!,
                                          style: const TextStyle(
                                            color: Color(0xFFE53935),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Password Field
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  onChanged: (value) {
                                    // Clear error saat user mulai mengetik
                                    if (_passwordError != null) {
                                      setState(() => _passwordError = null);
                                    }
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Masukkan Kata Sandi Anda',
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color: _passwordError != null
                                          ? const Color(0xFFE53935)
                                          : Colors.black54,
                                    ),
                                    prefixIconConstraints: const BoxConstraints(
                                      minWidth: 50,
                                      minHeight: 50,
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () => setState(
                                        () => _obscurePassword = !_obscurePassword,
                                      ),
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: _passwordError != null
                                            ? const Color(0xFFE53935)
                                            : Colors.black54,
                                      ),
                                      tooltip: _obscurePassword
                                          ? 'Tampilkan kata sandi'
                                          : 'Sembunyikan kata sandi',
                                    ),
                                    filled: true,
                                    fillColor: _passwordError != null
                                        ? const Color(0xFFFFEBEE)
                                        : Colors.white,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(50),
                                      borderSide: BorderSide(
                                        color: _passwordError != null
                                            ? const Color(0xFFE53935)
                                            : Colors.black26.withOpacity(0.3),
                                        width: _passwordError != null ? 2 : 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(50),
                                      borderSide: BorderSide(
                                        color: _passwordError != null
                                            ? const Color(0xFFE53935)
                                            : const Color(0xff1E3A8A).withOpacity(0.6),
                                        width: 1.3,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 22,
                                    ),
                                  ),
                                ),
                                // Error message
                                if (_passwordError != null)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 22,
                                      top: 6,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.error_outline,
                                          size: 16,
                                          color: Color(0xFFE53935),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _passwordError!,
                                          style: const TextStyle(
                                            color: Color(0xFFE53935),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 35),

                        // 🔵 Tombol Masuk
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff1E3A8A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              elevation: 6,
                              shadowColor: const Color(
                                0xffffd700,
                              ).withOpacity(0.4),
                            ),
                            child: const Text(
                              'Masuk',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🟨 Segitiga Kuning
class YellowTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xffffd700);
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height * 0.5);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// 🟦 Segitiga Biru
class BlueTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xff1E3A8A);
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height * 0.5);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
