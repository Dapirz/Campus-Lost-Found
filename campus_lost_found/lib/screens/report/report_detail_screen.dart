import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/report_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';
import '../../services/report_service.dart';

class ReportDetailScreen extends StatefulWidget {
  final int reportId;

  const ReportDetailScreen({super.key, required this.reportId});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final ReportService _reportService = ReportService();
  ReportModel? _report;
  bool _isLoading = true;
  bool _isResolving = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() => _isLoading = true);
    final report = await _reportService.getReportDetail(widget.reportId);
    if (mounted) {
      setState(() {
        _report = report;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.neutral,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          title: const Text('Report Detail'),
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_report == null) {
      return Scaffold(
        backgroundColor: AppColors.neutral,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          title: const Text('Report Detail'),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.textMuted),
              const SizedBox(height: 16),
              const Text('Report not found',
                  style: TextStyle(fontSize: 16, color: AppColors.textMuted)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.neutral,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  /// SliverAppBar dengan hero image
  Widget _buildSliverAppBar() {
    final report = _report!;
    final hasImage = report.images.isNotEmpty ||
        (report.imageUrl != null && report.imageUrl!.isNotEmpty);

    String? heroImageUrl;
    if (report.images.isNotEmpty) {
      heroImageUrl = report.images.first.url;
    } else if (report.imageUrl != null && report.imageUrl!.isNotEmpty) {
      heroImageUrl = report.imageUrl;
    }

    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        // Badge tipe di atas gambar
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Center(
            child: _TypeBadgeOverlay(type: report.type),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: hasImage && heroImageUrl != null
            ? Image.network(
                heroImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
              )
            : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.borderDefault,
      child: const Center(
        child: Icon(Icons.image, size: 64, color: Color(0xFF9CA3AF)),
      ),
    );
  }

  /// Body content
  Widget _buildBody() {
    final report = _report!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul + Tanggal + Lokasi
          _buildTitleSection(report),
          const SizedBox(height: 12),

          // Card Deskripsi
          if (report.description != null && report.description!.isNotEmpty)
            _buildDescriptionCard(report),

          // Card Reported By
          _buildReporterCard(report),

          // Card Info Tambahan
          _buildInfoCard(report),

          // Extra gallery jika ada lebih dari 1 foto
          if (report.images.length > 1)
            _buildGalleryCard(report),

          const SizedBox(height: 80), // space untuk bottom button
        ],
      ),
    );
  }

  /// Judul, tanggal, lokasi
  Widget _buildTitleSection(ReportModel report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status badge
        _StatusBadge(status: report.status),
        const SizedBox(height: 12),

        // Title
        Text(
          report.title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 10),

        // Tanggal
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              '${report.type == 'found' ? 'Found' : 'Lost'} ${_formatDate(report.incidentDate)}',
              style: const TextStyle(fontSize: 14, color: AppColors.secondary),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Lokasi
        Row(
          children: [
            const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                report.locationText,
                style: const TextStyle(fontSize: 14, color: AppColors.secondary),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Card deskripsi
  Widget _buildDescriptionCard(ReportModel report) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.description_outlined, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Item Description',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            report.description!,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.secondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  /// Card reporter
  Widget _buildReporterCard(ReportModel report) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'REPORTED BY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Avatar inisial
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _getInitials(report.reporter.name),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                report.reporter.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Card info tambahan
  Widget _buildInfoCard(ReportModel report) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Information',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          _infoRow(Icons.calendar_today, 'Incident Date', _formatDate(report.incidentDate)),
          const SizedBox(height: 12),
          _infoRow(Icons.access_time, 'Reported', _formatDateTime(report.createdAt)),
          const SizedBox(height: 12),
          _infoRow(Icons.person_outline, 'Reporter', report.reporter.name),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
            ],
          ),
        ),
      ],
    );
  }

  /// Gallery card (jika lebih dari 1 foto)
  Widget _buildGalleryCard(ReportModel report) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Photos (${report.images.length})',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: report.images.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 100,
                  margin: EdgeInsets.only(right: index < report.images.length - 1 ? 8 : 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      report.images[index].url,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.neutral,
                        child: const Icon(Icons.broken_image, color: AppColors.textMuted),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Tombol bawah: Tandai Selesai (kondisional)
  Widget? _buildBottomButton() {
    final report = _report;
    if (report == null) return null;

    final authProvider = context.watch<AuthProvider>();
    final isOwner = authProvider.isLoggedIn &&
        authProvider.user != null &&
        authProvider.user!.id == report.reporter.id;
    final canResolve = isOwner && report.status == 'verified';

    if (!canResolve) return null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _isResolving ? null : _showResolveDialog,
            icon: _isResolving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.white),
                  )
                : const Icon(Icons.check_circle_outline, size: 20),
            label: Text(_isResolving ? 'Processing...' : 'Mark as Resolved'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tertiary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showResolveDialog() {
    final report = _report!;
    final isLost = report.type == 'lost';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Mark Report as Resolved?'),
        content: Text(
          isLost
              ? 'Confirm that your item has been found.'
              : 'Confirm that the item has been returned to its owner.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _resolveReport();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tertiary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Yes, Resolve'),
          ),
        ],
      ),
    );
  }

  Future<void> _resolveReport() async {
    final authProvider = context.read<AuthProvider>();
    final reportProvider = context.read<ReportProvider>();
    final token = authProvider.token;
    if (token == null) return;

    setState(() => _isResolving = true);

    final result = await reportProvider.resolveReport(
      id: widget.reportId,
      token: token,
    );

    if (mounted) {
      setState(() => _isResolving = false);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Report has been marked as resolved!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  // === Helpers ===

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month]} ${date.day}, ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatDateTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${date.day} ${months[date.month]} ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}

/// Badge tipe overlay (di atas gambar hero)
class _TypeBadgeOverlay extends StatelessWidget {
  final String type;
  const _TypeBadgeOverlay({required this.type});

  @override
  Widget build(BuildContext context) {
    final isLost = type.toLowerCase() == 'lost';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isLost ? const Color(0xFFFEE2E2) : const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isLost ? 'Lost' : 'Found',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: isLost ? const Color(0xFF991B1B) : const Color(0xFF065F46),
        ),
      ),
    );
  }
}

/// Status badge
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: config['bg'],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        config['label'],
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: config['text'],
        ),
      ),
    );
  }

  Map<String, dynamic> _getConfig() {
    switch (status) {
      case 'pending':
        return {'bg': const Color(0xFFFEF3C7), 'text': const Color(0xFF92400E), 'label': 'Pending'};
      case 'verified':
        return {'bg': const Color(0xFFDBEAFE), 'text': const Color(0xFF1E40AF), 'label': 'Verified'};
      case 'resolved':
        return {'bg': const Color(0xFFD1FAE5), 'text': const Color(0xFF065F46), 'label': 'Resolved'};
      case 'rejected':
        return {'bg': const Color(0xFFFEE2E2), 'text': const Color(0xFF991B1B), 'label': 'Rejected'};
      default:
        return {'bg': AppColors.neutral, 'text': AppColors.textMuted, 'label': status};
    }
  }
}
