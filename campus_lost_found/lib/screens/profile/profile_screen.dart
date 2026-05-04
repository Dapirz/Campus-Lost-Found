import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/report_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_loadMyReports);
  }

  Future<void> _loadMyReports() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;
    await context.read<ReportProvider>().loadMyReports(token);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    if (!auth.isLoggedIn || user == null) {
      return const _LoginPrompt();
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadMyReports,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _ProfileHeader(name: user.name, email: user.email),
          Consumer<ReportProvider>(
            builder: (context, reportProvider, _) {
              return _StatsRow(reports: reportProvider.myReports);
            },
          ),
          const SizedBox(height: 12),
          _MenuList(onLogout: () => _confirmLogout(context)),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out?'),
        content: const Text('You will be signed out of this account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;

  const _ProfileHeader({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: EdgeInsets.fromLTRB(20, topPadding + 20, 20, 30),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _initials(name),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Student',
              style: TextStyle(fontSize: 12, color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed[0].toUpperCase();
  }
}

class _StatsRow extends StatelessWidget {
  final List<ReportModel> reports;

  const _StatsRow({required this.reports});

  @override
  Widget build(BuildContext context) {
    final total = reports.length;
    final active = reports
        .where(
          (report) => report.status == 'pending' || report.status == 'verified',
        )
        .length;
    final resolved = reports
        .where((report) => report.status == 'resolved')
        .length;

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          _StatColumn(value: total, label: 'Total Reports'),
          _divider(),
          _StatColumn(value: active, label: 'Active Reports'),
          _divider(),
          _StatColumn(value: resolved, label: 'Resolved'),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 34, color: AppColors.borderDefault);
  }
}

class _StatColumn extends StatelessWidget {
  final int value;
  final String label;

  const _StatColumn({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _MenuList extends StatelessWidget {
  final VoidCallback onLogout;

  const _MenuList({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: Column(
        children: [
          _ProfileMenuItem(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          ),
          _separator(),
          _ProfileMenuItem(
            icon: Icons.help_outline,
            title: 'Help',
            onTap: () => _showHelpDialog(context),
          ),
          _separator(),
          _ProfileMenuItem(
            icon: Icons.info_outline,
            title: 'About App',
            onTap: () => _showAboutDialog(context),
          ),
          _separator(),
          _ProfileMenuItem(
            icon: Icons.logout,
            title: 'Sign Out',
            color: AppColors.error,
            onTap: onLogout,
          ),
        ],
      ),
    );
  }

  Widget _separator() {
    return const Divider(height: 1, indent: 76, color: AppColors.borderDefault);
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Help'),
        content: const Text('Contact admin at admin@telkomuniversity.ac.id'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('About App'),
        content: const Text(
          'Campus Lost & Found\nVersion 1.0.0\nKelompok 1 JOSSJISS',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? AppColors.primary;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: itemColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: itemColor),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          color: color ?? AppColors.textDark,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
      onTap: onTap,
    );
  }
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
              'Sign in to view your profile',
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
