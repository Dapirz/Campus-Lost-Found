/// Model gambar laporan (dari detail endpoint).
class ReportImageModel {
  final int id;
  final String url;

  ReportImageModel({
    required this.id,
    required this.url,
  });

  factory ReportImageModel.fromJson(Map<String, dynamic> json) {
    String imageUrl = json['url'] ?? '';
    // Fix URL: ganti 127.0.0.1 → 10.0.2.2 agar bisa diakses dari emulator
    if (imageUrl.contains('127.0.0.1')) {
      imageUrl = imageUrl.replaceAll('127.0.0.1', '10.0.2.2');
    }
    return ReportImageModel(id: json['id'] ?? 0, url: imageUrl);
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
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    // Fix image URL: ganti 127.0.0.1 → 10.0.2.2 agar bisa diakses dari emulator
    String? fixedImageUrl = json['image_url'];
    if (fixedImageUrl != null && fixedImageUrl.contains('127.0.0.1')) {
      fixedImageUrl = fixedImageUrl.replaceAll('127.0.0.1', '10.0.2.2');
    }

    // Parse images array (dari detail endpoint)
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
      imageUrl: fixedImageUrl,
      images: imagesList,
      reporter: json['reporter'] != null
          ? ReporterModel.fromJson(json['reporter'])
          : ReporterModel(id: 0, name: 'Unknown'),
      rejectionReason: json['rejection_reason'],
      adminNotes: json['admin_notes'],
    );
  }
}
