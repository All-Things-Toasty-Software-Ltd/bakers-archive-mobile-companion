/// Lightweight recipe summary representation for list feeds and explore grids.
class RecipeSummary {
  final int id;
  final String name;
  final String teaser;
  final DateTime? publishedDate;
  final String? apiUrl;
  final int? archiveId;
  final String? archiveName;
  final String? coverImageUrl;

  const RecipeSummary({
    required this.id,
    required this.name,
    this.teaser = '',
    this.publishedDate,
    this.apiUrl,
    this.archiveId,
    this.archiveName,
    this.coverImageUrl,
  });

  factory RecipeSummary.fromJson(
    Map<String, dynamic> json, {
    String? baseUrl,
    int? archiveId,
    String? archiveName,
  }) {
    final int recipeId = json['id'] as int;

    DateTime? date;
    final dateStr = json['published_date'];
    if (dateStr is String && dateStr.isNotEmpty) {
      date = DateTime.tryParse(dateStr);
    }

    final String server = baseUrl?.replaceAll(RegExp(r'/+$'), '') ?? '';
    final String image = (server.isNotEmpty)
        ? '$server/web/image/bakers_archive.recipe/$recipeId/main_image'
        : '';

    return RecipeSummary(
      id: recipeId,
      name: json['name'] as String? ?? 'Untitled Recipe',
      teaser: json['teaser'] as String? ?? '',
      publishedDate: date,
      apiUrl: json['api_url'] as String?,
      archiveId: archiveId ?? json['archive_id'] as int?,
      archiveName: archiveName ?? json['archive_name'] as String?,
      coverImageUrl: json['cover_image_url'] as String? ?? image,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'teaser': teaser,
      'published_date': publishedDate?.toIso8601String(),
      'api_url': apiUrl,
      'archive_id': archiveId,
      'archive_name': archiveName,
      'cover_image_url': coverImageUrl,
    };
  }

  RecipeSummary copyWith({
    int? id,
    String? name,
    String? teaser,
    DateTime? publishedDate,
    String? apiUrl,
    int? archiveId,
    String? archiveName,
    String? coverImageUrl,
  }) {
    return RecipeSummary(
      id: id ?? this.id,
      name: name ?? this.name,
      teaser: teaser ?? this.teaser,
      publishedDate: publishedDate ?? this.publishedDate,
      apiUrl: apiUrl ?? this.apiUrl,
      archiveId: archiveId ?? this.archiveId,
      archiveName: archiveName ?? this.archiveName,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeSummary && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
