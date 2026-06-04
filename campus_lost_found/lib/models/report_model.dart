import '../config/api_config.dart';

/// Memperbaiki host URL gambar secara dinamis agar sesuai dengan koneksi aktif.
/// Seluruh komentar dalam berkas ini ditulis dalam Bahasa Indonesia.
String _fixImageUrl(String? url) {
  if (url == null || url.isEmpty) return '';
  try {
    // Dapatkan authority aktif dari ApiConfig.baseUrl
    final baseUri = Uri.parse(ApiConfig.baseUrl);
    final activeAuthority = '${baseUri.scheme}://${baseUri.host}:${baseUri.port}';
    
    // Parsing URL gambar yang dikirim oleh backend
    final imageUri = Uri.parse(url);
    
    // Satukan kembali menggunakan authority aktif agar selalu sinkron
    return '$activeAuthority${imageUri.path}';
  } catch (_) {
    return url;
  }
}

/// Model gambar laporan (dari detail endpoint).
class ReportImageModel {
  final int id;
  final String url;

  ReportImageModel({
    required this.id,
    required this.url,
  });

  factory ReportImageModel.fromJson(Map<String, dynamic> json) {
    return ReportImageModel(
      id: json['id'] ?? 0,
      url: _fixImageUrl(json['url']),
    );
  }
}

/// Model reporter (pelapor).
class ReporterModel {
  final int id;
  final String name;

  ReporterModel({
    required this.id,
    required this.name,
  });

  factory ReporterModel.fromJson(Map<String, dynamic> json) {
    return ReporterModel(
      id: json['id'],
      name: json['name'] ?? 'Unknown',
    );
  }
}

/// Model klaim aktif untuk laporan (dari detail endpoint).
class ReportActiveClaimModel {
  final int id;
  final String status;
  final String? claimCode;

  ReportActiveClaimModel({
    required this.id,
    required this.status,
    this.claimCode,
  });

  factory ReportActiveClaimModel.fromJson(Map<String, dynamic> json) {
    return ReportActiveClaimModel(
      id: json['id'] ?? 0,
      status: json['status'] ?? 'pending',
      claimCode: json['claim_code'],
    );
  }
}

/// Model laporan.
class ReportModel {
  final int id;
  final String type; // 'lost' atau 'found'
  final String title;
  final String? description; // nullable: tidak ada di list endpoint
  final String locationText;
  final String status;
  final String incidentDate;
  final String createdAt;
  final String? imageUrl; // URL foto pertama (dari list endpoint)
  final List<ReportImageModel> images; // Semua foto (dari detail endpoint)
  final ReporterModel reporter;
  final String? rejectionReason;
  final String? adminNotes;
  final ReportActiveClaimModel? activeClaim; // Klaim aktif dari pengguna yang sedang login

  ReportModel({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    required this.locationText,
    required this.status,
    required this.incidentDate,
    required this.createdAt,
    this.imageUrl,
    this.images = const [],
    required this.reporter,
    this.rejectionReason,
    this.adminNotes,
    this.activeClaim,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    // Parse array gambar (dari detail endpoint)
    List<ReportImageModel> imagesList = [];
    if (json['images'] != null && json['images'] is List) {
      imagesList = (json['images'] as List)
          .map((img) => ReportImageModel.fromJson(img))
          .toList();
    }

    return ReportModel(
      id: json['id'],
      type: json['type'] ?? 'lost',
      title: json['title'] ?? '',
      description: json['description'],
      locationText: json['location_text'] ?? '',
      status: json['status'] ?? 'pending',
      incidentDate: json['incident_date'] ?? '',
      createdAt: json['created_at'] ?? '',
      imageUrl: _fixImageUrl(json['image_url']),
      images: imagesList,
      reporter: json['reporter'] != null
          ? ReporterModel.fromJson(json['reporter'])
          : ReporterModel(id: 0, name: 'Unknown'),
      rejectionReason: json['rejection_reason'],
      adminNotes: json['admin_notes'],
      activeClaim: json['active_claim'] != null
          ? ReportActiveClaimModel.fromJson(json['active_claim'])
          : null,
    );
  }
}
