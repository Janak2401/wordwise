import 'package:flutter_test/flutter_test.dart';
import 'package:wordwise/core/constants/game_constants.dart';
import 'package:wordwise/data/models/guess_result.dart';

void main() {
  group('GameConstants tests', () {
    test('dynamic guess limits scale correctly', () {
      expect(GameConstants.getMaxGuesses(5), 6);
      expect(GameConstants.getMaxGuesses(6), 7);
      expect(GameConstants.getMaxGuesses(7), 8);
    });
  });

  group('Letter Evaluation logic', () {
    test('Exact match returns correct', () {
      const target = 'BRAVE';
      const guess = 'BRAVE';
      
      final evals = <LetterEvaluation>[];
      for (int i = 0; i < 5; i++) {
        if (guess[i] == target[i]) {
          evals.add(LetterEvaluation.correct);
        }
      }
      expect(evals.every((e) => e == LetterEvaluation.correct), true);
    });
  });
}
