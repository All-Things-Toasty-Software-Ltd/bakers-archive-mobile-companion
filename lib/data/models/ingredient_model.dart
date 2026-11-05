import '../../core/utils/bakers_math.dart';

/// Representation of a single recipe ingredient.
class IngredientModel {
  final int id;
  final String name;
  final double quantity;
  final String unit;
  final String notes;
  final double? bakersPercentage;

  const IngredientModel({
    required this.id,
    required this.name,
    this.quantity = 0.0,
    this.unit = '',
    this.notes = '',
    this.bakersPercentage,
  });

  factory IngredientModel.fromFieldMap(Map<String, dynamic> map) {
    int id = 0;
    String name = '';
    double qty = 0.0;
    String unit = '';
    String notes = '';

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
        } else if (fName == 'name') {
          if (fValue is Map<String, dynamic>) {
            name = fValue['display_name'] as String? ?? '';
          } else if (fValue is String) {
            name = fValue;
          }
        } else if (fName == 'quantity') {
          if (fValue is num) {
            qty = fValue.toDouble();
          }
        } else if (fName == 'unit' && fValue is String) {
          unit = fValue;
        } else if (fName == 'notes' && fValue is String) {
          notes = fValue;
        }
      }
    } else {
      id = map['id'] as int? ?? 0;
      name = map['name'] as String? ?? '';
      qty = (map['quantity'] as num?)?.toDouble() ?? 0.0;
      unit = map['unit'] as String? ?? '';
      notes = map['notes'] as String? ?? '';
    }

    final pct = BakersMath.extractPercentage(notes);

    return IngredientModel(
      id: id,
      name: name.isEmpty ? (map['display_name'] as String? ?? 'Ingredient') : name,
      quantity: qty,
      unit: unit,
      notes: notes,
      bakersPercentage: pct,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'notes': notes,
      'bakers_percentage': bakersPercentage,
    };
  }

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      bakersPercentage: (json['bakers_percentage'] as num?)?.toDouble(),
    );
  }

  /// Get formatted display string scaled by [multiplier]
  String displayQuantityScaled(double multiplier) {
    if (quantity <= 0) return '';
    final scaled = BakersMath.scaleQuantity(quantity, multiplier);
    return '${BakersMath.formatQuantity(scaled)} $unit'.trim();
  }
}
