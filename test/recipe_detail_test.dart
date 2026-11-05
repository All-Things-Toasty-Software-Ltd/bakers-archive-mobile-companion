import 'package:bakers_archive/data/models/recipe_detail.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a serialized recipe response into a detail model', () {
    final recipe = RecipeDetail.fromOdooApiResponse(
      {
        'data': {
          'id': 42,
          'display_name': 'Everyday Sourdough',
          'fields': [
            {'name': 'subtitle', 'value': 'A reliable weekly loaf'},
            {
              'name': 'ingredient_ids',
              'value': [
                {
                  'id': 1,
                  'fields': [
                    {'name': 'name', 'value': 'Strong white flour'},
                    {'name': 'quantity', 'value': 500},
                    {'name': 'unit', 'value': 'g'},
                    {'name': 'notes', 'value': '100% in Baker\'s math.'},
                  ],
                },
              ],
            },
            {
              'name': 'instruction_ids',
              'value': [
                {
                  'id': 1,
                  'fields': [
                    {'name': 'name', 'value': 'Mix the dough.'},
                    {'name': 'sequence', 'value': 2},
                    {'name': 'time', 'value': 10},
                  ],
                },
                {
                  'id': 2,
                  'fields': [
                    {'name': 'name', 'value': 'Bake.'},
                    {'name': 'sequence', 'value': 1},
                    {'name': 'time', 'value': 45},
                  ],
                },
              ],
            },
          ],
        },
      },
      baseUrl: 'https://example.test',
    );

    expect(recipe.name, 'Everyday Sourdough');
    expect(recipe.subtitle, 'A reliable weekly loaf');
    expect(recipe.ingredients.single.name, 'Strong white flour');
    expect(recipe.ingredients.single.bakersPercentage, 100);
    expect(recipe.instructions.first.text, 'Bake.');
    expect(recipe.instructions.last.text, 'Mix the dough.');
    expect(
      recipe.mainImageUrl,
      'https://example.test/web/image/bakers_archive.recipe/42/main_image',
    );
  });
}
