import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      child: Column(
        children: [
          Row(
            children: _row1.map((letter) {
              return KeyboardKey(
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
                label: 'ENTER',
                flex: 1.5,
                onTap: onEnterPressed,
                customChild: const Text(
                  'ENTER',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              ..._row3.map((letter) {
                return KeyboardKey(
                  label: letter,
                  evaluation: keyEvaluations[letter] ?? LetterEvaluation.empty,
                  onTap: () => onLetterPressed(letter),
                );
              }),
              KeyboardKey(
                label: 'BACKSPACE',
                flex: 1.5,
                onTap: onBackspacePressed,
                customChild: const Icon(
                  Icons.backspace_outlined,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
