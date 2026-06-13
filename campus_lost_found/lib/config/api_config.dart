class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:8000/api'; // Emulator
  //static const String baseUrl = 'http://10.21.222.49:8000/api'; // mobile

  static const Duration timeout = Duration(seconds: 15);

  static Map<String, String> headers({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Menerjemahkan pesan API dari Bahasa Indonesia ke Bahasa Inggris.
  /// Notifikasi sudah dikirim dalam Bahasa Inggris oleh backend,
  /// sehingga fungsi ini hanya menangani pesan response API controller.
  static String translate(String? message) {
    if (message == null || message.isEmpty) return '';

    // Kamus statis untuk menerjemahkan pesan sukses/gagal dari API controller
    const translations = {
      'Validasi gagal': 'Validation failed',
      'Profil berhasil diupdate': 'Profile successfully updated',
      'Laporan tidak ditemukan': 'Report not found',
      'Laporan berhasil dikirim dan menunggu verifikasi admin':
          'Report successfully submitted and awaiting admin verification',
      'Akses ditolak': 'Access denied',
      'Laporan berhasil dihapus': 'Report successfully deleted',
      'Akses ditolak atau laporan belum diverifikasi':
          'Access denied or report not yet verified',
      'Laporan ditandai sebagai selesai': 'Report marked as resolved',
      'FCM token berhasil disimpan': 'FCM token successfully saved',
      'Notifikasi tidak ditemukan': 'Notification not found',
      'Notifikasi ditandai sudah dibaca': 'Notification marked as read',
      'Registrasi berhasil': 'Registration successful',
      'Kredensial tidak valid': 'Invalid credentials',
      'Akun Anda telah dinonaktifkan oleh Admin. Hubungi dukungan untuk informasi lebih lanjut.':
          'Your account has been deactivated by the Admin. Please contact support for further information.',
      'Login berhasil': 'Login successful',
      'Logout berhasil': 'Logout successful',
      'Anda tidak bisa mengklaim laporan Anda sendiri':
          'You cannot claim your own report',
      'Anda sudah mengajukan klaim untuk laporan ini':
          'You have already submitted a claim for this report',
      'Pengajuan klaim berhasil dikirim, silakan tunggu verifikasi admin':
          'Claim request submitted successfully, please await admin verification',
      'Pengajuan klaim tidak ditemukan': 'Claim request not found',
      'Status klaim tidak valid untuk dikonfirmasi':
          'Invalid claim status for confirmation',
      'Konfirmasi terima barang berhasil, laporan kini ditandai selesai':
          'Handover confirmation successful, report marked as resolved',
    };

    // Cari kecocokan langsung di dalam kamus translasi
    if (translations.containsKey(message)) {
      return translations[message]!;
    }

    // Pendekatan toleran (fallback) menggunakan pencarian substring case-insensitive
    final lowerMessage = message.toLowerCase();
    if (lowerMessage.contains('kredensial tidak valid')) {
      return 'Invalid credentials';
    }
    if (lowerMessage.contains('akun anda telah dinonaktifkan')) {
      return 'Your account has been deactivated by the Admin. Please contact support for further information.';
    }
    if (lowerMessage.contains('laporan ditandai sebagai selesai')) {
      return 'Report marked as resolved';
    }
    if (lowerMessage.contains('profil berhasil diupdate')) {
      return 'Profile successfully updated';
    }

    return message;
  }

  /// Memeriksa apakah aplikasi mobile harus memaksa logout (force logout).
  /// Sesi akan diakhiri secara paksa jika status code adalah 401 (Unauthorized),
  /// ATAU status code adalah 403 (Forbidden) namun response body memuat kata kunci deaktifasi akun oleh admin.
  static bool shouldForceLogout(int statusCode, String responseBody) {
    if (statusCode == 401) {
      // 401 berarti token kedaluwarsa atau tidak valid, selalu paksa logout
      return true;
    }
    if (statusCode == 403) {
      // 403 berarti akses ditolak, tetapi kita hanya memaksa logout jika akun dinonaktifkan admin
      final lower = responseBody.toLowerCase();
      return lower.contains('deactivated') || lower.contains('dinonaktifkan');
    }
    return false;
  }
}
