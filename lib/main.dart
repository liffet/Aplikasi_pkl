import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'config/api_config.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';
import 'pages/kalender_page.dart';
import 'pages/profile_page.dart';
import 'providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Inisialisasi format tanggal untuk locale Indonesia
  await initializeDateFormatting('id_ID', null);
  Intl.defaultLocale = 'id_ID';

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider()..loadUser(),
          lazy: false,
        ),
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
      supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
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
            return MaterialPageRoute(builder: (_) => const HomePage());

          default:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
        }
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _nextPage();
  }

  Future<void> _nextPage() async {
    await Future.delayed(const Duration(seconds: 2));

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadUser();

    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      userProvider.isLoggedIn ? '/home' : '/login',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo.png', width: 110, height: 110),

            // Geser teks mendekati gambar
            Transform.translate(
              offset: const Offset(-20, 0), // geser ke kiri 10px
              child: const Text(
                "ManagementHub",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontFamily: 'inter',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
