import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

class ApiConfig {
  // ===== KONFIGURASI UTAMA =====
  // Ganti IP ini dengan IP laptop Anda di WiFi
  static const String deviceHost = '10.200.138.147';
  
  // Set true jika running di HP fisik, false jika di emulator
  static const bool isPhysicalDevice = true; // ← UBAH INI!
  
  // ===== JANGAN EDIT DI BAWAH INI =====
  
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8080/api';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      if (isPhysicalDevice) {
        // HP fisik → pakai IP LAN
        return 'http://$deviceHost:8080/api';
      } else {
        // Android emulator → 10.0.2.2
        return 'http://10.0.2.2:8080/api';
      }
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      if (isPhysicalDevice) {
        // iPhone fisik → pakai IP LAN
        return 'http://$deviceHost:8080/api';
      } else {
        // iOS simulator → localhost
        return 'http://127.0.0.1:8080/api';
      }
    }

    // Desktop (Windows/Mac/Linux)
    return 'http://127.0.0.1:8080/api';
  }

  // Base origin tanpa suffix /api
  static String get baseOrigin {
    final url = baseUrl;
    if (url.endsWith('/api')) {
      return url.substring(0, url.length - 4);
    }
    return url;
  }

  // Normalisasi URL media
  static String resolveMediaUrl(String? path) {
    if (path == null || path.isEmpty) {
      return 'https://i.pravatar.cc/300';
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    final normalized = path.startsWith('/') ? path.substring(1) : path;

    if (normalized.startsWith('storage/')) {
      return '$baseOrigin/$normalized';
    }

    if (normalized.startsWith('public/storage/')) {
      return '$baseOrigin/${normalized.replaceFirst('public/', '')}';
    }

    return '$baseOrigin/storage/$normalized';
  }
  
  // Debug helper
  static void printConfig() {
    print('=== API Configuration ===');
    print('Platform: ${defaultTargetPlatform.toString()}');
    print('Is Physical Device: $isPhysicalDevice');
    print('Base URL: $baseUrl');
    print('Base Origin: $baseOrigin');
    print('========================');
  }
}