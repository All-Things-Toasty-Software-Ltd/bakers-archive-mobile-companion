/// Representation of a single baking recipe step instruction.
class InstructionModel {
  final int id;
  final String text;
  final int sequence;
  final double timeMinutes;
  final int? categoryId;
  final String categoryName;

  const InstructionModel({
    required this.id,
    required this.text,
    this.sequence = 0,
    this.timeMinutes = 0.0,
    this.categoryId,
    this.categoryName = 'Instructions',
  });

  factory InstructionModel.fromFieldMap(Map<String, dynamic> map) {
    int id = 0;
    String text = '';
    int seq = 0;
    double time = 0.0;
    int? catId;
    String catName = 'Instructions';

    if (map['id'] is int) {
      id = map['id'] as int;
    }

    final fields = map['fields'];
    if (fields is List) {
      for (final f in fields) {
        if (f is! Map<String, dynamic>) continue;
        final fName = f['name'] as String?;
        final fValue = f['value'];

        if (fName == 'id' && fValue is int) {
          id = fValue;
        } else if (fName == 'name' && fValue is String) {
          text = fValue;
        } else if (fName == 'sequence' && fValue is num) {
          seq = fValue.toInt();
        } else if (fName == 'time' && fValue is num) {
          time = fValue.toDouble();
        } else if (fName == 'category_id' && fValue is Map<String, dynamic>) {
          catId = fValue['id'] as int?;
          catName = fValue['display_name'] as String? ?? 'Instructions';
        }
      }
    } else {
      id = map['id'] as int? ?? 0;
      text = map['text'] as String? ?? map['name'] as String? ?? '';
      seq = (map['sequence'] as num?)?.toInt() ?? 0;
      time = (map['time_minutes'] as num?)?.toDouble() ?? 0.0;
      catId = map['category_id'] as int?;
      catName = map['category_name'] as String? ?? 'Instructions';
    }

    return InstructionModel(
      id: id,
      text: text.isEmpty ? (map['display_name'] as String? ?? '') : text,
      sequence: seq,
      timeMinutes: time,
      categoryId: catId,
      categoryName: catName.replaceAll(RegExp(r':\s*$'), ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'sequence': sequence,
      'time_minutes': timeMinutes,
      'category_id': categoryId,
      'category_name': categoryName,
    };
  }

  factory InstructionModel.fromJson(Map<String, dynamic> json) {
    return InstructionModel(
      id: json['id'] as int? ?? 0,
      text: json['text'] as String? ?? '',
      sequence: (json['sequence'] as num?)?.toInt() ?? 0,
      timeMinutes: (json['time_minutes'] as num?)?.toDouble() ?? 0.0,
      categoryId: json['category_id'] as int?,
      categoryName: json['category_name'] as String? ?? 'Instructions',
    );
  }
}
