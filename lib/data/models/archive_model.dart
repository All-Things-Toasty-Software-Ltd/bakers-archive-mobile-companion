/// Archive model representing a baker's archive collection (e.g., Sourdough Archives).
class ArchiveModel {
  final int id;
  final String name;
  final String? subtitle;
  final String? url;
  final String? feedUrl;
  final String? apiUrl;

  const ArchiveModel({
    required this.id,
    required this.name,
    this.subtitle,
    this.url,
    this.feedUrl,
    this.apiUrl,
  });

  factory ArchiveModel.fromJson(Map<String, dynamic> json) {
    return ArchiveModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Untitled Archive',
      subtitle: (json['subtitle'] is String) ? json['subtitle'] as String : null,
      url: json['url'] as String?,
      feedUrl: json['feed_url'] as String?,
      apiUrl: json['api_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subtitle': subtitle,
      'url': url,
      'feed_url': feedUrl,
      'api_url': apiUrl,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArchiveModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
