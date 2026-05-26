class AppConfig {
  final MaintenanceConfig? maintenance;
  final UpdateConfig? update;

  const AppConfig({
    required this.maintenance,
    required this.update,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      maintenance: json['maintenance'] is Map<String, dynamic>
          ? MaintenanceConfig.fromJson(json['maintenance'])
          : null,
      update: json['update'] is Map<String, dynamic>
          ? UpdateConfig.fromJson(json['update'])
          : null,
    );
  }
}

class MaintenanceConfig {
  final bool isActive;
  final String title;
  final String message;
  final String? imageUrl;
  final DateTime? estimatedEnd;

  const MaintenanceConfig({
    required this.isActive,
    required this.title,
    required this.message,
    required this.imageUrl,
    required this.estimatedEnd,
  });

  factory MaintenanceConfig.fromJson(Map<String, dynamic> json) {
    return MaintenanceConfig(
      isActive: json['is_active'] == true,
      title: _readString(json['title'], fallback: 'Under Maintenance'),
      message: _readString(
        json['message'],
        fallback: 'We are improving Turf11 Partner. Please try again soon.',
      ),
      imageUrl: _nullableString(json['image_url']),
      estimatedEnd: DateTime.tryParse(_readString(json['estimated_end'])),
    );
  }
}

class UpdateConfig {
  final bool isAvailable;
  final bool isForce;
  final String latestVersion;
  final String minVersion;
  final String title;
  final String message;
  final String? imageUrl;
  final String? playstoreUrl;
  final String? appstoreUrl;
  final String? downloadUrl;
  final String updateMode;
  final List<String> whatsNew;

  const UpdateConfig({
    required this.isAvailable,
    required this.isForce,
    required this.latestVersion,
    required this.minVersion,
    required this.title,
    required this.message,
    required this.imageUrl,
    required this.playstoreUrl,
    required this.appstoreUrl,
    required this.downloadUrl,
    required this.updateMode,
    required this.whatsNew,
  });

  factory UpdateConfig.fromJson(Map<String, dynamic> json) {
    return UpdateConfig(
      isAvailable: json['is_available'] == true,
      isForce: json['is_force'] == true,
      latestVersion: _readString(json['latest_version']),
      minVersion: _readString(json['min_version']),
      title: _readString(json['title'], fallback: 'Update Available'),
      message: _readString(
        json['message'],
        fallback: 'A newer Turf11 Partner version is available.',
      ),
      imageUrl: _nullableString(json['image_url']),
      playstoreUrl: _nullableString(json['playstore_url']),
      appstoreUrl: _nullableString(json['appstore_url']),
      downloadUrl: _nullableString(json['download_url']),
      updateMode: _readString(json['update_mode'], fallback: 'playstore'),
      whatsNew: json['whats_new'] is List
          ? List<String>.from(
              (json['whats_new'] as List).map((item) => item.toString()),
            )
          : const [],
    );
  }
}

String _readString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final text = value.toString().trim();
  return text.isEmpty ? fallback : text;
}

String? _nullableString(dynamic value) {
  final text = _readString(value);
  return text.isEmpty ? null : text;
}
