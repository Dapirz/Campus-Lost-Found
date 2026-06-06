import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/report_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';
import '../../services/report_service.dart';
import 'claim_report_dialog.dart';

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
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: 16),
              const Text(
                'Report not found',
                style: TextStyle(fontSize: 16, color: AppColors.textMuted),
              ),
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
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.white,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        // Badge tipe di atas gambar
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Center(child: _TypeBadgeOverlay(type: report.type)),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: hasImage && heroImageUrl != null
            ? GestureDetector(
                // Ketika diketuk, panggil fungsi untuk menampilkan foto layar penuh
                onTap: () => _showFullscreenImage(context, heroImageUrl!),
                child: Image.network(
                  heroImageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: AppColors.neutral,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      _buildImagePlaceholder(),
                ),
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
    final authProvider = context.read<AuthProvider>();
    final isOwner = authProvider.isLoggedIn &&
        authProvider.user != null &&
        authProvider.user!.id == report.reporter.id;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul + Tanggal + Lokasi
          _buildTitleSection(report),
          const SizedBox(height: 12),

          // Card Info Penuntut yang Disetujui (Khusus Pemilik Laporan)
          if (isOwner &&
              report.status == 'collection_pending' &&
              report.approvedClaimant != null) ...[
            _buildApprovedClaimantCard(report),
            const SizedBox(height: 12),
          ],

          // Card Status Klaim Pengguna (jika ada klaim aktif)
          if (report.activeClaim != null) ...[
            _buildClaimStatusCard(report),
            const SizedBox(height: 12),
          ],

          // Card Alasan Penolakan
          if (report.status == 'rejected' &&
              report.rejectionReason != null &&
              report.rejectionReason!.isNotEmpty) ...[
            _buildRejectionReasonCard(report),
            const SizedBox(height: 12),
          ],

          // Card Deskripsi
          if (report.description != null && report.description!.isNotEmpty)
            _buildDescriptionCard(report),

          // Card Admin Notes (Khusus laporan yang di-reject)
          if (report.status == 'rejected' &&
              report.adminNotes != null &&
              report.adminNotes!.isNotEmpty)
            _buildAdminNotesCard(report),

          // Card Reported By
          _buildReporterCard(report),

          // Card Info Tambahan
          _buildInfoCard(report),

          // Extra gallery jika ada lebih dari 1 foto
          if (report.images.length > 1) _buildGalleryCard(report),

          const SizedBox(height: 80), // space untuk bottom button
        ],
      ),
    );
  }

  /// Card Info Penuntut yang Disetujui (Dilihat oleh pemilik laporan)
  Widget _buildApprovedClaimantCard(ReportModel report) {
    final claimant = report.approvedClaimant;
    if (claimant == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5), // Hijau sangat muda
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA7F3D0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
              Icon(
                Icons.check_circle_outline,
                color: Color(0xFF059669),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Claim Approved by Admin',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF065F46),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Please contact the claimant below to coordinate the handover of the item:',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF047857),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF6EE7B7)),
                ),
                child: Center(
                  child: Text(
                    _getInitials(claimant.name),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF059669),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      claimant.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF064E3B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () {
                        if (claimant.contactSocial != null &&
                            claimant.contactSocial!.isNotEmpty) {
                          Clipboard.setData(
                              ClipboardData(text: claimant.contactSocial!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Username "${claimant.contactSocial}" copied to clipboard'),
                              backgroundColor: AppColors.success,
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.alternate_email,
                              size: 14,
                              color: Color(0xFF059669),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              claimant.contactSocial ?? '-',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF047857),
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.copy,
                              size: 12,
                              color: Color(0xFF059669),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (claimant.claimCode != null && claimant.claimCode!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFA7F3D0), height: 1),
            const SizedBox(height: 16),
            const Text(
              'Unique Verification Code:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF047857),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF6EE7B7)),
              ),
              child: Center(
                child: Text(
                  claimant.claimCode!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Color(0xFF065F46),
                  ),
                ),
              ),
            ),
          ],
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
            const Icon(
              Icons.calendar_today,
              size: 16,
              color: AppColors.primary,
            ),
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
            const Icon(
              Icons.location_on_outlined,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                report.locationText,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.secondary,
                ),
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
              Icon(
                Icons.description_outlined,
                size: 18,
                color: AppColors.primary,
              ),
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
          _infoRow(
            Icons.calendar_today,
            'Incident Date',
            _formatDate(report.incidentDate),
          ),
          const SizedBox(height: 12),
          _infoRow(
            Icons.access_time,
            'Reported',
            _formatDateTime(report.createdAt),
          ),
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
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
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
                final imageUrl = report.images[index].url;
                return GestureDetector(
                  // Ketuk untuk memperbesar foto galeri
                  onTap: () => _showFullscreenImage(context, imageUrl),
                  child: Container(
                    width: 100,
                    margin: EdgeInsets.only(
                      right: index < report.images.length - 1 ? 8 : 0,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.neutral,
                          child: const Icon(
                            Icons.broken_image,
                            color: AppColors.textMuted,
                          ),
                        ),
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

  /// Tombol bawah: Tindai Selesai atau Klaim Barang (kondisional)
  Widget? _buildBottomButton() {
    final report = _report;
    if (report == null) return null;

    final authProvider = context.watch<AuthProvider>();

    // Cek apakah pengguna sudah login
    if (!authProvider.isLoggedIn || authProvider.user == null) {
      return null;
    }

    final isOwner = authProvider.user!.id == report.reporter.id;

    // Jika pemilik laporan (pelapor asli) dan statusnya verified, tampilkan tombol selesaikan laporan
    if (isOwner) {
      final canResolve = report.status == 'verified';
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
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
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

    // Jika BUKAN pemilik laporan (calon pengambil/penemu barang lain)
    // Tampilkan tombol Klaim Barang jika belum ada klaim aktif dan laporan verified
    if (report.status == 'verified' && report.activeClaim == null) {
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
              onPressed: () => _openClaimDialog(authProvider.token!),
              icon: const Icon(Icons.security, size: 20),
              label: const Text('Claim Item (Contact Admin)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
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

    // Jika ada klaim aktif dengan status 'approved', tampilkan tombol konfirmasi pengambilan
    if (report.activeClaim != null &&
        report.activeClaim!.status == 'approved') {
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
              onPressed: _isResolving
                  ? null
                  : () => _confirmPhysicalCollection(authProvider.token!),
              icon: _isResolving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Icon(Icons.handshake, size: 20),
              label: Text(
                  _isResolving ? 'Processing...' : 'Confirm I Received the Item'),
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

    return null;
  }

  /// Membuat kartu informasi status klaim aktif untuk calon penerima barang.
  Widget _buildClaimStatusCard(ReportModel report) {
    final claim = report.activeClaim!;

    if (claim.status == 'pending') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB), // Kuning muda
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: const Row(
          children: [
            Icon(Icons.hourglass_empty, color: Color(0xFFD97706), size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Claim Pending Verification',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF92400E),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Your proof of ownership is currently being reviewed by the Admin. Please await further notification.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFB45309),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (claim.status == 'approved') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5), // Hijau muda
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFA7F3D0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.check_circle_outline,
                    color: Color(0xFF059669), size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Claim Approved by Admin!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF065F46),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Please show the following claim code to the finder/reporter to retrieve your item:',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF047857),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: const Color(0xFF34D399), width: 1.5),
                ),
                child: Text(
                  claim.claimCode ?? 'NO CODE',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Color(0xFF065F46),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (claim.status == 'rejected') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2), // Merah muda
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFCA5A5)),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel_outlined, color: Color(0xFFDC2626), size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Claim Rejected',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF991B1B),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Sorry, the proof of ownership you submitted is incorrect or insufficient.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFB91C1C),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (claim.status == 'received') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4), // Hijau sangat muda
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFBBF7D0)),
        ),
        child: const Row(
          children: [
            Icon(Icons.celebration, color: Color(0xFF16A34A), size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Item Successfully Collected!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF15803D),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Thank you for using the Campus Lost & Found service.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF166534),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  /// Membuka modal dialog pengajuan klaim barang.
  Future<void> _openClaimDialog(String token) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ClaimReportDialog(
        reportId: widget.reportId,
        token: token,
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Claim request successfully submitted to Admin.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      // Muat ulang detail laporan untuk memperbarui state UI
      _loadDetail();
    }
  }

  /// Melakukan konfirmasi serah terima fisik secara mandiri oleh pemilik barang (Opsi 2).
  Future<void> _confirmPhysicalCollection(String token) async {
    final claimId = _report?.activeClaim?.id;
    if (claimId == null) return;

    // Tampilkan dialog konfirmasi terlebih dahulu agar aman dari salah pencet
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Item Receipt'),
        content: const Text(
          'Are you sure you have physically received the item from the security guard (Satpam)? This will permanently resolve the report.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tertiary,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Yes, Received'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isResolving = true);

    final result = await _reportService.confirmCollection(
      claimId: claimId,
      token: token,
    );

    if (mounted) {
      setState(() => _isResolving = false);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ??
                'Confirmation successful, report status resolved!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        // Muat ulang data terbaru agar UI sinkron
        _loadDetail();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ??
                'Failed to confirm handover.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  void _showResolveDialog() {
    final report = _report!;
    final isLost = report.type == 'lost';

    showDialog(
      context: context,
      barrierDismissible:
          false, // Mencegah penutupan dialog secara tidak sengaja dengan mengetuk bagian luar saat sedang memproses API
      builder: (ctx) {
        bool dialogResolving = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text('Mark Report as Resolved?'),
              content: Text(
                isLost
                    ? 'Confirm that your item has been found.'
                    : 'Confirm that the item has been returned to its owner.',
              ),
              actions: [
                TextButton(
                  onPressed: dialogResolving ? null : () => Navigator.pop(ctx),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
                ElevatedButton(
                  onPressed: dialogResolving
                      ? null
                      : () async {
                          // Ubah state dialog menjadi sedang memproses untuk menonaktifkan tombol dan menampilkan spinner loading
                          setState(() {
                            dialogResolving = true;
                          });

                          // Panggil proses utama penyelesaian laporan dengan mengirimkan context dialog agar bisa ditutup secara aman
                          await _resolveReport(ctx);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tertiary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: dialogResolving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : const Text('Yes, Resolve'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _resolveReport(BuildContext dialogCtx) async {
    // Pengaman awal untuk mencegah pemanggilan ganda jika proses resolve sedang berlangsung
    if (_isResolving) return;

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
        // Tutup dialog secara aman terlebih dahulu sebelum berpindah halaman
        if (dialogCtx.mounted) {
          Navigator.pop(dialogCtx);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                result['message'] ?? 'Report has been marked as resolved!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        // Kembali ke halaman sebelumnya setelah berhasil menyelesaikan laporan
        Navigator.pop(context);
      } else {
        // Tutup dialog secara aman jika terjadi kegagalan transaksi
        if (dialogCtx.mounted) {
          Navigator.pop(dialogCtx);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to resolve report'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Widget _buildRejectionReasonCard(ReportModel report) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFCA5A5).withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
              Icon(Icons.gavel_outlined, size: 18, color: Color(0xFFDC2626)),
              SizedBox(width: 8),
              Text(
                'Rejection Reason',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF991B1B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            report.rejectionReason!,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7F1D1D),
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminNotesCard(ReportModel report) {
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
              Icon(
                Icons.speaker_notes_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              SizedBox(width: 8),
              Text(
                'Admin Notes',
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
            report.adminNotes!,
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
      return '${months[date.month]} ${date.day}, ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatDateTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
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
    } catch (_) {
      return dateStr;
    }
  }

  /// Menampilkan dialog layar penuh dengan fitur pinch-to-zoom (InteractiveViewer)
  void _showFullscreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // InteractiveViewer memungkinkan zoom (cubit layar) dan geser foto
              InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              // Tombol X (tutup) di pojok kanan atas
              Positioned(
                top: 40,
                right: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close,
                        color: AppColors.white, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
        return {
          'bg': const Color(0xFFFEF3C7),
          'text': const Color(0xFF92400E),
          'label': 'Pending',
        };
      case 'verified':
        return {
          'bg': const Color(0xFFDBEAFE),
          'text': const Color(0xFF1E40AF),
          'label': 'Verified',
        };
      case 'collection_pending':
        return {
          'bg': const Color(0xFFFEF3C7),
          'text': const Color(0xFFD97706),
          'label': 'Collection Pending',
        };
      case 'resolved':
        return {
          'bg': const Color(0xFFD1FAE5),
          'text': const Color(0xFF065F46),
          'label': 'Resolved',
        };
      case 'rejected':
        return {
          'bg': const Color(0xFFFEE2E2),
          'text': const Color(0xFF991B1B),
          'label': 'Rejected',
        };
      default:
        return {
          'bg': AppColors.neutral,
          'text': AppColors.textMuted,
          'label': status,
        };
    }
  }
}
