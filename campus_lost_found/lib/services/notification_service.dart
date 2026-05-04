import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/notification_model.dart';

class NotificationService {
  Future<List<NotificationModel>> getNotifications(String token) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/notifications'),
            headers: ApiConfig.headers(token: token),
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List<dynamic> notificationsJson = data['data'] ?? [];
        return notificationsJson
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      }

      return <NotificationModel>[];
    } on TimeoutException {
      return <NotificationModel>[];
    } catch (e) {
      return <NotificationModel>[];
    }
  }

  Future<bool> markAsRead(int id, String token) async {
    try {
      final response = await http
          .patch(
            Uri.parse('${ApiConfig.baseUrl}/notifications/$id/read'),
            headers: ApiConfig.headers(token: token),
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);
      return response.statusCode == 200 && data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> saveFcmToken(String fcmToken, String token) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/notifications/fcm-token'),
            headers: ApiConfig.headers(token: token),
            body: jsonEncode({'fcm_token': fcmToken}),
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);
      return response.statusCode == 200 && data['success'] == true;
    } catch (e) {
      return false;
    }
  }
}
