import 'package:flutter/material.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/guess_result.dart';
import 'keyboard_key.dart';

class GameKeyboard extends StatelessWidget {
  final Function(String) onLetterPressed;
  final VoidCallback onEnterPressed;
  final VoidCallback onBackspacePressed;
  final Map<String, LetterEvaluation> keyEvaluations;

  const GameKeyboard({
    super.key,
    required this.onLetterPressed,
    required this.onEnterPressed,
    required this.onBackspacePressed,
    required this.keyEvaluations,
  });

  static const List<String> _row1 = ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'];
  static const List<String> _row2 = ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'];
  static const List<String> _row3 = ['Z', 'X', 'C', 'V', 'B', 'N', 'M'];

  /// Key height for the current screen: shorter keys on short screens leave room for the grid.
  static double keyHeightFor(double screenHeight) {
    return (screenHeight * AppDimensions.keyHeightScreenRatio)
        .clamp(AppDimensions.keyHeightMin, AppDimensions.keyHeightMax)
        .floorToDouble();
  }

  @override
  Widget build(BuildContext context) {
    final keyHeight = keyHeightFor(MediaQuery.sizeOf(context).height);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      child: Column(
        children: [
          Row(
            children: _row1.map((letter) {
              return KeyboardKey(
                height: keyHeight,
                label: letter,
                evaluation: keyEvaluations[letter] ?? LetterEvaluation.empty,
                onTap: () => onLetterPressed(letter),
              );
            }).toList(),
          ),
          Row(
            children: [
              const Spacer(flex: 5),
              ..._row2.map((letter) {
                return KeyboardKey(
                  height: keyHeight,
                  label: letter,
                  evaluation: keyEvaluations[letter] ?? LetterEvaluation.empty,
                  onTap: () => onLetterPressed(letter),
                );
              }),
              const Spacer(flex: 5),
            ],
          ),
          Row(
            children: [
              KeyboardKey(
                height: keyHeight,
                label: 'ENTER',
                flex: 1.5,
                onTap: onEnterPressed,
                customChild: const Text(
                  'ENTER',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ..._row3.map((letter) {
                return KeyboardKey(
                  height: keyHeight,
                  label: letter,
                  evaluation: keyEvaluations[letter] ?? LetterEvaluation.empty,
                  onTap: () => onLetterPressed(letter),
                );
              }),
              KeyboardKey(
                height: keyHeight,
                label: 'BACKSPACE',
                flex: 1.5,
                onTap: onBackspacePressed,
                customChild: const Icon(
                  Icons.backspace_outlined,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
