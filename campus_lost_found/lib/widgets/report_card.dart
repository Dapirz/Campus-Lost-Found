import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/report_model.dart';

/// Widget kartu laporan untuk ditampilkan di list Home Screen.
class ReportCard extends StatelessWidget {
  final ReportModel report;
  final VoidCallback onTap;

  const ReportCard({
    super.key,
    required this.report,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Kiri — Foto thumbnail
                _buildThumbnail(),
                const SizedBox(width: 12),
                // Kanan — Info
                Expanded(child: _buildInfo()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 80,
        height: 80,
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
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.neutral,
                    child: const Icon(
                      Icons.broken_image_outlined,
                      color: AppColors.textMuted,
                      size: 28,
                    ),
                  );
                },
              )
            : Container(
                color: AppColors.neutral,
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.textMuted,
                  size: 28,
                ),
              ),
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Baris 1: Title + TypeBadge
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
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _TypeBadge(type: report.type),
          ],
        ),
        const SizedBox(height: 6),

        // Baris 2: Lokasi
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 14,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                report.locationText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Baris 3: Tanggal
        Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 12,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              report.incidentDate,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Baris 4: Reporter
        Row(
          children: [
            const Icon(
              Icons.person_outline,
              size: 12,
              color: AppColors.primary,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'Reported by ${report.reporter.name}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Badge tipe laporan: LOST (merah) atau FOUND (hijau).
class _TypeBadge extends StatelessWidget {
  final String type;

  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final isLost = type.toLowerCase() == 'lost';

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
