import 'package:flutter_test/flutter_test.dart';
import 'package:Huddle/subpages/readbook.dart';

void main() {
  group('favorite limit handling', () {
    test('blocks adding a new favorite once the limit is reached', () {
      expect(
        canToggleFavorite(
          isAlreadyFavorite: false,
          favoritesCount: 5,
          limit: 5,
        ),
        isFalse,
      );
    });

    test('still allows removing an existing favorite at the limit', () {
      expect(
        canToggleFavorite(isAlreadyFavorite: true, favoritesCount: 5, limit: 5),
        isTrue,
      );
    });
  });
}
