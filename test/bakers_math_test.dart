import 'package:bakers_archive/core/utils/bakers_math.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BakersMath.extractPercentage', () {
    test('reads a plain percentage', () {
      expect(BakersMath.extractPercentage('100%'), 100);
    });

    test('reads a percentage followed by baker wording', () {
      expect(
        BakersMath.extractPercentage('80% in Baker\'s math.'),
        80,
      );
    });

    test('returns null when there is no percentage', () {
      expect(BakersMath.extractPercentage('Strong white flour'), isNull);
    });
  });

  group('BakersMath.formatQuantity', () {
    test('drops a trailing decimal for whole numbers', () {
      expect(BakersMath.formatQuantity(400), '400');
    });

    test('keeps a single decimal place', () {
      expect(BakersMath.formatQuantity(1.5), '1.5');
    });
  });

  group('BakersMath.formatDurationMinutes', () {
    test('formats minutes', () {
      expect(BakersMath.formatDurationMinutes(45), '45 min');
    });

    test('formats hours and minutes', () {
      expect(BakersMath.formatDurationMinutes(90), '1 hr 30 min');
    });

    test('formats whole hours', () {
      expect(BakersMath.formatDurationMinutes(120), '2 hrs');
    });
  });
}
