import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/api_config.dart'; // Ditambahkan untuk lokalisasi pesan
import '../../models/notification_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../auth/login_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_loadNotifications);
  }

  Future<void> _loadNotifications() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;
    await context.read<NotificationProvider>().loadNotifications(token);
  }

  Future<void> _markAllAsRead() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;
    await context.read<NotificationProvider>().markAllAsRead(token);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isLoggedIn) {
      return const _LoginPrompt();
    }

    return Column(
      children: [
        // Header
        Container(
          color: AppColors.primary,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Inbox',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
                IconButton(
                  onPressed: _markAllAsRead,
                  tooltip: 'Mark all as read',
                  icon: const Icon(
                    Icons.done_all,
                    color: AppColors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Body
        Expanded(
          child: Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading && provider.notifications.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (provider.notifications.isEmpty) {
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _loadNotifications,
                  child: ListView(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.25,
                      ),
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: AppColors.textMuted.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No notifications yet',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _loadNotifications,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.notifications.length,
                  itemBuilder: (context, index) {
                    return NotificationTile(
                      notification: provider.notifications[index],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;

  const NotificationTile({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final config = _iconConfig(notification.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: notification.isRead
            ? AppColors.white
            : AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: config.bg,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Icon(config.icon, color: config.color),
        ),
        title: Text(
          // Terjemahkan pesan notifikasi dari Bahasa Indonesia ke Bahasa Inggris secara dinamis
          ApiConfig.translate(notification.message),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: notification.isRead
                ? FontWeight.normal
                : FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            timeAgo(notification.createdAt),
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ),
        trailing: notification.isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
        onTap: () async {
          if (notification.isRead) return;
          final token = context.read<AuthProvider>().token;
          if (token == null) return;
          await context.read<NotificationProvider>().markAsRead(
            notification.id,
            token,
          );
        },
      ),
    );
  }

  ({Color bg, Color color, IconData icon}) _iconConfig(String type) {
    return switch (type) {
      'report_verified' => (
        bg: const Color(0xFFDBEAFE),
        color: const Color(0xFF1E40AF),
        icon: Icons.verified,
      ),
      'report_rejected' => (
        bg: const Color(0xFFFEE2E2),
        color: const Color(0xFF991B1B),
        icon: Icons.cancel,
      ),
      _ => (
        bg: const Color(0xFFF3E8FF),
        color: const Color(0xFF7C3AED),
        icon: Icons.notifications,
      ),
    };
  }
}

String timeAgo(String createdAt) {
  final date = DateTime.tryParse(createdAt);
  if (date == null) return createdAt;

  final diff = DateTime.now().difference(date.toLocal());
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inHours < 1) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';

  const months = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month]} ${date.year}';
}

class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            const Text(
              'Sign in to view your notifications',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
