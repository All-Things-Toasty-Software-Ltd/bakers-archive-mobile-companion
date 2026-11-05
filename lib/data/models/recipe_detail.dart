import 'ingredient_model.dart';
import 'instruction_model.dart';

/// Full recipe representation with complete ingredients, steps, and metadata.
class RecipeDetail {
  final int id;
  final String name;
  final String? subtitle;
  final String teaser;
  final String description;
  final String notes;
  final DateTime? publishedDate;
  final int visits;

  final int? archiveId;
  final String? archiveName;

  final int? authorId;
  final String? authorName;
  final String? authorAvatarUrl;

  final int? originalAuthorId;
  final String? originalAuthorName;
  final String? originalAuthorAvatarUrl;

  final String? sourceName;
  final String? licenseName;
  final String? countryName;

  final List<IngredientModel> ingredients;
  final List<InstructionModel> instructions;
  final List<String> tags;

  final String? mainImageUrl;
  final String? webUrl;
  final Map<String, dynamic>? rawJson;

  const RecipeDetail({
    required this.id,
    required this.name,
    this.subtitle,
    this.teaser = '',
    this.description = '',
    this.notes = '',
    this.publishedDate,
    this.visits = 0,
    this.archiveId,
    this.archiveName,
    this.authorId,
    this.authorName,
    this.authorAvatarUrl,
    this.originalAuthorId,
    this.originalAuthorName,
    this.originalAuthorAvatarUrl,
    this.sourceName,
    this.licenseName,
    this.countryName,
    this.ingredients = const [],
    this.instructions = const [],
    this.tags = const [],
    this.mainImageUrl,
    this.webUrl,
    this.rawJson,
  });

  /// Parse from Odoo `/archive/api/v1/recipe/<id>` serialized output
  factory RecipeDetail.fromOdooApiResponse(Map<String, dynamic> root, {String? baseUrl}) {
    final data = root['data'] as Map<String, dynamic>? ?? root;
    final int recipeId = data['id'] as int? ?? 0;

    String name = data['display_name'] as String? ?? 'Untitled Recipe';
    String? subtitle;
    String teaser = '';
    String description = '';
    String notes = '';
    DateTime? publishedDate;
    int visits = 0;

    int? archiveId;
    String? archiveName;

    int? authorId;
    String? authorName;

    int? originalAuthorId;
    String? originalAuthorName;

    String? sourceName;
    String? licenseName;
    String? countryName;

    final List<IngredientModel> ingredientsList = [];
    final List<InstructionModel> instructionsList = [];
    final List<String> tagsList = [];

    final fields = data['fields'];
    if (fields is List) {
      for (final f in fields) {
        if (f is! Map<String, dynamic>) continue;
        final fName = f['name'] as String?;
        final fVal = f['value'];

        switch (fName) {
          case 'name':
            if (fVal is String && fVal.isNotEmpty) name = fVal;
            break;
          case 'subtitle':
            if (fVal is String) subtitle = fVal;
            break;
          case 'teaser':
            if (fVal is String) teaser = fVal;
            break;
          case 'description':
            if (fVal is String) description = _stripHtml(fVal);
            break;
          case 'notes':
            if (fVal is String) notes = _stripHtml(fVal);
            break;
          case 'published_date':
            if (fVal is String && fVal.isNotEmpty) {
              publishedDate = DateTime.tryParse(fVal);
            }
            break;
          case 'visits':
            if (fVal is num) visits = fVal.toInt();
            break;
          case 'archive_id':
            if (fVal is Map<String, dynamic>) {
              archiveId = fVal['id'] as int?;
              archiveName = fVal['display_name'] as String?;
            }
            break;
          case 'author_id':
            if (fVal is Map<String, dynamic>) {
              authorId = fVal['id'] as int?;
              authorName = fVal['display_name'] as String?;
            }
            break;
          case 'original_author_id':
            if (fVal is Map<String, dynamic>) {
              originalAuthorId = fVal['id'] as int?;
              originalAuthorName = fVal['display_name'] as String?;
            }
            break;
          case 'source_id':
            if (fVal is Map<String, dynamic>) {
              sourceName = fVal['display_name'] as String?;
            }
            break;
          case 'license':
            if (fVal is Map<String, dynamic>) {
              licenseName = fVal['display_name'] as String?;
            }
            break;
          case 'country_id':
            if (fVal is Map<String, dynamic>) {
              countryName = fVal['display_name'] as String?;
            }
            break;
          case 'ingredient_ids':
            if (fVal is List) {
              for (final ing in fVal) {
                if (ing is Map<String, dynamic>) {
                  ingredientsList.add(IngredientModel.fromFieldMap(ing));
                }
              }
            }
            break;
          case 'instruction_ids':
            if (fVal is List) {
              for (final inst in fVal) {
                if (inst is Map<String, dynamic>) {
                  instructionsList.add(InstructionModel.fromFieldMap(inst));
                }
              }
            }
            break;
          case 'tag_ids':
            if (fVal is List) {
              for (final tag in fVal) {
                if (tag is Map<String, dynamic>) {
                  final tName = tag['display_name'] as String?;
                  if (tName != null && tName.isNotEmpty) tagsList.add(tName);
                }
              }
            }
            break;
        }
      }
    }

    // Sort instructions by sequence
    instructionsList.sort((a, b) => a.sequence.compareTo(b.sequence));

    final String server = baseUrl?.replaceAll(RegExp(r'/+$'), '') ?? '';
    final String mainImage = server.isNotEmpty
        ? '$server/web/image/bakers_archive.recipe/$recipeId/main_image'
        : '';
    final String authorAvatar = (server.isNotEmpty && authorId != null)
        ? '$server/web/image/res.partner/$authorId/image_128'
        : '';
    final String origAuthorAvatar = (server.isNotEmpty && originalAuthorId != null)
        ? '$server/web/image/res.partner/$originalAuthorId/image_128'
        : '';

    return RecipeDetail(
      id: recipeId,
      name: name,
      subtitle: subtitle,
      teaser: teaser,
      description: description,
      notes: notes,
      publishedDate: publishedDate,
      visits: visits,
      archiveId: archiveId,
      archiveName: archiveName,
      authorId: authorId,
      authorName: authorName,
      authorAvatarUrl: authorAvatar.isNotEmpty ? authorAvatar : null,
      originalAuthorId: originalAuthorId,
      originalAuthorName: originalAuthorName,
      originalAuthorAvatarUrl: origAuthorAvatar.isNotEmpty ? origAuthorAvatar : null,
      sourceName: sourceName,
      licenseName: licenseName,
      countryName: countryName,
      ingredients: ingredientsList,
      instructions: instructionsList,
      tags: tagsList,
      mainImageUrl: mainImage.isNotEmpty ? mainImage : null,
      webUrl: server.isNotEmpty ? '$server/archive/recipe/$recipeId' : null,
      rawJson: root,
    );
  }

  /// Serialize locally for offline storage caching
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subtitle': subtitle,
      'teaser': teaser,
      'description': description,
      'notes': notes,
      'published_date': publishedDate?.toIso8601String(),
      'visits': visits,
      'archive_id': archiveId,
      'archive_name': archiveName,
      'author_id': authorId,
      'author_name': authorName,
      'author_avatar_url': authorAvatarUrl,
      'original_author_id': originalAuthorId,
      'original_author_name': originalAuthorName,
      'original_author_avatar_url': originalAuthorAvatarUrl,
      'source_name': sourceName,
      'license_name': licenseName,
      'country_name': countryName,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'instructions': instructions.map((e) => e.toJson()).toList(),
      'tags': tags,
      'main_image_url': mainImageUrl,
      'web_url': webUrl,
      'raw_json': rawJson,
    };
  }

  factory RecipeDetail.fromJson(Map<String, dynamic> json) {
    return RecipeDetail(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Untitled Recipe',
      subtitle: json['subtitle'] as String?,
      teaser: json['teaser'] as String? ?? '',
      description: json['description'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      publishedDate: json['published_date'] != null
          ? DateTime.tryParse(json['published_date'] as String)
          : null,
      visits: json['visits'] as int? ?? 0,
      archiveId: json['archive_id'] as int?,
      archiveName: json['archive_name'] as String?,
      authorId: json['author_id'] as int?,
      authorName: json['author_name'] as String?,
      authorAvatarUrl: json['author_avatar_url'] as String?,
      originalAuthorId: json['original_author_id'] as int?,
      originalAuthorName: json['original_author_name'] as String?,
      originalAuthorAvatarUrl: json['original_author_avatar_url'] as String?,
      sourceName: json['source_name'] as String?,
      licenseName: json['license_name'] as String?,
      countryName: json['country_name'] as String?,
      ingredients: (json['ingredients'] as List? ?? [])
          .map((e) => IngredientModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      instructions: (json['instructions'] as List? ?? [])
          .map((e) => InstructionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      tags: (json['tags'] as List? ?? []).map((e) => e.toString()).toList(),
      mainImageUrl: json['main_image_url'] as String?,
      webUrl: json['web_url'] as String?,
      rawJson: json['raw_json'] as Map<String, dynamic>?,
    );
  }

  /// Categorize instructions by their category header
  Map<String, List<InstructionModel>> get categorizedInstructions {
    final Map<String, List<InstructionModel>> map = {};
    for (final inst in instructions) {
      final cat = inst.categoryName.isEmpty ? 'Instructions' : inst.categoryName;
      map.putIfAbsent(cat, () => []).add(inst);
    }
    return map;
  }

  /// Strip HTML tags and entities for clean text rendering
  static String _stripHtml(String html) {
    var text = html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
    return text.trim();
  }
}
