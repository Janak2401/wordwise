import 'package:share_plus/share_plus.dart';
import '../../data/models/guess_result.dart';

class ShareUtils {
  static String generateEmojiGrid({
    required String targetWord,
    required List<List<GuessLetter>> guessRows,
    required int maxGuesses,
    required int streak,
  }) {
    final buffer = StringBuffer();
    final isWon = guessRows.isNotEmpty &&
        guessRows.last.every((l) => l.evaluation == LetterEvaluation.correct);

    final scoreStr = isWon ? '${guessRows.length}/$maxGuesses' : 'X/$maxGuesses';
    buffer.writeln('WordWise $scoreStr 🔥 $streak');
    buffer.writeln();

    for (final row in guessRows) {
      for (final letter in row) {
        switch (letter.evaluation) {
          case LetterEvaluation.correct:
            buffer.write('🟩');
            break;
          case LetterEvaluation.wrongPosition:
            buffer.write('🟨');
            break;
          case LetterEvaluation.absent:
            buffer.write('⬛');
            break;
          default:
            buffer.write('⬜');
        }
      }
      buffer.writeln();
    }

    return buffer.toString().trim();
  }

  static Future<void> shareResult(String text) async {
    // ignore: deprecated_member_use
    await Share.share(text);
  }
}
