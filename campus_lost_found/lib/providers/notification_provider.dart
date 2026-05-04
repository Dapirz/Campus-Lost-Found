import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount =>
      _notifications.where((notification) => !notification.isRead).length;

  Future<void> loadNotifications(String token) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      _notifications = await _notificationService.getNotifications(token);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int id, String token) async {
    final success = await _notificationService.markAsRead(id, token);
    if (!success) return;

    _notifications = _notifications.map((notification) {
      if (notification.id == id) {
        return notification.copyWith(isRead: true);
      }
      return notification;
    }).toList();
    notifyListeners();
  }

  Future<void> markAllAsRead(String token) async {
    final unreadNotifications =
        _notifications.where((notification) => !notification.isRead).toList();

    for (final notification in unreadNotifications) {
      await _notificationService.markAsRead(notification.id, token);
    }

    _notifications = _notifications
        .map((notification) => notification.copyWith(isRead: true))
        .toList();
    notifyListeners();
  }
}
