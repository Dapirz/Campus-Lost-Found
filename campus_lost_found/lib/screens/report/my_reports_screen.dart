import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/report_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';
import '../auth/login_screen.dart';
import 'report_detail_screen.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    Future.microtask(_loadReports);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;
    await context.read<ReportProvider>().loadMyReports(token);
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
          child: Column(
            children: [
              const SizedBox(height: 14),
              const Text(
                'My Reports',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 14),
              // Tab bar
              Container(
                color: AppColors.white,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: false,
                  indicatorColor: AppColors.primary,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textMuted,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                  ),
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Pending'),
                    Tab(text: 'Verified'),
                    Tab(text: 'Resolved'),
                    Tab(text: 'Rejected'),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Body
        Expanded(
          child: Consumer<ReportProvider>(
            builder: (context, provider, _) {
              if (provider.isLoadingMyReports && provider.myReports.isEmpty) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: 3,
                  itemBuilder: (context, index) => const _SkeletonCard(),
                );
              }

              return TabBarView(
                controller: _tabController,
                children: [
                  _ReportList(
                    reports: provider.myReports,
                    emptyText: 'No reports yet',
                    onRefresh: _loadReports,
                  ),
                  _ReportList(
                    reports: _filterReports(provider.myReports, 'pending'),
                    emptyText: 'No pending reports',
                    onRefresh: _loadReports,
                  ),
                  _ReportList(
                    reports: _filterReports(provider.myReports, 'verified'),
                    emptyText: 'No verified reports',
                    onRefresh: _loadReports,
                  ),
                  _ReportList(
                    reports: _filterReports(provider.myReports, 'resolved'),
                    emptyText: 'No resolved reports',
                    onRefresh: _loadReports,
                  ),
                  _ReportList(
                    reports: _filterReports(provider.myReports, 'rejected'),
                    emptyText: 'No rejected reports',
                    onRefresh: _loadReports,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  List<ReportModel> _filterReports(List<ReportModel> reports, String status) {
    return reports.where((report) => report.status == status).toList();
  }
}

class _ReportList extends StatelessWidget {
  final List<ReportModel> reports;
  final String emptyText;
  final Future<void> Function() onRefresh;

  const _ReportList({
    required this.reports,
    required this.emptyText,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: reports.isEmpty
          ? ListView(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.22),
                Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: AppColors.textMuted.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  emptyText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                return MyReportCard(report: reports[index]);
              },
            ),
    );
  }
}

class MyReportCard extends StatelessWidget {
  final ReportModel report;

  const MyReportCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReportDetailScreen(reportId: report.id),
          ),
        ).then((_) {
          if (context.mounted) {
            final token = context.read<AuthProvider>().token;
            if (token != null) {
              context.read<ReportProvider>().loadMyReports(token);
            }
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThumbnail(),
            const SizedBox(width: 12),
            Expanded(child: _buildContent(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 70,
        height: 70,
        child: report.imageUrl != null && report.imageUrl!.isNotEmpty
            ? Image.network(
                report.imageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: AppColors.neutral,
                    child: const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) =>
                    _thumbnailPlaceholder(),
              )
            : _thumbnailPlaceholder(),
      ),
    );
  }

  Widget _thumbnailPlaceholder() {
    return Container(
      color: AppColors.neutral,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.textMuted,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                report.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _TypeBadge(type: report.type),
          ],
        ),
        const SizedBox(height: 4),
        _StatusBadge(status: report.status),
        const SizedBox(height: 4),
        Text(
          report.createdAt.isNotEmpty ? report.createdAt : report.incidentDate,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        if (report.status == 'rejected' &&
            report.rejectionReason != null &&
            report.rejectionReason!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFCA5A5).withValues(alpha: 0.5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFDC2626),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Reason: ${report.rejectionReason}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF991B1B),
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            if (report.status == 'verified')
              OutlinedButton(
                onPressed: () => _showResolveDialog(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.tertiary,
                  side: const BorderSide(color: AppColors.tertiary),
                  visualDensity: VisualDensity.compact,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                ),
                child: const Text(
                  'Mark as Resolved',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            const Spacer(),
            if (report.status == 'pending' || report.status == 'verified')
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: () => _showDeleteDialog(context),
              ),
          ],
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Report?'),
        content: const Text('This report will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final token = context.read<AuthProvider>().token;
              if (token == null) return;
              final result = await context
                  .read<ReportProvider>()
                  .deleteReport(report.id, token);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    result['success'] == true
                        ? 'Report deleted successfully'
                        : result['message'] ?? 'Failed to delete report',
                  ),
                  backgroundColor: result['success'] == true
                      ? AppColors.success
                      : AppColors.error,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showResolveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Mark as Resolved?'),
        content: const Text('This report will be marked as resolved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final token = context.read<AuthProvider>().token;
              if (token == null) return;
              final result = await context.read<ReportProvider>().resolveReport(
                    id: report.id,
                    token: token,
                  );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result['message'] ?? 'Report updated'),
                  backgroundColor: result['success'] == true
                      ? AppColors.success
                      : AppColors.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tertiary,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;

  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final isLost = type == 'lost';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLost ? const Color(0xFFFEE2E2) : const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isLost ? 'LOST' : 'FOUND',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isLost ? const Color(0xFF991B1B) : const Color(0xFF065F46),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final config = switch (status) {
      'pending' => (
          label: 'Pending',
          bg: const Color(0xFFFEF3C7),
          color: const Color(0xFF92400E),
        ),
      'verified' => (
          label: 'Verified',
          bg: const Color(0xFFDBEAFE),
          color: const Color(0xFF1E40AF),
        ),
      'resolved' => (
          label: 'Resolved',
          bg: const Color(0xFFD1FAE5),
          color: const Color(0xFF065F46),
        ),
      'rejected' => (
          label: 'Rejected',
          bg: const Color(0xFFFEE2E2),
          color: const Color(0xFF991B1B),
        ),
      _ => (
          label: status,
          bg: AppColors.neutral,
          color: AppColors.textMuted,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: config.color,
        ),
      ),
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
              'Sign in to view your reports',
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

class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Thumbnail Skeleton
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey[200]!,
                      Colors.grey[300]!,
                      Colors.grey[200]!,
                    ],
                    stops: const [0.15, 0.5, 0.85],
                    begin: Alignment(-1.0 + (_controller.value * 2.5), -0.2),
                    end: Alignment(1.0 + (_controller.value * 2.5), 0.2),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Skeleton
                    Container(
                      width: double.infinity,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          colors: [
                            Colors.grey[200]!,
                            Colors.grey[300]!,
                            Colors.grey[200]!,
                          ],
                          stops: const [0.15, 0.5, 0.85],
                          begin: Alignment(-1.0 + (_controller.value * 2.5), -0.2),
                          end: Alignment(1.0 + (_controller.value * 2.5), 0.2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Status Badge Skeleton
                    Container(
                      width: 70,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                        gradient: LinearGradient(
                          colors: [
                            Colors.grey[200]!,
                            Colors.grey[300]!,
                            Colors.grey[200]!,
                          ],
                          stops: const [0.15, 0.5, 0.85],
                          begin: Alignment(-1.0 + (_controller.value * 2.5), -0.2),
                          end: Alignment(1.0 + (_controller.value * 2.5), 0.2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Date Skeleton
                    Container(
                      width: 130,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          colors: [
                            Colors.grey[200]!,
                            Colors.grey[300]!,
                            Colors.grey[200]!,
                          ],
                          stops: const [0.15, 0.5, 0.85],
                          begin: Alignment(-1.0 + (_controller.value * 2.5), -0.2),
                          end: Alignment(1.0 + (_controller.value * 2.5), 0.2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

