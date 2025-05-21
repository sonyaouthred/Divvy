import 'package:all_emojis/all_emojis.dart';
import 'package:divvy/screens/edit_or_add_chore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Test that all emojis are recognized', () {
    test('All emojis [single string] detected', () {
      final emojis = allEmojis.keys.toList();
      for (String emoji in emojis) {
        assert(isEmoji(emoji));
      }
    });

    test('odd', () {
      assert(isEmoji('🥳'));
    });

    test('Two emojis are rejected', () {
      final text = '😄😆';
      assert(!isEmoji(text));
    });

    test('Emoji + string rejected', () {
      final text = '😄 hi!!';
      assert(!isEmoji(text));
    });
  });
}
