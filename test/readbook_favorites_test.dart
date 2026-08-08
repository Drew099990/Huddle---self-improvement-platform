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

  group('comment storage helpers', () {
    test('adds a trimmed comment to the top of the list', () {
      final comments = addCommentToList(['old'], '  new comment  ');

      expect(comments, ['new comment', 'old']);
    });

    test('ignores empty comment text', () {
      final comments = addCommentToList(['old'], '   ');

      expect(comments, ['old']);
    });
  });
}
