import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';
import 'pages/kalender_page.dart';
import 'pages/profile_page.dart';
import 'models/user_model.dart';
import 'services/auth_service.dart';
import 'providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Inisialisasi format tanggal untuk locale Indonesia
  await initializeDateFormatting('id_ID', null);
  Intl.defaultLocale = 'id_ID';

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth Flutter + Laravel',
      debugShowCheckedModeBanner: false,

      // 🔹 Tema dasar aplikasi
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),

      // 🔹 Lokal dan delegasi terjemahan
      locale: const Locale('id', 'ID'),
      supportedLocales: const [
        Locale('id', 'ID'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // 🔹 Rute awal berdasarkan status login
      initialRoute: '/splash',

      // 🔹 Gunakan onGenerateRoute agar lebih fleksibel
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/splash':
            return MaterialPageRoute(builder: (_) => const SplashScreen());

          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginPage());

          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterPage());

          case '/kalender':
            return MaterialPageRoute(builder: (_) => const KalenderPage());

          case '/home':
            // Cek arguments untuk user
            final args = settings.arguments;
            if (args is UserModel) {
              return MaterialPageRoute(builder: (_) => HomePage(user: args));
            }
            return _unauthorizedRoute();

          default:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
        }
      },
    );
  }

  /// 🔒 Halaman fallback jika argumen user tidak valid
  MaterialPageRoute _unauthorizedRoute() {
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(
          child: Text(
            'Akses tidak valid! Silakan login terlebih dahulu.',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

/// 🖼️ Splash Screen untuk cek status login
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadUser();

    if (mounted) {
      if (userProvider.isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/home', arguments: userProvider.user);
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Memuat...'),
          ],
        ),
      ),
    );
  }
}
