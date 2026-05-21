import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/report_model.dart';
import '../providers/auth_provider.dart';

class ReportService {
  /// GET /reports
  /// Fetch public reports (verified only).
  /// Return Map with keys: 'success' (bool), 'data' (List of ReportModel), 'lastPage' (int), 'total' (int)
  Future<Map<String, dynamic>> getReports({
    String? type,
    String? search,
    int page = 1,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
      };
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/reports')
          .replace(queryParameters: queryParams);

      final response = await http
          .get(uri, headers: ApiConfig.headers())
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final paginatedData = data['data'];
        final List<dynamic> reportsJson = paginatedData['data'] ?? [];

        final reports = reportsJson
            .map((json) => ReportModel.fromJson(json))
            .toList();

        return {
          'success': true,
          'data': reports,
          'lastPage': paginatedData['last_page'] ?? 1,
          'total': paginatedData['total'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'data': <ReportModel>[],
          'lastPage': 1,
          'total': 0,
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'data': <ReportModel>[],
        'lastPage': 1,
        'total': 0,
      };
    } catch (e) {
      return {
        'success': false,
        'data': <ReportModel>[],
        'lastPage': 1,
        'total': 0,
      };
    }
  }

  /// GET /reports/{id}
  /// Fetch single report detail.
  /// Returns ReportModel or null on failure.
  Future<ReportModel?> getReportDetail(int id) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/reports/$id'),
            headers: ApiConfig.headers(),
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ReportModel.fromJson(data['data']);
      }
      return null;
    } on TimeoutException {
      return null;
    } catch (e) {
      return null;
    }
  }

  /// GET /reports/my
  /// Fetch reports that belong to the authenticated user.
  Future<List<ReportModel>> getMyReports(String token) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/reports/my'),
            headers: ApiConfig.headers(token: token),
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List<dynamic> reportsJson = data['data'] ?? [];
        return reportsJson
            .map((json) => ReportModel.fromJson(json))
            .toList();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        AuthProvider.instance?.forceLogout();
      }
      
      return <ReportModel>[];
    } on TimeoutException {
      return <ReportModel>[];
    } catch (e) {
      return <ReportModel>[];
    }
  }

  /// POST /reports
  /// Create a new report with photo upload via multipart/form-data.
  /// Return Map: { 'success': bool, 'message': String, 'errors': Map? }
  Future<Map<String, dynamic>> createReport({
    required String type,
    required String title,
    required String description,
    required String locationText,
    required String incidentDate,
    required List<File> images,
    required String token,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/reports');
      final request = http.MultipartRequest('POST', uri);

      // Headers
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Fields
      request.fields['type'] = type;
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['location_text'] = locationText;
      request.fields['incident_date'] = incidentDate;

      // Files
      for (final image in images) {
        request.files.add(
          await http.MultipartFile.fromPath('images[]', image.path),
        );
      }

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Report submitted successfully',
        };
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        AuthProvider.instance?.forceLogout();
        return {
          'success': false,
          'message': data['message'] ?? 'Sesi Anda telah berakhir atau akun dinonaktifkan.',
        };
      } else if (response.statusCode == 422) {
        return {
          'success': false,
          'message': data['message'] ?? 'Validation failed',
          'errors': data['errors'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to submit report',
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Connection timeout. Please make sure the server is running.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to connect to server. Please check your internet connection.',
      };
    }
  }

  /// DELETE /reports/{id}
  /// Delete a report owned by the authenticated user.
  Future<Map<String, dynamic>> deleteReport(int id, String token) async {
    try {
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.baseUrl}/reports/$id'),
            headers: ApiConfig.headers(token: token),
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 401 || response.statusCode == 403) {
        AuthProvider.instance?.forceLogout();
      }

      return {
        'success': response.statusCode == 200 && data['success'] == true,
        'message': data['message'] ?? 'Failed to delete report',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Connection timeout.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to connect to server.',
      };
    }
  }

  /// PATCH /reports/{id}/resolve
  /// Mark report as resolved.
  /// Return Map: { 'success': bool, 'message': String }
  Future<Map<String, dynamic>> resolveReport({
    required int id,
    required String token,
    String? note,
  }) async {
    try {
      final response = await http
          .patch(
            Uri.parse('${ApiConfig.baseUrl}/reports/$id/resolve'),
            headers: ApiConfig.headers(token: token),
            body: jsonEncode({
              if (note != null && note.isNotEmpty) 'note': note,
            }),
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Report marked as resolved',
        };
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        AuthProvider.instance?.forceLogout();
        return {
          'success': false,
          'message': data['message'] ?? 'Sesi Anda telah berakhir atau akun dinonaktifkan.',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to resolve report',
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Connection timeout.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred.',
      };
    }
  }
}
