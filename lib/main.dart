import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';
import 'pages/kalender_page.dart';
import 'pages/profile_page.dart';
import 'models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Inisialisasi format tanggal untuk locale Indonesia
  await initializeDateFormatting('id_ID', null);
  Intl.defaultLocale = 'id_ID';

  runApp(const MyApp());
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

      // 🔹 Rute awal
      initialRoute: '/login',

      // 🔹 Gunakan onGenerateRoute agar lebih fleksibel
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginPage());

          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterPage());

          case '/kalender':
            return MaterialPageRoute(builder: (_) => const KalenderPage());

          case '/home':
            final args = settings.arguments;
            if (args is UserModel) {
              return MaterialPageRoute(builder: (_) => HomePage(user: args));
            }
            return _unauthorizedRoute();

          default:
            return MaterialPageRoute(builder: (_) => const LoginPage());
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
