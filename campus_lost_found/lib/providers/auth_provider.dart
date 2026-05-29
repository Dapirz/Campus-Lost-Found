import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/fcm_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  static AuthProvider? _instance;
  static AuthProvider? get instance => _instance;

  AuthProvider() {
    _instance = this;
  }

  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  bool _isInitialized = false;

  // Getters
  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  bool get isInitialized => _isInitialized;

  /// Force user logout immediately (used on session expiry or account deactivation)
  void forceLogout() {
    _user = null;
    _token = null;
    _isLoggedIn = false;
    notifyListeners();
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('auth_token');
    });
  }

  /// Inisialisasi: load token dari SharedPreferences,
  /// kalau ada token → panggil getMe() untuk validasi,
  /// kalau valid → set _user dan _isLoggedIn = true
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('auth_token');

      if (savedToken != null && savedToken.isNotEmpty) {
        final user = await _authService.getMe(savedToken);
        if (user != null) {
          _user = user;
          _token = savedToken;
          _isLoggedIn = true;
          
          // Kirim FCM token ke backend saat inisialisasi awal
          FcmService.instance.sendTokenToServer();
        } else {
          // Token sudah expired atau tidak valid
          await prefs.remove('auth_token');
        }
      }
    } catch (e) {
      // Gagal init, biarkan state default (belum login)
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Login: panggil AuthService.login(),
  /// kalau sukses → simpan token ke SharedPreferences
  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.login(email, password);

      if (result['success'] == true) {
        _token = result['token'];
        _user = result['user'];
        _isLoggedIn = true;

        // Simpan token ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        
        // Panggil untuk mengirim FCM token ke backend karena user sudah login
        FcmService.instance.sendTokenToServer();
      }

      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register: delegasi ke AuthService (tidak auto-login)
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.register(
        name,
        email,
        password,
        passwordConfirmation,
      );
      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update profil user dan sinkronkan nama lokal setelah sukses.
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? currentPassword,
    String? password,
    String? passwordConfirmation,
  }) async {
    if (_token == null) {
      return {
        'success': false,
        'message': 'You must sign in first.',
        'errors': null,
      };
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.updateProfile(
        _token!,
        name: name,
        currentPassword: currentPassword,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      if (result['success'] == true && name != null && _user != null) {
        _user = _user!.copyWith(name: name);
      }

      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout: hapus token, reset semua state
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_token != null) {
        await _authService.logout(_token!);
      }

      // Hapus token dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');

      // Reset state
      _user = null;
      _token = null;
      _isLoggedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
