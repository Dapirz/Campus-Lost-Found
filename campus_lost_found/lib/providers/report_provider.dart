import 'dart:io';
import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';
import '../providers/auth_provider.dart';

class ReportProvider extends ChangeNotifier {
  final ReportService _reportService = ReportService();

  List<ReportModel> _reports = [];
  List<ReportModel> _myReports = [];
  bool _isLoading = false;
  bool _isLoadingMyReports = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String _activeTab = 'all'; // 'all', 'lost', 'found'
  String _searchQuery = '';
  String? _errorMessage;

  List<ReportModel> get reports => _reports;
  List<ReportModel> get myReports => _myReports;
  bool get isLoading => _isLoading;
  bool get isLoadingMyReports => _isLoadingMyReports;
  bool get hasMore => _hasMore;
  String get activeTab => _activeTab;
  String get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;

  Future<void> loadReports({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _reports = [];
      _hasMore = true;
      _errorMessage = null;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Ambil token aktif dari AuthProvider agar backend Laravel dapat memfilter data dengan benar.
      final String? token = AuthProvider.instance?.token;

      final result = await _reportService.getReports(
        type: _activeTab == 'all' ? null : _activeTab,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        page: _currentPage,
        token: token,
      );

      if (result['success'] == true) {
        final List<ReportModel> newReports = result['data'];
        final int lastPage = result['lastPage'];

        _reports.addAll(newReports);
        _hasMore = _currentPage < lastPage;
        _errorMessage = null;
      } else {
        _errorMessage = 'Failed to load reports. Please try again.';
      }
    } catch (e) {
      _errorMessage = 'An error occurred. Please check your internet connection.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyReports(String token) async {
    if (_isLoadingMyReports) return;

    _isLoadingMyReports = true;
    notifyListeners();

    try {
      _myReports = await _reportService.getMyReports(token);
    } finally {
      _isLoadingMyReports = false;
      notifyListeners();
    }
  }

  void setTab(String tab) {
    if (_activeTab == tab) return;
    _activeTab = tab;
    loadReports(refresh: true);
  }

  void setSearch(String query) {
    _searchQuery = query;
    loadReports(refresh: true);
  }

  Future<void> loadMore() async {
    if (_hasMore && !_isLoading) {
      _currentPage++;
      await loadReports();
    }
  }

  Future<Map<String, dynamic>> createReport({
    required String type,
    required String title,
    required String description,
    required String locationText,
    required String incidentDate,
    required List<File> images,
    required String token,
  }) async {
    final result = await _reportService.createReport(
      type: type,
      title: title,
      description: description,
      locationText: locationText,
      incidentDate: incidentDate,
      images: images,
      token: token,
    );

    if (result['success'] == true) {
      await loadReports(refresh: true);
      await loadMyReports(token);
    }

    return result;
  }

  Future<Map<String, dynamic>> deleteReport(int id, String token) async {
    final result = await _reportService.deleteReport(id, token);

    if (result['success'] == true) {
      _myReports = _myReports.where((report) => report.id != id).toList();
      notifyListeners();
    }

    return result;
  }

  Future<Map<String, dynamic>> resolveReport({
    required int id,
    required String token,
    String? note,
  }) async {
    final result = await _reportService.resolveReport(
      id: id,
      token: token,
      note: note,
    );

    if (result['success'] == true) {
      await loadReports(refresh: true);
      await loadMyReports(token);
    }

    return result;
  }
}
