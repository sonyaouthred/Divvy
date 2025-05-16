import 'package:divvy/screens/edit_or_add_chore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unicode_emojis/unicode_emojis.dart';

void main() {
  group('Test that all emojis are recognized', () {
    test('All emojis [single string] detected', () {
      final emojis = UnicodeEmojis.allEmojis;
      for (Emoji emoji in emojis) {
        assert(isEmoji(emoji.toString()), true);
      }
    });

    test('Two emojis are rejected', () {
      final text = '😄😆';
      assert(isEmoji(text), false);
    });

    test('Emoji + string rejected', () {
      final text = '😄 hi!!';
      assert(isEmoji(text), false);
    });
  });
}
